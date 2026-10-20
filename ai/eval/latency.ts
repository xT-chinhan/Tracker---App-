/**
 * Độ trễ ấm (warm) p50/p95 từng lần gọi + thông lượng khi 2/3 request đồng thời. Câu lấy từ DEV (không đụng TEST).
 * Đồng thời là phép đo DUY NHẤT chạy song song; không đổi cấu hình service Ollama.
 */
import { execSync } from 'node:child_process';
import { chat, embed, LLM, OLLAMA } from '../lib/ollama.js';
import { runGhi } from '../skills/ghi-giao-dich/pipeline.js';
import { arg, bankOf, ctx, ghi, pctl, seedExamples, table, writeResult } from './common.js';

const N = +arg('n', '30');
const texts = ghi('dev').filter((c) => !c.ask).map((c) => c.text);
const bank = await bankOf('nomic-embed-text', seedExamples());
let gpuMax = 0;
const gpu = () => +execSync('nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits').toString().trim();
const timer = setInterval(() => (gpuMax = Math.max(gpuMax, gpu())), 500);

async function measure(label: string, fn: (i: number) => Promise<unknown>, n = N) {
  await fn(0); await fn(1); // làm ấm
  const ms: number[] = [];
  for (let i = 0; i < n; i++) { const t = performance.now(); await fn(i); ms.push(performance.now() - t); }
  return { label, n, p50: pctl(ms, 50), p95: pctl(ms, 95), mean: Math.round(ms.reduce((a, b) => a + b, 0) / n) };
}

const rows = [];
rows.push(await measure(`${LLM} V1 (1 lần gọi)`, (i) => runGhi(texts[i % texts.length], ctx, { variant: 'V1' })));
rows.push(await measure(`${LLM} V3 (kNN 5-shot, gồm embed)`, (i) => runGhi(texts[i % texts.length], ctx, { variant: 'V3', bank })));
rows.push(await measure(`${LLM} V0 (model tự làm hết)`, (i) => runGhi(texts[i % texts.length], ctx, { variant: 'V0' }), 15));
rows.push(await measure('V1 không có stop "\\n\\n"', async (i) => {
  const { systemV1, userV1 } = await import('../skills/ghi-giao-dich/prompt.js');
  const { schemaV1 } = await import('../skills/ghi-giao-dich/schema.js');
  return chat([{ role: 'system', content: systemV1(ctx) }, { role: 'user', content: userV1(texts[i % texts.length], [texts[i % texts.length]]) }], schemaV1(ctx, 1), 100, []);
}, 15));
const gpuLLM = gpuMax;
for (const m of ['nomic-embed-text', 'bge-m3'])
  rows.push(await measure(`embed ${m} (1 câu, không cache)`, (i) => embed(m, [`${texts[i % texts.length]} #${i}-${Math.random()}`], false), 50));

// đồng thời: 12 request V3 (đã có cache embed của câu dev), chạy theo lô 1/2/3
const conc = [];
for (const c of [1, 2, 3]) {
  const total = 12, lat: number[] = [];
  const t0 = performance.now();
  for (let i = 0; i < total; i += c)
    await Promise.all(Array.from({ length: Math.min(c, total - i) }, async (_, k) => {
      const t = performance.now(); await runGhi(texts[(i + k) % texts.length], ctx, { variant: 'V3', bank }); lat.push(performance.now() - t);
    }));
  const wall = performance.now() - t0;
  conc.push({ concurrency: c, requests: total, 'wall s': +(wall / 1000).toFixed(1), 'req/s': +((total * 1000) / wall).toFixed(2), 'p50 ms': pctl(lat, 50), 'p95 ms': pctl(lat, 95) });
}
clearInterval(timer);
const ps: any = await (await fetch(`${OLLAMA}/api/ps`)).json();
const loaded = ps.models.map((m: any) => `${m.name}: ${(m.size_vram / 2 ** 20).toFixed(0)} MiB VRAM / ${(m.size / 2 ** 20).toFixed(0)} MiB`);
console.log(table(rows));
console.log('\n' + table(conc));
console.log(`\nGPU dùng tối đa: ${gpuMax} MiB (lúc chỉ chạy LLM: ${gpuLLM} MiB). Model đang nạp: ${loaded.join('; ')}`);
writeResult('latency.json', { rows, concurrency: conc, gpuMaxMiB: gpuMax, gpuLLMMiB: gpuLLM, loaded, numParallel: process.env.OLLAMA_NUM_PARALLEL ?? 'mặc định service (log: 1)' });
