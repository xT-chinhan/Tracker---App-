/**
 * V4 — mô phỏng tự học: bắt đầu V3 với kho nhỏ (10 ví dụ), cho "user" dùng 200 lượt trên tập ghi.sim.json
 * (tách biệt hoàn toàn với TEST). User xác nhận nháp đúng, sửa nháp sai → ví dụ vào kho + đếm luật.
 * Đo TEST ở 0/50/100/200 lượt, cộng ablation ở 200 lượt (chỉ kho / chỉ luật).
 *   npm run simulate -- [--embed nomic-embed-text] [--steps 0,50,100,200]
 */
import { saveEmbCache } from '../lib/ollama.js';
import { titleMatch } from '../lib/text.js';
import type { GhiCase } from '../lib/types.js';
import { RuleBook, setKeyMode, type KeyMode } from '../learn/store.js';
import { runGhi, type Options } from '../skills/ghi-giao-dich/pipeline.js';
import { arg, bankOf, ctx, ghi, seedExamples, table, writeResult } from './common.js';
import { scoreCase, summarize } from './score.js';

const embedModel = arg('embed', 'nomic-embed-text');
const keyMode = arg('keys', 'bigram') as KeyMode;
setKeyMode(keyMode);
const steps = arg('steps', '0,50,100,200').split(',').map(Number);
const test = ghi('test'), sim = ghi('sim');
const overlap = sim.filter((s) => test.some((t) => t.text.toLowerCase() === s.text.toLowerCase())).length;
if (overlap) throw new Error(`sim trùng test ${overlap} câu`);

const bank = await bankOf(embedModel, seedExamples(10));
const rules = new RuleBook(3, 0.85);

async function evalTest(label: string, o: Options) {
  const scores = [];
  const ruleHits: { text: string; rule: string; ok: boolean }[] = [];
  for (const c of test) {
    const d = await runGhi(c.text, ctx, o);
    const sc = scoreCase(c, d);
    scores.push(sc);
    ((d.meta?.rules ?? []) as (string | null)[]).forEach((r, i) => r && ruleHits.push({ text: c.text, rule: r, ok: d.items[i]?.categoryName === c.items[i]?.categoryName }));
  }
  const s = summarize(scores);
  const bad = ruleHits.filter((h) => !h.ok);
  console.log(`  ${label}: item ${s.itemExact}% | category ${s.field.categoryName}% | title ${s.field.title}% | luật áp ${ruleHits.length} lần, sai ${bad.length}${bad.length ? ': ' + bad.map((h) => `"${h.text}"[${h.rule}]`).join(', ') : ''}`);
  return { label, bank: bank.items.length, rules: rules.active().length, ruleHits, ...s };
}

const curve: unknown[] = [];
const online: { block: string; accepted: number; total: number }[] = [];
let accepted = 0, total = 0, ruleUses = 0, ruleRight = 0;
const interact = async (c: GhiCase) => {
  const d = await runGhi(c.text, ctx, { variant: 'V4', bank, rules });
  const segs = (d.meta?.segs ?? []) as { text: string; clean: string }[];
  const used = (d.meta?.rules ?? []) as (string | null)[];
  const ok = !d.ask && d.items.length === c.items.length &&
    c.items.every((g, i) => d.items[i].categoryName === g.categoryName && titleMatch(d.items[i].title, g.title));
  total++; if (ok) accepted++;
  // phản hồi của user: xác nhận (nháp đúng) hoặc sửa (đưa bản đúng) — đều là nhãn vàng
  for (const [i, g] of c.items.entries()) {
    const seg = segs[i];
    if (!seg) continue;
    if (used[i]) { ruleUses++; const good = d.items[i].categoryName === g.categoryName; if (good) ruleRight++; rules.feedback(used[i]!, good); }
    await bank.add({ text: seg.text, clean: seg.clean, title: g.title, categoryName: g.categoryName, source: ok ? 'confirm' : 'edit' });
    rules.observe(seg.clean, g.categoryName);
  }
};

let done = 0;
for (const step of steps) {
  while (done < step) {
    await interact(sim[done++]);
    if (done % 50 === 0) { online.push({ block: `${done - 49}-${done}`, accepted, total }); accepted = total = 0; }
  }
  console.log(`sau ${done} lượt: kho ${bank.items.length} ví dụ, ${rules.active().length} luật bật`);
  curve.push({ interactions: done, ...(await evalTest(`V4@${done}`, { variant: 'V4', bank, rules })) });
  saveEmbCache();
}

// ablation tại điểm cuối
console.log('ablation:');
const onlyBank = await evalTest('chỉ kho kNN (không luật)', { variant: 'V3', bank });
const small = await bankOf(embedModel, seedExamples(10));
const onlyRules = await evalTest('chỉ luật (kho 10 ban đầu)', { variant: 'V4', bank: small, rules });
saveEmbCache();

console.log('\n' + table(curve.map((c: any) => ({ 'lượt': c.interactions, 'kho': c.bank, 'luật bật': c.rules, 'item%': c.itemExact, 'category%': c.field.categoryName, 'title%': c.field.title, 'case%': c.caseExact }))));
console.log('\nnháp được chấp nhận ngay (online, theo khối 50 lượt): ' + online.map((b) => `${b.block}: ${Math.round((100 * b.accepted) / b.total)}%`).join(' | '));
console.log(`luật được dùng ${ruleUses} lần khi mô phỏng, đúng ${ruleRight}`);
console.log('luật đang bật:\n  ' + rules.active().join('\n  '));
writeResult(`simulate-${embedModel.replace(/\W/g, '_')}-keys-${keyMode}.json`, {
  embedModel, keyMode, minSupport: rules.minSupport, minPrecision: rules.minPrecision, curve, online,
  ablation: { onlyBank, onlyRules }, ruleUses, ruleRight, activeRules: rules.active(),
});
