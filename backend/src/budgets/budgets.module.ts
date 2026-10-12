import { BadRequestException, Body, ConflictException, Controller, Delete, Get, HttpCode, Injectable, Module, NotFoundException, Param, ParseUUIDPipe, Patch, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsInt, IsOptional, IsUUID, Matches, Max, Min } from 'class-validator';
import { Budget } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuthUser, CurrentUser } from '../common/auth';
import { MAX_AMOUNT } from '../common/dto';
import { MONTH_REGEX, monthOf, monthRange } from '../common/time';
import { CategoriesModule, CategoriesService } from '../categories/categories.module';
import { SystemConfigService } from '../system-config/system-config.module';

export class CreateBudgetDto {
  /** Danh mục chi tiêu; bỏ trống => ngân sách tổng của tháng */
  @IsOptional() @IsUUID() categoryId?: string;
  /** YYYY-MM */
  @Matches(MONTH_REGEX) month: string;
  @Type(() => Number) @IsInt() @Min(1) @Max(MAX_AMOUNT) limitAmount: number;
}

class UpdateBudgetDto {
  @Type(() => Number) @IsInt() @Min(1) @Max(MAX_AMOUNT) limitAmount: number;
}

class BudgetQuery {
  @IsOptional() @Matches(MONTH_REGEX) month?: string;
}

class CopyBudgetsDto {
  @Matches(MONTH_REGEX) fromMonth: string;
  @Matches(MONTH_REGEX) toMonth: string;
}

/** Ngưỡng lấy từ Cấu hình hệ thống (business.budgetWarningPercent / budgetExceededPercent, mặc định 80% / 100%). */
interface Thresholds {
  warningPercent: number;
  exceededPercent: number;
}
const CATEGORY_SELECT = { select: { id: true, name: true, icon: true, color: true } } as const;
const fmt = (v: number) => v.toLocaleString('vi-VN');

@Injectable()
export class BudgetsService {
  constructor(private readonly prisma: PrismaService, private readonly categories: CategoriesService, private readonly sys: SystemConfigService) {}

  async list(userId: string, month: string) {
    const th = await this.sys.budgetThresholds();
    const budgets = await this.prisma.budget.findMany({
      where: { userId, month },
      include: { category: CATEGORY_SELECT },
      orderBy: { createdAt: 'asc' },
    });
    const spent = await this.spent(userId, month);
    const overallBudget = budgets.find((b) => !b.categoryId);
    const items = budgets.filter((b) => b.categoryId).map((b) => withProgress(b, spent.get(b.categoryId!) ?? 0, th));
    const totalLimit = items.reduce((s, b) => s + b.limitAmount, 0);
    const totalSpent = items.reduce((s, b) => s + b.spent, 0);
    return {
      month,
      thresholds: th,
      overall: overallBudget ? withProgress(overallBudget, spent.get(null) ?? 0, th) : null,
      totalLimit,
      totalSpent,
      totalRemaining: totalLimit - totalSpent,
      items,
    };
  }

  async create(userId: string, dto: CreateBudgetDto) {
    if (dto.categoryId) {
      const category = await this.categories.usableForUser(userId, dto.categoryId);
      if (category.type !== 'EXPENSE') throw new BadRequestException('Ngân sách chỉ áp dụng cho danh mục chi tiêu');
    } else if (await this.prisma.budget.findFirst({ where: { userId, month: dto.month, categoryId: null } })) {
      throw new ConflictException('Tháng này đã có ngân sách tổng');
    }
    const budget = await this.prisma.budget.create({
      data: { userId, categoryId: dto.categoryId ?? null, month: dto.month, limitAmount: BigInt(dto.limitAmount) },
      include: { category: CATEGORY_SELECT },
    });
    return withProgress(budget, (await this.spent(userId, dto.month)).get(budget.categoryId) ?? 0, await this.sys.budgetThresholds());
  }

  /** Đổi hạn mức => tính lại dấu đã báo: tụt dưới ngưỡng thì xóa dấu để lần vượt sau báo lại. */
  async update(userId: string, id: string, dto: UpdateBudgetDto) {
    const current = await this.findOwned(userId, id);
    const th = await this.sys.budgetThresholds();
    const spent = (await this.spent(userId, current.month)).get(current.categoryId) ?? 0;
    const pctNew = (spent / dto.limitAmount) * 100;
    const budget = await this.prisma.budget.update({
      where: { id },
      data: {
        limitAmount: BigInt(dto.limitAmount),
        warnedAt: pctNew < th.warningPercent ? null : undefined,
        exceededAt: pctNew < th.exceededPercent ? null : undefined,
      },
      include: { category: CATEGORY_SELECT },
    });
    return withProgress(budget, spent, th);
  }

  async remove(userId: string, id: string) {
    await this.findOwned(userId, id);
    await this.prisma.budget.delete({ where: { id } });
  }

  /** Sao chép ngân sách (kể cả ngân sách tổng) sang tháng khác; mục đã có ở tháng đích được giữ nguyên. */
  async copy(userId: string, dto: CopyBudgetsDto) {
    if (dto.fromMonth === dto.toMonth) throw new BadRequestException('Tháng nguồn và tháng đích phải khác nhau');
    const [source, existing] = await Promise.all([
      this.prisma.budget.findMany({
        where: { userId, month: dto.fromMonth, OR: [{ categoryId: null }, { category: { isArchived: false } }] },
      }),
      this.prisma.budget.findMany({ where: { userId, month: dto.toMonth }, select: { categoryId: true } }),
    ]);
    const taken = new Set(existing.map((b) => b.categoryId));
    const { count } = await this.prisma.budget.createMany({
      data: source
        .filter((b) => !taken.has(b.categoryId))
        .map((b) => ({ userId, categoryId: b.categoryId, month: dto.toMonth, limitAmount: b.limitAmount })),
      skipDuplicates: true,
    });
    return { copied: count };
  }

  /**
   * Gọi sau khi tạo/sửa/xóa giao dịch chi: ngân sách danh mục + ngân sách tổng của tháng đó vượt ngưỡng cảnh báo / vượt (cấu hình, mặc định 80% / 100%)
   * => sinh 1 thông báo. Mỗi ngưỡng mỗi ngân sách chỉ báo 1 lần (updateMany có điều kiện => an toàn khi chạy đồng thời).
   * Chi tụt dưới ngưỡng (xóa / sửa / dời giao dịch) => xóa dấu để lần vượt sau báo lại (giống khi đổi hạn mức).
   */
  async checkThresholds(userId: string, month: string, categoryId: string) {
    const budgets = await this.prisma.budget.findMany({
      where: { userId, month, OR: [{ categoryId }, { categoryId: null }] },
      include: { category: CATEGORY_SELECT },
    });
    if (!budgets.length) return;
    const { warningPercent: W, exceededPercent: X } = await this.sys.budgetThresholds();
    const spent = await this.spent(userId, month);
    for (const b of budgets) {
      const used = spent.get(b.categoryId) ?? 0;
      const limit = Number(b.limitAmount);
      const pct = (used / limit) * 100;
      const level = pct >= X ? 'exceeded' : pct >= W ? 'warning' : null;
      if ((pct < W && b.warnedAt) || (pct < X && b.exceededAt)) {
        await this.prisma.budget.update({
          where: { id: b.id },
          data: { warnedAt: pct < W ? null : undefined, exceededAt: null },
        });
      }
      if (!level) continue;
      const now = new Date();
      // Vượt ngưỡng vượt => đánh dấu cả 2 ngưỡng, chỉ gửi 1 thông báo "vượt"
      const { count } = await this.prisma.budget.updateMany({
        where: level === 'exceeded' ? { id: b.id, exceededAt: null } : { id: b.id, warnedAt: null },
        data: level === 'exceeded' ? { exceededAt: now, warnedAt: b.warnedAt ?? now } : { warnedAt: now },
      });
      if (!count) continue;
      const name = b.category ? `"${b.category.name}"` : 'tổng';
      await this.prisma.notification.create({
        data: {
          userId,
          type: level === 'exceeded' ? 'BUDGET_EXCEEDED' : 'BUDGET_WARNING',
          title: level === 'exceeded' ? `Vượt ngân sách ${name}` : `Sắp hết ngân sách ${name}`,
          body: `Tháng ${month}: đã chi ${fmt(used)}đ / ${fmt(limit)}đ (${Math.round(pct * 10) / 10}%)`,
          data: { budgetId: b.id, month, categoryId: b.categoryId, spent: used, limit, percentage: Math.round(pct * 10) / 10 },
        },
      });
    }
  }

  private async findOwned(userId: string, id: string) {
    const b = await this.prisma.budget.findFirst({ where: { id, userId } });
    if (!b) throw new NotFoundException('Không tìm thấy ngân sách');
    return b;
  }

  /** Tổng chi theo danh mục của tháng; key null = tổng chi cả tháng. Chuyển tiền / tiết kiệm không tính. */
  private async spent(userId: string, month: string) {
    const { start, end } = monthRange(month);
    const rows = await this.prisma.transaction.groupBy({
      by: ['categoryId'],
      where: { userId, type: 'EXPENSE', occurredAt: { gte: start, lt: end } },
      _sum: { amount: true },
    });
    const m = new Map<string | null, number>(rows.map((r) => [r.categoryId, Number(r._sum.amount ?? 0)]));
    m.set(null, rows.reduce((s, r) => s + Number(r._sum.amount ?? 0), 0));
    return m;
  }
}

function withProgress<T extends Budget>(b: T, spent: number, th: Thresholds) {
  const limitAmount = Number(b.limitAmount);
  const percentage = limitAmount ? Math.round((spent / limitAmount) * 1000) / 10 : 0;
  return {
    ...b,
    limitAmount,
    spent,
    remaining: limitAmount - spent,
    percentage,
    status: percentage >= th.exceededPercent ? 'exceeded' : percentage >= th.warningPercent ? 'warning' : 'ok',
  };
}

@ApiTags('budgets')
@ApiBearerAuth()
@Controller('budgets')
export class BudgetsController {
  constructor(private readonly budgets: BudgetsService) {}

  /** Ngân sách của tháng: `overall` (ngân sách tổng) + `items` theo danh mục, kèm spent/remaining/percentage/status; `thresholds` = ngưỡng cảnh báo / vượt đang áp dụng */
  @Get()
  list(@CurrentUser() u: AuthUser, @Query() q: BudgetQuery) {
    return this.budgets.list(u.id, q.month ?? monthOf(new Date()));
  }

  /** Bỏ trống categoryId => ngân sách tổng (mỗi tháng 1) */
  @Post()
  create(@CurrentUser() u: AuthUser, @Body() dto: CreateBudgetDto) {
    return this.budgets.create(u.id, dto);
  }

  @Post('copy')
  copy(@CurrentUser() u: AuthUser, @Body() dto: CopyBudgetsDto) {
    return this.budgets.copy(u.id, dto);
  }

  @Patch(':id')
  update(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string, @Body() dto: UpdateBudgetDto) {
    return this.budgets.update(u.id, id, dto);
  }

  @Delete(':id') @HttpCode(204)
  remove(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.budgets.remove(u.id, id);
  }
}

@Module({ imports: [CategoriesModule], controllers: [BudgetsController], providers: [BudgetsService], exports: [BudgetsService] })
export class BudgetsModule {}
