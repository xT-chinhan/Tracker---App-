import { chat, type ChatMsg } from '../../lib/ollama.js';
import { fold } from '../../lib/text.js';
import type { Draft, DraftItem, TxType, UserContext } from '../../lib/types.js';
import { today } from '../../parser/date.js';
import { parse, type Segment } from '../../parser/index.js';
import type { Example, ExampleBank, RuleBook } from '../../learn/store.js';
import { systemV0, systemV1, userV1 } from './prompt.js';
import { schemaV0, schemaV1 } from './schema.js';

export type Variant = 'V0' | 'V1' | 'V2' | 'V3' | 'V4';
export interface Options { variant: Variant; staticShots?: Example[]; bank?: ExampleBank; rules?: RuleBook; k?: number }

const WEEKDAY = ['Chủ nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'];
const INCOME_HINT = /\b(luong|thuong|duoc (cho|tang)|ban |lai |co tuc|hoan tien|nhan|thu nhap)/;

/** Bóc JSON từ output model: cắt rác đầu/cuối, bỏ dấu phẩy thừa. */
export function repairJson(s: string): any {
  const a = s.indexOf('{'), b = s.lastIndexOf('}');
  if (a < 0 || b < a) throw new Error('không thấy JSON');
  return JSON.parse(s.slice(a, b + 1).replace(/,\s*([}\]])/g, '$1'));
}

/** Khớp tên danh mục lỏng (bỏ dấu, hoa thường) về đúng tên trong danh sách của user. */
const canonCat = (ctx: UserContext, name: unknown) =>
  typeof name === 'string' ? ctx.categories.find((c) => fold(c.name) === fold(name.trim()))?.name : undefined;

const typeOf = (ctx: UserContext, cat: string): TxType => ctx.categories.find((c) => c.name === cat)!.type;
const fallbackCat = (seg: Segment) => (INCOME_HINT.test(fold(seg.text)) ? 'Thu khác' : 'Chi khác');

const shot = (ex: Example): ChatMsg[] => [
  { role: 'user', content: userV1(ex.text, [ex.text]) },
  { role: 'assistant', content: JSON.stringify({ items: [{ title: ex.title, categoryName: ex.categoryName }] }) },
];

async function pickShots(segs: Segment[], o: Options): Promise<Example[]> {
  if (o.variant === 'V2') return o.staticShots ?? [];
  if ((o.variant !== 'V3' && o.variant !== 'V4') || !o.bank?.items.length) return [];
  const k = o.k ?? 5;
  const lists = await Promise.all(segs.map((s) => o.bank!.nearest(s.clean || s.text, k)));
  const out: { e: Example; s: number }[] = [];
  for (let r = 0; out.length < k && r < k; r++)
    for (const l of lists) if (l[r] && !out.some((x) => x.e === l[r].e) && out.length < k) out.push(l[r]);
  return out.sort((a, b) => a.s - b.s).map((x) => x.e); // gần nhất đặt cuối, sát câu hỏi
}

export async function runGhi(text: string, ctx: UserContext, o: Options): Promise<Draft> {
  return o.variant === 'V0' ? runV0(text, ctx) : runParsed(text, ctx, o);
}

async function runV0(text: string, ctx: UserContext): Promise<Draft> {
  const t = today(ctx.now);
  const sys = systemV0(ctx, new Date(t).toISOString().slice(0, 10), WEEKDAY[new Date(t).getUTCDay()]);
  const r = await chat([{ role: 'system', content: sys }, { role: 'user', content: text }], schemaV0(ctx), 400);
  try {
    const j = repairJson(r.content);
    const items: DraftItem[] = (j.items ?? []).map((x: any) => ({
      title: String(x.title ?? ''), amount: Number(x.amount) || 0, categoryName: String(x.categoryName ?? ''),
      type: x.type, date: String(x.date ?? ''), walletName: x.walletName ?? null,
    }));
    return { ask: !!j.ask || !items.length, items: j.ask ? [] : items, meta: { ms: r.ms, calls: 1 } };
  } catch (e) {
    return { ask: false, items: [], meta: { ms: r.ms, calls: 1, error: String(e) } };
  }
}

async function runParsed(text: string, ctx: UserContext, o: Options): Promise<Draft> {
  const segs = parse(text, ctx);
  if (!segs.length) return { ask: true, items: [], meta: { ms: 0, calls: 0, reason: 'không có số tiền' } };

  const ruleHits = segs.map((s) => (o.variant === 'V4' && o.rules ? o.rules.match(s.clean) : null));
  const shots = await pickShots(segs, o);
  const msgs: ChatMsg[] = [
    { role: 'system', content: systemV1(ctx) },
    ...shots.flatMap(shot),
    { role: 'user', content: userV1(text, segs.map((s) => s.text)) },
  ];
  const schema = schemaV1(ctx, segs.length);
  let ms = 0, calls = 0, retried = false, fallback = 0;
  let out: { title: string; categoryName: string }[] | null = null;
  for (let attempt = 0; attempt < 2 && !out; attempt++) {
    const r = await chat(msgs, schema, 60 + 40 * segs.length);
    ms += r.ms; calls++;
    try {
      const j = repairJson(r.content);
      if (!Array.isArray(j.items) || j.items.length !== segs.length) throw new Error(`cần đúng ${segs.length} khoản`);
      const bad = j.items.findIndex((x: any) => !canonCat(ctx, x.categoryName));
      if (bad >= 0) throw new Error(`categoryName "${j.items[bad].categoryName}" không có trong danh sách`);
      out = j.items.map((x: any) => ({ title: String(x.title ?? '').trim(), categoryName: canonCat(ctx, x.categoryName)! }));
    } catch (e) {
      retried = true;
      msgs.push({ role: 'assistant', content: r.content }, { role: 'user', content: `Lỗi: ${(e as Error).message}. Trả lại JSON đúng schema.` });
    }
  }
  const items = segs.map((s, i) => {
    let categoryName = ruleHits[i]?.categoryName ?? out?.[i]?.categoryName;
    if (!categoryName) { categoryName = fallbackCat(s); fallback++; }
    const title = out?.[i]?.title || s.clean || s.text;
    // hậu kiểm: loại thu/chi theo danh mục; tiền/ngày/ví theo parser
    return { title, amount: s.amount, categoryName, type: typeOf(ctx, categoryName), date: s.date, walletName: s.walletName };
  });
  return { ask: false, items, meta: { ms, calls, retried, fallback, shots: shots.length, rules: ruleHits.map((r) => r?.key ?? null), segs } };
}
