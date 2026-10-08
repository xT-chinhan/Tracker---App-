/** Đo router: luật vs kNN (nomic-embed-text, bge-m3) vs kết hợp. Ngưỡng chỉnh trên DEV, chấm trên TEST. */
import { saveEmbCache } from '../lib/ollama.js';
import { KnnRouter, routeCombined, routeRules } from '../router/index.js';
import { BANK, DEV, TEST } from './data/router-source.js';
import { ctx, table, writeResult } from './common.js';

const MODELS = (process.argv[2] ?? 'nomic-embed-text,bge-m3').split(',');
type Pred = { text: string; gold: string; pred: string; by?: string; score?: number };
const acc = (ps: Pred[]) => Math.round((1000 * ps.filter((p) => p.pred === p.gold).length) / ps.length) / 10;
const confusions = (ps: Pred[]) => {
  const m = new Map<string, number>();
  for (const p of ps) if (p.pred !== p.gold) m.set(`${p.gold} → ${p.pred}`, (m.get(`${p.gold} → ${p.pred}`) ?? 0) + 1);
  return [...m.entries()].sort((a, b) => b[1] - a[1]);
};

const results: Record<string, { dev: number; test: number; threshold?: number; preds: Pred[]; confusions: [string, number][] }> = {};
const rulesRun = (set: [string, string][]) => set.map(([text, gold]) => ({ text, gold, pred: routeRules(text, ctx)?.skill ?? 'hoi-lai', by: 'rule' }));
{
  const preds = rulesRun(TEST);
  results['luật'] = { dev: acc(rulesRun(DEV)), test: acc(preds), preds, confusions: confusions(preds) };
  const cov = TEST.filter(([t]) => routeRules(t, ctx)).length;
  console.log(`luật bắt được ${cov}/${TEST.length} câu test`);
}

for (const model of MODELS) {
  const knn = new KnnRouter(model);
  const t0 = performance.now();
  await knn.fit(BANK);
  const fitMs = performance.now() - t0;
  const knnRun = async (set: [string, string][]) => {
    const out: Pred[] = [];
    for (const [text, gold] of set) { const r = await knn.route(text); out.push({ text, gold, pred: r.skill, score: +r.top1.toFixed(3), by: r.neighbor }); }
    return out;
  };
  const devK = await knnRun(DEV), testK = await knnRun(TEST);
  results[`kNN ${model}`] = { dev: acc(devK), test: acc(testK), preds: testK, confusions: confusions(testK) };

  // chọn ngưỡng trên DEV (lưới 0.30..0.95), rồi áp nguyên cho TEST
  const combo = async (set: [string, string][], th: number) => {
    const out: Pred[] = [];
    for (const [text, gold] of set) { const r = await routeCombined(text, ctx, knn, th); out.push({ text, gold, pred: r.skill, by: r.by, score: r.score }); }
    return out;
  };
  let best = { th: 0, a: -1 };
  for (let th = 0.3; th <= 0.951; th += 0.025) { const a = acc(await combo(DEV, th)); if (a > best.a) best = { th: +th.toFixed(3), a }; }
  const testC = await combo(TEST, best.th);
  results[`luật + kNN ${model}`] = { dev: best.a, test: acc(testC), threshold: best.th, preds: testC, confusions: confusions(testC) };
  console.log(`${model}: embed ${Object.values(BANK).flat().length} câu mẫu mất ${Math.round(fitMs)} ms (gồm cache)`);
}
saveEmbCache();

console.log(`\nrouter — DEV ${DEV.length} câu, TEST ${TEST.length} câu, ${Object.values(BANK).flat().length} câu mẫu\n` +
  table(Object.entries(results).map(([k, r]) => ({ method: k, 'dev%': r.dev, 'test%': r.test, threshold: r.threshold ?? '-', 'top nhầm lẫn': r.confusions.slice(0, 3).map(([c, n]) => `${c} ×${n}`).join('; ') }))));
writeResult('router.json', results);
