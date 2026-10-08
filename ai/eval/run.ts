/**
 * Chạy bộ đề ghi-giao-dich cho các biến thể, in bảng, lưu JSON vào results/.
 *   npm run eval                          # test, V0..V3
 *   npm run eval -- --split dev --variants V1,V2
 *   npm run eval -- --split blind --variants P   # chỉ parser (tiền/ngày/ví/số khoản)
 */
import { saveEmbCache } from '../lib/ollama.js';
import type { Draft } from '../lib/types.js';
import { parse } from '../parser/index.js';
import { runGhi, type Variant } from '../skills/ghi-giao-dich/pipeline.js';
import { arg, bankOf, ctx, ghi, pctl, seedExamples, table, writeResult } from './common.js';
import { scoreCase, summarize } from './score.js';

const split = arg('split', 'test');
const variants = arg('variants', 'V0,V1,V2,V3').split(',') as (Variant | 'P')[];
const embedModel = arg('embed', 'nomic-embed-text');
const cases = ghi(split);
const seeds = seedExamples();
const bank = await bankOf(embedModel, seeds);

const rows: Record<string, unknown>[] = [];
const raw: Record<string, unknown> = { split, embedModel, now: ctx.now, at: new Date().toISOString() };
for (const v of variants) {
  const preds: { id: string; text: string; draft: Draft; errors: string[] }[] = [];
  const scores = [];
  const ms: number[] = [];
  let calls = 0, retries = 0, fallbacks = 0;
  for (const c of cases) {
    const draft: Draft = v === 'P'
      ? (() => { const s = parse(c.text, ctx); return { ask: !s.length, items: s.map((x) => ({ title: '', categoryName: '', type: 'EXPENSE' as const, ...x })) }; })()
      : await runGhi(c.text, ctx, { variant: v, staticShots: seeds.slice(0, 5), bank });
    const sc = scoreCase(c, draft);
    scores.push(sc);
    const m = draft.meta ?? {};
    if (typeof m.ms === 'number' && m.calls) ms.push(m.ms);
    calls += Number(m.calls ?? 0); retries += m.retried ? 1 : 0; fallbacks += Number(m.fallback ?? 0);
    preds.push({ id: c.id, text: c.text, draft: { ...draft, meta: { ...m, segs: undefined } }, errors: sc.errors });
    process.stdout.write(sc.ok ? '.' : 'x');
  }
  process.stdout.write(` ${v}\n`);
  const sum = summarize(scores);
  raw[v] = { summary: sum, calls, retries, fallbacks, latency: { p50: pctl(ms, 50), p95: pctl(ms, 95) }, preds };
  rows.push({
    variant: v, 'case%': sum.caseExact, 'item%': sum.itemExact, ...Object.fromEntries(Object.entries(sum.field).map(([k, x]) => [k, x])),
    'askRecall%': sum.ask.recall, falseAsk: sum.ask.falseAsk, 'count%': sum.countOk, retries, fallbacks, p50ms: pctl(ms, 50),
  });
}
saveEmbCache();
console.log(`\nghi-giao-dich — split=${split} (${cases.length} câu), embed=${embedModel}\n` + table(rows));
writeResult(`ghi-${split}${variants.join('') === 'P' ? '-parser' : ''}${embedModel === 'nomic-embed-text' ? '' : '-' + embedModel.replace(/\W/g, '_')}.json`, raw);
