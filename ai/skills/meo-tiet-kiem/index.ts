import type { SkillDef } from '../../lib/contracts.js';
import { monthOf, shiftMonth } from '../../lib/period.js';
import { findName, llmJson, money, userGuard } from '../../lib/skillkit.js';
import TIPS from './tips.json' with { type: 'json' };

type Tip = { id: string; text: string };
const BANK = TIPS as Record<string, Tip[]>;
const ALIAS: Record<string, string[]> = { 'an uong': ['an uong', 'an', 'ca phe', 'cafe', 'tra sua', 'an ngoai', 'di cho'], 'di chuyen': ['di chuyen', 'xang', 'grab', 'xe'], 'mua sam': ['mua sam', 'shopee', 'shopping', 'mua do'], 'giai tri': ['giai tri', 'netflix', 'phim', 'game'], 'hoa don': ['hoa don', 'tien dien', 'dien nuoc', 'internet'] };
const SYS = 'Chọn 2 đến 3 mẹo tiết kiệm phù hợp nhất với câu hỏi của người dùng. Chỉ trả JSON {"ids": [...]}.';
const months = (now: string) => [3, 2, 1].map((k) => shiftMonth(monthOf(now), -k));

export const skill: SkillDef = {
  name: 'meo-tiet-kiem', scope: 'USER', output: 'text', providers: ['user.categoryHistory'],
  plan: (_input, now) => [{ provider: 'user.categoryHistory', params: { months: months(now) } }],
  async run({ input, context, llm }) {
    const g = userGuard(input, context.principal); if (g) return g;
    const h = context['user.categoryHistory'] ?? [];
    const n = h.length || 1;
    const tot = new Map<string, number>();
    for (const m of h) for (const c of m.expenseByCategory) tot.set(c.categoryName, (tot.get(c.categoryName) ?? 0) + c.amount);
    const ranked = [...tot.entries()].map(([name, t]) => ({ name, avg: Math.round(t / n) })).sort((a, b) => b.avg - a.avg);
    const computed = ranked.map((r) => r.avg);
    const asked = findName(input, Object.keys(BANK).filter((k) => k !== '_chung'), ALIAS);
    const focus = asked ? [asked] : ranked.map((r) => r.name).filter((c) => BANK[c]).slice(0, 3);
    const pool: Tip[] = [...focus.flatMap((c) => BANK[c] ?? []), ...BANK._chung];
    let ids: string[] = [], ms = 0, accepted: boolean | null = null;
    const r = await llmJson<{ ids: string[] }>(llm, SYS,
      `Câu hỏi: «${input}»\nCác mẹo:\n${pool.map((t) => `- ${t.id}: ${t.text}`).join('\n')}`,
      { type: 'object', properties: { ids: { type: 'array', minItems: 2, maxItems: 3, items: { type: 'string', enum: pool.map((t) => t.id) } } }, required: ['ids'] }, 40);
    ms = r.ms;
    const got = Array.isArray(r.data?.ids) ? [...new Set(r.data!.ids.filter((id) => pool.some((t) => t.id === id)))] : [];
    accepted = got.length >= 2;
    // Hậu kiểm: luôn có ít nhất 1 mẹo của danh mục trọng tâm đầu tiên
    ids = accepted ? got : [];
    if (focus[0] && !ids.some((id) => BANK[focus[0]].some((t) => t.id === id))) ids.unshift(BANK[focus[0]][0].id);
    for (const c of focus) if (ids.length < 3 && !ids.some((id) => BANK[c].some((t) => t.id === id))) ids.push(BANK[c][0].id);
    if (ids.length < 2) ids.push(BANK._chung[0].id);
    ids = ids.slice(0, 3);
    const lines: string[] = [];
    const top = ranked.slice(0, 3);
    if (asked) {
      const a = ranked.find((r) => r.name === asked);
      lines.push(a ? `${h.length} tháng qua bạn chi trung bình ${money(a.avg)}/tháng cho ${asked}. Vài mẹo:` : `Vài mẹo cho ${asked}:`);
    } else if (top.length) lines.push(`${h.length} tháng qua bạn chi nhiều nhất cho ${top.map((r) => `${r.name} (TB ${money(r.avg)}/tháng)`).join(', ')}. Vài mẹo:`);
    else lines.push('Bạn chưa có nhiều dữ liệu chi tiêu, đây là vài mẹo chung:');
    for (const id of ids) lines.push(`• ${pool.find((t) => t.id === id)!.text}`);
    return { reply: lines.join('\n'), followUps: ['Gợi ý ngân sách cho tôi', 'Ngân sách tháng này thế nào?'], meta: { computed: [...computed, h.length], tips: ids, focus, llm: { calls: 1, ms: Math.round(ms), accepted } } };
  },
};
export const run = skill.run;
