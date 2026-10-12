/**
 * Hợp đồng skill ↔ backend. KHỚP với backend Track C: `backend/src/ai/ai.types.ts` + provider ở `backend/src/ai/ai.context.ts`.
 *
 * Luồng: router chọn skill (lọc theo scope hội thoại) → backend nạp sẵn các provider skill khai báo trong `context`
 * vào `context.data` (luôn theo principal của JWT) → `skill.run({ input, context, llm, now })`.
 * Provider có tham số (tháng, tìm kiếm…) skill gọi qua `context.get(name, args)`; backend lọc tham số theo danh sách trắng,
 * không có tham số nào chọn được user. Skill không đụng DB, không tự gọi mạng (ngoài `llm`).
 * Nháp (`draft`) không bao giờ tự chạy: backend chuẩn hóa (tên → id của chính principal) và chỉ thực thi khi người dùng xác nhận.
 *
 * Provider/field đánh dấu MỚI chưa có ở backend: skill vẫn chạy (lùi về provider sẵn có / bỏ phần đó), xem báo cáo Track B.
 * Tiền là number (VND). Ngày 'YYYY-MM-DD' giờ VN; tháng 'YYYY-MM'; mốc thời gian ISO.
 */

export type Role = 'USER' | 'ADMIN';
export type TxType = 'INCOME' | 'EXPENSE';

export interface ChatMsg { role: 'system' | 'user' | 'assistant'; content: string }
export interface ChatOptions { format?: object; numPredict?: number; stop?: string[]; temperature?: number }
export interface ChatResult { content: string; ms: number; promptTokens?: number; evalTokens?: number }
/** = LlmClient của backend (Ollama thật hoặc FAKE tất định). Skill Track B chỉ dùng `chat`. */
export interface LlmClient {
  readonly provider?: 'ollama' | 'fake';
  readonly chatModel?: string;
  readonly embedModel?: string;
  chat(messages: ChatMsg[], opts?: ChatOptions): Promise<ChatResult>;
  embed?(texts: string[]): Promise<number[][]>;
}

// ───────────── provider USER (backend gắn principal.id, không nhận userId từ skill) ─────────────
/** `balance` — GET /stats/balance, chỉ ví chưa lưu trữ */
export interface BalanceData { total: number; savings: number; wallets: { name: string; balance: number }[] }
/** `wallets` */
export interface WalletRow { id: string; name: string; type: 'CASH' | 'BANK' | 'EWALLET'; balance: number }
/** `categories` — hệ thống ∪ của user */
export interface CategoryRow { id?: string; name: string; type: TxType }
/**
 * `monthSummary` args {month, limit?}. Backend hiện: topExpenses cắt 5 mục, bỏ qua `limit`.
 * MỚI (tùy chọn): topExpenses theo `limit`; `largestExpense`.
 */
export interface MonthSummaryData {
  month: string; income: number; expense: number; net: number;
  topExpenses: { name: string; amount: number }[];
  largestExpense?: { title: string; amount: number; categoryName: string; date: string } | null;
}
/** MỚI `periodSummary` args {from, to} (to không bao gồm) — cần thêm from/to vào danh sách trắng tham số. */
export interface PeriodSummaryData { from: string; to: string; income: number; expense: number; net: number; incomeCount: number; expenseCount: number; topExpenses: { name: string; amount: number }[] }
/** `budgets` args {month} */
export interface BudgetRow { categoryName: string | null; limit: number; spent: number; percentage: number; status: 'ok' | 'warning' | 'exceeded' }
export interface BudgetsData { month: string; overall: BudgetRow | null; items: BudgetRow[] }
/** `savingGoals` */
export interface SavingGoalRow { name: string; target: number; saved: number; progress: number; status: 'ACTIVE' | 'COMPLETED' | 'WITHDRAWN' | 'EARLY_WITHDRAWN'; targetDate: string; dailyRequired: number }

// ───────────── provider ADMIN (backend chặn khi role ≠ ADMIN) ─────────────
/** `adminOverview` — GET /admin/overview */
export interface AdminOverviewData {
  users: { total: number; active: number; locked: number; new30d: number };
  transactions: { total: number; new30d: number; totalIncome: number; totalExpense: number };
  savingGoals: Record<string, number>;
  trend: { month: string; income: number; expense: number; net: number }[];
}
/** `adminUsersSearch` args {q, limit} */
export interface AdminUsersSearchData { total: number; items: { id: string; email: string; name: string; role: Role; status: 'ACTIVE' | 'LOCKED' }[] }
/** `adminAnomalies` */
export interface AdminAnomaliesData { since: string; lockedUsers: number; mostActive24h: { email: string; transactions: number }[] }
/** `adminConfigHistory` args {limit} — item của GET /admin/config/history */
export interface ConfigChangeRow { id?: string; createdAt: string; section: string; key: string; secret: boolean; oldValue: unknown; newValue: unknown; actor: { id: string; name: string; email: string } | null }
/** MỚI `adminUserActivity`: mỗi user một dòng (tổng hợp User + Transaction). failedLogins24h: chỉ khi hệ thống có ghi nhận. */
export interface UserActivityRow {
  id: string; email: string; name: string; role: Role; status: 'ACTIVE' | 'LOCKED';
  createdAt: string; lastLoginAt: string | null;
  txCount30d: number;             // số giao dịch phát sinh (occurredAt) trong 30 ngày
  expenseThisMonth: number;       // tổng chi tháng hiện tại
  expenseAvgPrev3: number;        // TB chi 3 tháng liền trước
  largestExpense30d: number;      // khoản chi lớn nhất 30 ngày
  failedLogins24h?: number;
}
/** MỚI `adminBroadcasts` args {limit} — GET /admin/broadcasts */
export interface BroadcastRow { title: string; body: string; recipients: number; readCount: number; createdAt: string }
/** MỚI `publicConfig` — GET /config/public (rút gọn) */
export interface PublicConfigData { appName: string; supportEmail?: string; hotline?: string }

export interface ProviderData {
  balance: BalanceData; wallets: WalletRow[]; categories: CategoryRow[]; monthSummary: MonthSummaryData; budgets: BudgetsData; savingGoals: SavingGoalRow[];
  periodSummary: PeriodSummaryData;
  adminOverview: AdminOverviewData; adminUsersSearch: AdminUsersSearchData; adminAnomalies: AdminAnomaliesData; adminConfigHistory: ConfigChangeRow[];
  adminUserActivity: UserActivityRow[]; adminBroadcasts: BroadcastRow[]; publicConfig: PublicConfigData;
}
export type ProviderName = keyof ProviderData;
/** Provider skill Track B dùng mà backend CHƯA có. */
export const NEW_PROVIDERS: ProviderName[] = ['periodSummary', 'adminUserActivity', 'adminBroadcasts', 'publicConfig'];
export const ADMIN_PROVIDERS: ProviderName[] = ['adminOverview', 'adminUsersSearch', 'adminAnomalies', 'adminConfigHistory', 'adminUserActivity', 'adminBroadcasts'];

// ───────────── skill ─────────────
export interface SkillContext {
  /** Người hỏi (JWT). Không có email để skill khỏi lỡ in ra. */
  principal: { id: string; name: string; role: Role };
  now: string;
  history: ChatMsg[];
  /** Provider khai báo trong `skill.context`, đã nạp sẵn */
  data: Record<string, unknown>;
  get<T = unknown>(provider: string, args?: Record<string, unknown>): Promise<T>;
}

/** Backend hiện dùng q + month; các trường còn lại MỚI (xem báo cáo). */
export interface TxFilterPayload { target: 'transactions'; q?: string; month?: string; from?: string; to?: string; type?: TxType; categoryName?: string; walletName?: string; minAmount?: number; maxAmount?: number }
/** Backend hiện dùng q; status/role MỚI. */
export interface UserFilterPayload { target: 'users'; q?: string; status?: 'ACTIVE' | 'LOCKED'; role?: Role }
export interface BudgetItemPayload { categoryName: string | null; month: string; limitAmount: number; median3m?: number; avg3m?: number; monthsSeen?: number }

/** Loại nháp backend hỗ trợ: transactions | budgets | broadcast | lock_user | search_filter */
export type DraftProposal =
  | { kind: 'search_filter'; payload: TxFilterPayload | UserFilterPayload }
  | { kind: 'budgets'; payload: { items: BudgetItemPayload[] } }
  | { kind: 'broadcast'; payload: { title: string; body: string } }
  | { kind: 'lock_user'; payload: { userId: string; email: string; name: string; reasons: string[] } };

export interface SkillResult {
  reply: string;
  draft?: DraftProposal;
  followUps?: string[];
  /** true = câu trả lời là câu hỏi lại (không có nháp) */
  askBack?: boolean;
  /** Chẩn đoán. computed = số do code tính thêm (ngoài dữ liệu provider), được phép xuất hiện trong reply. */
  meta?: { computed?: number[]; llm?: { calls: number; ms: number; accepted: boolean | null; [k: string]: unknown }; refused?: string; [k: string]: unknown };
}

export interface SkillRunArgs { input: string; context: SkillContext; llm: LlmClient; now: string }

export interface Skill {
  name: string;
  /** USER/ANY: ai cũng dùng được; ADMIN: chỉ admin trong hội thoại phạm vi ADMIN */
  scope: 'USER' | 'ADMIN' | 'ANY';
  description: string;
  /** Provider nạp sẵn vào context.data */
  context: ProviderName[];
  run(args: SkillRunArgs): Promise<SkillResult>;
}
