/**
 * Chạy bộ đề ghi-giao-dich cho các biến thể, in bảng (kèm KTC Wilson 95%), lưu JSON vào results/.
 *   npm run eval                                         # test, V0..V3, bge-m3
 *   npm run eval -- --split test,blind --variants V1,V3 --tag trackA
 *   npm run eval -- --split dev --variants V3            # vòng chỉnh (chỉ dev)
 *   npm run eval -- --split blindp --variants P          # chỉ parser (tiền/ngày/ví/số khoản)
 * Lệnh gọi Ollama phải bọc: flock /tmp/app-tracker-gpu.lock npm run eval -- ...
 */
import { saveEmbCache } from '../lib/ollama.js';
import type { Draft } from '../lib/types.js';
import { parse } from '../parser/index.js';
import { runGhi, type Variant } from '../skills/ghi-giao-dich/pipeline.js';
import { arg, bankOf, ctx, ghi, pctl, seedExamples, table, writeResult } from './common.js';
import { scoreCase, summarize } from './score.js';

const splits = arg('split', 'test').split(',');
const variants = arg('variants', 'V0,V1,V2,V3').split(',') as (Variant | 'P')[];
const embedModel = arg('embed', 'bge-m3');
const tag = arg('tag', '');
const seeds = seedExamples();
const bank = await bankOf(embedModel, seeds);

for (const split of splits) {
  const cases = ghi(split);
  const rows: Record<string, unknown>[] = [];
  const raw: Record<string, unknown> = { split, tag, embedModel, now: ctx.now, at: new Date().toISOString() };
  for (const v of variants) {
    const preds: { id: string; text: string; draft: Draft; errors: string[]; ok: boolean; accept: boolean; itemOk: boolean[] }[] = [];
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
      preds.push({ id: c.id, text: c.text, draft: { ...draft, items: draft.items.map(({ title, amount, categoryName, type, date, walletName }) => ({ title, amount, categoryName, type, date, walletName })), meta: { ...m, segs: undefined } }, errors: sc.errors, ok: sc.ok, accept: sc.accept, itemOk: sc.itemOk });
      process.stdout.write(sc.ok ? '.' : 'x');
    }
    process.stdout.write(` ${split} ${v}\n`);
    const sum = summarize(scores);
    raw[v] = { summary: sum, calls, retries, fallbacks, latency: { p50: pctl(ms, 50), p95: pctl(ms, 95) }, preds };
    rows.push({
      variant: v, 'item% [95% CI]': sum.ci.item, 'case%': sum.caseExact, 'accept%': sum.accept,
      ...Object.fromEntries(Object.entries(sum.field).map(([k, x]) => [k, x])),
      'askRecall%': sum.ask.recall, falseAsk: sum.ask.falseAsk, 'count%': sum.countOk, retries, fallbacks, p50ms: pctl(ms, 50),
    });
    saveEmbCache();
  }
  console.log(`\nghi-giao-dich — split=${split} (${cases.length} câu), embed=${embedModel}${tag ? `, tag=${tag}` : ''}\n` + table(rows));
  const name = [`ghi-${split}`, variants.join('') === 'P' ? 'parser' : variants.join(''), embedModel.replace(/\W/g, '_'), tag].filter(Boolean).join('-');
  writeResult(`${name}.json`, raw);
}
