import { Controller, Get, Injectable, Module, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsEnum, IsInt, IsOptional, IsUUID, Matches, Max, Min } from 'class-validator';
import { Prisma, TxType } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuthUser, CurrentUser } from '../common/auth';
import { RangeQuery } from '../common/dto';
import { APP_TZ, MONTH_REGEX, monthOf, monthRange, resolveRange, shiftMonth } from '../common/time';
import { WalletsModule, WalletsService } from '../wallets/wallets.module';

class WalletRangeQuery extends RangeQuery {
  /** Chỉ tính giao dịch của ví này */
  @IsOptional() @IsUUID() walletId?: string;
}

class ByCategoryQuery extends WalletRangeQuery {
  @IsOptional() @IsEnum(TxType) type: TxType = 'EXPENSE';
}

class MonthQuery {
  /** YYYY-MM, mặc định tháng hiện tại */
  @IsOptional() @Matches(MONTH_REGEX) month?: string;
  /** Chỉ tính giao dịch của ví này */
  @IsOptional() @IsUUID() walletId?: string;
}

class TrendQuery extends MonthQuery {
  /** Số tháng lấy về (tính lùi từ month) */
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) @Max(36) months: number = 6;
}

class ReportQuery extends MonthQuery {
  /** Số tháng quan sát để dự báo tháng sau */
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) @Max(24) observationMonths: number = 6;
}

const n = (v: bigint | number | null | undefined) => Number(v ?? 0);
const pct = (part: number, total: number) => (total ? Math.round((part / total) * 1000) / 10 : 0);

export interface MonthTotal {
  month: string;
  income: number;
  expense: number;
  net: number;
}

/**
 * Toàn bộ số liệu đều tính trực tiếp từ giao dịch (không lưu số dư cộng dồn).
 * Thu/chi chỉ gồm giao dịch; chuyển tiền giữa ví và tiền tiết kiệm không phải thu/chi.
 */
@Injectable()
export class StatsService {
  constructor(private readonly prisma: PrismaService, private readonly wallets: WalletsService) {}

  /** Số dư tổng = tổng số dư các ví (= ban đầu + thu − chi − tiền đang gửi tiết kiệm), kèm từng ví. */
  async balance(userId: string) {
    const [tx, entries, list] = await Promise.all([
      this.prisma.transaction.groupBy({ by: ['type'], where: { userId }, _sum: { amount: true } }),
      this.prisma.savingEntry.groupBy({ by: ['type'], where: { userId }, _sum: { amount: true } }),
      this.wallets.list(userId),
    ]);
    const income = n(tx.find((t) => t.type === 'INCOME')?._sum.amount);
    const expense = n(tx.find((t) => t.type === 'EXPENSE')?._sum.amount);
    const deposited = n(entries.find((e) => e.type === 'DEPOSIT')?._sum.amount);
    const withdrawn = n(entries.find((e) => e.type === 'WITHDRAW')?._sum.amount);
    return {
      balance: list.totalBalance,
      totalIncome: income,
      totalExpense: expense,
      savings: deposited - withdrawn,
      wallets: list.items.map((w) => ({ id: w.id, name: w.name, type: w.type, isArchived: w.isArchived, balance: w.balance })),
    };
  }

  /** walletId không thuộc user => 404 */
  async assertWallet(userId: string, walletId?: string) {
    if (walletId) await this.wallets.findOwned(userId, walletId);
  }

  async summary(userId: string, q: WalletRangeQuery) {
    await this.assertWallet(userId, q.walletId);
    const range = resolveRange(q);
    const rows = await this.prisma.transaction.groupBy({
      by: ['type'],
      where: { userId, walletId: q.walletId, occurredAt: range },
      _sum: { amount: true },
      _count: true,
    });
    const get = (t: TxType) => rows.find((r) => r.type === t);
    const income = n(get('INCOME')?._sum.amount);
    const expense = n(get('EXPENSE')?._sum.amount);
    const bal = await this.balance(userId);
    return {
      income,
      expense,
      net: income - expense,
      incomeCount: get('INCOME')?._count ?? 0,
      expenseCount: get('EXPENSE')?._count ?? 0,
      /** Số dư hiện tại của ví được lọc, hoặc tổng nếu không lọc */
      balance: q.walletId ? bal.wallets.find((w) => w.id === q.walletId)!.balance : bal.balance,
    };
  }

  async byCategory(userId: string, range: { gte?: Date; lt?: Date }, type: TxType, walletId?: string) {
    const rows = await this.prisma.transaction.groupBy({
      by: ['categoryId'],
      where: { userId, walletId, type, occurredAt: range },
      _sum: { amount: true },
      _count: true,
    });
    const cats = await this.prisma.category.findMany({
      where: { id: { in: rows.map((r) => r.categoryId) } },
      select: { id: true, name: true, icon: true, color: true },
    });
    const total = rows.reduce((s, r) => s + n(r._sum.amount), 0);
    return rows
      .map((r) => ({
        category: cats.find((c) => c.id === r.categoryId)!,
        amount: n(r._sum.amount),
        count: r._count,
        percentage: pct(n(r._sum.amount), total),
      }))
      .sort((a, b) => b.amount - a.amount);
  }

  /** Tổng thu/chi theo từng ngày trong tháng (cho lịch / biểu đồ ngày). */
  async daily(userId: string, month: string, walletId?: string) {
    const { start, end } = monthRange(month);
    const walletFilter = walletId ? Prisma.sql`AND "walletId" = ${walletId}` : Prisma.empty;
    const rows = await this.prisma.$queryRaw<{ day: string; type: TxType; total: bigint }[]>`
      SELECT to_char(("occurredAt" AT TIME ZONE 'UTC') AT TIME ZONE ${APP_TZ}, 'YYYY-MM-DD') AS day,
             type, SUM(amount)::bigint AS total
      FROM "Transaction"
      WHERE "userId" = ${userId} AND "occurredAt" >= ${start} AND "occurredAt" < ${end} ${walletFilter}
      GROUP BY 1, 2 ORDER BY 1`;
    const days = new Map<string, { date: string; income: number; expense: number }>();
    for (const r of rows) {
      const d = days.get(r.day) ?? { date: r.day, income: 0, expense: 0 };
      d[r.type === 'INCOME' ? 'income' : 'expense'] += n(r.total);
      days.set(r.day, d);
    }
    return [...days.values()];
  }

  /** Thu/chi theo tháng, đủ `months` tháng liên tục kết thúc ở endMonth. userId = null => toàn hệ thống. */
  async monthlyTotals(userId: string | null, endMonth: string, months: number, walletId?: string): Promise<MonthTotal[]> {
    const firstMonth = shiftMonth(endMonth, -(months - 1));
    const start = monthRange(firstMonth).start;
    const end = monthRange(endMonth).end;
    const userFilter = userId ? Prisma.sql`AND "userId" = ${userId}` : Prisma.empty;
    const walletFilter = walletId ? Prisma.sql`AND "walletId" = ${walletId}` : Prisma.empty;
    const rows = await this.prisma.$queryRaw<{ month: string; type: TxType; total: bigint }[]>`
      SELECT to_char(("occurredAt" AT TIME ZONE 'UTC') AT TIME ZONE ${APP_TZ}, 'YYYY-MM') AS month,
             type, SUM(amount)::bigint AS total
      FROM "Transaction"
      WHERE "occurredAt" >= ${start} AND "occurredAt" < ${end} ${userFilter} ${walletFilter}
      GROUP BY 1, 2`;
    return Array.from({ length: months }, (_, i) => {
      const month = shiftMonth(firstMonth, i);
      const income = n(rows.find((r) => r.month === month && r.type === 'INCOME')?.total);
      const expense = n(rows.find((r) => r.month === month && r.type === 'EXPENSE')?.total);
      return { month, income, expense, net: income - expense };
    });
  }

  /** Báo cáo tháng: tổng, so sánh tháng trước, cơ cấu danh mục, giao dịch lớn/nhỏ nhất, dự báo tháng sau. */
  async report(userId: string, month: string, observationMonths: number, walletId?: string) {
    const range = monthRange(month);
    const occurredAt = { gte: range.start, lt: range.end };
    const history = await this.monthlyTotals(userId, month, Math.max(observationMonths, 2), walletId);
    const cur = history[history.length - 1];
    const prev = history[history.length - 2];

    const extreme = async (type: TxType, dir: 'asc' | 'desc', total: number) => {
      const tx = await this.prisma.transaction.findFirst({
        where: { userId, walletId, type, occurredAt },
        orderBy: [{ amount: dir }, { occurredAt: 'desc' }],
        include: { category: { select: { id: true, name: true, icon: true, color: true } } },
      });
      return tx ? { transaction: tx, percentage: pct(n(tx.amount), total) } : null;
    };

    const window = history.slice(-observationMonths);
    const [incomeByCategory, expenseByCategory, largestIncome, largestExpense, smallestIncome, smallestExpense] =
      await Promise.all([
        this.byCategory(userId, occurredAt, 'INCOME', walletId),
        this.byCategory(userId, occurredAt, 'EXPENSE', walletId),
        extreme('INCOME', 'desc', cur.income),
        extreme('EXPENSE', 'desc', cur.expense),
        extreme('INCOME', 'asc', cur.income),
        extreme('EXPENSE', 'asc', cur.expense),
      ]);

    return {
      month,
      walletId: walletId ?? null,
      income: cur.income,
      expense: cur.expense,
      net: cur.net,
      savingRate: pct(cur.net, cur.income),
      comparison: {
        previousMonth: prev.month,
        income: compare(cur.income, prev.income),
        expense: compare(cur.expense, prev.expense),
      },
      incomeByCategory,
      expenseByCategory,
      largestIncome,
      largestExpense,
      smallestIncome,
      smallestExpense,
      forecast: {
        month: shiftMonth(month, 1),
        income: forecast(window.map((m) => m.income)),
        expense: forecast(window.map((m) => m.expense)),
      },
      history: window,
    };
  }
}

/** Chênh lệch so với tháng trước; |thay đổi| <= 5% coi là ổn định. */
function compare(current: number, previous: number) {
  const difference = current - previous;
  const percentageChange = previous ? Math.round((difference / previous) * 1000) / 10 : null;
  const trend =
    percentageChange === null
      ? current > 0 ? 'increase' : 'stable'
      : percentageChange > 5 ? 'increase' : percentageChange < -5 ? 'decrease' : 'stable';
  return { current, previous, difference, percentageChange, trend };
}

/** Dự báo: trung bình có trọng số (tháng gần nặng hơn) nếu có >= 3 tháng, ngược lại trung bình cộng. */
function forecast(series: number[]) {
  const average = Math.round(series.reduce((s, v) => s + v, 0) / series.length);
  let predicted = average;
  if (series.length >= 3) {
    const weightSum = (series.length * (series.length + 1)) / 2;
    predicted = Math.round(series.reduce((s, v, i) => s + v * (i + 1), 0) / weightSum);
  }
  return {
    predicted,
    average,
    growthRate: average ? Math.round(((predicted - average) / average) * 1000) / 10 : 0,
    method: series.length >= 3 ? 'weighted_average' : 'simple_average',
  };
}

@ApiTags('stats')
@ApiBearerAuth()
@Controller('stats')
export class StatsController {
  constructor(private readonly stats: StatsService) {}

  /** Số dư tổng + từng ví + tổng thu/chi + tiền đang nằm trong mục tiêu tiết kiệm */
  @Get('balance')
  balance(@CurrentUser() u: AuthUser) {
    return this.stats.balance(u.id);
  }

  /** Tổng thu/chi trong khoảng (month hoặc from/to), lọc ví tùy chọn, kèm số dư */
  @Get('summary')
  summary(@CurrentUser() u: AuthUser, @Query() q: WalletRangeQuery) {
    return this.stats.summary(u.id, q);
  }

  @Get('by-category')
  async byCategory(@CurrentUser() u: AuthUser, @Query() q: ByCategoryQuery) {
    await this.stats.assertWallet(u.id, q.walletId);
    return this.stats.byCategory(u.id, resolveRange(q), q.type, q.walletId);
  }

  @Get('daily')
  async daily(@CurrentUser() u: AuthUser, @Query() q: MonthQuery) {
    await this.stats.assertWallet(u.id, q.walletId);
    return this.stats.daily(u.id, q.month ?? monthOf(new Date()), q.walletId);
  }

  @Get('trend')
  async trend(@CurrentUser() u: AuthUser, @Query() q: TrendQuery) {
    await this.stats.assertWallet(u.id, q.walletId);
    return this.stats.monthlyTotals(u.id, q.month ?? monthOf(new Date()), q.months, q.walletId);
  }

  @Get('report')
  async report(@CurrentUser() u: AuthUser, @Query() q: ReportQuery) {
    await this.stats.assertWallet(u.id, q.walletId);
    return this.stats.report(u.id, q.month ?? monthOf(new Date()), q.observationMonths, q.walletId);
  }
}

@Module({ imports: [WalletsModule], controllers: [StatsController], providers: [StatsService], exports: [StatsService] })
export class StatsModule {}
