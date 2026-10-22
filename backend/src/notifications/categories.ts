import { NotificationType } from '@prisma/client';

/** Nhóm hiển thị trong app (suy ra từ `type`, không lưu DB → app cũ đọc `type` vẫn chạy). */
export const NOTIFICATION_CATEGORIES = ['system', 'balance', 'budget', 'reminder', 'security'] as const;
export type NotificationCategory = (typeof NOTIFICATION_CATEGORIES)[number];

export const CATEGORY_OF: Record<NotificationType, NotificationCategory> = {
  BROADCAST: 'system',
  BALANCE_CHANGE: 'balance',
  BUDGET_WARNING: 'budget',
  BUDGET_EXCEEDED: 'budget',
  RECURRING_PAUSED: 'reminder',
  SECURITY: 'security',
};

export const typesOf = (c: NotificationCategory) => (Object.keys(CATEGORY_OF) as NotificationType[]).filter((t) => CATEGORY_OF[t] === c);

/** 45000 → "45.000đ" */
export const vnd = (n: number | bigint) => `${new Intl.NumberFormat('vi-VN').format(Number(n))}đ`;

/** Thông báo nhóm Bảo mật (song song email bảo mật). Lỗi ghi thông báo không làm hỏng thao tác chính. */
export function notifySecurity(prisma: { notification: { create(args: { data: { userId: string; type: NotificationType; title: string; body: string } }): Promise<unknown> } }, userId: string, title: string, body: string) {
  return prisma.notification.create({ data: { userId, type: 'SECURITY', title, body } }).catch(() => undefined);
}
