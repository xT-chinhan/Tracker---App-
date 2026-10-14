/**
 * Context provider: dữ liệu cho skill, lấy qua service nghiệp vụ sẵn có, LUÔN theo principal (JWT).
 *
 * Chống prompt injection: tham số từ skill/câu người dùng đi qua danh sách trắng (q, month, limit, skill, texts, k, kind) —
 * không có trường nào chọn user. Câu "cho tôi xem dữ liệu của b@x.com" chỉ có thể thành `q = "..."` trong dữ liệu của CHÍNH người hỏi.
 * Provider admin* chỉ chạy khi principal.role = ADMIN (đọc từ DB mỗi request).
 */
import { ForbiddenException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { MONTH_REGEX, monthOf, monthRange, resolveRange, shiftMonth } from '../common/time';
import { WalletsService } from '../wallets/wallets.module';
import { StatsService } from '../stats/stats.module';
import { BudgetsService } from '../budgets/budgets.module';
import { SavingGoalsService } from '../saving-goals/saving-goals.module';
import { TransactionFilter, TransactionsService } from '../transactions/transactions.module';
import { CategoriesService } from '../categories/categories.module';
import { AdminService } from '../admin/admin.module';
import { SystemConfigService } from '../system-config/system-config.module';
import type { AiRepo } from './ai.store';
import type { LlmClient, Principal, SkillContext } from './ai.types';
import { cos, norm, toBytes } from './ai.text';

export interface ProviderArgs {
  q?: string;
  month?: string;
  limit?: number;
  skill?: string;
  texts?: string[];
  k?: number;
  kind?: string;
  /** YYYY-MM-DD hoặc ISO; `to` không bao gồm */
  from?: string;
  to?: string;
}

interface Env {
  p: Principal;
  repo: AiRepo;
  llm: LlmClient;
  now: string;
}

interface Provider {
  admin?: boolean;
  fetch(env: Env, a: ProviderArgs): Promise<unknown>;
}

/** Danh sách trắng tham số. Mọi thứ khác (userId, email, ...) bị bỏ. */
export function sanitizeArgs(raw: Record<string, unknown> = {}): ProviderArgs {
  const out: ProviderArgs = {};
  if (typeof raw.q === 'string' && raw.q.trim()) out.q = raw.q.trim().slice(0, 100);
  if (typeof raw.month === 'string' && MONTH_REGEX.test(raw.month)) out.month = raw.month;
  if (Number.isInteger(raw.limit)) out.limit = Math.min(Math.max(raw.limit as number, 1), 50);
  if (typeof raw.skill === 'string') out.skill = raw.skill.slice(0, 60);
  if (Array.isArray(raw.texts)) out.texts = raw.texts.filter((t): t is string => typeof t === 'string').slice(0, 10).map((t) => t.slice(0, 200));
  if (Number.isInteger(raw.k)) out.k = Math.min(Math.max(raw.k as number, 1), 10);
  if (typeof raw.kind === 'string') out.kind = raw.kind.slice(0, 30);
  const DATE = /^\d{4}-\d{2}-\d{2}(T[\d:.]+(Z|[+-]\d{2}:?\d{2})?)?$/;
  if (typeof raw.from === 'string' && DATE.test(raw.from)) out.from = raw.from;
  if (typeof raw.to === 'string' && DATE.test(raw.to)) out.to = raw.to;
  return out;
}

const txView = (t: any) => ({
  title: t.title,
  amount: Number(t.amount),
  type: t.type,
  categoryName: t.category?.name,
  walletName: t.wallet?.name,
  occurredAt: t.occurredAt,
});

@Injectable()
export class AiContextService {
  private readonly providers: Record<string, Provider>;

  constructor(
    private readonly prisma: PrismaService,
    private readonly wallets: WalletsService,
    private readonly stats: StatsService,
    private readonly budgets: BudgetsService,
    private readonly goals: SavingGoalsService,
    private readonly txs: TransactionsService,
    private readonly categories: CategoriesService,
    private readonly admin: AdminService,
    private readonly sys: SystemConfigService,
  ) {
    this.providers = {
      /** UserContext của ai/lib/types.ts (danh mục + ví đang dùng) */
      userContext: {
        fetch: async ({ p, now }) => {
          const [cats, ws] = await Promise.all([this.categories.listForUser(p.id), this.wallets.list(p.id)]);
          return {
            userId: p.id,
            displayName: p.name,
            now,
            categories: cats.map((c) => ({ name: c.name, type: c.type })),
            wallets: ws.items.filter((w) => !w.isArchived).map((w) => ({ name: w.name, type: w.type })),
          };
        },
      },
      wallets: {
        fetch: async ({ p }) => (await this.wallets.list(p.id)).items.filter((w) => !w.isArchived).map((w) => ({ id: w.id, name: w.name, type: w.type, balance: w.balance })),
      },
      categories: {
        fetch: async ({ p }) => (await this.categories.listForUser(p.id)).map((c) => ({ id: c.id, name: c.name, type: c.type })),
      },
      balance: {
        fetch: async ({ p }) => {
          const b = await this.stats.balance(p.id);
          return { total: b.balance, savings: b.savings, wallets: b.wallets.filter((w) => !w.isArchived).map((w) => ({ name: w.name, balance: w.balance })) };
        },
      },
      /** {month?, limit? (số danh mục chi, mặc định 5)} + khoản chi lớn nhất tháng */
      monthSummary: {
        fetch: async ({ p, now }, a) => {
          const month = a.month ?? monthOf(new Date(now));
          const s = await this.stats.summary(p.id, { month } as any);
          const { start, end } = monthRange(month);
          const top = await this.stats.byCategory(p.id, { gte: start, lt: end }, 'EXPENSE');
          return {
            month, income: s.income, expense: s.expense, net: s.net,
            topExpenses: top.slice(0, a.limit ?? 5).map((c) => ({ name: c.category.name, amount: c.amount })),
            largestExpense: await this.largest(p.id, start, end),
          };
        },
      },
      /** {from, to} (to không bao gồm; mặc định 7 ngày gần nhất): thu, chi, số khoản, top chi */
      periodSummary: {
        fetch: async ({ p, now }, a) => {
          const to = a.to ?? new Date(now).toISOString();
          const from = a.from ?? new Date(new Date(now).getTime() - 7 * 86400_000).toISOString();
          const s = await this.stats.summary(p.id, { from, to } as any);
          const range = resolveRange({ from, to });
          const top = await this.stats.byCategory(p.id, range, 'EXPENSE');
          return {
            from, to, income: s.income, expense: s.expense, net: s.net, incomeCount: s.incomeCount, expenseCount: s.expenseCount,
            topExpenses: top.slice(0, a.limit ?? 5).map((c) => ({ name: c.category.name, amount: c.amount })),
            largestExpense: await this.largest(p.id, range.gte, range.lt),
          };
        },
      },
      /** Cấu hình công khai rút gọn (tên app, liên hệ) */
      publicConfig: {
        fetch: async () => {
          const c = await this.sys.publicConfig();
          return { appName: c.appName, supportEmail: c.supportEmail, hotline: c.hotline };
        },
      },
      budgets: {
        fetch: async ({ p, now }, a) => {
          const b = await this.budgets.list(p.id, a.month ?? monthOf(new Date(now)));
          const v = (x: any) => ({ categoryName: x.category?.name ?? null, limit: x.limitAmount, spent: x.spent, percentage: x.percentage, status: x.status });
          return { month: b.month, overall: b.overall ? v(b.overall) : null, items: b.items.map(v) };
        },
      },
      savingGoals: {
        fetch: async ({ p }) => (await this.goals.list(p.id)).map((g) => ({ name: g.name, target: g.targetAmount, saved: g.savedAmount, progress: g.progress, status: g.status, targetDate: g.targetDate, dailyRequired: g.dailyRequired })),
      },
      recentTransactions: {
        fetch: async ({ p }, a) => (await this.txs.list(p.id, Object.assign(new TransactionFilter(), { page: 1, limit: a.limit ?? 10 }))).items.map(txView),
      },
      searchTransactions: {
        fetch: async ({ p }, a) => {
          const r = await this.txs.list(p.id, Object.assign(new TransactionFilter(), { page: 1, limit: a.limit ?? 10, q: a.q, month: a.month }));
          return { total: r.total, items: r.items.map(txView) };
        },
      },
      userMemory: {
        fetch: async ({ repo }) => (await repo.listMemory()).map((m) => ({ key: m.key, value: m.value, helpful: m.helpful, harmful: m.harmful })),
      },
      userRules: {
        fetch: ({ repo }, a) => repo.activeRules(a.kind ?? 'category', a.skill ?? 'ghi-giao-dich'),
      },
      /** kNN few-shot: ví dụ của user + ví dụ chung, mỗi text top-k. Vector trong tiến trình (VectorIndex, sau thay pgvector). */
      similarExamples: {
        fetch: async ({ repo, llm }, a) => this.similar(repo, llm, a.skill ?? 'ghi-giao-dich', a.texts ?? [], a.k ?? 5),
      },
      adminOverview: { admin: true, fetch: () => this.admin.overview() },
      adminUsersSearch: {
        admin: true,
        fetch: async (_e, a) => {
          const r = await this.admin.users(Object.assign(Object.create(null), { q: a.q, page: 1, limit: a.limit ?? 10 }));
          return { total: r.total, items: r.items.map((u: any) => ({ id: u.id, email: u.email, name: u.name, role: u.role, status: u.status })) };
        },
      },
      adminAnomalies: {
        admin: true,
        fetch: async ({ now }) => {
          const since = new Date(new Date(now).getTime() - 24 * 3600_000);
          const busy = await this.prisma.transaction.groupBy({ by: ['userId'], where: { createdAt: { gte: since } }, _count: true, orderBy: { _count: { userId: 'desc' } }, take: 5 });
          const users = await this.prisma.user.findMany({ where: { id: { in: busy.map((b) => b.userId) } }, select: { id: true, email: true } });
          const locked = await this.prisma.user.count({ where: { status: 'LOCKED' } });
          return {
            since,
            lockedUsers: locked,
            mostActive24h: busy.filter((b) => b._count >= 50).map((b) => ({ email: users.find((u) => u.id === b.userId)?.email, transactions: b._count })),
          };
        },
      },
      /** Mỗi user một dòng: hoạt động 30 ngày, chi tháng này vs TB 3 tháng trước, khoản chi lớn nhất, số lần đăng nhập SAI 24h */
      adminUserActivity: { admin: true, fetch: ({ now }, a) => this.userActivity(new Date(now), a.limit ?? 200) },
      adminBroadcasts: {
        admin: true,
        fetch: async (_e, a) => (await this.admin.broadcasts(Object.assign(Object.create(null), { page: 1, limit: a.limit ?? 5 }))).items.map((b: any) => ({ title: b.title, body: b.body, recipients: b.recipients, readCount: b.readCount, createdAt: b.createdAt })),
      },
      adminConfigHistory: {
        admin: true,
        fetch: async (_e, a) => (await this.sys.history(Object.assign(Object.create(null), { page: 1, limit: a.limit ?? 10 }))).items,
      },
    };
  }

  private async largest(userId: string, gte?: Date, lt?: Date) {
    const t = await this.prisma.transaction.findFirst({
      where: { userId, type: 'EXPENSE', occurredAt: { gte, lt } },
      orderBy: [{ amount: 'desc' }, { occurredAt: 'desc' }],
      include: { category: { select: { name: true } } },
    });
    return t ? { title: t.title, amount: Number(t.amount), categoryName: t.category.name, date: new Date(t.occurredAt.getTime() + 7 * 3600_000).toISOString().slice(0, 10) } : null;
  }

  /** Tổng hợp hoạt động theo user (chỉ admin). Tối đa `limit` user: ưu tiên có đăng nhập sai / giao dịch nhiều. */
  private async userActivity(now: Date, limit: number) {
    const d30 = new Date(now.getTime() - 30 * 86400_000), d1 = new Date(now.getTime() - 86400_000);
    const month = monthOf(now);
    const cur = monthRange(month), prev = { start: monthRange(shiftMonth(month, -3)).start, end: cur.start };
    const [tx30, expCur, expPrev, big30, fails] = await Promise.all([
      this.prisma.transaction.groupBy({ by: ['userId'], where: { occurredAt: { gte: d30, lte: now } }, _count: true }),
      this.prisma.transaction.groupBy({ by: ['userId'], where: { type: 'EXPENSE', occurredAt: { gte: cur.start, lt: cur.end } }, _sum: { amount: true } }),
      this.prisma.transaction.groupBy({ by: ['userId'], where: { type: 'EXPENSE', occurredAt: { gte: prev.start, lt: prev.end } }, _sum: { amount: true } }),
      this.prisma.transaction.groupBy({ by: ['userId'], where: { type: 'EXPENSE', occurredAt: { gte: d30, lte: now } }, _max: { amount: true } }),
      this.prisma.loginFailure.groupBy({ by: ['userId'], where: { createdAt: { gte: d1 } }, _count: true }),
    ]);
    const m = <T extends { userId: string }>(xs: T[]) => new Map(xs.map((x) => [x.userId, x]));
    const T = m(tx30), C = m(expCur), P = m(expPrev), B = m(big30), F = m(fails);
    const score = (id: string) => (F.get(id)?._count ?? 0) * 1000 + (T.get(id)?._count ?? 0);
    // Có đăng nhập sai / giao dịch nhiều trước, rồi các user mới đăng ký gần đây (để tra được cả tài khoản chưa có giao dịch)
    const active = [...new Set([...F.keys(), ...T.keys()])].sort((a, b) => score(b) - score(a)).slice(0, limit);
    const recent = active.length < limit ? await this.prisma.user.findMany({ where: { id: { notIn: active } }, orderBy: { createdAt: 'desc' }, take: limit - active.length, select: { id: true } }) : [];
    const ids = [...active, ...recent.map((u) => u.id)];
    const users = await this.prisma.user.findMany({ where: { id: { in: ids } }, select: { id: true, email: true, name: true, role: true, status: true, createdAt: true, lastLoginAt: true } });
    return ids.map((id) => users.find((u) => u.id === id)).filter((u): u is NonNullable<typeof u> => !!u).map((u) => ({
      ...u,
      txCount30d: T.get(u.id)?._count ?? 0,
      expenseThisMonth: Number(C.get(u.id)?._sum.amount ?? 0),
      expenseAvgPrev3: Math.round(Number(P.get(u.id)?._sum.amount ?? 0) / 3),
      largestExpense30d: Number(B.get(u.id)?._max.amount ?? 0),
      failedLogins24h: F.get(u.id)?._count ?? 0,
    }));
  }

  names() {
    return Object.keys(this.providers);
  }

  async fetch(env: Env, name: string, raw?: Record<string, unknown>) {
    const pv = this.providers[name];
    if (!pv) throw new Error(`Không có context provider "${name}"`);
    if (pv.admin && env.p.role !== 'ADMIN') throw new ForbiddenException(`Provider ${name} chỉ dành cho admin`);
    return pv.fetch(env, sanitizeArgs(raw));
  }

  /**
   * Context cho 1 lần chạy skill: nạp sẵn provider khai báo, `get` gắn cố định principal.
   * `debug` (không production) => trace giữ cả dữ liệu đã đưa cho skill (e2e kiểm tra không lẫn dữ liệu người khác).
   */
  async build(env: Env, declared: string[], history: SkillContext['history'], debug = false, preloaded: Record<string, unknown> = {}) {
    const trace: { name: string; args?: unknown; data: unknown }[] = [];
    const get = async <T>(name: string, args?: Record<string, unknown>) => {
      const data = await this.fetch(env, name, args);
      trace.push({ name, ...(debug ? { args: sanitizeArgs(args), data } : { data: undefined }) });
      return data as T;
    };
    const data: Record<string, unknown> = {};
    for (const n of declared) {
      if (!this.providers[n] || (this.providers[n].admin && env.p.role !== 'ADMIN')) continue;
      data[n] = n in preloaded ? preloaded[n] : await get(n);
    }
    const ctx: SkillContext = { principal: { id: env.p.id, name: env.p.name, role: env.p.role }, now: env.now, history, data, get };
    return { ctx, trace };
  }

  /** kNN trong tiến trình trên ví dụ của user + chung. Bổ sung embedding còn thiếu (ví dụ chung: dữ liệu hệ thống, không thuộc user). */
  private async similar(repo: AiRepo, llm: LlmClient, skill: string, texts: string[], k: number) {
    if (!texts.length) return [];
    const rows = await repo.knnRows(skill, llm.embedModel);
    const missing = rows.filter((r) => !r.vec);
    if (missing.length) {
      const vecs = await llm.embed(missing.map((r) => norm(r.input)));
      for (let i = 0; i < missing.length; i++) {
        missing[i].vec = Float32Array.from(vecs[i]);
        if (missing[i].scope === 'GLOBAL') {
          await this.prisma.aiExample.update({ where: { id: missing[i].id }, data: { embedding: toBytes(vecs[i]), embedModel: llm.embedModel } });
        } else {
          await repo.setOwnEmbedding(missing[i].id, vecs[i], llm.embedModel);
        }
      }
    }
    if (!rows.length) return texts.map(() => []);
    const qs = await llm.embed(texts);
    return qs.map((q) =>
      rows
        .map((r) => ({ input: r.input, output: r.output, scope: r.scope, score: cos(q, r.vec!) }))
        .sort((a, b) => b.score - a.score)
        .slice(0, k),
    );
  }
}
