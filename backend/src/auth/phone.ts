/**
 * Xác thực số điện thoại kiểu tự nhắn (cách A) — máy chủ không gửi SMS nào:
 * 1. App xin phiên → máy chủ trả mã 6 số + số cổng (máy Android có SIM của mình).
 * 2. Người dùng nhắn đúng mã đó TỪ SIM của họ tới số cổng (app mở sẵn khung soạn tin).
 * 3. Máy cổng chuyển tin tới POST /sms-gateway/inbound (khóa x-gateway-key). Số gửi do nhà mạng ghi,
 *    không giả được → khớp (số gửi, mã) của phiên đang chờ thì VERIFIED.
 * Biết số của người khác là không đủ: phải cầm SIM đó mới gửi được tin mang số đó.
 */
import { createHash, randomInt, timingSafeEqual } from 'crypto';
import type { Request } from 'express';
import {
  BadRequestException, Body, ConflictException, Controller, Delete, ForbiddenException, Get, Headers, HttpCode, HttpException,
  Injectable, Logger, NotFoundException, Param, ParseUUIDPipe, Post, Req, UnauthorizedException, UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiHeader, ApiTags, ApiTooManyRequestsResponse } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';
import * as bcrypt from 'bcryptjs';
import { PhonePurpose, PhoneVerification } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuthUser, CurrentUser, Public } from '../common/auth';
import { AppThrottlerGuard } from '../common/throttle';
import { SystemConfigService } from '../system-config/system-config.module';
import { MailService } from './mail.service';
import { maskPhone, passwordResetByPhoneMail, phoneLinkedMail, phoneRemovedMail } from './mail-templates';
import { notifySecurity } from '../notifications/categories';

class StartLinkDto {
  @IsString() @MaxLength(20) phone: string;
  /** Mật khẩu hiện tại: gắn / đổi số là thao tác nhạy cảm */
  @IsString() password: string;
}

class StartResetDto {
  @IsString() @MaxLength(20) phone: string;
}

class ResetByPhoneDto {
  @IsString() verificationId: string;
  @IsString() @MinLength(6) @MaxLength(72) newPassword: string;
}

class RemovePhoneDto {
  @IsString() password: string;
}

/** Trường thường gặp của các app chuyển tiếp SMS (SMS Forwarder, SMS Gateway…): nhận linh hoạt. */
class InboundSmsDto {
  @IsOptional() @IsString() from?: string;
  @IsOptional() @IsString() sender?: string;
  @IsOptional() @IsString() phone?: string;
  @IsOptional() @IsString() phoneNumber?: string;
  @IsOptional() @IsString() text?: string;
  @IsOptional() @IsString() message?: string;
  @IsOptional() @IsString() body?: string;
  @IsOptional() @IsString() content?: string;
}

/** 0912345678 / +84912345678 / 84 912 345 678 → 0912345678; không phải số di động VN → null */
export function normalizePhone(raw: string): string | null {
  let d = raw.replace(/[\s.\-()]/g, '');
  if (d.startsWith('+84')) d = '0' + d.slice(3);
  else if (/^84\d{9}$/.test(d)) d = '0' + d.slice(2);
  return /^0(3|5|7|8|9)\d{8}$/.test(d) ? d : null;
}

/** minhanh.nguyen@gmail.com → minh•••@gmail.com */
export function maskEmail(email: string) {
  const [local, domain] = email.split('@');
  return `${local.slice(0, Math.min(4, Math.max(1, local.length - 1)))}•••@${domain}`;
}

const codeHash = (phone: string, code: string) => createHash('sha256').update(`${phone}:${code}`).digest('hex');
const PHONE_INVALID = 'Số điện thoại không hợp lệ (số di động Việt Nam, 10 chữ số)';
const SESSION_INVALID = 'Phiên xác thực không hợp lệ hoặc đã hết hạn';

@Injectable()
export class PhoneService {
  private readonly logger = new Logger('Phone');

  constructor(
    private readonly prisma: PrismaService,
    private readonly sys: SystemConfigService,
    private readonly mail: MailService,
  ) {}

  private async cfg() {
    const c = await this.sys.phoneOtp();
    if (!c.enabled) throw new ForbiddenException({ statusCode: 403, code: 'FEATURE_DISABLED', feature: 'phoneOtp', message: 'Xác thực số điện thoại đang tạm tắt' });
    return c;
  }

  /** Tối đa N phiên / 10 phút cho mỗi số và mỗi tài khoản. */
  private async assertRate(phone: string, userId: string | null, max: number) {
    const since = new Date(Date.now() - 10 * 60_000);
    const [byPhone, byUser] = await Promise.all([
      this.prisma.phoneVerification.count({ where: { phone, createdAt: { gte: since } } }),
      userId ? this.prisma.phoneVerification.count({ where: { userId, createdAt: { gte: since } } }) : Promise.resolve(0),
    ]);
    if (byPhone >= max || byUser >= max) {
      throw new HttpException({ statusCode: 429, code: 'PHONE_RATE_LIMIT', message: `Bạn đã xin mã ${max} lần trong 10 phút, thử lại sau ít phút`, retryAfterSeconds: 600 }, 429);
    }
  }

  /** Phiên mới (mã 6 số); phiên cũ đang chờ cùng mục đích bị hủy. */
  private async create(phone: string, userId: string | null, purpose: PhonePurpose) {
    const c = await this.sys.phoneOtp();
    // chỉ hủy phiên đang chờ của CHÍNH tài khoản này (gắn số) / của số này (quên mật khẩu), không đụng phiên người khác
    await this.prisma.phoneVerification.updateMany({ where: purpose === 'LINK' ? { userId, purpose, status: 'PENDING' } : { phone, purpose, status: 'PENDING' }, data: { status: 'FAILED' } });
    const code = String(randomInt(0, 1_000_000)).padStart(6, '0');
    const expiresAt = new Date(Date.now() + c.codeMinutes * 60_000);
    const v = await this.prisma.phoneVerification.create({ data: { phone, userId, purpose, codeHash: codeHash(phone, code), expiresAt } });
    const body = encodeURIComponent(code);
    return {
      verificationId: v.id,
      phone,
      code,
      expiresAt,
      // app KHÔNG hiển thị số cổng; chỉ dùng link này để mở sẵn khung soạn tin (nút "Gửi yêu cầu xác nhận")
      // Android: sms:<số>?body=…  ·  iOS: sms:<số>&body=…
      smsLink: { android: `sms:${c.gatewayNumber}?body=${body}`, ios: `sms:${c.gatewayNumber}&body=${body}` },
    };
  }

  private view(v: PhoneVerification) {
    const expired = v.status === 'PENDING' && v.expiresAt < new Date();
    return { verificationId: v.id, phone: v.phone, status: expired ? 'EXPIRED' : v.status, expiresAt: v.expiresAt, verifiedAt: v.verifiedAt };
  }

  /* ---------- gắn / đổi số cho tài khoản đang đăng nhập ---------- */

  async startLink(userId: string, dto: StartLinkDto) {
    const c = await this.cfg();
    const phone = normalizePhone(dto.phone);
    if (!phone) throw new BadRequestException(PHONE_INVALID);
    const user = await this.prisma.user.findUniqueOrThrow({ where: { id: userId } });
    if (!(await bcrypt.compare(dto.password, user.passwordHash))) throw new BadRequestException('Mật khẩu không đúng');
    if (user.phone === phone) throw new ConflictException({ statusCode: 409, code: 'PHONE_ALREADY_LINKED', message: 'Số này đã gắn với tài khoản của bạn' });
    if (await this.prisma.user.findFirst({ where: { phone, id: { not: userId } }, select: { id: true } })) {
      throw new ConflictException({ statusCode: 409, code: 'PHONE_TAKEN', message: 'Số điện thoại đã được dùng cho tài khoản khác' });
    }
    await this.assertRate(phone, userId, c.maxRequests);
    return this.create(phone, userId, 'LINK');
  }

  async linkStatus(userId: string, id: string) {
    const v = await this.prisma.phoneVerification.findFirst({ where: { id, userId, purpose: 'LINK' } });
    if (!v) throw new NotFoundException('Không tìm thấy phiên xác thực');
    return this.view(v);
  }

  async removePhone(userId: string, dto: RemovePhoneDto) {
    const user = await this.prisma.user.findUniqueOrThrow({ where: { id: userId } });
    if (!(await bcrypt.compare(dto.password, user.passwordHash))) throw new BadRequestException('Mật khẩu không đúng');
    if (!user.phone) throw new NotFoundException('Tài khoản chưa gắn số điện thoại');
    await this.prisma.user.update({ where: { id: userId }, data: { phone: null, phoneVerifiedAt: null } });
    await this.mail.notify(user.email, (b) => phoneRemovedMail(b, { name: user.name, phone: user.phone!, at: new Date() }));
    await notifySecurity(this.prisma, userId, 'Đã gỡ số điện thoại', `Số ${maskPhone(user.phone!)} không còn gắn với tài khoản. Bạn vẫn lấy lại mật khẩu được qua email.`);
  }

  /* ---------- quên mật khẩu bằng số điện thoại ---------- */

  /** Luôn tạo phiên (kể cả số chưa gắn tài khoản nào) → không dò được số nào có tài khoản. */
  async startReset(dto: StartResetDto) {
    const c = await this.cfg();
    const phone = normalizePhone(dto.phone);
    if (!phone) throw new BadRequestException(PHONE_INVALID);
    await this.assertRate(phone, null, c.maxRequests);
    const user = await this.prisma.user.findUnique({ where: { phone }, select: { id: true, status: true } });
    return this.create(phone, user && user.status !== 'LOCKED' ? user.id : null, 'RESET');
  }

  /** maskedEmail chỉ có khi đã VERIFIED (người gọi vừa chứng minh cầm SIM) — trước đó không lộ số nào gắn tài khoản nào. */
  async resetStatus(id: string) {
    const v = await this.prisma.phoneVerification.findFirst({ where: { id, purpose: 'RESET' } });
    if (!v) throw new NotFoundException('Không tìm thấy phiên xác thực');
    const view = this.view(v);
    if (view.status !== 'VERIFIED') return view;
    const user = v.userId ? await this.prisma.user.findUnique({ where: { id: v.userId }, select: { email: true, phone: true } }) : null;
    return { ...view, maskedEmail: user && user.phone === v.phone ? maskEmail(user.email) : null };
  }

  /** Phiên RESET đã VERIFIED, còn hạn, gắn đúng tài khoản → đặt mật khẩu mới, đăng xuất mọi thiết bị, báo qua email. */
  async resetPassword(dto: ResetByPhoneDto) {
    const v = await this.prisma.phoneVerification.findFirst({ where: { id: dto.verificationId, purpose: 'RESET' } });
    if (!v || v.status !== 'VERIFIED' || !v.userId || v.expiresAt < new Date()) throw new BadRequestException(SESSION_INVALID);
    const user = await this.prisma.user.findUnique({ where: { id: v.userId } });
    if (!user || user.phone !== v.phone || user.status === 'LOCKED') throw new BadRequestException(SESSION_INVALID);
    const min = await this.sys.get<number>('password.minLength');
    if (dto.newPassword.length < min) throw new BadRequestException(`Mật khẩu mới phải có ít nhất ${min} ký tự`);
    // USED trước (điều kiện status = VERIFIED) để 2 request đồng thời không cùng dùng được 1 phiên
    const used = await this.prisma.phoneVerification.updateMany({ where: { id: v.id, status: 'VERIFIED' }, data: { status: 'USED' } });
    if (used.count !== 1) throw new BadRequestException(SESSION_INVALID);
    await this.prisma.user.update({ where: { id: user.id }, data: { passwordHash: await bcrypt.hash(dto.newPassword, 10), tokenVersion: { increment: 1 } } });
    await this.prisma.passwordReset.deleteMany({ where: { userId: user.id } });
    await this.mail.notify(user.email, (b) => passwordResetByPhoneMail(b, { name: user.name, phone: v.phone, at: new Date() }));
    await notifySecurity(this.prisma, user.id, 'Mật khẩu vừa được đặt lại', `Đặt lại bằng số điện thoại ${maskPhone(v.phone)}. Mọi thiết bị đã được đăng xuất.`);
  }

  /* ---------- máy cổng ---------- */

  async inbound(key: string | undefined, dto: InboundSmsDto) {
    const c = await this.sys.phoneOtp();
    const a = Buffer.from(key ?? ''), b = Buffer.from(c.gatewayKey);
    if (!c.gatewayKey || a.length !== b.length || !timingSafeEqual(a, b)) throw new UnauthorizedException('Sai khóa máy cổng');
    // mọi tin đúng khóa (kể cả "Gửi tin thử" của app chuyển tiếp) → admin thấy máy cổng còn sống
    const at = { value: new Date().toISOString() };
    await this.prisma.systemSetting.upsert({ where: { key: 'access.smsGatewayLastInboundAt' }, create: { key: 'access.smsGatewayLastInboundAt', ...at }, update: at }).catch(() => undefined);
    const phone = normalizePhone(dto.from ?? dto.sender ?? dto.phoneNumber ?? dto.phone ?? '');
    const code = (dto.text ?? dto.message ?? dto.body ?? dto.content ?? '').match(/(?<!\d)\d{6}(?!\d)/)?.[0];
    if (!phone || !code) return { matched: false, reason: 'not_otp' };
    const v = await this.prisma.phoneVerification.findFirst({
      where: { phone, codeHash: codeHash(phone, code), status: 'PENDING', expiresAt: { gt: new Date() } },
      orderBy: { createdAt: 'desc' },
    });
    if (!v) return { matched: false, reason: 'no_session' };
    if (v.purpose === 'RESET') {
      await this.prisma.phoneVerification.update({ where: { id: v.id }, data: { status: 'VERIFIED', verifiedAt: new Date() } });
      return { matched: true, purpose: v.purpose };
    }
    // LINK: kiểm lại "mỗi số 1 tài khoản" lúc gắn (người khác có thể vừa gắn số này)
    const user = await this.prisma.user.findUnique({ where: { id: v.userId! } });
    const taken = await this.prisma.user.findFirst({ where: { phone, id: { not: v.userId! } }, select: { id: true } });
    if (!user || taken) {
      await this.prisma.phoneVerification.update({ where: { id: v.id }, data: { status: 'FAILED' } });
      return { matched: true, purpose: v.purpose, linked: false };
    }
    const now = new Date();
    try {
      await this.prisma.$transaction([
        this.prisma.user.update({ where: { id: user.id }, data: { phone, phoneVerifiedAt: now } }),
        this.prisma.phoneVerification.update({ where: { id: v.id }, data: { status: 'VERIFIED', verifiedAt: now } }),
      ]);
    } catch (e) {
      // unique(phone) bị chiếm giữa chừng
      this.logger.warn(`gắn số ${phone} thất bại: ${(e as Error).message}`);
      await this.prisma.phoneVerification.update({ where: { id: v.id }, data: { status: 'FAILED' } });
      return { matched: true, purpose: v.purpose, linked: false };
    }
    await this.mail.notify(user.email, (b) => phoneLinkedMail(b, { name: user.name, phone, at: now, replaced: user.phone }));
    await notifySecurity(this.prisma, user.id, user.phone ? 'Đã đổi số điện thoại' : 'Đã gắn số điện thoại', `Số ${maskPhone(phone)} đã được xác thực. Dùng để lấy lại mật khẩu khi quên.`);
    return { matched: true, purpose: v.purpose, linked: true };
  }

}

@ApiTags('auth')
@Controller()
export class PhoneController {
  constructor(private readonly phone: PhoneService) {}

  /** Gắn / đổi số: trả mã 6 số + số cổng + link mở khung soạn SMS. 403 tắt, 409 PHONE_TAKEN, 429 PHONE_RATE_LIMIT */
  @ApiBearerAuth() @Post('me/phone/verifications')
  startLink(@CurrentUser() u: AuthUser, @Body() dto: StartLinkDto) {
    return this.phone.startLink(u.id, dto);
  }

  /** App hỏi định kỳ: PENDING → VERIFIED (đã gắn) | EXPIRED | FAILED (số vừa bị tài khoản khác gắn) */
  @ApiBearerAuth() @Get('me/phone/verifications/:id')
  linkStatus(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.phone.linkStatus(u.id, id);
  }

  /** Gỡ số điện thoại (cần mật khẩu), báo qua email */
  @ApiBearerAuth() @Delete('me/phone') @HttpCode(204)
  remove(@CurrentUser() u: AuthUser, @Body() dto: RemovePhoneDto) {
    return this.phone.removePhone(u.id, dto);
  }

  /** Quên mật khẩu bằng SĐT: luôn trả phiên (không lộ số nào có tài khoản) */
  @Public() @UseGuards(AppThrottlerGuard) @ApiTooManyRequestsResponse() @Post('auth/forgot-password/phone')
  startReset(@Body() dto: StartResetDto) {
    return this.phone.startReset(dto);
  }

  @Public() @Get('auth/forgot-password/phone/:id')
  resetStatus(@Param('id', ParseUUIDPipe) id: string) {
    return this.phone.resetStatus(id);
  }

  /** Phiên đã VERIFIED → đặt mật khẩu mới; mọi phiên đăng nhập cũ hết hiệu lực */
  @Public() @UseGuards(AppThrottlerGuard) @ApiTooManyRequestsResponse() @Post('auth/reset-password/phone') @HttpCode(204)
  reset(@Body() dto: ResetByPhoneDto) {
    return this.phone.resetPassword(dto);
  }

  /** Máy cổng (app chuyển tiếp SMS trên Android) gọi khi nhận tin. Header x-gateway-key = khóa trong Cấu hình */
  @Public() @ApiHeader({ name: 'x-gateway-key', required: true }) @Post('sms-gateway/inbound') @HttpCode(200)
  inbound(@Headers('x-gateway-key') key: string | undefined, @Req() req: Request, @Body() body: Record<string, unknown>) {
    // Mỗi app chuyển tiếp gửi kèm trường riêng (sentStamp, sim, battery…) → nhận body thô, chỉ lấy các trường cần, bỏ phần thừa
    const str = (v: unknown) => (typeof v === 'string' ? v : typeof v === 'number' ? String(v) : undefined);
    const b = body && typeof body === 'object' && !Array.isArray(body) ? body : {};
    const dto: InboundSmsDto = {};
    for (const k of ['from', 'sender', 'phone', 'phoneNumber', 'text', 'message', 'body', 'content'] as const) {
      const v = str(b[k]);
      if (v !== undefined) dto[k] = v.slice(0, 2000);
    }
    return this.phone.inbound(key ?? (req.query.key as string | undefined), dto);
  }
}
