/**
 * Bảng so sánh trước/sau từ results/*.json (không gọi model):
 *   npx tsx eval/report.ts [--base base] [--new trackA] [--splits test,blind,test0] [--variants V0,V1,V2,V3]
 * Mỗi ô: % [KTC Wilson 95%]. Cột p = McNemar chính xác trên cùng câu/khoản (base vs new) — p < 0.05 mới coi là khác thật.
 */
import { existsSync, readFileSync } from 'node:fs';
import { arg } from './common.js';
import { ci, mcnemar } from './stats.js';

const baseTag = arg('base', 'base'), newTag = arg('new', 'trackA');
const splits = arg('splits', 'test,blind,test0').split(',');
const variants = arg('variants', 'V0,V1,V2,V3').split(',');
const embed = arg('embed', 'bge_m3');
const dirs = (arg('dirs', '') || '').split(',').filter(Boolean);
const R = (f: string) => [new URL(`../results/${f}`, import.meta.url).pathname, ...dirs.map((d) => `${d}/${f}`)].find(existsSync);
const load = (split: string, v: string, tag: string) => {
  const f = R(`ghi-${split}-${v}-${embed}-${tag}.json`);
  return f ? JSON.parse(readFileSync(f, 'utf8'))[v] : null;
};

const out: string[] = [];
for (const split of splits) {
  out.push(`\n### ${split}\n`, '| Biến thể | item% base | item% mới | p (item) | accept% base | accept% mới | p (accept) | category% base → mới | type% base → mới | hỏi lại đúng base → mới | hỏi lại thừa base → mới |', '|---|---|---|---|---|---|---|---|---|---|---|');
  for (const v of variants) {
    const a = load(split, v, baseTag), b = load(split, v, newTag);
    if (!a && !b) continue;
    const cell = (x: any, k: 'item' | 'accept') => (x ? (k === 'item' ? ci(x.summary.counts.itemsExact, x.summary.counts.items) : ci(x.summary.counts.accepted, x.summary.counts.cases)) : '–');
    const pair = (k: 'item' | 'accept') => {
      if (!a || !b) return '–';
      const fa = k === 'item' ? a.preds.flatMap((p: any) => p.itemOk) : a.preds.map((p: any) => p.accept);
      const fb = k === 'item' ? b.preds.flatMap((p: any) => p.itemOk) : b.preds.map((p: any) => p.accept);
      const m = mcnemar(fa, fb);
      return `${m.p < 0.001 ? '<0.001' : m.p} (${m.onlyA}/${m.onlyB})`;
    };
    const f = (x: any, k: string) => (x ? x.summary.field[k] : '–');
    const ask = (x: any) => (x ? `${x.summary.counts.askTP}/${x.summary.counts.askGold}` : '–');
    const fa = (x: any) => (x ? x.summary.ask.falseAsk : '–');
    out.push(`| ${v} | ${cell(a, 'item')} | ${cell(b, 'item')} | ${pair('item')} | ${cell(a, 'accept')} | ${cell(b, 'accept')} | ${pair('accept')} | ${f(a, 'categoryName')} → ${f(b, 'categoryName')} | ${f(a, 'type')} → ${f(b, 'type')} | ${ask(a)} → ${ask(b)} | ${fa(a)} → ${fa(b)} |`);
  }
}
out.push('\n(p: McNemar chính xác hai phía; trong ngoặc = số khoản/câu chỉ base đúng / chỉ bản mới đúng.)');
console.log(out.join('\n'));
