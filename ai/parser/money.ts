export interface Span { start: number; end: number }
export interface MoneySpan extends Span { amount: number }

const WORDS: Record<string, number> = { mot: 1, hai: 2, ba: 3, bon: 4, nam: 5, sau: 6, bay: 7, tam: 8, chin: 9, muoi: 10, nua: 0.5 };
const NUM = String.raw`(\d+(?:[.,]\d+)?|mot|hai|ba|bon|nam|sau|bay|tam|chin|muoi|nua)`;
const num = (s: string) => WORDS[s] ?? parseFloat(s.replace(',', '.'));
/** "2" sau "tr" = 2 trăm nghìn, "25" = 250 nghìn, "250" = 250 nghìn. */
const tail = (s: string | undefined, unit: number) =>
  !s ? 0 : s === 'ruoi' ? unit / 2 : (+s * unit) / 10 ** s.length;

// Số đứng trước/sau các từ này không phải tiền ("tháng 9", "2 ly", "quý 3", "25kg").
const BEFORE = /(?:thang|quy|nam|ngay|mung|thu|lan|so|tuan|tang|phong|lop|top|iphone|ban|ky|dot|loai|size|tuoi)\s*$/;
const AFTER = /^\s*(?:ly|coc|cai|ve|chuyen|nguoi|ngay|thang|nam|lan|bua|kg|g|gram|cuon|doi|chiec|hop|chai|goi|phan|suat|to|dia|lon|h|gio|phut|%|tuoi|qua|con|mon|km|so|tiet|buoi|dem|tang|bo|cay|lit|xi|ky|ki)\b/;

const RULES: [RegExp, (m: RegExpExecArray) => number][] = [
  [new RegExp(String.raw`(?<![\w.,])${NUM}\s*(?:trieu|tr|cu|m)(?:\s*(ruoi|\d{1,3}))?(?![a-z0-9])`, 'g'), (m) => num(m[1]) * 1e6 + tail(m[2], 1e6)],
  [new RegExp(String.raw`(?<![\w.,])${NUM}\s*(?:k|nghin|ngan|ng)(?![a-z0-9])`, 'g'), (m) => num(m[1]) * 1e3],
  [new RegExp(String.raw`(?<![\w.,])${NUM}\s*(?:lit|xi)(?:\s*(ruoi))?(?![a-z0-9])`, 'g'), (m) => num(m[1]) * 1e5 + tail(m[2], 1e5)],
  [new RegExp(String.raw`(?<![\w.,])${NUM}\s*tram(?:\s*(ruoi|\d))?(?![a-z0-9])`, 'g'), (m) => num(m[1]) * 1e5 + tail(m[2], 1e5)],
  [/(?<![\w.,])tram ruoi(?![a-z])/g, () => 150000],
  [new RegExp(String.raw`(?<![\w.,])${NUM}\s*chuc(?![a-z0-9])`, 'g'), (m) => num(m[1]) * 1e4],
  [/(?<![\w.,])(\d{1,3}(?:[.,]\d{3})+)\s*(?:d|dong|vnd)?(?![a-z0-9])/g, (m) => +m[1].replace(/[.,]/g, '')],
  [/(?<![\w.,/])(\d+)\s*(?:d|dong|vnd)?(?![\w.,/])/g, (m) => (+m[1] < 1000 ? +m[1] * 1000 : +m[1])],
];

/** Tìm số tiền trên chuỗi đã fold() và đã che ngày/ví. */
export function findAmounts(f: string): MoneySpan[] {
  const out: MoneySpan[] = [];
  let s = f;
  RULES.forEach(([re, fn], i) => {
    for (const m of s.matchAll(re)) {
      const start = m.index!, end = start + m[0].trimEnd().length;
      if (i === RULES.length - 1 && (BEFORE.test(s.slice(0, start)) || AFTER.test(s.slice(end)))) continue;
      const amount = Math.round(fn(m as RegExpExecArray));
      if (amount > 0) out.push({ start, end, amount });
    }
    s = out.reduce((acc, sp) => acc.slice(0, sp.start) + ' '.repeat(sp.end - sp.start) + acc.slice(sp.end), f);
  });
  return out.sort((a, b) => a.start - b.start);
}
