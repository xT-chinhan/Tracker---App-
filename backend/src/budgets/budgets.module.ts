import { BadRequestException, Body, Controller, Delete, Get, HttpCode, Injectable, Module, NotFoundException, Param, ParseUUIDPipe, Patch, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsInt, IsOptional, IsUUID, Matches, Max, Min } from 'class-validator';
import { Budget } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuthUser, CurrentUser } from '../common/auth';
import { MAX_AMOUNT } from '../common/dto';
import { MONTH_REGEX, monthOf, monthRange } from '../common/time';
import { CategoriesModule, CategoriesService } from '../categories/categories.module';

class CreateBudgetDto {
  /** Danh mục chi tiêu */
  @IsUUID() categoryId: string;
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

/** Ngưỡng cảnh báo giữ như app cũ: >= 80% là sắp hết, >= 100% là vượt. */
const WARNING_PERCENT = 80;

@Injectable()
export class BudgetsService {
  constructor(private readonly prisma: PrismaService, private readonly categories: CategoriesService) {}

  async list(userId: string, month: string) {
    const budgets = await this.prisma.budget.findMany({
      where: { userId, month },
      include: { category: { select: { id: true, name: true, icon: true, color: true } } },
      orderBy: { createdAt: 'asc' },
    });
    const spent = await this.spentByCategory(userId, month, budgets.map((b) => b.categoryId));
    const items = budgets.map((b) => withProgress(b, spent.get(b.categoryId) ?? 0));
    const totalLimit = items.reduce((s, b) => s + b.limitAmount, 0);
    const totalSpent = items.reduce((s, b) => s + b.spent, 0);
    return {
      month,
      totalLimit,
      totalSpent,
      totalRemaining: totalLimit - totalSpent,
      items,
    };
  }

  async create(userId: string, dto: CreateBudgetDto) {
    const category = await this.categories.usableForUser(userId, dto.categoryId);
    if (category.type !== 'EXPENSE') throw new BadRequestException('Ngân sách chỉ áp dụng cho danh mục chi tiêu');
    const budget = await this.prisma.budget.create({
      data: { userId, categoryId: category.id, month: dto.month, limitAmount: BigInt(dto.limitAmount) },
      include: { category: { select: { id: true, name: true, icon: true, color: true } } },
    });
    const spent = await this.spentByCategory(userId, dto.month, [budget.categoryId]);
    return withProgress(budget, spent.get(budget.categoryId) ?? 0);
  }

  async update(userId: string, id: string, dto: UpdateBudgetDto) {
    await this.findOwned(userId, id);
    const budget = await this.prisma.budget.update({
      where: { id },
      data: { limitAmount: BigInt(dto.limitAmount) },
      include: { category: { select: { id: true, name: true, icon: true, color: true } } },
    });
    const spent = await this.spentByCategory(userId, budget.month, [budget.categoryId]);
    return withProgress(budget, spent.get(budget.categoryId) ?? 0);
  }

  async remove(userId: string, id: string) {
    await this.findOwned(userId, id);
    await this.prisma.budget.delete({ where: { id } });
  }

  /** Sao chép ngân sách sang tháng khác; danh mục đã có ngân sách ở tháng đích được giữ nguyên. */
  async copy(userId: string, dto: CopyBudgetsDto) {
    const source = await this.prisma.budget.findMany({
      where: { userId, month: dto.fromMonth, category: { isArchived: false } },
    });
    const { count } = await this.prisma.budget.createMany({
      data: source.map((b) => ({ userId, categoryId: b.categoryId, month: dto.toMonth, limitAmount: b.limitAmount })),
      skipDuplicates: true,
    });
    return { copied: count };
  }

  private async findOwned(userId: string, id: string) {
    const b = await this.prisma.budget.findFirst({ where: { id, userId } });
    if (!b) throw new NotFoundException('Không tìm thấy ngân sách');
    return b;
  }

  private async spentByCategory(userId: string, month: string, categoryIds: string[]) {
    const { start, end } = monthRange(month);
    const rows = await this.prisma.transaction.groupBy({
      by: ['categoryId'],
      where: { userId, type: 'EXPENSE', categoryId: { in: categoryIds }, occurredAt: { gte: start, lt: end } },
      _sum: { amount: true },
    });
    return new Map(rows.map((r) => [r.categoryId, Number(r._sum.amount ?? 0)]));
  }
}

function withProgress<T extends Budget>(b: T, spent: number) {
  const limitAmount = Number(b.limitAmount);
  const percentage = limitAmount ? Math.round((spent / limitAmount) * 1000) / 10 : 0;
  return {
    ...b,
    limitAmount,
    spent,
    remaining: limitAmount - spent,
    percentage,
    status: percentage >= 100 ? 'exceeded' : percentage >= WARNING_PERCENT ? 'warning' : 'ok',
  };
}

@ApiTags('budgets')
@ApiBearerAuth()
@Controller('budgets')
export class BudgetsController {
  constructor(private readonly budgets: BudgetsService) {}

  /** Ngân sách của tháng kèm số đã chi, còn lại, % và trạng thái ok | warning | exceeded */
  @Get()
  list(@CurrentUser() u: AuthUser, @Query() q: BudgetQuery) {
    return this.budgets.list(u.id, q.month ?? monthOf(new Date()));
  }

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

@Module({ imports: [CategoriesModule], controllers: [BudgetsController], providers: [BudgetsService] })
export class BudgetsModule {}
