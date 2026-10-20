import { Cron } from '@nestjs/schedule';
import type { Request } from 'express';
import { Req, BadRequestException, Body, ConflictException, Controller, Delete, ForbiddenException, Get, HttpCode, Injectable, Logger, Module, Patch, Post, UnauthorizedException, UseGuards } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { AppThrottlerGuard } from '../common/throttle';
import { ApiBearerAuth, ApiTags, ApiTooManyRequestsResponse } from '@nestjs/swagger';
import { IsEmail, IsString, Matches, MaxLength, MinLength } from 'class-validator';
import * as bcrypt from 'bcryptjs';
import { randomInt } from 'crypto';
import { User } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuthUser, CurrentUser, Public } from '../common/auth';
import { SystemConfigService } from '../system-config/system-config.module';
import { Trim } from '../common/dto';
import { MailService } from './mail.service';
import { PhoneController, PhoneService } from './phone';

export { MailService };

class RegisterDto {
  @IsEmail() email: string;
  @IsString() @MinLength(6) @MaxLength(72) password: string;
  @Trim() @IsString() @MinLength(1) @MaxLength(100) name: string;
}

class LoginDto {
  @IsEmail() email: string;
  @IsString() password: string;
}

class UpdateProfileDto {
  @Trim() @IsString() @MinLength(1) @MaxLength(100) name: string;
}

class ChangePasswordDto {
  @IsString() currentPassword: string;
  @IsString() @MinLength(6) @MaxLength(72) newPassword: string;
}

class ForgotPasswordDto {
  @IsEmail() email: string;
}

class ResetPasswordDto {
  @IsEmail() email: string;
  /** Mã 6 số gửi qua email */
  @Matches(/^\d{6}$/, { message: 'otp phải gồm 6 chữ số' }) otp: string;
  @IsString() @MinLength(6) @MaxLength(72) newPassword: string;
}

class DeleteAccountDto {
  /** Mật khẩu hiện tại để xác nhận */
  @IsString() password: string;
}

const OTP_INVALID = 'Mã OTP không đúng hoặc đã hết hạn';
/** Hash giả để email không tồn tại cũng tốn 1 lần bcrypt (không dò email qua thời gian phản hồi) */
const DUMMY_HASH = bcrypt.hashSync('dummy-password', 10);

export function publicUser<T extends { passwordHash: string; tokenVersion: number }>(u: T): Omit<T, 'passwordHash' | 'tokenVersion'> {
  const { passwordHash, tokenVersion, ...rest } = u;
  return rest;
}

@Injectable()
export class AuthService {
  private readonly logger = new Logger('Auth');

  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly mail: MailService,
    private readonly sys: SystemConfigService,
  ) {}

  /** Độ dài tối thiểu lấy từ Cấu hình hệ thống (password.minLength), áp cho đăng ký / đổi / đặt lại mật khẩu. */
  private async assertPasswordLength(password: string, field = 'Mật khẩu') {
    const min = await this.sys.get<number>('password.minLength');
    if (password.length < min) throw new BadRequestException(`${field} phải có ít nhất ${min} ký tự`);
  }

  /** Tạo user kèm ví mặc định (tên theo cấu hình business.defaultWalletName). Tắt đăng ký => 403; bảo trì => 503. */
  async register(dto: RegisterDto) {
    if (!(await this.sys.get<boolean>('access.registrationEnabled'))) {
      throw new ForbiddenException({ statusCode: 403, code: 'REGISTRATION_DISABLED', message: 'Ứng dụng đang tạm ngưng nhận đăng ký mới' });
    }
    await this.sys.assertNotMaintenance('USER');
    await this.assertPasswordLength(dto.password);
    const email = dto.email.toLowerCase().trim();
    if (await this.prisma.user.findUnique({ where: { email } })) {
      throw new ConflictException('Email đã được sử dụng');
    }
    const user = await this.prisma.user.create({
      data: {
        email,
        name: dto.name,
        lastLoginAt: new Date(),
        passwordHash: await bcrypt.hash(dto.password, 10),
        wallets: { create: { name: await this.sys.get<string>('business.defaultWalletName'), type: 'CASH' } },
      },
    });
    return this.issue(user);
  }

  async login(dto: LoginDto, ip?: string) {
    const user = await this.prisma.user.findUnique({ where: { email: dto.email.toLowerCase().trim() } });
    const ok = await bcrypt.compare(dto.password, user?.passwordHash ?? DUMMY_HASH);
    if (!user || !ok) {
      // Ghi nhận lần sai của tài khoản có thật (không lưu mật khẩu) → admin / AI phát hiện dò mật khẩu
      if (user) await this.prisma.loginFailure.create({ data: { userId: user.id, ip: ip?.slice(0, 64) ?? null } }).catch(() => undefined);
      throw new UnauthorizedException('Email hoặc mật khẩu không đúng');
    }
    if (user.status === 'LOCKED') throw new ForbiddenException('Tài khoản đã bị khóa');
    await this.sys.assertNotMaintenance(user.role);
    return this.issue(await this.prisma.user.update({ where: { id: user.id }, data: { lastLoginAt: new Date() } }));
  }

  /** Xóa log đăng nhập sai quá 30 ngày (hằng ngày 03:10 giờ VN). */
  @Cron('10 3 * * *', { timeZone: 'Asia/Ho_Chi_Minh' })
  async pruneLoginFailures() {
    await this.prisma.loginFailure.deleteMany({ where: { createdAt: { lt: new Date(Date.now() - 30 * 86400_000) } } }).catch(() => undefined);
    await this.prisma.phoneVerification.deleteMany({ where: { createdAt: { lt: new Date(Date.now() - 86400_000) } } }).catch(() => undefined);
  }

  async me(userId: string) {
    return publicUser(await this.prisma.user.findUniqueOrThrow({ where: { id: userId } }));
  }

  async updateProfile(userId: string, dto: UpdateProfileDto) {
    return publicUser(await this.prisma.user.update({ where: { id: userId }, data: { name: dto.name } }));
  }

  /** Đổi mật khẩu => mọi phiên cũ hết hiệu lực; trả token mới để thiết bị hiện tại vẫn đăng nhập. */
  async changePassword(userId: string, dto: ChangePasswordDto) {
    const user = await this.prisma.user.findUniqueOrThrow({ where: { id: userId } });
    if (!(await bcrypt.compare(dto.currentPassword, user.passwordHash))) {
      throw new BadRequestException('Mật khẩu hiện tại không đúng');
    }
    await this.assertPasswordLength(dto.newPassword, 'Mật khẩu mới');
    const updated = await this.prisma.user.update({
      where: { id: userId },
      data: { passwordHash: await bcrypt.hash(dto.newPassword, 10), tokenVersion: { increment: 1 } },
    });
    return this.issue(updated);
  }

  /** Đăng xuất mọi thiết bị (kể cả thiết bị hiện tại). */
  async logoutAll(userId: string) {
    await this.prisma.user.update({ where: { id: userId }, data: { tokenVersion: { increment: 1 } } });
  }

  /**
   * Chạy nền sau khi đã trả 204 => email có tồn tại hay không đều phản hồi như nhau.
   * OTP mới ghi đè OTP cũ; trong 60s kể từ lần gửi trước thì bỏ qua.
   */
  async forgotPassword(dto: ForgotPasswordDto) {
    const user = await this.prisma.user.findUnique({ where: { email: dto.email.toLowerCase().trim() } });
    if (!user || user.status === 'LOCKED') return;
    const cfg = await this.sys.otp();
    const prev = await this.prisma.passwordReset.findUnique({ where: { userId: user.id } });
    if (prev && Date.now() - prev.createdAt.getTime() < cfg.resendSeconds * 1000) return;
    const otp = String(randomInt(0, 1_000_000)).padStart(6, '0');
    const data = { codeHash: await bcrypt.hash(otp, 10), expiresAt: new Date(Date.now() + cfg.expiryMinutes * 60_000), attempts: 0, createdAt: new Date() };
    await this.prisma.passwordReset.upsert({ where: { userId: user.id }, create: { userId: user.id, ...data }, update: data });
    await this.mail.sendOtp(user.email, otp, cfg.expiryMinutes, user.name);
  }

  /** Sai quá số lần cho phép (password.otpMaxAttempts) => OTP bị hủy, phải xin mã mới. */
  async resetPassword(dto: ResetPasswordDto) {
    const { maxAttempts } = await this.sys.otp();
    const user = await this.prisma.user.findUnique({ where: { email: dto.email.toLowerCase().trim() } });
    const rec = user && (await this.prisma.passwordReset.findUnique({ where: { userId: user.id } }));
    if (!user || !rec || rec.expiresAt < new Date() || rec.attempts >= maxAttempts) throw new BadRequestException(OTP_INVALID);
    if (!(await bcrypt.compare(dto.otp, rec.codeHash))) {
      const { attempts } = await this.prisma.passwordReset.update({ where: { userId: user.id }, data: { attempts: { increment: 1 } } });
      if (attempts >= maxAttempts) await this.prisma.passwordReset.deleteMany({ where: { userId: user.id } });
      throw new BadRequestException(OTP_INVALID);
    }
    await this.assertPasswordLength(dto.newPassword, 'Mật khẩu mới');
    await this.prisma.$transaction([
      this.prisma.user.update({ where: { id: user.id }, data: { passwordHash: await bcrypt.hash(dto.newPassword, 10), tokenVersion: { increment: 1 } } }),
      this.prisma.passwordReset.delete({ where: { userId: user.id } }),
    ]);
  }

  /** Xóa tài khoản + toàn bộ dữ liệu (cascade). Admin cuối cùng không tự xóa được. */
  async deleteAccount(userId: string, dto: DeleteAccountDto) {
    const user = await this.prisma.user.findUniqueOrThrow({ where: { id: userId } });
    if (!(await bcrypt.compare(dto.password, user.passwordHash))) throw new BadRequestException('Mật khẩu không đúng');
    if (user.role === 'ADMIN' && (await this.prisma.user.count({ where: { role: 'ADMIN' } })) <= 1) {
      throw new ConflictException('Không thể xóa admin cuối cùng');
    }
    await this.prisma.user.delete({ where: { id: userId } });
  }

  runForgot(dto: ForgotPasswordDto) {
    this.forgotPassword(dto).catch((e) => this.logger.error(`forgot-password: ${e?.message ?? e}`));
  }

  private async issue(user: User) {
    return {
      accessToken: await this.jwt.signAsync(
        { sub: user.id, role: user.role, tv: user.tokenVersion },
        { expiresIn: (await this.sys.jwtExpiresIn()) as `${number}d` },
      ),
      user: publicUser(user),
    };
  }
}

@ApiTags('auth')
@Controller()
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  /** Giới hạn theo IP (THROTTLE_*), quá => 429. Tắt đăng ký => 403 REGISTRATION_DISABLED; bảo trì => 503 MAINTENANCE */
  @Public() @UseGuards(AppThrottlerGuard) @ApiTooManyRequestsResponse() @Post('auth/register')
  register(@Body() dto: RegisterDto) {
    return this.auth.register(dto);
  }

  /** Giới hạn theo IP (THROTTLE_*) và theo email (Cấu hình: số lần / khung phút). Bảo trì => user thường 503, admin vẫn vào được */
  @Public() @UseGuards(AppThrottlerGuard) @ApiTooManyRequestsResponse() @Post('auth/login') @HttpCode(200)
  login(@Body() dto: LoginDto, @Req() req: Request) {
    return this.auth.login(dto, req.ip);
  }

  /** Luôn 204 (chống dò email). Có tài khoản => gửi OTP 6 số; hạn / chờ gửi lại theo Cấu hình hệ thống (mặc định 10 phút / 60s). Giới hạn chặt hơn (THROTTLE_FORGOT_LIMIT). */
  @Public() @UseGuards(AppThrottlerGuard) @ApiTooManyRequestsResponse() @Post('auth/forgot-password') @HttpCode(204)
  forgotPassword(@Body() dto: ForgotPasswordDto) {
    this.auth.runForgot(dto);
  }

  /** Đặt lại mật khẩu bằng OTP; sai quá số lần cho phép (mặc định 5) => OTP bị hủy. Mọi phiên cũ hết hiệu lực. */
  @Public() @UseGuards(AppThrottlerGuard) @ApiTooManyRequestsResponse() @Post('auth/reset-password') @HttpCode(204)
  resetPassword(@Body() dto: ResetPasswordDto) {
    return this.auth.resetPassword(dto);
  }

  /** Đăng xuất mọi thiết bị: mọi token hiện có (kể cả token đang dùng) hết hiệu lực */
  @ApiBearerAuth() @Post('auth/logout-all') @HttpCode(204)
  logoutAll(@CurrentUser() u: AuthUser) {
    return this.auth.logoutAll(u.id);
  }

  @ApiBearerAuth() @Get('me')
  me(@CurrentUser() u: AuthUser) {
    return this.auth.me(u.id);
  }

  @ApiBearerAuth() @Patch('me')
  updateProfile(@CurrentUser() u: AuthUser, @Body() dto: UpdateProfileDto) {
    return this.auth.updateProfile(u.id, dto);
  }

  /** Trả `{accessToken, user}` mới; mọi token cũ (thiết bị khác) hết hiệu lực */
  @ApiBearerAuth() @Post('me/password') @HttpCode(200)
  changePassword(@CurrentUser() u: AuthUser, @Body() dto: ChangePasswordDto) {
    return this.auth.changePassword(u.id, dto);
  }

  /** Xóa tài khoản và toàn bộ dữ liệu, cần mật khẩu */
  @ApiBearerAuth() @Delete('me') @HttpCode(204)
  deleteAccount(@CurrentUser() u: AuthUser, @Body() dto: DeleteAccountDto) {
    return this.auth.deleteAccount(u.id, dto);
  }
}

@Module({ controllers: [AuthController, PhoneController], providers: [AuthService, MailService, PhoneService] })
export class AuthModule {}
