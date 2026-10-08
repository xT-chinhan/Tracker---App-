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

const MIN_DATE = Date.UTC(2000, 0, 1) - OFFSET_MS;
const MAX_DATE = Date.UTC(2100, 0, 1) - OFFSET_MS;

/**
 * Parse ngày giờ ISO từ client. Không kèm múi giờ ("2026-09-01", "2026-09-01T08:00") => hiểu là giờ VN,
 * không phụ thuộc TZ của máy chủ (container thường chạy UTC). Ngoài [2000, 2100) giờ VN => 400.
 */
export function parseDate(s: string, field = 'Ngày'): Date {
  const zoned = /T.*(Z|[+-]\d{2}(:?\d{2})?)$/i.test(s);
  const d = zoned ? new Date(s) : new Date(s.includes('T') ? `${s}${OFFSET}` : `${s}T00:00:00${OFFSET}`);
  if (Number.isNaN(d.getTime())) throw new BadRequestException(`${field} không hợp lệ`);
  if (d.getTime() < MIN_DATE || d.getTime() >= MAX_DATE) throw new BadRequestException(`${field} phải trong khoảng năm 2000 – 2099`);
  return d;
}

/** Khoảng thời gian từ query: ưu tiên month, sau đó from/to; không có gì => không lọc. */
export function resolveRange(q: { month?: string; from?: string; to?: string }): { gte?: Date; lt?: Date } {
  if (q.month) {
    const { start, end } = monthRange(q.month);
    return { gte: start, lt: end };
  }
  const gte = q.from ? parseDate(q.from, 'from') : undefined;
  const lt = q.to ? parseDate(q.to, 'to') : undefined;
  if (gte && lt && gte >= lt) throw new BadRequestException('from phải trước to');
  return { gte, lt };
}
