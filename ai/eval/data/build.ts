/** Sinh các file JSON của bộ đề từ nguồn viết tay ghi-source.ts. Chạy: npx tsx eval/data/build.ts */
import { readFileSync, writeFileSync } from 'node:fs';
import type { DraftItem, GhiCase, UserContext } from '../../lib/types.js';
import { BLIND } from './ghi-blind-source.js';
import { DEV, DEV2, SEED_BANK, SIM_VOCAB, TEST, TEST0, type Src } from './ghi-source.js';

const ctx: UserContext = JSON.parse(readFileSync(new URL('../user-context.json', import.meta.url), 'utf8'));
const WALLET: Record<string, string> = { m: 'MoMo', mb: 'MB Bank', t: 'Techcombank', c: 'Tiền mặt' };
const shift = (d: number) => new Date(Date.UTC(2026, 9, 8 + d)).toISOString().slice(0, 10);
const day = (s: string) => (!s ? shift(0) : s.startsWith('-') ? shift(+s) : `2026-${s}`);
const typeOf = (cat: string) => {
  const c = ctx.categories.find((x) => x.name === cat);
  if (!c) throw new Error(`danh mục lạ: ${cat}`);
  return c.type;
};
const item = (spec: string): DraftItem => {
  const [title, amount, categoryName, date = '', w = ''] = spec.split('|');
  return { title, amount: +amount, categoryName, type: typeOf(categoryName), date: day(date), walletName: w ? WALLET[w] : null };
};
const cases = (src: Src[], p: string): GhiCase[] =>
  src.map(([text, ...items], i) => ({ id: `${p}${String(i + 1).padStart(3, '0')}`, text, ...(items.length ? {} : { ask: true }), items: items.map(item) }));
const out = (f: string, v: unknown) => writeFileSync(new URL(f, import.meta.url), JSON.stringify(v, null, 1) + '\n');

// Tách tập (Track A, 2026-10-12):
//   test  = TEST mới (held-out, không chỉnh trên đó)      test0 = TEST cũ 120 câu (để so số cũ; giờ đã "nhìn thấy")
//   dev   = DEV cũ + DEV2 + TEST cũ (dùng để chỉnh)        blind = đề mù do agent khác viết từ spec (bỏ câu trùng dev/test)
//   sim   = 400 lượt sinh tự động cho mô phỏng tự học       blindp = đề mù cũ 50 câu, chỉ chấm tiền/ngày/ví (giữ nguyên file)
const norm = (t: string) => t.trim().toLowerCase().normalize('NFC');
const test = cases(TEST, 'T'), test0 = cases(TEST0, 't'), dev = [...cases(DEV, 'd'), ...cases(DEV2, 'e'), ...test0];
const seenDT = new Set([...test, ...dev].map((c) => norm(c.text)));
const blindAll = cases(BLIND, 'b');
const blind = blindAll.filter((c) => !seenDT.has(norm(c.text)));
for (const [name, xs] of Object.entries({ test, dev, blind })) {
  const dup = xs.filter((c, i) => xs.findIndex((x) => norm(x.text) === norm(c.text)) !== i);
  if (dup.length) throw new Error(`${name} có câu trùng: ${dup.map((c) => c.text).join(' | ')}`);
}
const devText = new Set(dev.map((c) => norm(c.text)));
const leak = test.filter((c) => devText.has(norm(c.text)));
if (leak.length) throw new Error(`test trùng dev: ${leak.map((c) => c.text).join(' | ')}`);
out('ghi.test.json', test);
out('ghi.test0.json', test0);
out('ghi.dev.json', dev);
out('ghi.blind.json', blind);
out('bank.seed.json', SEED_BANK.map(([text, title, categoryName]) => ({ text, title, categoryName })));

// --- tập mô phỏng 200 lượt (seed cố định) ---
let s = 20261008;
const rnd = () => ((s = (s * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff);
const pick = <T>(a: T[]) => a[Math.floor(rnd() * a.length)];
const DATES: [string, string][] = [['', ''], ['', ''], ['', ''], ['hôm qua', '-1'], ['sáng nay', ''], ['tối qua', '-1'], ['hôm kia', '-2'], ['thứ 2', '10-05'], ['chủ nhật', '10-04'], ['12/9', '09-12'], ['mùng 3', '10-03']];
const WALLETS: [string, string][] = [['', ''], ['', ''], ['', ''], ['trả momo', 'm'], ['ck mb', 'mb'], ['tiền mặt', 'c'], ['qua tcb', 't']];
function money(lo: number, hi: number): [string, number] {
  const step = hi >= 1000 ? 100 : hi >= 100 ? 10 : 5;
  const v = Math.max(step, Math.round((lo + rnd() * (hi - lo)) / step) * step);
  if (v >= 1000) {
    const tr = Math.floor(v / 1000), r = (v % 1000) / 100;
    return [pick(r ? [`${tr}tr${r}`, `${tr} triệu ${r}`] : [`${tr}tr`, `${tr} củ`, `${tr} triệu`]), v * 1000];
  }
  return [pick(v % 100 === 0 ? [`${v}k`, `${v / 100} lít`] : [`${v}k`, `${v}k`, `${v} nghìn`, `${v}.000đ`]), v * 1000];
}
const seen = new Set([...test, ...dev, ...blindAll].map((c) => norm(c.text)));
const sim: GhiCase[] = [];
while (sim.length < 400) {
  const n = rnd() < 0.15 ? 2 : 1;
  const [dp, dc] = pick(DATES), [wp, wc] = pick(WALLETS);
  const parts = Array.from({ length: n }, () => {
    const [say, title, cat, lo, hi] = pick(SIM_VOCAB);
    const [m, amount] = money(lo, hi);
    return { text: `${pick(say.split('/'))} ${m}`, it: { title, amount, categoryName: cat, type: typeOf(cat), date: day(dc), walletName: wc ? WALLET[wc] : null } };
  });
  const body = parts.map((p) => p.text).join(pick([', ', ' với ', ', ']));
  const text = (rnd() < 0.5 ? [dp, body, wp] : [body, dp, wp]).filter(Boolean).join(' ');
  if (seen.has(norm(text))) continue;
  seen.add(norm(text));
  sim.push({ id: `s${String(sim.length + 1).padStart(3, '0')}`, text, items: parts.map((p) => p.it) });
}
out('ghi.sim.json', sim);
const desc = (xs: GhiCase[]) => `${xs.length} câu (hỏi lại ${xs.filter((c) => c.ask).length}, khoản ${xs.reduce((a, c) => a + c.items.length, 0)})`;
console.log(`test ${desc(test)} | test0 ${desc(test0)} | dev ${desc(dev)} | blind ${desc(blind)} (bỏ ${blindAll.length - blind.length} câu trùng) | seed ${SEED_BANK.length} | sim ${sim.length}`);
