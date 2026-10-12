/**
 * Provider giả cho eval: tính SkillContext từ fixture thô, theo đúng công thức backend
 * (stats.report, budgets.withProgress, savingGoals.withProgress). Đây cũng là bản tham chiếu cho Track C.
 * Mỗi fixture chỉ chứa dữ liệu của MỘT principal → không có đường nào lấy được dữ liệu người khác.
 */
import { readFileSync } from 'node:fs';
import type { SkillContext, UserActivityRow } from '../../lib/contracts.js';
import { ADMIN_PROVIDERS } from '../../lib/contracts.js';

// Kiểu nội bộ của fixture (bản đầy đủ như response API; makeContext rút về đúng shape provider của backend)
type CategoryAmount = { categoryName: string; amount: number; count: number; percentage: number };
type Compare = Record<string, any>;
type TxBrief = { title: string; amount: number; categoryName: string; walletName: string; date: string };
type MonthReportCtx = { month: string; income: number; expense: number; net: number; savingRate: number; comparison: any; expenseByCategory: CategoryAmount[]; incomeByCategory: CategoryAmount[]; largestExpense: TxBrief | null };
type PeriodSummaryCtx = { from: string; to: string; income: number; expense: number; net: number; incomeCount: number; expenseCount: number; expenseByCategory: CategoryAmount[] };
type BudgetLine = { categoryName: string | null; limitAmount: number; spent: number; remaining: number; percentage: number; status: 'ok' | 'warning' | 'exceeded' };
type BudgetsCtx = { month: string; thresholds: { warningPercent: number; exceededPercent: number }; overall: BudgetLine | null; items: BudgetLine[] };
type GoalCtx = { name: string; targetAmount: number; savedAmount: number; remaining: number; progress: number; daysLeft: number; dailyRequired: number; targetDate: string; status: 'ACTIVE' | 'COMPLETED' | 'WITHDRAWN' | 'EARLY_WITHDRAWN' };
type MonthCategoryCtx = { month: string; expense: number; expenseByCategory: CategoryAmount[] };
import { monthOf, shiftMonth } from '../../lib/period.js';

export interface UserFixture {
  now: string;
  principal: { userId: string; role: 'USER' | 'ADMIN'; displayName: string };
  wallets: { name: string; type: string; isArchived: boolean; balance: number }[];
  savings: number;
  categories: { name: string; type: 'INCOME' | 'EXPENSE' }[];
  transactions: { title: string; amount: number; type: 'INCOME' | 'EXPENSE'; categoryName: string; walletName: string; date: string }[];
  budgets: { month: string; categoryName: string | null; limitAmount: number }[];
  goals: { name: string; targetAmount: number; savedAmount: number; targetDate: string; status: GoalCtx['status'] }[];
  thresholds?: { warningPercent: number; exceededPercent: number };
}
export interface AdminFixture {
  now: string;
  principal: { userId: string; role: 'USER' | 'ADMIN'; displayName: string };
  overview: any;
  userActivity: UserActivityRow[];
  broadcasts: { title: string; body: string; recipients: number; readCount: number; createdAt: string }[];
  configHistory: { createdAt: string; actorName: string | null; section: string; key: string; oldValue: unknown; newValue: unknown; secret: boolean }[];
  publicConfig: { appName: string; supportEmail: string; hotline: string };
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

/**
 * SkillContext giống backend Track C (ai.context.ts): `data` = provider khai báo, `get(name, args)` = provider có tham số,
 * provider admin* chỉ khi role ADMIN (ngược lại ném lỗi như ForbiddenException). `trace` ghi mọi dữ liệu đã đưa cho skill.
 * `missing`: giả lập backend chưa có các provider MỚI (kiểm tra đường lùi).
 */
export function makeContext(fx: Fixture, declared: string[], opts: { missing?: string[]; asis?: boolean } = {}) {
  const trace: { name: string; args?: Record<string, unknown>; data: unknown }[] = [];
  const role = fx.principal.role;
  const fetch = (name: string, args: Record<string, unknown> = {}): unknown => {
    if (opts.missing?.includes(name)) throw new Error(`Không có context provider "${name}"`);
    if (ADMIN_PROVIDERS.includes(name as any) && role !== 'ADMIN') throw new Error(`Provider ${name} chỉ dành cho admin`);
    if (role === 'USER') {
      const f = fx as UserFixture;
      const month = (args.month as string) ?? monthOf(f.now);
      switch (name) {
        case 'balance': return { total: f.wallets.reduce((s, w) => s + w.balance, 0), savings: f.savings, wallets: f.wallets.filter((w) => !w.isArchived).map((w) => ({ name: w.name, balance: w.balance })) };
        case 'wallets': return f.wallets.filter((w) => !w.isArchived).map((w, i) => ({ id: `w${i}`, name: w.name, type: w.type, balance: w.balance }));
        case 'categories': return f.categories.map((c, i) => ({ id: `c${i}`, name: c.name, type: c.type }));
        case 'monthSummary': {
          const r = monthReport(f, month);
          const lim = opts.asis ? 5 : Math.min((args.limit as number) ?? 5, 50);
          return { month, income: r.income, expense: r.expense, net: r.net, topExpenses: r.expenseByCategory.slice(0, lim).map((c) => ({ name: c.categoryName, amount: c.amount })), largestExpense: opts.asis ? undefined : r.largestExpense ? { title: r.largestExpense.title, amount: r.largestExpense.amount, categoryName: r.largestExpense.categoryName, date: r.largestExpense.date } : null };
        }
        case 'periodSummary': {
          const r = periodSummary(f, args.from as string, args.to as string);
          return { from: r.from, to: r.to, income: r.income, expense: r.expense, net: r.net, incomeCount: r.incomeCount, expenseCount: r.expenseCount, topExpenses: r.expenseByCategory.slice(0, 5).map((c) => ({ name: c.categoryName, amount: c.amount })) };
        }
        case 'budgets': {
          const b = budgets(f, month);
          const v = (x: BudgetLine) => ({ categoryName: x.categoryName, limit: x.limitAmount, spent: x.spent, percentage: x.percentage, status: x.status });
          return { month: b.month, overall: b.overall ? v(b.overall) : null, items: b.items.map(v) };
        }
        case 'savingGoals': return goals(f).map((g) => ({ name: g.name, target: g.targetAmount, saved: g.savedAmount, progress: g.progress, status: g.status, targetDate: g.targetDate, dailyRequired: g.dailyRequired }));
      }
    } else {
      const f = fx as AdminFixture;
      const limit = (args.limit as number) ?? 10;
      switch (name) {
        case 'adminOverview': return f.overview;
        case 'adminUserActivity': return f.userActivity;
        case 'adminBroadcasts': return f.broadcasts.slice(0, limit);
        case 'adminConfigHistory': return f.configHistory.slice(0, limit).map((c: any) => ({ createdAt: c.createdAt, section: c.section, key: c.key, secret: c.secret, oldValue: c.oldValue, newValue: c.newValue, actor: c.actorName ? { id: 'x', name: c.actorName, email: '' } : null }));
        case 'publicConfig': return { appName: f.publicConfig.appName, supportEmail: f.publicConfig.supportEmail, hotline: f.publicConfig.hotline };
        case 'adminUsersSearch': {
          const q = String(args.q ?? '').toLowerCase();
          const items = f.userActivity.filter((u) => u.email.toLowerCase().includes(q) || u.name.toLowerCase().includes(q)).map((u) => ({ id: u.id, email: u.email, name: u.name, role: u.role, status: u.status }));
          return { total: items.length, items: items.slice(0, limit) };
        }
        case 'adminAnomalies': return { since: f.now, lockedUsers: f.overview.users.locked, mostActive24h: [] };
      }
    }
    throw new Error(`Không có context provider "${name}"`);
  };
  const get = async <T,>(name: string, args?: Record<string, unknown>) => { const d = fetch(name, args); trace.push({ name, args, data: d }); return d as T; };
  const data: Record<string, unknown> = {};
  for (const n of declared) { try { data[n] = fetch(n); trace.push({ name: n, data: data[n] }); } catch { /* như backend: bỏ provider không dùng được */ } }
  const p = fx.principal as any;
  const ctx: SkillContext = { principal: { id: p.userId, name: p.displayName, role: p.role }, now: fx.now, history: [], data, get };
  return { ctx, trace };
}
