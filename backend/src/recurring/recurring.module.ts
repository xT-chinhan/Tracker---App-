import { BadRequestException, Body, ConflictException, Controller, Delete, Get, HttpCode, HttpException, Injectable, Logger, Module, NotFoundException, OnApplicationBootstrap, Param, ParseUUIDPipe, Patch, Post, Query } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsDateString, IsEnum, IsInt, IsOptional, IsString, IsUUID, Max, MaxLength, Min, MinLength } from 'class-validator';
import { Frequency, Prisma, RecurringRule } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuthUser, CurrentUser } from '../common/auth';
import { MAX_AMOUNT, Trim } from '../common/dto';
import { CategoriesModule, CategoriesService } from '../categories/categories.module';
import { WalletsModule, WalletsService } from '../wallets/wallets.module';
import { TransactionsModule, TransactionsService } from '../transactions/transactions.module';

class CreateRuleDto {
  @IsUUID() walletId: string;
  @IsUUID() categoryId: string;
  @Type(() => Number) @IsInt() @Min(1) @Max(MAX_AMOUNT) amount: number;
  @Trim() @IsString() @MinLength(1) @MaxLength(120) title: string;
  @IsOptional() @IsString() @MaxLength(500) note?: string;
  @IsEnum(Frequency) frequency: Frequency;
  /** Mỗi `interval` kỳ một lần (vd WEEKLY + 2 = 2 tuần/lần) */
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) @Max(365) interval?: number;
  /** Kỳ đầu tiên (ISO). Ngày + giờ theo giờ VN được giữ cho mọi kỳ. Ở quá khứ => các kỳ đã qua được sinh bù. */
  @IsDateString() startDate: string;
  /** Sinh tới hết ngày này (giờ VN), bỏ trống = không hạn */
  @IsOptional() @IsDateString() endDate?: string;
}

class UpdateRuleDto {
  @IsOptional() @IsUUID() walletId?: string;
  @IsOptional() @IsUUID() categoryId?: string;
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) @Max(MAX_AMOUNT) amount?: number;
  @IsOptional() @Trim() @IsString() @MinLength(1) @MaxLength(120) title?: string;
  @IsOptional() @IsString() @MaxLength(500) note?: string;
  @IsOptional() @IsEnum(Frequency) frequency?: Frequency;
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) @Max(365) interval?: number;
  @IsOptional() @IsDateString() startDate?: string;
  /** null => bỏ hạn */
  @IsOptional() @IsDateString() endDate?: string | null;
}

class PreviewQuery {
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) @Max(50) count: number = 5;
}

class RunDueQuery {
  /** Mốc "hiện tại" giả lập (chỉ môi trường dev/test) */
  @IsOptional() @IsDateString() now?: string;
}

const OFFSET_MS = 7 * 60 * 60 * 1000;
const DAY_MS = 24 * 60 * 60 * 1000;
/** Mỗi lần chạy sinh tối đa chừng này kỳ / rule, phần còn lại để lần cron sau */
const MAX_PER_RUN = 500;

type Schedule = Pick<RecurringRule, 'frequency' | 'interval' | 'startDate' | 'anchorDay'>;

const vn = (d: Date) => new Date(d.getTime() + OFFSET_MS);
const vnDate = (d: Date) => vn(d).toISOString().slice(0, 10);
const daysInMonth = (y: number, m0: number) => new Date(Date.UTC(y, m0 + 1, 0)).getUTCDate();
/** Cuối ngày (23:59:59.999 giờ VN) của thời điểm d */
const endOfVnDay = (d: Date) => {
  const v = vn(d);
  return new Date(Date.UTC(v.getUTCFullYear(), v.getUTCMonth(), v.getUTCDate() + 1) - OFFSET_MS - 1);
};

/**
 * Kỳ thứ k (k = 0 là startDate). Tính trực tiếp từ startDate + anchorDay nên không trôi:
 * 31/1 -> 28|29/2 -> 31/3. Giờ trong ngày giữ như startDate (giờ VN, không có DST).
 */
export function occurrence(r: Schedule, k: number): Date {
  const s = vn(r.startDate);
  const [y, m, d] = [s.getUTCFullYear(), s.getUTCMonth(), s.getUTCDate()];
  const timeOfDay = s.getTime() - Date.UTC(y, m, d);
  const step = k * r.interval;
  let day: number;
  switch (r.frequency) {
    case 'DAILY': day = Date.UTC(y, m, d + step); break;
    case 'WEEKLY': day = Date.UTC(y, m, d + 7 * step); break;
    case 'MONTHLY': day = Date.UTC(y, m + step, Math.min(r.anchorDay, daysInMonth(y, m + step))); break;
    case 'YEARLY': day = Date.UTC(y + step, m, Math.min(r.anchorDay, daysInMonth(y + step, m))); break;
  }
  return new Date(day + timeOfDay - OFFSET_MS);
}

/** Chỉ số kỳ đầu tiên có thời điểm >= t. */
function indexOnOrAfter(r: Schedule, t: Date): number {
  const diff = t.getTime() - r.startDate.getTime();
  if (diff <= 0) return 0;
  const s = vn(r.startDate), v = vn(t);
  const months = (v.getUTCFullYear() - s.getUTCFullYear()) * 12 + (v.getUTCMonth() - s.getUTCMonth());
  const estimate =
    r.frequency === 'DAILY' ? diff / (DAY_MS * r.interval)
    : r.frequency === 'WEEKLY' ? diff / (7 * DAY_MS * r.interval)
    : r.frequency === 'MONTHLY' ? months / r.interval
    : months / 12 / r.interval;
  let k = Math.max(Math.floor(estimate) - 1, 0);
  while (occurrence(r, k) < t) k++;
  return k;
}

const nextAfter = (r: Schedule, t: Date) => occurrence(r, indexOnOrAfter(r, new Date(t.getTime() + 1)));

const INCLUDE = {
  wallet: { select: { id: true, name: true, type: true, isArchived: true } },
  category: { select: { id: true, name: true, type: true, icon: true, color: true, isArchived: true } },
  _count: { select: { transactions: true } },
} as const;

const view = <T extends RecurringRule>(r: T) => ({ ...r, amount: Number(r.amount) });

@Injectable()
export class RecurringService implements OnApplicationBootstrap {
  private readonly logger = new Logger('Recurring');
  private running = false;

  constructor(
    private readonly prisma: PrismaService,
    private readonly categories: CategoriesService,
    private readonly wallets: WalletsService,
    private readonly txs: TransactionsService,
  ) {}

  /** Chạy bù ngay khi khởi động (các kỳ lỡ lúc server tắt). */
  onApplicationBootstrap() {
    setImmediate(() => this.tick());
  }

  @Cron('*/15 * * * *')
  async tick() {
    if (this.running) return;
    this.running = true;
    try {
      const r = await this.runDue(new Date());
      if (r.created) this.logger.log(`Đã sinh ${r.created} giao dịch định kỳ từ ${r.rules} quy tắc`);
    } catch (e) {
      this.logger.error(`Lỗi chạy giao dịch định kỳ: ${(e as Error).message}`);
    } finally {
      this.running = false;
    }
  }

  /**
   * Sinh mọi kỳ đến hạn (<= now). Idempotent: unique(recurringRuleId, scheduledFor) chặn sinh trùng,
   * nextRunAt chỉ được đẩy lên bằng updateMany có điều kiện => chạy lặp / nhiều instance an toàn.
   */
  async runDue(now: Date, scope: { userId?: string } = {}) {
    const rules = await this.prisma.recurringRule.findMany({
      where: { isActive: true, nextRunAt: { lte: now }, userId: scope.userId },
      orderBy: { nextRunAt: 'asc' },
    });
    let created = 0;
    for (const rule of rules) created += await this.runRule(rule, now);
    return { rules: rules.length, created };
  }

  private async runRule(rule: RecurringRule, now: Date) {
    let created = 0;
    let next = rule.nextRunAt;
    for (let i = 0; i < MAX_PER_RUN && next <= now; i++) {
      if (rule.endDate && next > rule.endDate) break;
      const after = nextAfter(rule, next);
      const reason = await this.blockReason(rule);
      if (reason) {
        await this.pauseWithNotice(rule, next, after, reason);
        return created;
      }
      try {
        await this.txs.create(
          rule.userId,
          { walletId: rule.walletId, categoryId: rule.categoryId, amount: Number(rule.amount), title: rule.title, note: rule.note ?? undefined, occurredAt: next.toISOString() },
          { ruleId: rule.id, scheduledFor: next },
        );
        created++;
      } catch (e) {
        if (e instanceof HttpException) {
          await this.pauseWithNotice(rule, next, after, e.message);
          return created;
        }
        // P2002 = kỳ này đã được sinh (lần chạy trước / instance khác) => chỉ cần đẩy nextRunAt
        if (!(e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2002')) throw e;
      }
      const { count } = await this.prisma.recurringRule.updateMany({
        where: { id: rule.id, nextRunAt: next },
        data: { nextRunAt: after, lastRunAt: new Date() },
      });
      if (!count) return created;
      next = after;
    }
    if (rule.endDate && next > rule.endDate) {
      await this.prisma.recurringRule.updateMany({ where: { id: rule.id, nextRunAt: next }, data: { isActive: false } });
    }
    return created;
  }

  private async blockReason(rule: RecurringRule) {
    const [user, wallet, category] = await Promise.all([
      this.prisma.user.findUnique({ where: { id: rule.userId }, select: { status: true } }),
      this.prisma.wallet.findUnique({ where: { id: rule.walletId }, select: { name: true, isArchived: true } }),
      this.prisma.category.findUnique({ where: { id: rule.categoryId }, select: { name: true, isArchived: true } }),
    ]);
    if (user?.status === 'LOCKED') return 'tài khoản đang bị khóa';
    if (!wallet || wallet.isArchived) return `ví "${wallet?.name}" đã lưu trữ`;
    if (!category || category.isArchived) return `danh mục "${category?.name}" đã lưu trữ`;
    return null;
  }

  /** Bỏ qua kỳ `skipped`, tự tạm dừng rule và báo cho user (1 lần nhờ điều kiện nextRunAt + isActive). */
  private async pauseWithNotice(rule: RecurringRule, skipped: Date, after: Date, reason: string) {
    const { count } = await this.prisma.recurringRule.updateMany({
      where: { id: rule.id, nextRunAt: skipped, isActive: true },
      data: { isActive: false, nextRunAt: after },
    });
    if (!count) return;
    await this.prisma.notification.create({
      data: {
        userId: rule.userId,
        type: 'RECURRING_PAUSED',
        title: `Đã tạm dừng giao dịch định kỳ "${rule.title}"`,
        body: `Bỏ qua kỳ ${vnDate(skipped)} vì ${reason}. Hãy kiểm tra rồi bật lại.`,
        data: { ruleId: rule.id, scheduledFor: skipped.toISOString(), reason },
      },
    });
  }

  async list(userId: string) {
    const rules = await this.prisma.recurringRule.findMany({ where: { userId }, include: INCLUDE, orderBy: [{ isActive: 'desc' }, { nextRunAt: 'asc' }] });
    return rules.map(view);
  }

  async get(userId: string, id: string) {
    const r = await this.prisma.recurringRule.findFirst({ where: { id, userId }, include: INCLUDE });
    if (!r) throw new NotFoundException('Không tìm thấy giao dịch định kỳ');
    return view(r);
  }

  async create(userId: string, dto: CreateRuleDto) {
    await this.categories.usableForUser(userId, dto.categoryId);
    await this.wallets.usable(userId, dto.walletId);
    const startDate = new Date(dto.startDate);
    const endDate = dto.endDate ? endOfVnDay(new Date(dto.endDate)) : null;
    if (endDate && endDate < startDate) throw new BadRequestException('Ngày kết thúc phải sau ngày bắt đầu');
    const r = await this.prisma.recurringRule.create({
      data: {
        userId,
        walletId: dto.walletId,
        categoryId: dto.categoryId,
        amount: BigInt(dto.amount),
        title: dto.title,
        note: dto.note?.trim() || null,
        frequency: dto.frequency,
        interval: dto.interval ?? 1,
        startDate,
        endDate,
        anchorDay: vn(startDate).getUTCDate(),
        nextRunAt: startDate,
      },
      include: INCLUDE,
    });
    return view(r);
  }

  /** Chỉ ảnh hưởng các kỳ tương lai: đổi lịch => nextRunAt = kỳ đầu tiên của lịch mới sau hiện tại. */
  async update(userId: string, id: string, dto: UpdateRuleDto) {
    const cur = await this.get(userId, id);
    if (dto.categoryId && dto.categoryId !== cur.categoryId) await this.categories.usableForUser(userId, dto.categoryId);
    if (dto.walletId && dto.walletId !== cur.walletId) await this.wallets.usable(userId, dto.walletId);
    const startDate = dto.startDate ? new Date(dto.startDate) : cur.startDate;
    const endDate = dto.endDate === null ? null : dto.endDate ? endOfVnDay(new Date(dto.endDate)) : cur.endDate;
    if (endDate && endDate < startDate) throw new BadRequestException('Ngày kết thúc phải sau ngày bắt đầu');
    const schedule: Schedule = {
      frequency: dto.frequency ?? cur.frequency,
      interval: dto.interval ?? cur.interval,
      startDate,
      anchorDay: vn(startDate).getUTCDate(),
    };
    const rescheduled = dto.frequency !== undefined || dto.interval !== undefined || dto.startDate !== undefined;
    const nextRunAt = rescheduled ? occurrence(schedule, indexOnOrAfter(schedule, new Date(Math.max(Date.now(), startDate.getTime())))) : cur.nextRunAt;
    const r = await this.prisma.recurringRule.update({
      where: { id },
      data: {
        walletId: dto.walletId,
        categoryId: dto.categoryId,
        amount: dto.amount !== undefined ? BigInt(dto.amount) : undefined,
        title: dto.title,
        note: dto.note !== undefined ? dto.note.trim() || null : undefined,
        ...schedule,
        endDate,
        nextRunAt,
        isActive: cur.isActive && !(endDate && nextRunAt > endDate),
      },
      include: INCLUDE,
    });
    return view(r);
  }

  /** Giao dịch đã sinh được giữ lại (recurringRuleId => null). */
  async remove(userId: string, id: string) {
    await this.get(userId, id);
    await this.prisma.recurringRule.delete({ where: { id } });
  }

  async pause(userId: string, id: string) {
    await this.get(userId, id);
    await this.prisma.recurringRule.update({ where: { id }, data: { isActive: false } });
    return this.get(userId, id);
  }

  /** Không sinh bù các kỳ trong lúc dừng: nextRunAt nhảy tới kỳ đầu tiên sau hiện tại. */
  async resume(userId: string, id: string) {
    const r = await this.get(userId, id);
    if (r.wallet.isArchived) throw new ConflictException(`Ví "${r.wallet.name}" đã lưu trữ, hãy đổi ví hoặc khôi phục ví`);
    if (r.category.isArchived) throw new ConflictException(`Danh mục "${r.category.name}" đã lưu trữ, hãy đổi danh mục`);
    const next = r.nextRunAt > new Date() ? r.nextRunAt : nextAfter(r, new Date());
    if (r.endDate && next > r.endDate) throw new ConflictException('Giao dịch định kỳ đã hết hạn, hãy đổi ngày kết thúc');
    await this.prisma.recurringRule.update({ where: { id }, data: { isActive: true, nextRunAt: next } });
    return this.get(userId, id);
  }

  /** Các kỳ sắp chạy (đang dừng => tính như khi bật lại bây giờ). */
  async preview(userId: string, id: string, count: number) {
    const r = await this.get(userId, id);
    const from = r.isActive ? r.nextRunAt : r.nextRunAt > new Date() ? r.nextRunAt : nextAfter(r, new Date());
    const items: { scheduledFor: Date; date: string }[] = [];
    for (let k = indexOnOrAfter(r, from); items.length < count; k++) {
      const at = occurrence(r, k);
      if (r.endDate && at > r.endDate) break;
      items.push({ scheduledFor: at, date: vnDate(at) });
    }
    return { ruleId: r.id, isActive: r.isActive, items };
  }
}

@ApiTags('recurring')
@ApiBearerAuth()
@Controller('recurring')
export class RecurringController {
  constructor(private readonly recurring: RecurringService) {}

  @Get()
  list(@CurrentUser() u: AuthUser) {
    return this.recurring.list(u.id);
  }

  /**
   * Chỉ dev/test (NODE_ENV != production): sinh ngay các kỳ đến hạn của user hiện tại tới mốc `now`.
   * Production dùng cron 15 phút.
   */
  @Post('run-due') @HttpCode(200)
  runDue(@CurrentUser() u: AuthUser, @Query() q: RunDueQuery) {
    if (process.env.NODE_ENV === 'production') throw new NotFoundException();
    return this.recurring.runDue(q.now ? new Date(q.now) : new Date(), { userId: u.id });
  }

  @Get(':id')
  get(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.recurring.get(u.id, id);
  }

  @Get(':id/preview')
  preview(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string, @Query() q: PreviewQuery) {
    return this.recurring.preview(u.id, id, q.count);
  }

  @Post()
  create(@CurrentUser() u: AuthUser, @Body() dto: CreateRuleDto) {
    return this.recurring.create(u.id, dto);
  }

  @Patch(':id')
  update(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string, @Body() dto: UpdateRuleDto) {
    return this.recurring.update(u.id, id, dto);
  }

  @Delete(':id') @HttpCode(204)
  remove(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.recurring.remove(u.id, id);
  }

  @Post(':id/pause') @HttpCode(200)
  pause(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.recurring.pause(u.id, id);
  }

  @Post(':id/resume') @HttpCode(200)
  resume(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.recurring.resume(u.id, id);
  }
}

@Module({
  imports: [CategoriesModule, WalletsModule, TransactionsModule],
  controllers: [RecurringController],
  providers: [RecurringService],
})
export class RecurringModule {}
