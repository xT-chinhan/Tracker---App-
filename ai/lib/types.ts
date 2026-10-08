export type TxType = 'INCOME' | 'EXPENSE';

/** Ngữ cảnh của DUY NHẤT một user — pipeline không được thấy gì ngoài object này. */
export interface UserContext {
  userId: string;
  displayName: string;
  now: string; // ISO có offset, vd 2026-10-08T09:00:00+07:00
  categories: { name: string; type: TxType }[]; // hệ thống ∪ của user
  wallets: { name: string; type: string }[];
}

export interface DraftItem {
  title: string;
  amount: number;
  categoryName: string;
  type: TxType;
  date: string; // YYYY-MM-DD
  walletName: string | null;
}

export interface Draft {
  ask: boolean; // true = cần hỏi lại, không có nháp
  items: DraftItem[];
  meta?: Record<string, unknown>;
}

export interface GhiCase {
  id: string;
  text: string;
  ask?: boolean;
  items: DraftItem[];
}
