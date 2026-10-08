import { titleMatch } from '../lib/text.js';
import type { Draft, DraftItem, GhiCase } from '../lib/types.js';

export const FIELDS = ['title', 'amount', 'categoryName', 'type', 'date', 'walletName'] as const;
type Field = (typeof FIELDS)[number];

export interface CaseScore {
  id: string; ok: boolean; askGold: boolean; askPred: boolean; countOk: boolean;
  fields: Record<Field, number>; totals: Record<Field, number>; items: number; itemsExact: number; errors: string[];
}

const fieldOk = (f: Field, p: DraftItem, g: DraftItem) =>
  f === 'title' ? g.title.split('/').some((t) => titleMatch(p.title, t)) : p[f] === g[f];

/** Ghép khoản dự đoán với khoản chuẩn: ưu tiên cùng số tiền, rồi cùng vị trí. */
function align(pred: DraftItem[], gold: DraftItem[]) {
  const used = new Set<number>();
  return gold.map((g, i) => {
    let j = pred.findIndex((p, k) => !used.has(k) && p.amount === g.amount);
    if (j < 0 && i < pred.length && !used.has(i)) j = i;
    if (j >= 0) used.add(j);
    return j >= 0 ? pred[j] : null;
  });
}

export function scoreCase(c: GhiCase, d: Draft): CaseScore {
  const fields = Object.fromEntries(FIELDS.map((f) => [f, 0])) as Record<Field, number>;
  const totals = { ...fields };
  const s: CaseScore = { id: c.id, ok: false, askGold: !!c.ask, askPred: d.ask, countOk: false, fields, totals, items: c.items.length, itemsExact: 0, errors: [] };
  if (c.ask || d.ask) {
    s.ok = s.countOk = !!c.ask === d.ask;
    if (!s.ok) s.errors.push(c.ask ? 'ask:lẽ ra phải hỏi lại' : 'ask:hỏi lại thừa');
    return s;
  }
  s.countOk = d.items.length === c.items.length;
  if (!s.countOk) s.errors.push(`count:${d.items.length}≠${c.items.length}`);
  align(d.items, c.items).forEach((p, i) => {
    const g = c.items[i];
    let exact = !!p;
    for (const f of FIELDS) {
      if (g[f] === undefined) continue; // bộ đề chỉ có một số trường (vd. blind: tiền/ngày/ví)
      totals[f]++;
      const ok = !!p && fieldOk(f, p, g);
      if (ok) fields[f]++;
      else {
        s.errors.push(`${f}:${p ? JSON.stringify(p[f]) : '∅'}→${JSON.stringify(g[f])}`);
        if (f !== 'title') exact = false;
      }
    }
    if (exact) s.itemsExact++;
  });
  s.ok = s.countOk && s.itemsExact === c.items.length;
  return s;
}

export function summarize(scores: CaseScore[]) {
  const items = scores.reduce((a, s) => a + s.items, 0);
  const pct = (n: number, d: number) => (d ? Math.round((1000 * n) / d) / 10 : 0);
  const field = Object.fromEntries(FIELDS.map((f) => [f, pct(scores.reduce((a, s) => a + s.fields[f], 0), scores.reduce((a, s) => a + s.totals[f], 0))]));
  const askTP = scores.filter((s) => s.askGold && s.askPred).length;
  return {
    cases: scores.length,
    caseExact: pct(scores.filter((s) => s.ok).length, scores.length),
    itemExact: pct(scores.reduce((a, s) => a + s.itemsExact, 0), items),
    field,
    ask: { recall: pct(askTP, scores.filter((s) => s.askGold).length), falseAsk: scores.filter((s) => !s.askGold && s.askPred).length },
    countOk: pct(scores.filter((s) => !s.askGold && s.countOk).length, scores.filter((s) => !s.askGold).length),
  };
}
