/**
 * Eval các skill Track B trên fixture (eval/fixtures). Mỗi skill: skills/<tên>/eval.json.
 * Kiểm tra bằng code cho MỌI ca: số trong reply ⊆ (context ∪ câu hỏi ∪ meta.computed ∪ dữ liệu tĩnh của skill ∪ hằng template),
 * câu model viết không có chữ số, tiếng Việt, độ dài, không lộ tên/email người khác (phiên USER), draft đúng schema.
 * Cộng thêm kiểm tra riêng của từng ca (expect). Chạy: flock /tmp/app-tracker-gpu.lock npx tsx eval/skills.ts [--skills a,b]
 */
import { existsSync, readFileSync } from 'node:fs';
import type { DraftProposal, SkillResult } from '../lib/contracts.js';
import { NEW_PROVIDERS } from '../lib/contracts.js';
import { ollamaLlm } from '../lib/skillkit.js';
import { fold } from '../lib/text.js';
import { SKILLS } from '../router/registry.js';
import { loadFixture, makeContext, type AdminFixture } from './fixtures/providers.js';
import { arg, pctl, table, writeResult } from './common.js';

interface Expect {
  contains?: string[]; containsAny?: string[]; notContains?: string[];
  refused?: string | false; askBack?: boolean;
  draft?: Record<string, unknown> | null; draftItems?: Record<string, unknown>[];
  maxLen?: number; faq?: string; draftText?: string[]; tipsFocus?: string; flagged?: string[]; notFlagged?: string[];
}
interface Case { id: string; fixture: string; input: string; expect: Expect; note?: string }

const VI = /[ăâđêôơưáàảãạấầẩẫậắằẳẵặéèẻẽẹếềểễệíìỉĩịóòỏõọốồổỗộớờởỡợúùủũụứừửữựýỳỷỹỵ]/i;
/** Hằng số nằm sẵn trong template (không phải dữ liệu): "30 ngày", "24 giờ". */
const TEMPLATE_CONSTANTS = [30, 24];

function numbersIn(x: unknown, out = new Set<number>()): Set<number> {
  if (typeof x === 'number') { out.add(Math.abs(x)); out.add(Math.round(Math.abs(x) * 10) / 10); }
  else if (typeof x === 'string') for (const m of x.match(/\d+(?:[.,]\d+)*/g) ?? []) { out.add(+m.replace(/[.,]/g, '')); for (const p of m.split(/[.,]/)) out.add(+p); out.add(+m.replace(/\./g, '').replace(',', '.')); }
  else if (Array.isArray(x)) x.forEach((v) => numbersIn(v, out));
  else if (x && typeof x === 'object') Object.values(x).forEach((v) => numbersIn(v, out));
  return out;
}
/** Số trong reply: "18.672.000đ" → 18672000, "62,5%" → 62.5, "08/10" → 8 và 10. */
function replyNumbers(s: string): { raw: string; vals: number[]; parts: number[] }[] {
  return (s.match(/\d+(?:[.,]\d+)*/g) ?? []).map((m) => ({ raw: m, vals: [+m.replace(/\./g, '').replace(',', '.'), +m.replace(/[.,]/g, '')], parts: m.split(/[.,]/).map(Number) }));
}
function inputNumbers(s: string): number[] {
  const f = fold(s);
  const out: number[] = [];
  for (const m of f.matchAll(/(\d+(?:[.,]\d+)?)\s*(k|nghin|ngan|tr|trieu|cu|m)?(\d{1,3})?\b/g)) {
    const n = parseFloat(m[1].replace(',', '.'));
    const tail = m[3] ? +m[3] / 10 ** m[3].length : 0;
    if (m[2] === 'k' || m[2] === 'nghin' || m[2] === 'ngan') out.push(n * 1000);
    else if (m[2]) out.push((n + tail) * 1e6);
    out.push(n, +m[1].replace(/[.,]/g, ''));
  }
  return out;
}
function staticNumbers(skill: string): number[] {
  const out: number[] = [];
  for (const f of ['faq.json', 'tips.json']) {
    const p = new URL(`../skills/${skill}/${f}`, import.meta.url);
    if (existsSync(p)) out.push(...numbersIn(readFileSync(p, 'utf8')));
  }
  return out;
}

function allowedDates(context: unknown, now: string, extra: unknown[], input = '') {
  const days = new Set<string>(), years = new Set<number>(), times = new Set<string>();
  const add = (iso: string) => {
    if (/^\d{4}-\d{2}-\d{2}$/.test(iso)) { days.add(iso.slice(5)); years.add(+iso.slice(0, 4)); return; }
    const t = Date.parse(iso); if (Number.isNaN(t)) return;
    const v = new Date(t + 7 * 3600000).toISOString();
    days.add(v.slice(5, 10)); years.add(+v.slice(0, 4)); times.add(v.slice(11, 16));
  };
  const walk = (x: unknown, key = ''): void => {
    if (typeof x === 'string') {
      if (/^\d{4}-\d{2}-\d{2}/.test(x)) { add(x); if (key === 'to' && x.length === 10) add(new Date(Date.parse(x) - 86400000).toISOString().slice(0, 10)); }
      if (/^\d{4}-\d{2}$/.test(x)) { add(`${x}-01`); const [y, m] = x.split('-').map(Number); add(new Date(Date.UTC(y, m, 0)).toISOString().slice(0, 10)); }
    } else if (Array.isArray(x)) x.forEach((v) => walk(v, key));
    else if (x && typeof x === 'object') Object.entries(x).forEach(([k, v]) => walk(v, k));
  };
  walk(context); walk(extra); add(now);
  for (const m of input.matchAll(/\b(\d{1,2})\/(\d{1,2})(?:\/(\d{4}))?/g)) { days.add(`${m[2].padStart(2, '0')}-${m[1].padStart(2, '0')}`); if (m[3]) years.add(+m[3]); }
  return { days, years, times };
}

function validDraft(d: DraftProposal): string | null {
  const isStr = (v: unknown) => typeof v === 'string' && v.length > 0;
  const isDate = (v: unknown) => typeof v === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(v);
  const p: any = d.payload;
  if (!p || typeof p !== 'object') return 'payload';
  switch (d.kind) {
    case 'search_filter':
      if (p.target === 'users') {
        if (p.status && !['ACTIVE', 'LOCKED'].includes(p.status)) return 'status';
        if (p.role && !['USER', 'ADMIN'].includes(p.role)) return 'role';
        if (p.q !== undefined && (!isStr(p.q) || p.q.length > 100)) return 'q';
        return null;
      }
      if (p.target !== 'transactions') return 'target';
      if (p.month && !/^\d{4}-\d{2}$/.test(p.month)) return 'month';
      if (p.from && !isDate(p.from)) return 'from'; if (p.to && !isDate(p.to)) return 'to';
      if (p.from && p.to && p.from >= p.to) return 'from>=to';
      if (p.type && !['INCOME', 'EXPENSE'].includes(p.type)) return 'type';
      for (const k of ['minAmount', 'maxAmount']) if (p[k] !== undefined && !(Number.isInteger(p[k]) && p[k] > 0)) return k;
      if (p.minAmount && p.maxAmount && p.minAmount > p.maxAmount) return 'min>max';
      if (p.q !== undefined && (!isStr(p.q) || p.q.length > 100)) return 'q';
      return null;
    case 'budgets':
      if (!Array.isArray(p.items) || p.items.length < 1 || p.items.length > 50) return 'items';
      for (const i of p.items) if (!/^\d{4}-\d{2}$/.test(i.month) || !Number.isInteger(i.limitAmount) || i.limitAmount < 1 || !(i.categoryName === null || isStr(i.categoryName))) return 'item';
      return null;
    case 'broadcast':
      if (!isStr(p.title) || p.title.length > 120) return 'title';
      if (!isStr(p.body) || p.body.length > 2000) return 'body';
      if (!VI.test(p.title + p.body)) return 'vi';
      return null;
    case 'lock_user':
      if (!/^[0-9a-f-]{36}$/i.test(p.userId) || !isStr(p.email) || !Array.isArray(p.reasons) || !p.reasons.length) return 'lock';
      return null;
    default: return 'kind';
  }
}

const sub = (a: unknown, b: unknown): boolean => {
  if (b && typeof b === 'object' && !Array.isArray(b)) return !!a && typeof a === 'object' && Object.entries(b).every(([k, v]) => sub((a as any)[k], v));
  if (typeof b === 'string' && typeof a === 'string') return b.startsWith('~') ? fold(a).includes(fold(b.slice(1))) : fold(a) === fold(b);
  return a === b;
};

const admin = loadFixture('admin') as AdminFixture;
/** --fake: model luôn trả {} → kiểm tra đường lùi của code, không cần GPU. */
const FAKE = process.argv.includes('--fake');
/** --asis: backend như hiện tại — chưa có provider MỚI, monthSummary chỉ top 5, không có largestExpense. */
const ASIS = process.argv.includes('--asis');
const fakeLlm = { chat: async () => ({ content: '{}', ms: 0 }) };
const only = arg('skills', '').split(',').filter(Boolean);
const names = Object.keys(SKILLS).filter((n) => !only.length || only.includes(n));
const all: any[] = [];
const summary: Record<string, unknown>[] = [];

for (const name of names) {
  const skill = SKILLS[name];
  const file = new URL(`../skills/${name}/eval.json`, import.meta.url);
  if (!existsSync(file)) { console.log(`(bỏ qua ${name}: chưa có eval.json)`); continue; }
  const cases: Case[] = JSON.parse(readFileSync(file, 'utf8'));
  const stat = staticNumbers(name);
  const rows: any[] = [];
  for (const c of cases) {
    const fx = loadFixture(c.fixture);
    const { ctx: context, trace } = makeContext(fx, skill.context, { missing: ASIS ? NEW_PROVIDERS : [], asis: ASIS });
    const t0 = performance.now();
    let r: SkillResult;
    try { r = await skill.run({ input: c.input, context, llm: FAKE ? fakeLlm : ollamaLlm, now: fx.now }); }
    catch (e) { r = { reply: '', meta: { error: String((e as Error).stack ?? e) } }; }
    const ms = performance.now() - t0;
    const fails: string[] = [];
    const e = c.expect;
    const text = [r.reply, r.askBack ?? '', r.draft ? JSON.stringify(r.draft) : ''].join('\n');
    // ── kiểm tra chung ──
    if (r.meta?.error) fails.push(`lỗi: ${r.meta.error}`);
    const allowed = new Set<number>([...numbersIn(trace.map((t) => t.data)), ...inputNumbers(c.input), ...numbersIn(c.input), ...(r.meta?.computed ?? []).flatMap((x) => [Math.abs(x), Math.round(Math.abs(x) * 10) / 10]), ...stat, ...TEMPLATE_CONSTANTS]);
    // Ngày/giờ trong reply (dd/mm, dd/mm/yyyy, hh:mm) phải là ngày có trong context (đổi sang giờ VN), hôm nay, hoặc mốc của bộ lọc / tham số plan.
    const dates = allowedDates(trace.map((t) => t.data), fx.now, [r.draft, trace.map((t) => t.args ?? null)], c.input);
    for (const k of dates.days) allowed.add(+k.slice(0, 2));
    const badDates: string[] = [];
    const replyNoDates = r.reply.replace(/\b(\d{1,2})\/(\d{1,2})(?:\/(\d{4}))?(?:\s+(\d{2}):(\d{2}))?\b/g, (m, d, mo, y, hh, mi) => {
      const key = `${String(mo).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
      if (!dates.days.has(key) || (y && !dates.years.has(+y)) || (hh && !dates.times.has(`${hh}:${mi}`))) badDates.push(m);
      return ' ';
    });
    if (badDates.length) fails.push(`ngày không có nguồn: ${badDates.join(', ')}`);
    const bad = replyNumbers(replyNoDates).filter((n) => !n.vals.some((v) => allowed.has(v)) && !n.parts.every((p) => allowed.has(p)));
    if (bad.length) fails.push(`số không có nguồn: ${bad.map((b) => b.raw).join(', ')}`);
    const lt = typeof r.meta?.llmText === 'string' ? r.meta.llmText : '';
    if (r.meta?.llm?.accepted && /\d/.test(lt)) fails.push('câu model có chữ số');
    if (!VI.test(r.reply)) fails.push('không phải tiếng Việt');
    if (r.reply.length > (e.maxLen ?? 1500)) fails.push(`reply dài ${r.reply.length}`);
    if (fx.principal.role === 'USER') {
      const foreign = admin.userActivity.filter((u) => u.id !== (fx.principal as any).userId).flatMap((u) => [u.email, u.name]).filter((s) => !fold(c.input).includes(fold(s)));
      const leak = foreign.filter((s) => text.includes(s));
      if (leak.length) fails.push(`lộ dữ liệu người khác: ${leak.join(', ')}`);
    }
    if (r.draft) { const v = validDraft(r.draft); if (v) fails.push(`draft sai schema: ${v}`); }
    // ── kiểm tra riêng ──
    for (const s of e.contains ?? []) if (!r.reply.includes(s)) fails.push(`thiếu "${s}"`);
    if (e.containsAny && !e.containsAny.some((s) => r.reply.includes(s))) fails.push(`thiếu một trong ${JSON.stringify(e.containsAny)}`);
    for (const s of e.notContains ?? []) if (fold(r.reply).includes(fold(s))) fails.push(`không được có "${s}"`);
    if (e.refused !== undefined) { const got = (r.meta?.refused as string) ?? false; if (got !== e.refused) fails.push(`refused=${got}, cần ${e.refused}`); }
    else if (r.meta?.refused) fails.push(`từ chối nhầm (${r.meta.refused})`);
    if (e.askBack !== undefined && !!r.askBack !== e.askBack) fails.push(`askBack=${!!r.askBack}, cần ${e.askBack}`);
    if (e.draft === null && r.draft) fails.push('không được có draft');
    if (e.draft) {
      if (!r.draft) fails.push('thiếu draft');
      else {
        for (const [k, v] of Object.entries(e.draft)) if (!sub((r.draft as any)[k], v)) fails.push(`draft.${k}=${JSON.stringify((r.draft as any)[k])}, cần ${JSON.stringify(v)}`);
        if (r.draft.kind === 'search_filter' && (e.draft as any).payload) {
          // bộ lọc: không được có thêm trường ngoài đáp án
          for (const k of Object.keys(r.draft.payload)) if (!(k in (e.draft as any).payload)) fails.push(`draft thừa ${k}=${JSON.stringify((r.draft.payload as any)[k])}`);
        }
      }
    }
    for (const it of e.draftItems ?? []) {
      const items = (r.draft as any)?.payload?.items ?? [];
      if (!items.some((x: any) => sub(x, it))) fails.push(`draft thiếu item ${JSON.stringify(it)}`);
    }
    for (const t of e.draftText ?? []) { const d: any = r.draft?.payload ?? {}; if (!`${d.title ?? ''} ${d.body ?? ''}`.includes(t)) fails.push(`nháp thiếu "${t}"`); }
    if (e.faq && r.meta?.faq !== e.faq) fails.push(`faq=${r.meta?.faq}, cần ${e.faq}`);
    if (e.tipsFocus && !(r.meta?.focus as string[] | undefined)?.includes(e.tipsFocus)) fails.push(`focus=${JSON.stringify(r.meta?.focus)}, cần ${e.tipsFocus}`);
    const flagged = new Set(((r.meta?.flags as any[]) ?? []).map((f) => f.email));
    for (const m of e.flagged ?? []) if (!flagged.has(m)) fails.push(`không gắn cờ ${m}`);
    for (const m of e.notFlagged ?? []) if (flagged.has(m)) fails.push(`gắn cờ nhầm ${m}`);
    const row = { skill: name, id: c.id, input: c.input, pass: !fails.length, fails, ms: Math.round(ms), llm: r.meta?.llm ?? null, reply: r.reply, draft: r.draft ?? null, askBack: r.askBack ?? null };
    rows.push(row); all.push(row);
    if (fails.length) console.log(`✗ ${name}/${c.id} «${c.input}»: ${fails.join(' | ')}\n   → ${r.reply.replace(/\n/g, ' ⏎ ').slice(0, 300)}${r.draft ? `\n   draft ${JSON.stringify(r.draft).slice(0, 250)}` : ''}`);
  }
  const llmRows = rows.filter((x) => x.llm && x.llm.calls > 0);
  summary.push({
    skill: name, scope: skill.scope, cases: rows.length, 'pass%': Math.round((1000 * rows.filter((x) => x.pass).length) / rows.length) / 10,
    'gọi model': llmRows.length, 'model đạt%': llmRows.length ? Math.round((1000 * llmRows.filter((x) => x.llm.accepted !== false).length) / llmRows.length) / 10 : '-',
    'p50 ms': pctl(rows.map((x) => x.ms), 50), 'p95 ms': pctl(rows.map((x) => x.ms), 95),
  });
}
console.log('\n' + table(summary));
const tot = all.length, pass = all.filter((x) => x.pass).length;
console.log(`\nTổng: ${pass}/${tot} = ${Math.round((1000 * pass) / tot) / 10}%  · p50 ${pctl(all.map((x) => x.ms), 50)} ms`);
if (!only.length) writeResult(`trackB-skills${FAKE ? '-fake-llm' : ''}${ASIS ? '-asis' : ''}.json`, { summary, total: { cases: tot, pass, p50: pctl(all.map((x) => x.ms), 50), p95: pctl(all.map((x) => x.ms), 95) }, cases: all });
