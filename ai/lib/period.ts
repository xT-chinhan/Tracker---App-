/** Khoảng thời gian tiếng Việt → {from, to} (YYYY-MM-DD, `to` không bao gồm, giờ VN). Thuần, không phụ thuộc TZ máy. */
import { fold } from './text.js';

const DAY = 86400000;
const iso = (t: number) => new Date(t).toISOString().slice(0, 10);
const utc = (y: number, m: number, d: number) => Date.UTC(y, m - 1, d);

/** Nửa đêm (UTC giả) của "hôm nay" giờ VN. */
export function vnDay(nowIso: string): number {
  const d = new Date(new Date(nowIso).getTime() + 7 * 3600000);
  return utc(d.getUTCFullYear(), d.getUTCMonth() + 1, d.getUTCDate());
}
export const monthOf = (nowIso: string) => iso(vnDay(nowIso)).slice(0, 7);
export function shiftMonth(month: string, k: number): string {
  const [y, m] = month.split('-').map(Number);
  const t = new Date(Date.UTC(y, m - 1 + k, 1));
  return t.toISOString().slice(0, 7);
}
export const daysInMonth = (month: string) => { const [y, m] = month.split('-').map(Number); return new Date(Date.UTC(y, m, 0)).getUTCDate(); };
/** Số ngày còn lại của tháng tính cả hôm nay (tháng hiện tại); tháng khác → 0. */
export function daysLeftInMonth(month: string, nowIso: string): number {
  const today = iso(vnDay(nowIso));
  if (today.slice(0, 7) !== month) return 0;
  return daysInMonth(month) - Number(today.slice(8, 10)) + 1;
}
export function monthLabel(month: string, nowIso?: string): string {
  const [y, m] = month.split('-').map(Number);
  return nowIso && monthOf(nowIso).slice(0, 4) === String(y) ? `tháng ${m}` : `tháng ${m}/${y}`;
}
export const dmy = (d: string) => `${d.slice(8, 10)}/${d.slice(5, 7)}/${d.slice(0, 4)}`;
export const dm = (d: string) => `${d.slice(8, 10)}/${d.slice(5, 7)}`;

export interface Period { from: string; to: string; label: string; kind: 'day' | 'week' | 'month' | 'year' | 'range' | 'days'; month?: string }

const WD: Record<string, number> = { '2': 0, hai: 0, '3': 1, ba: 1, '4': 2, tu: 2, '5': 3, nam: 3, '6': 4, sau: 4, '7': 5, bay: 5 };

/** Tháng được hỏi: "tháng này/trước/rồi/vừa rồi", "tháng 9", "tháng 9/2025", "tháng 9 năm 2025", "T9". Không có → null. */
export function parseMonth(text: string, nowIso: string): string | null {
  const f = fold(text);
  const cur = monthOf(nowIso);
  // "so với tháng trước, tháng này…" → chủ thể là tháng này
  if (/\bthang nay\b|\bthis month\b/.test(f)) return cur;
  if (/\bthang (truoc|roi|vua roi|vua qua|qua)\b|\blast month\b/.test(f)) return shiftMonth(cur, -1);
  const m = /\b(?:thang|t)\s?(\d{1,2})(?:\s*(?:\/|nam)\s*(\d{4}))?\b/.exec(f);
  if (m && +m[1] >= 1 && +m[1] <= 12) {
    let y = m[2] ? +m[2] : +cur.slice(0, 4);
    if (!m[2] && +m[1] > +cur.slice(5, 7)) y -= 1; // "tháng 11" khi đang tháng 10 → năm trước
    return `${y}-${String(+m[1]).padStart(2, '0')}`;
  }
  return null;
}

/** Khoảng thời gian trong câu. Không có → null. */
export function parsePeriod(text: string, nowIso: string): Period | null {
  const f = fold(text);
  const t0 = vnDay(nowIso);
  const wd = (new Date(t0).getUTCDay() + 6) % 7; // 0 = thứ 2
  const monday = t0 - wd * DAY;
  const day = (t: number, label: string): Period => ({ from: iso(t), to: iso(t + DAY), label, kind: 'day' });
  const Y = new Date(t0).getUTCFullYear();

  // từ dd/mm (đến|tới|-) dd/mm
  let m = /\btu (?:ngay )?(\d{1,2})[/-](\d{1,2})(?:[/-](\d{4}))? (?:den|toi|-) (?:ngay )?(\d{1,2})[/-](\d{1,2})(?:[/-](\d{4}))?/.exec(f);
  if (m) {
    const a = utc(m[3] ? +m[3] : Y, +m[2], +m[1]), b = utc(m[6] ? +m[6] : Y, +m[5], +m[4]);
    if (a <= b) return { from: iso(a), to: iso(b + DAY), label: `từ ${dm(iso(a))} đến ${dm(iso(b))}`, kind: 'range' };
  }
  if (/\b(hom|bua|sang|trua|chieu|toi|dem) nay\b|\btoday\b/.test(f)) return day(t0, 'hôm nay');
  if (/\b(hom|bua|sang|trua|chieu|toi|dem) qua\b|\byesterday\b/.test(f)) return day(t0 - DAY, 'hôm qua');
  if (/\bhom kia\b/.test(f)) return day(t0 - 2 * DAY, 'hôm kia');
  m = /\b(\d{1,3}) ngay (?:qua|gan (?:day|nhat)|vua qua|truoc|nay)\b|\blast (\d{1,3}) days\b/.exec(f);
  if (m) { const n = +(m[1] ?? m[2]); return { from: iso(t0 - (n - 1) * DAY), to: iso(t0 + DAY), label: `${n} ngày qua`, kind: 'days' }; }
  if (/\bcuoi tuan (truoc|roi)\b/.test(f)) return { from: iso(monday - 2 * DAY), to: iso(monday), label: 'cuối tuần trước', kind: 'range' };
  if (/\btuan (truoc|roi|vua roi|vua qua)\b|\blast week\b/.test(f)) return { from: iso(monday - 7 * DAY), to: iso(monday), label: 'tuần trước', kind: 'week' };
  if (/\btuan nay\b|\bthis week\b/.test(f)) return { from: iso(monday), to: iso(t0 + DAY), label: 'tuần này', kind: 'week' };
  if (/\bcuoi tuan\b/.test(f)) {
    const sat = wd >= 5 ? monday + 5 * DAY : monday - 2 * DAY;
    return { from: iso(sat), to: iso(sat + 2 * DAY), label: 'cuối tuần', kind: 'range' };
  }
  // thứ X (tuần trước) / chủ nhật
  m = /\b(?:hom |ngay )?(?:thu ?([2-7]|hai|ba|tu|nam|sau|bay)|(chu nhat))( tuan (?:truoc|roi))?\b/.exec(f);
  if (m) {
    let t = monday + (m[2] ? 6 : WD[m[1]]) * DAY;
    if (m[3]) t -= 7 * DAY; else if (t > t0) t -= 7 * DAY;
    return day(t, `${m[2] ? 'chủ nhật' : `thứ ${m[1]}`}${m[3] ? ' tuần trước' : ''}`);
  }
  // ngày dd/mm(/yyyy) hoặc dd/mm
  m = /\b(\d{1,2})[/-](\d{1,2})(?:[/-](\d{4}))?\b/.exec(f);
  if (m && +m[2] >= 1 && +m[2] <= 12 && +m[1] >= 1 && +m[1] <= 31) {
    let t = utc(m[3] ? +m[3] : Y, +m[2], +m[1]);
    if (!m[3] && t > t0) t = utc(Y - 1, +m[2], +m[1]);
    return day(t, `ngày ${dm(iso(t))}`);
  }
  if (/\bnam (ngoai|truoc|roi)\b|\blast year\b/.test(f)) return { from: `${Y - 1}-01-01`, to: `${Y}-01-01`, label: `năm ${Y - 1}`, kind: 'year' };
  if (/\bnam nay\b|\bthis year\b/.test(f)) return { from: `${Y}-01-01`, to: iso(t0 + DAY), label: `năm ${Y}`, kind: 'year' };
  const month = parseMonth(text, nowIso);
  if (month) {
    const to = shiftMonth(month, 1) + '-01';
    return { from: month + '-01', to, label: monthLabel(month, nowIso), kind: 'month', month };
  }
  if (/\bgan day\b|\bdao nay\b|\brecent(ly)?\b/.test(f)) return { from: iso(t0 - 29 * DAY), to: iso(t0 + DAY), label: '30 ngày qua', kind: 'days' };
  return null;
}
