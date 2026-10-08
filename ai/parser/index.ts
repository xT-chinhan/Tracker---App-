import { fold } from '../lib/text.js';
import type { UserContext } from '../lib/types.js';
import { findDates, mask, today } from './date.js';
import { findAmounts, type Span } from './money.js';
import { findWallets } from './wallet.js';

export interface Segment {
  text: string; // đoạn gốc của một khoản
  clean: string; // đã bỏ tiền/ngày/ví/từ đệm — dùng cho kNN và luật
  amount: number;
  date: string;
  walletName: string | null;
}

const SEP = /[,;\n]|\.\s|\s(?:va|voi|roi|con|them|xong|\+|sau do)\s/g;
const FILLER = /\b(?:het|tong|mat|tieu|tra|duoc|khoang|cho minh|ghi|giup)\b/g;

const inside = (sp: Span, a: number, b: number) => sp.start >= a && sp.start < b;

/** Tách câu thành các khoản (mỗi khoản đúng 1 số tiền) và gán tiền/ngày/ví bằng code. */
export function parse(text: string, ctx: UserContext): Segment[] {
  const f = fold(text);
  const dates = findDates(f, ctx.now);
  const wallets = findWallets(mask(f, dates), ctx.wallets);
  const amounts = findAmounts(mask(f, [...dates, ...wallets]));
  if (!amounts.length) return [];

  // 1) cắt theo dấu phân cách; 2) đoạn có ≥2 số tiền thì cắt tiếp sau mỗi số tiền
  const cuts = [0];
  for (const m of f.matchAll(SEP)) cuts.push(m.index!, m.index! + m[0].length);
  cuts.push(f.length);
  let chunks: [number, number][] = [];
  for (let i = 0; i < cuts.length; i += 2) if (cuts[i + 1] > cuts[i]) chunks.push([cuts[i], cuts[i + 1]]);
  chunks = chunks.flatMap(([a, b]) => {
    const inA = amounts.filter((x) => inside(x, a, b));
    if (inA.length < 2) return [[a, b] as [number, number]];
    const parts: [number, number][] = [];
    let s = a;
    inA.forEach((x, k) => { const e = k === inA.length - 1 ? b : x.end; parts.push([s, e]); s = e; });
    return parts;
  });
  // 3) đoạn không có tiền gộp vào đoạn có tiền kế tiếp (hoặc đoạn trước nếu ở cuối)
  const items: [number, number][] = [];
  let pending: number | null = null;
  for (const [a, b] of chunks) {
    const has = amounts.some((x) => inside(x, a, b));
    if (has) { items.push([pending ?? a, b]); pending = null; }
    else if (pending == null) pending = a;
  }
  if (pending != null && items.length) items[items.length - 1][1] = f.length;

  const todayIso = new Date(today(ctx.now)).toISOString().slice(0, 10);
  let carryDate = todayIso;
  return items.map(([a, b]) => {
    const amount = amounts.find((x) => inside(x, a, b))!.amount;
    const ownDate = dates.filter((d) => inside(d, a, b)).at(-1)?.date;
    const date = dates.length === 1 ? dates[0].date : (ownDate ?? carryDate);
    carryDate = date;
    const ownWallet = wallets.filter((w) => inside(w, a, b)).at(-1)?.walletName;
    const uniq = [...new Set(wallets.map((w) => w.walletName))];
    const walletName = ownWallet ?? (uniq.length === 1 ? uniq[0] : null);
    const raw = text.slice(a, b).replace(/^[\s,;.+]+|[\s,;.+]+$/g, '').replace(/^(?:và|với|rồi|còn|thêm|xong|sau đó)\s+/i, '');
    const local = [...dates, ...wallets, ...amounts].filter((s) => inside(s, a, b));
    const clean = mask(f, local).slice(a, b).replace(FILLER, ' ').replace(/[^a-z0-9]+/g, ' ').trim();
    return { text: raw, clean, amount, date, walletName };
  });
}
