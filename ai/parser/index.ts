import { fold } from '../lib/text.js';
import type { UserContext } from '../lib/types.js';
import { direction, isEmptyContent, sentenceIntent, type DirCue } from './cues.js';
import { findDates, mask, today } from './date.js';
import { findAmounts, type Span } from './money.js';
import { hasDiacritics, normVi } from './norm.js';
import { findWallets } from './wallet.js';

export interface Segment {
  text: string; // đoạn gốc của một khoản
  clean: string; // đã bỏ tiền/ngày/ví/từ đệm, BỎ DẤU — dùng cho kNN (và luật khi câu không dấu)
  norm: string; // như clean nhưng CÒN DẤU (normVi) — khóa luật học được
  amount: number;
  date: string;
  walletName: string | null;
  dia: boolean; // đoạn có dấu tiếng Việt
  dir: DirCue | null; // tín hiệu THU/CHI bằng code
}

export interface Analysis {
  segs: Segment[];
  /** Lý do phải hỏi lại dù có số tiền: chuyển giữa ví của mình, vay/nợ, hoặc không có nội dung. */
  ask: 'transfer' | 'loan' | 'empty' | null;
}

const SEP = /[,;\n]|\.\s|\s(?:va|voi|vs|roi|con|them|xong|\+|sau do)\s/g;
// "tra" của "trà sữa/trà đá…" (câu không dấu) không phải "trả"
const FILLER = /\b(?:het|tong|mat|tieu|tra(?! (?:sua|da|chanh|dao|tac|xanh|sen|gung|quat|thai|chieu|nong|tui))|duoc|khoang|cho minh|ghi|giup)\b/g;
// cùng danh sách nhưng còn dấu: "trà sữa" không bị mất chữ "trà" như bản bỏ dấu
const FILLER_ACC = /(?<![\p{L}])(?:hết|tổng|mất|tiêu|trả|đã|được|đc|khoảng|cho mình|ghi|giúp)(?![\p{L}])/gu;

const inside = (sp: Span, a: number, b: number) => sp.start >= a && sp.start < b;
const blank = (s: string, spans: Span[]) => mask(s, spans);

/** Tách câu thành các khoản (mỗi khoản đúng 1 số tiền) và gán tiền/ngày/ví bằng code. */
export function parse(text: string, ctx: UserContext): Segment[] {
  return analyze(text, ctx).segs;
}

export function analyze(input: string, ctx: UserContext): Analysis {
  const text = input.normalize('NFC');
  const f = fold(text);
  const n = normVi(text);
  const sameLen = n.length === f.length;
  const dates = findDates(f, ctx.now);
  const wallets = findWallets(mask(f, dates), ctx.wallets);
  const amounts = findAmounts(mask(f, [...dates, ...wallets]));
  if (!amounts.length) return { segs: [], ask: null };

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

  const sentDia = hasDiacritics(text) && sameLen;
  const todayIso = new Date(today(ctx.now)).toISOString().slice(0, 10);
  let carryDate = todayIso;
  const segs = items.map(([a, b]): Segment => {
    const amount = amounts.find((x) => inside(x, a, b))!.amount;
    const ownDate = dates.filter((d) => inside(d, a, b)).at(-1)?.date;
    const date = dates.length === 1 ? dates[0].date : (ownDate ?? carryDate);
    carryDate = date;
    const ownWallet = wallets.filter((w) => inside(w, a, b)).at(-1)?.walletName;
    const uniq = [...new Set(wallets.map((w) => w.walletName))];
    const walletName = ownWallet ?? (uniq.length === 1 ? uniq[0] : null);
    const raw = text.slice(a, b).replace(/^[\s,;.+]+|[\s,;.+]+$/g, '').replace(/^(?:và|với|vs|rồi|còn|thêm|xong|sau đó)\s+/i, '');
    const localDW = [...dates, ...wallets].filter((s) => inside(s, a, b));
    const localAmt = amounts.filter((s) => inside(s, a, b));
    const dia = sentDia; // người gõ có dấu ở bất kỳ đâu trong câu thì coi cả câu là có dấu
    const spans = (s: string, re: RegExp) => [...s.matchAll(re)].map((m) => ({ start: m.index!, end: m.index! + m[0].length }));
    const mf = blank(f, [...localDW, ...localAmt]).slice(a, b);
    const mn = blank(n, [...localDW, ...localAmt]).slice(a, b);
    // có dấu: bỏ từ đệm theo bản còn dấu rồi mới bỏ dấu; không dấu: bỏ theo bản bỏ dấu
    const fillers = dia ? spans(mn, FILLER_ACC) : spans(mf, FILLER);
    const clean = blank(mf, fillers).replace(/[^a-z0-9]+/g, ' ').trim();
    const norm = sameLen ? blank(mn, fillers).replace(/[^\p{L}\p{N}]+/gu, ' ').trim() : clean;
    // chuỗi cho tín hiệu thu/chi: che ngày/ví, tiền thành "#"
    const withHash = (s: string) => {
      let out = blank(s, localDW).slice(a, b);
      for (const x of [...localAmt].sort((p, q) => q.start - p.start)) out = out.slice(0, x.start - a) + ' # ' + out.slice(x.end - a);
      return out.replace(/[^\p{L}\p{N}#]+/gu, ' ').trim();
    };
    const dir = direction(sameLen ? withHash(n) : withHash(f), withHash(f), dia);
    return { text: raw, clean, norm, amount, date, walletName, dia, dir };
  });

  const intent = sentenceIntent(n, f, sentDia, wallets);
  const ask = intent ?? (segs.some((s) => isEmptyContent(s)) ? 'empty' : null);
  return { segs, ask };
}
