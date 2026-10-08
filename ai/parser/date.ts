import type { Span } from './money.js';

export interface DateSpan extends Span { date: string }

const DAY = 86400000;
const iso = (t: number) => new Date(t).toISOString().slice(0, 10);
const utc = (y: number, m: number, d: number) => Date.UTC(y, m - 1, d);

/** "Hôm nay" theo giờ VN (now là ISO có offset +07:00). */
export function today(nowIso: string): number {
  const d = new Date(new Date(nowIso).getTime() + 7 * 3600000);
  return utc(d.getUTCFullYear(), d.getUTCMonth() + 1, d.getUTCDate());
}

const WD: Record<string, number> = { '2': 0, hai: 0, '3': 1, ba: 1, '4': 2, tu: 2, '5': 3, nam: 3, '6': 4, sau: 4, '7': 5, bay: 5 };

/** Ngày tương đối/tuyệt đối trên chuỗi đã fold(). Ngày trong tương lai được lùi về quá khứ gần nhất. */
export function findDates(f: string, nowIso: string): DateSpan[] {
  const t0 = today(nowIso);
  const now = new Date(t0);
  const Y = now.getUTCFullYear(), M = now.getUTCMonth() + 1;
  const monday = t0 - ((now.getUTCDay() + 6) % 7) * DAY;
  const pastDay = (d: number, m = M, y = Y) => {
    let t = utc(y, m, d);
    if (t > t0) t = m === M ? utc(y, m - 1, d) : utc(y - 1, m, d);
    return t;
  };
  const rules: [RegExp, (m: RegExpExecArray) => number | null][] = [
    [/\b(?:hom|bua|sang|trua|chieu|toi|dem) nay\b|(?<=^|[,;.]\s*)nay\b/g, () => t0],
    [/\b(?:hom|bua|sang|trua|chieu|toi|dem) qua\b/g, () => t0 - DAY],
    [/\bhom kia\b/g, () => t0 - 2 * DAY],
    [/\b(\d+) (?:ngay|hom) truoc\b/g, (m) => t0 - +m[1] * DAY],
    [/\b(?:hom |ngay )?(?:thu ?([2-7]|hai|ba|tu|nam|sau|bay)|t([2-7])|(chu nhat|cn))( tuan (?:truoc|roi))?\b/g, (m) => {
      const idx = m[3] ? 6 : WD[m[1] ?? m[2]];
      let t = monday + idx * DAY;
      if (m[4]) t -= 7 * DAY;
      else if (t > t0) t -= 7 * DAY;
      return t;
    }],
    [/\b(?:ngay|mung|mong) (\d{1,2}) thang (\d{1,2})\b/g, (m) => pastDay(+m[1], +m[2])],
    [/\b(\d{1,2})[/-](\d{1,2})(?:[/-](\d{4}))?\b/g, (m) => (+m[2] >= 1 && +m[2] <= 12 ? (m[3] ? utc(+m[3], +m[2], +m[1]) : pastDay(+m[1], +m[2])) : null)],
    [/\b(?:ngay|mung|mong) (\d{1,2})\b/g, (m) => pastDay(+m[1])],
  ];
  const out: DateSpan[] = [];
  let masked = f;
  for (const [re, fn] of rules) {
    for (const m of masked.matchAll(re)) {
      const t = fn(m as RegExpExecArray);
      if (t == null) continue;
      const start = m.index! + (m[0].length - m[0].trimStart().length);
      out.push({ start, end: m.index! + m[0].length, date: iso(t) });
    }
    masked = mask(masked, out);
  }
  return out.sort((a, b) => a.start - b.start);
}

export const mask = (s: string, spans: Span[]) =>
  spans.reduce((acc, sp) => acc.slice(0, sp.start) + ' '.repeat(sp.end - sp.start) + acc.slice(sp.end), s);
