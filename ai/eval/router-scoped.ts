/**
 * Đo router theo scope (Track B): luật / kNN bge-m3 / luật + kNN (ngưỡng chọn trên DEV) trên TEST và đề mù.
 * Chạy: flock /tmp/app-tracker-gpu.lock npx tsx eval/router-scoped.ts
 */
import { readFileSync } from 'node:fs';
import { embed, saveEmbCache } from '../lib/ollama.js';
import { fold } from '../lib/text.js';
import { BANK, SKILLS_BY_SCOPE } from '../router/bank.js';
import { routeScoped, ScopedKnn } from '../router/scoped.js';
import { pctl, table, writeResult } from './common.js';
import { DEV, TEST, type Case } from './data/router-v2.js';

type Blind = { text: string; scope: 'USER' | 'ADMIN'; gold: string; tag: string };
const blindRaw: Blind[] = JSON.parse(readFileSync(new URL('./data/router-blind.json', import.meta.url), 'utf8'));
const TAGMAP: Record<string, Case['tag']> = { normal: 'n', adversarial: 'adv', english: 'en', nodiacritics: 'nd', teencode: 'n' };
const BLIND: (Case & { rawTag: string })[] = blindRaw.map((b) => ({ text: b.text, scope: b.scope, gold: b.gold, tag: TAGMAP[b.tag] ?? 'n', rawTag: b.tag }));

// Kiểm tra trùng giữa câu mẫu và đề
const bankSet = new Set(Object.values(BANK).flatMap((s) => Object.values(s).flat()).map((t) => fold(t).trim()));
const overlap = (xs: Case[]) => xs.filter((c) => bankSet.has(fold(c.text).trim())).map((c) => c.text);
console.log('trùng câu mẫu — DEV:', overlap(DEV), 'TEST:', overlap(TEST), 'BLIND:', overlap(BLIND));

type Pred = Case & { pred: string; by: string; score?: number; reason?: string };
const acc = (ps: Pred[]) => (ps.length ? Math.round((1000 * ps.filter((p) => p.pred === p.gold).length) / ps.length) / 10 : NaN);
const violations = (ps: Pred[]) => ps.filter((p) => !SKILLS_BY_SCOPE[p.scope].includes(p.pred)).length;
const confusions = (ps: Pred[]) => {
  const m = new Map<string, number>();
  for (const p of ps) if (p.pred !== p.gold) m.set(`${p.scope[0]}:${p.gold}→${p.pred}`, (m.get(`${p.scope[0]}:${p.gold}→${p.pred}`) ?? 0) + 1);
  return [...m.entries()].sort((a, b) => b[1] - a[1]);
};
function breakdown(ps: Pred[]) {
  const by = (f: (p: Pred) => boolean) => { const xs = ps.filter(f); return { n: xs.length, acc: acc(xs) }; };
  const perSkill: Record<string, { n: number; acc: number }> = {};
  for (const s of new Set(ps.map((p) => `${p.scope}:${p.gold}`))) perSkill[s] = by((p) => `${p.scope}:${p.gold}` === s);
  return {
    overall: by(() => true), USER: by((p) => p.scope === 'USER'), ADMIN: by((p) => p.scope === 'ADMIN'),
    adversarial: by((p) => p.tag === 'adv'), english: by((p) => p.tag === 'en'), noDiacritics: by((p) => p.tag === 'nd'),
    scopeViolations: violations(ps), perSkill,
  };
}

const knn = await new ScopedKnn('bge-m3').fit();
const run = async (set: Case[], th: number, rules: boolean, useKnn = true): Promise<Pred[]> => {
  const out: Pred[] = [];
  for (const c of set) { const r = await routeScoped(c.text, c.scope, useKnn ? knn : null, th, rules); out.push({ ...c, pred: r.skill, by: r.by, score: r.score && +r.score.toFixed(3), reason: r.reason }); }
  return out;
};

// ngưỡng trên DEV
let best = { th: 0, a: -1, k: 5 };
for (const k of [1, 3, 5]) {
  knn.k = k;
  for (let th = 0.3; th <= 0.901; th += 0.025) { const a = acc(await run(DEV, th, true)); if (a > best.a + 1e-9) best = { th: +th.toFixed(3), a, k }; }
}
knn.k = best.k;
console.log(`chọn trên DEV (${DEV.length} câu): k=${best.k}, ngưỡng ${best.th} → dev ${best.a}%`);

const methods: Record<string, { th: number; rules: boolean; knn: boolean }> = {
  'luật (không khớp → hỏi lại)': { th: 1, rules: true, knn: false },
  'kNN bge-m3 (theo scope)': { th: 0, rules: false, knn: true },
  [`luật + kNN (ngưỡng ${best.th})`]: { th: best.th, rules: true, knn: true },
};
const results: Record<string, any> = { k: best.k, threshold: best.th, devAcc: best.a, sizes: { dev: DEV.length, test: TEST.length, blind: BLIND.length, bank: [...bankSet].length } };
const rows: Record<string, unknown>[] = [];
for (const [name, m] of Object.entries(methods)) {
  const t = await run(TEST, m.th, m.rules, m.knn), b = await run(BLIND, m.th, m.rules, m.knn);
  const bt = breakdown(t), bb = breakdown(b);
  results[name] = { test: bt, blind: bb, confusionsTest: confusions(t), confusionsBlind: confusions(b), predsTest: t, predsBlind: b };
  rows.push({ 'phương pháp': name, 'test%': bt.overall.acc, 'USER%': bt.USER.acc, 'ADMIN%': bt.ADMIN.acc, 'đối kháng%': bt.adversarial.acc, 'blind%': bb.overall.acc, 'blind USER%': bb.USER.acc, 'blind ADMIN%': bb.ADMIN.acc, 'blind đối kháng%': bb.adversarial.acc, 'sai scope': bt.scopeViolations + bb.scopeViolations });
}
console.log(table(rows));
const main = results[`luật + kNN (ngưỡng ${best.th})`];
console.log('nhầm lẫn (test):', main.confusionsTest.slice(0, 12));
console.log('nhầm lẫn (blind):', main.confusionsBlind.slice(0, 15));

// độ trễ route thật (không dùng cache embedding): 40 câu
const lat: number[] = [];
for (const c of [...TEST.slice(0, 20), ...BLIND.slice(0, 20)]) {
  const t0 = performance.now();
  const r = await routeScoped(c.text, c.scope, null, 1, true);
  if (r.by === 'fallback') await embed('bge-m3', [c.text + ' '], false); // giả lập câu mới: luôn embed khi luật không khớp
  lat.push(performance.now() - t0);
}
const embLat: number[] = [];
for (const c of TEST.slice(0, 30)) { const t0 = performance.now(); await embed('bge-m3', [c.text + '  '], false); embLat.push(performance.now() - t0); }
results.latency = { routeP50: pctl(lat, 50), routeP95: pctl(lat, 95), embedP50: pctl(embLat, 50), embedP95: pctl(embLat, 95) };
console.log('latency', results.latency);
saveEmbCache();
writeResult('trackB-router.json', results);
