/**
 * Hợp đồng giữa backend và các skill AI (built-in trong backend hoặc nạp từ thư mục `ai/` của repo).
 * Khớp với hợp đồng Track B dự kiến (`ai/lib/contracts.ts`): `run({input, context, llm, now}) → {reply, draft?, followUps?, askBack?}`.
 * Skill KHÔNG bao giờ nhận userId từ câu người dùng: mọi dữ liệu lấy qua `context` đã gắn sẵn principal (JWT).
 */
import type { Role } from '@prisma/client';

export interface Principal {
  id: string;
  email: string;
  name: string;
  role: Role;
}

export interface ChatMsg {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

export interface ChatOptions {
  /** JSON schema (Ollama `format`) */
  format?: object;
  numPredict?: number;
  stop?: string[];
  temperature?: number;
}

export interface ChatResult {
  content: string;
  ms: number;
  promptTokens: number;
  evalTokens: number;
}

/** Client LLM do backend tiêm vào skill (Ollama thật hoặc FAKE tất định khi test). */
export interface LlmClient {
  readonly provider: 'ollama' | 'fake';
  readonly chatModel: string;
  readonly embedModel: string;
  chat(messages: ChatMsg[], opts?: ChatOptions): Promise<ChatResult>;
  /** Embedding đã chuẩn hóa L2 */
  embed(texts: string[]): Promise<number[][]>;
}

/** Tên các context provider (xem ai.context.ts). Skill khai báo `context: [...]` để được nạp sẵn vào `context.data`. */
export type ProviderName =
  | 'userContext'
  | 'balance'
  | 'wallets'
  | 'monthSummary'
  | 'budgets'
  | 'savingGoals'
  | 'recentTransactions'
  | 'searchTransactions'
  | 'categories'
  | 'userMemory'
  | 'userRules'
  | 'similarExamples'
  | 'adminOverview'
  | 'adminUsersSearch'
  | 'adminAnomalies'
  | 'adminConfigHistory';

export interface SkillContext {
  /** Người đang hỏi (từ JWT). Không có email để skill khỏi lỡ in ra. */
  principal: { id: string; name: string; role: Role };
  now: string;
  /** Lịch sử ngắn của hội thoại (mới nhất cuối) */
  history: ChatMsg[];
  /** Kết quả các provider khai báo trong `skill.context` */
  data: Record<string, unknown>;
  /** Gọi provider theo yêu cầu (vd tìm kiếm có tham số). Principal đã gắn cố định — không truyền userId được. */
  get<T = unknown>(provider: ProviderName | string, args?: Record<string, unknown>): Promise<T>;
}

export interface DraftProposal {
  /** transactions | budgets | broadcast | lock_user | search_filter */
  kind: string;
  payload: unknown;
}

export interface SkillResult {
  reply: string;
  draft?: DraftProposal;
  followUps?: string[];
  /** true = cần hỏi lại người dùng (không có nháp) */
  askBack?: boolean;
  /** Chẩn đoán (luật đã áp, số shot, số lần gọi LLM...) */
  meta?: Record<string, unknown>;
}

export interface SkillRunArgs {
  input: string;
  context: SkillContext;
  llm: LlmClient;
  now: string;
}

export interface Skill {
  name: string;
  /** USER/ANY: ai cũng dùng được; ADMIN: chỉ admin trong hội thoại phạm vi ADMIN */
  scope?: 'USER' | 'ADMIN' | 'ANY';
  description?: string;
  /** Provider nạp sẵn vào context.data */
  context?: string[];
  run(args: SkillRunArgs): Promise<SkillResult>;
}

export interface RouteResult {
  skill: string;
  by: 'learned' | 'rule' | 'knn' | 'fallback' | 'reroute' | 'guard';
  score?: number;
}
