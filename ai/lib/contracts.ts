/**
 * Hợp đồng chung giữa skill (ai/skills/<tên>/index.ts) và backend (Track C).
 *
 * Luồng: router chọn skill (lọc theo scope của phiên) → `skill.plan(input, now)` trả danh sách provider cần
 * → backend lấy dữ liệu qua provider, LUÔN theo userId/role trong JWT (USER chỉ dữ liệu của chính mình)
 * → `skill.run({ input, context, llm, now })` (hàm thuần, không đụng DB, không gọi mạng ngoài `llm`)
 * → trả `SkillResult`. Bản nháp (`draft`) không bao giờ tự thực thi: người dùng/admin xác nhận rồi backend mới chạy.
 *
 * Mọi số tiền là number (VND). Ngày: 'YYYY-MM-DD' theo giờ VN; tháng: 'YYYY-MM'; mốc thời gian: ISO có offset.
 * Các kiểu dưới đây là bản rút gọn của response API hiện có (ghi ở từng provider); backend map 1-1, không tính lại.
 */
import type { ChatMsg } from './ollama.js';

export type Scope = 'USER' | 'ADMIN';
export type TxType = 'INCOME' | 'EXPENSE';

/** Chủ thể của phiên. USER chỉ thấy dữ liệu của userId này; ADMIN thấy dữ liệu hệ thống qua provider admin.*. */
export interface Principal { userId: string; role: Scope; displayName: string }

// ───────────────────────── provider USER (lọc theo principal.userId) ─────────────────────────

/** GET /stats/balance → wallets[].{name,type,balance,isArchived}, total = balance */
export interface WalletBalance { name: string; type: 'CASH' | 'BANK' | 'EWALLET'; balance: number; isArchived: boolean }
export interface BalanceCtx { total: number; savings: number; wallets: WalletBalance[] }

/** GET /categories (hệ thống ∪ của user, chưa lưu trữ) */
export interface CategoryCtx { name: string; type: TxType }

export interface CategoryAmount { categoryName: string; amount: number; count: number; percentage: number }
export interface TxBrief { title: string; amount: number; categoryName: string; walletName: string; date: string }
export interface Compare { current: number; previous: number; difference: number; percentageChange: number | null; trend: 'increase' | 'decrease' | 'stable' }

/** GET /stats/report?month= (expenseByCategory/incomeByCategory: category.name → categoryName; largest*: transaction rút gọn) */
export interface MonthReportCtx {
  month: string;
  income: number; expense: number; net: number; savingRate: number;
  comparison: { previousMonth: string; income: Compare; expense: Compare };
  expenseByCategory: CategoryAmount[];
  incomeByCategory: CategoryAmount[];
  largestExpense: TxBrief | null;
}

/** GET /stats/summary?from=&to= + GET /stats/by-category?from=&to=&type=EXPENSE. `to` không bao gồm. */
export interface PeriodSummaryCtx {
  from: string; to: string;
  income: number; expense: number; net: number; incomeCount: number; expenseCount: number;
  expenseByCategory: CategoryAmount[];
}

/** GET /budgets?month= (category.name → categoryName; overall có categoryName = null) */
export interface BudgetLine { categoryName: string | null; limitAmount: number; spent: number; remaining: number; percentage: number; status: 'ok' | 'warning' | 'exceeded' }
export interface BudgetsCtx { month: string; thresholds: { warningPercent: number; exceededPercent: number }; overall: BudgetLine | null; items: BudgetLine[] }

/** GET /saving-goals (đủ trường withProgress) */
export interface GoalCtx {
  name: string; targetAmount: number; savedAmount: number; remaining: number; progress: number;
  daysLeft: number; dailyRequired: number; targetDate: string;
  status: 'ACTIVE' | 'COMPLETED' | 'WITHDRAWN' | 'EARLY_WITHDRAWN';
}

/** Chi theo danh mục của từng tháng (GET /stats/by-category?month=&type=EXPENSE lặp theo tháng). */
export interface MonthCategoryCtx { month: string; expense: number; expenseByCategory: CategoryAmount[] }

// ───────────────────────── provider ADMIN (chỉ khi role = ADMIN) ─────────────────────────

/** GET /admin/overview */
export interface OverviewCtx {
  users: { total: number; active: number; locked: number; new30d: number };
  transactions: { total: number; new30d: number; totalIncome: number; totalExpense: number };
  savingGoals: Record<string, number>;
  trend: { month: string; income: number; expense: number; net: number }[];
}

/**
 * Hoạt động theo user cho phát hiện bất thường / đề xuất khóa. MỚI — backend cần thêm truy vấn tổng hợp
 * (User + Transaction). `failedLogins24h` chỉ điền khi hệ thống có ghi nhận (hiện chưa có → bỏ trống).
 */
export interface UserActivity {
  id: string; email: string; name: string; role: Scope; status: 'ACTIVE' | 'LOCKED';
  createdAt: string; lastLoginAt: string | null;
  txCount30d: number;             // số giao dịch phát sinh (occurredAt) trong 30 ngày
  expenseThisMonth: number;       // tổng chi tháng hiện tại
  expenseAvgPrev3: number;        // trung bình chi 3 tháng liền trước
  largestExpense30d: number;      // khoản chi lớn nhất trong 30 ngày
  failedLogins24h?: number;
}

/** GET /admin/broadcasts */
export interface BroadcastCtx { title: string; body: string; recipients: number; readCount: number; createdAt: string }

/** GET /admin/config/history (bí mật đã che "••••") */
export interface ConfigChangeCtx { createdAt: string; actorName: string | null; section: string; key: string; oldValue: unknown; newValue: unknown; secret: boolean }

/** GET /config/public (rút gọn) */
export interface PublicConfigCtx { appName: string; supportEmail: string; hotline: string; maintenance: { enabled: boolean; message: string; endsAt: string | null } }

// ───────────────────────── registry provider ─────────────────────────

export interface Providers {
  'user.balance': BalanceCtx;
  'user.categories': CategoryCtx[];
  'user.monthReport': MonthReportCtx;          // params { month }
  'user.periodSummary': PeriodSummaryCtx;      // params { from, to }
  'user.budgets': BudgetsCtx;                  // params { month }
  'user.goals': GoalCtx[];
  'user.categoryHistory': MonthCategoryCtx[];  // params { months: string[] }
  'admin.overview': OverviewCtx;
  'admin.userActivity': UserActivity[];
  'admin.broadcasts': BroadcastCtx[];          // params { limit }
  'admin.configHistory': ConfigChangeCtx[];    // params { limit }
  'admin.publicConfig': PublicConfigCtx;
}
export type ProviderName = keyof Providers;
export const PROVIDER_SCOPE: Record<ProviderName, Scope> = {
  'user.balance': 'USER', 'user.categories': 'USER', 'user.monthReport': 'USER', 'user.periodSummary': 'USER',
  'user.budgets': 'USER', 'user.goals': 'USER', 'user.categoryHistory': 'USER',
  'admin.overview': 'ADMIN', 'admin.userActivity': 'ADMIN', 'admin.broadcasts': 'ADMIN', 'admin.configHistory': 'ADMIN', 'admin.publicConfig': 'ADMIN',
};

export interface ProviderRequest<K extends ProviderName = ProviderName> { provider: K; params?: Record<string, unknown> }

/** Ngữ cảnh đã lấy sẵn cho MỘT principal. Provider nào skill không khai báo thì không có mặt. */
export type SkillContext = { principal: Principal } & Partial<Providers>;

// ───────────────────────── skill ─────────────────────────

/** Model cục bộ. Adapter Ollama: `ollamaLlm` trong lib/skillkit.ts. */
export interface Llm { chat(messages: ChatMsg[], format: object, numPredict?: number): Promise<{ content: string; ms: number }> }

export interface TxFilterDraft {
  kind: 'tx-filter';
  from?: string; to?: string;                // YYYY-MM-DD, to không bao gồm (như API)
  type?: TxType; categoryName?: string; walletName?: string; q?: string;
  minAmount?: number; maxAmount?: number;    // API /transactions chưa có → backend lọc thêm hoặc bổ sung tham số
}
export interface BudgetPlanDraft {
  kind: 'budget-plan'; month: string;
  overall: number | null;
  items: { categoryName: string; limitAmount: number; avg3m: number; median3m: number; monthsSeen: number }[];
}
export interface UserFilterDraft { kind: 'user-filter'; q?: string; status?: 'ACTIVE' | 'LOCKED'; role?: Scope }
export interface BroadcastDraft { kind: 'broadcast'; title: string; body: string }
export interface LockDraft { kind: 'lock-user'; userId: string; email: string; reasons: string[] }
export type Draft = TxFilterDraft | BudgetPlanDraft | UserFilterDraft | BroadcastDraft | LockDraft;

export interface SkillResult {
  reply: string;
  draft?: Draft;
  followUps?: string[];
  askBack?: string;
  /** Không hiển thị. computed = số do code tính thêm (ngoài context) và được phép xuất hiện trong reply. */
  meta?: { computed?: number[]; llm?: { calls: number; ms: number; accepted: boolean | null }; refused?: string; [k: string]: unknown };
}

export interface SkillRunArgs { input: string; context: SkillContext; llm: Llm; now: string }

export interface SkillDef {
  name: string;
  scope: Scope | 'BOTH';
  output: 'text' | 'draft';
  providers: ProviderName[];
  /** Provider + tham số cần lấy cho câu này (vd tháng được hỏi). Thuần, không I/O. */
  plan(input: string, now: string): ProviderRequest[];
  run(args: SkillRunArgs): Promise<SkillResult>;
}
