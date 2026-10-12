/**
 * Provider giả cho eval: tính SkillContext từ fixture thô, theo đúng công thức backend
 * (stats.report, budgets.withProgress, savingGoals.withProgress). Đây cũng là bản tham chiếu cho Track C.
 * Mỗi fixture chỉ chứa dữ liệu của MỘT principal → không có đường nào lấy được dữ liệu người khác.
 */
import { readFileSync } from 'node:fs';
import type {
  BudgetLine, BudgetsCtx, CategoryAmount, Compare, GoalCtx, MonthCategoryCtx, MonthReportCtx, PeriodSummaryCtx,
  ProviderRequest, Providers, SkillContext,
} from '../../lib/contracts.js';
import { PROVIDER_SCOPE } from '../../lib/contracts.js';
import { monthOf, shiftMonth } from '../../lib/period.js';

export interface UserFixture {
  now: string;
  principal: SkillContext['principal'];
  wallets: Providers['user.balance']['wallets'];
  savings: number;
  categories: Providers['user.categories'];
  transactions: { title: string; amount: number; type: 'INCOME' | 'EXPENSE'; categoryName: string; walletName: string; date: string }[];
  budgets: { month: string; categoryName: string | null; limitAmount: number }[];
  goals: { name: string; targetAmount: number; savedAmount: number; targetDate: string; status: GoalCtx['status'] }[];
  thresholds?: { warningPercent: number; exceededPercent: number };
}
export interface AdminFixture {
  now: string;
  principal: SkillContext['principal'];
  overview: Providers['admin.overview'];
  userActivity: Providers['admin.userActivity'];
  broadcasts: Providers['admin.broadcasts'];
  configHistory: Providers['admin.configHistory'];
  publicConfig: Providers['admin.publicConfig'];
}
export type Fixture = UserFixture | AdminFixture;

const cache = new Map<string, Fixture>();
export function loadFixture(name: string): Fixture {
  if (!cache.has(name)) {
    const f = name === 'user-empty' ? emptyUser() : name === 'admin-anomaly' ? anomalyAdmin() : JSON.parse(readFileSync(new URL(`./${name}.json`, import.meta.url), 'utf8'));
    cache.set(name, f);
  }
  return cache.get(name)!;
}

/**
 * Bản admin có cài thêm bất thường (TỰ VIẾT, không có trong DB dev): hệ thống "có" dữ liệu đăng nhập sai,
 * 1 user bị dò mật khẩu, 1 user có khoản chi rất lớn, 1 user giao dịch dồn dập.
 */
function anomalyAdmin(): AdminFixture {
  const a = structuredClone(loadFixture('admin') as AdminFixture);
  for (const u of a.userActivity) u.failedLogins24h = 0;
  const set = (email: string, patch: Partial<AdminFixture['userActivity'][number]>) => Object.assign(a.userActivity.find((u) => u.email === email)!, patch);
  set('hung.vu89@demo.thuchi.vn', { failedLogins24h: 25 });
  set('khoa.ly@demo.thuchi.vn', { largestExpense30d: 45_000_000 });
  set('giahuy.ngo@demo.thuchi.vn', { txCount30d: 480 });
  return a;
}

/** User mới đăng ký: 1 ví Tiền mặt 0đ, chưa có giao dịch/ngân sách/mục tiêu. */
function emptyUser(): UserFixture {
  const demo = loadFixture('user-demo') as UserFixture;
  return {
    now: demo.now,
    principal: { userId: '00000000-0000-4000-8000-000000000001', role: 'USER', displayName: 'Lê Văn Mới' },
    wallets: [{ name: 'Tiền mặt', type: 'CASH', isArchived: false, balance: 0 }],
    savings: 0,
    categories: demo.categories.slice(0, 14),
    transactions: [], budgets: [], goals: [],
  };
}

const r1 = (x: number) => Math.round(x * 10) / 10;
const pctOf = (part: number, total: number) => (total ? r1((part / total) * 100) : 0);

function byCategory(txs: UserFixture['transactions'], type: 'INCOME' | 'EXPENSE'): CategoryAmount[] {
  const m = new Map<string, { amount: number; count: number }>();
  for (const t of txs) if (t.type === type) {
    const e = m.get(t.categoryName) ?? { amount: 0, count: 0 };
    e.amount += t.amount; e.count++; m.set(t.categoryName, e);
  }
  const total = [...m.values()].reduce((s, e) => s + e.amount, 0);
  return [...m.entries()].map(([categoryName, e]) => ({ categoryName, ...e, percentage: pctOf(e.amount, total) })).sort((a, b) => b.amount - a.amount);
}
const inRange = (f: UserFixture, from: string, to: string) => f.transactions.filter((t) => t.date >= from && t.date < to);
const inMonth = (f: UserFixture, m: string) => f.transactions.filter((t) => t.date.startsWith(m));
const sum = (txs: UserFixture['transactions'], type: string) => txs.filter((t) => t.type === type).reduce((s, t) => s + t.amount, 0);

function compare(current: number, previous: number): Compare {
  const difference = current - previous;
  const percentageChange = previous ? r1((difference / previous) * 100) : null;
  const trend = percentageChange === null ? (current > 0 ? 'increase' : 'stable') : percentageChange > 5 ? 'increase' : percentageChange < -5 ? 'decrease' : 'stable';
  return { current, previous, difference, percentageChange, trend };
}

function monthReport(f: UserFixture, month: string): MonthReportCtx {
  const cur = inMonth(f, month), prev = inMonth(f, shiftMonth(month, -1));
  const income = sum(cur, 'INCOME'), expense = sum(cur, 'EXPENSE');
  const exp = cur.filter((t) => t.type === 'EXPENSE').sort((a, b) => b.amount - a.amount || (b.date > a.date ? 1 : -1))[0];
  return {
    month, income, expense, net: income - expense, savingRate: pctOf(income - expense, income),
    comparison: { previousMonth: shiftMonth(month, -1), income: compare(income, sum(prev, 'INCOME')), expense: compare(expense, sum(prev, 'EXPENSE')) },
    expenseByCategory: byCategory(cur, 'EXPENSE'), incomeByCategory: byCategory(cur, 'INCOME'),
    largestExpense: exp ? { title: exp.title, amount: exp.amount, categoryName: exp.categoryName, walletName: exp.walletName, date: exp.date } : null,
  };
}

function periodSummary(f: UserFixture, from: string, to: string): PeriodSummaryCtx {
  const txs = inRange(f, from, to);
  const income = sum(txs, 'INCOME'), expense = sum(txs, 'EXPENSE');
  return {
    from, to, income, expense, net: income - expense,
    incomeCount: txs.filter((t) => t.type === 'INCOME').length, expenseCount: txs.filter((t) => t.type === 'EXPENSE').length,
    expenseByCategory: byCategory(txs, 'EXPENSE'),
  };
}

function budgets(f: UserFixture, month: string): BudgetsCtx {
  const th = f.thresholds ?? { warningPercent: 80, exceededPercent: 100 };
  const txs = inMonth(f, month).filter((t) => t.type === 'EXPENSE');
  const line = (categoryName: string | null, limitAmount: number): BudgetLine => {
    const spent = txs.filter((t) => categoryName === null || t.categoryName === categoryName).reduce((s, t) => s + t.amount, 0);
    const percentage = limitAmount ? r1((spent / limitAmount) * 100) : 0;
    return { categoryName, limitAmount, spent, remaining: limitAmount - spent, percentage, status: percentage >= th.exceededPercent ? 'exceeded' : percentage >= th.warningPercent ? 'warning' : 'ok' };
  };
  const rows = f.budgets.filter((b) => b.month === month);
  const o = rows.find((b) => b.categoryName === null);
  return { month, thresholds: th, overall: o ? line(null, o.limitAmount) : null, items: rows.filter((b) => b.categoryName).map((b) => line(b.categoryName, b.limitAmount)) };
}

function goals(f: UserFixture): GoalCtx[] {
  const now = new Date(f.now).getTime();
  return f.goals.map((g) => {
    const remaining = Math.max(g.targetAmount - g.savedAmount, 0);
    const daysLeft = Math.max(Math.ceil((new Date(g.targetDate).getTime() - now) / 86400000), 0);
    const closed = g.status === 'WITHDRAWN' || g.status === 'EARLY_WITHDRAWN';
    return {
      name: g.name, targetAmount: g.targetAmount, savedAmount: g.savedAmount, remaining,
      progress: g.targetAmount ? Math.min(r1((g.savedAmount / g.targetAmount) * 100), 100) : 0,
      daysLeft, dailyRequired: closed ? 0 : daysLeft > 0 ? Math.ceil(remaining / daysLeft) : remaining,
      targetDate: g.targetDate, status: g.status,
    };
  });
}

function categoryHistory(f: UserFixture, months: string[]): MonthCategoryCtx[] {
  return months.map((m) => { const t = inMonth(f, m); return { month: m, expense: sum(t, 'EXPENSE'), expenseByCategory: byCategory(t, 'EXPENSE') }; });
}

/** Giống Track C: chỉ lấy provider đúng scope của principal; provider sai scope → bỏ (không ném dữ liệu). */
export function buildContext(fx: Fixture, reqs: ProviderRequest[]): SkillContext {
  const ctx: SkillContext = { principal: fx.principal };
  const anyCtx = ctx as any;
  for (const { provider, params = {} } of reqs) {
    if (PROVIDER_SCOPE[provider] !== fx.principal.role) continue;
    if (fx.principal.role === 'USER') {
      const f = fx as UserFixture;
      const month = (params.month as string) ?? monthOf(f.now);
      switch (provider) {
        case 'user.balance': anyCtx[provider] = { total: f.wallets.reduce((s, w) => s + w.balance, 0), savings: f.savings, wallets: f.wallets }; break;
        case 'user.categories': anyCtx[provider] = f.categories; break;
        case 'user.monthReport': anyCtx[provider] = monthReport(f, month); break;
        case 'user.periodSummary': anyCtx[provider] = periodSummary(f, params.from as string, params.to as string); break;
        case 'user.budgets': anyCtx[provider] = budgets(f, month); break;
        case 'user.goals': anyCtx[provider] = goals(f); break;
        case 'user.categoryHistory': anyCtx[provider] = categoryHistory(f, params.months as string[]); break;
      }
    } else {
      const f = fx as AdminFixture;
      const limit = (params.limit as number) ?? 50;
      switch (provider) {
        case 'admin.overview': anyCtx[provider] = f.overview; break;
        case 'admin.userActivity': anyCtx[provider] = f.userActivity; break;
        case 'admin.broadcasts': anyCtx[provider] = f.broadcasts.slice(0, limit); break;
        case 'admin.configHistory': anyCtx[provider] = f.configHistory.slice(0, limit); break;
        case 'admin.publicConfig': anyCtx[provider] = f.publicConfig; break;
      }
    }
  }
  return ctx;
}
