import { BadRequestException } from '@nestjs/common';

/** Toàn bộ nghiệp vụ theo tháng/ngày tính theo giờ Việt Nam (UTC+7, không có DST). */
export const APP_TZ = 'Asia/Ho_Chi_Minh';
const OFFSET = '+07:00';
const OFFSET_MS = 7 * 60 * 60 * 1000;

export const MONTH_REGEX = /^\d{4}-(0[1-9]|1[0-2])$/;

/** [start, end) của một tháng "YYYY-MM". */
export function monthRange(month: string): { start: Date; end: Date } {
  if (!MONTH_REGEX.test(month)) throw new BadRequestException('month phải có dạng YYYY-MM');
  const [y, m] = month.split('-').map(Number);
  return { start: monthStart(y, m), end: monthStart(y, m + 1) };
}

function monthStart(year: number, month1: number): Date {
  const d = new Date(Date.UTC(year, month1 - 1, 1));
  return new Date(`${d.toISOString().slice(0, 7)}-01T00:00:00${OFFSET}`);
}

/** "YYYY-MM" của một thời điểm theo giờ VN. */
export function monthOf(date: Date): string {
  return new Date(date.getTime() + OFFSET_MS).toISOString().slice(0, 7);
}

/** Dịch tháng "YYYY-MM" đi delta tháng. */
export function shiftMonth(month: string, delta: number): string {
  const [y, m] = month.split('-').map(Number);
  return new Date(Date.UTC(y, m - 1 + delta, 1)).toISOString().slice(0, 7);
}

/** Khoảng thời gian từ query: ưu tiên month, sau đó from/to; không có gì => không lọc. */
export function resolveRange(q: { month?: string; from?: string; to?: string }): { gte?: Date; lt?: Date } {
  if (q.month) {
    const { start, end } = monthRange(q.month);
    return { gte: start, lt: end };
  }
  return {
    gte: q.from ? new Date(q.from) : undefined,
    lt: q.to ? new Date(q.to) : undefined,
  };
}
