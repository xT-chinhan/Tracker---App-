import type { BudgetPlanDraft, SkillDef } from '../../lib/contracts.js';
import { monthLabel, monthOf, parseMonth, shiftMonth } from '../../lib/period.js';
import { llmMeta, llmSentence, money, userGuard } from '../../lib/skillkit.js';
import { fold } from '../../lib/text.js';

const STEP = 50_000;
const roundUp = (n: number, step = STEP) => Math.ceil(n / step) * step;
/** 3 tháng ĐỦ gần nhất trước tháng hiện tại. */
const history = (now: string) => [3, 2, 1].map((k) => shiftMonth(monthOf(now), -k));
/** Tháng đích của ngân sách: "tháng sau/tới" → tháng sau; "tháng N" đã qua trong năm → tháng N năm sau (ngân sách là cho tương lai). */
const target = (input: string, now: string) => {
  if (/\bthang (sau|toi)\b|next month/.test(fold(input))) return shiftMonth(monthOf(now), 1);
  const m = parseMonth(input, now);
  if (!m || /\bthang (truoc|roi)\b|\d{4}/.test(fold(input))) return m;
  return m < monthOf(now) ? shiftMonth(m, 12) : m;
};

export const skill: SkillDef = {
  name: 'goi-y-ngan-sach', scope: 'USER', output: 'draft', providers: ['user.categoryHistory', 'user.budgets'],
  plan: (input, now) => [
    { provider: 'user.categoryHistory', params: { months: history(now) } },
    { provider: 'user.budgets', params: { month: target(input, now) ?? monthOf(now) } },
  ],
  async run({ input, context, llm, now }) {
    const g = userGuard(input, context.principal); if (g) return g;
    const h = context['user.categoryHistory'], cur = context['user.budgets'];
    if (!h) return { reply: 'Mình chưa lấy được lịch sử chi tiêu, bạn thử lại sau nhé.', meta: { error: 'missing user.categoryHistory' } };
    const explicit = target(input, now);
    const hasCur = !!cur && (!!cur.overall || cur.items.length > 0);
    // Không nói tháng: tháng này chưa có ngân sách → gợi ý tháng này, có rồi → tháng sau
    const month = explicit ?? (hasCur ? shiftMonth(monthOf(now), 1) : monthOf(now));
    const seen = h.filter((m) => m.expense > 0);
    if (seen.length < 2) {
      return { reply: `Mình cần ít nhất 2 tháng có chi tiêu để gợi ý ngân sách; hiện mới có ${seen.length} tháng.`, followUps: ['Cách tạo ngân sách'], meta: { computed: [2, seen.length], llm: llmMeta(null) } };
    }
    const n = h.length;
    // Trung vị theo tháng (tháng không chi = 0): bền với khoản mua lớn một lần (vd mua máy giặt).
    const med = (xs: number[]) => { const a = [...xs].sort((x, y) => x - y); return a.length % 2 ? a[(a.length - 1) / 2] : Math.round((a[a.length / 2 - 1] + a[a.length / 2]) / 2); };
    const names = [...new Set(h.flatMap((m) => m.expenseByCategory.map((c) => c.categoryName)))];
    const computed: number[] = [n, +month.slice(5)];
    const items = names
      .map((categoryName) => {
        const xs = h.map((m) => m.expenseByCategory.find((c) => c.categoryName === categoryName)?.amount ?? 0);
        return { categoryName, avg3m: Math.round(xs.reduce((s, x) => s + x, 0) / n), median3m: med(xs), monthsSeen: xs.filter((x) => x > 0).length };
      })
      .filter((x) => x.monthsSeen >= 2 && x.median3m >= 200_000)
      .sort((a, b) => b.median3m - a.median3m).slice(0, 6)
      .map((x) => ({ ...x, limitAmount: Math.max(roundUp(x.median3m), 100_000) }));
    const medTotal = med(h.map((m) => m.expense));
    const overall = roundUp(medTotal, 100_000);
    computed.push(medTotal, overall, ...items.flatMap((x) => [x.avg3m, x.median3m, x.limitAmount]));
    const draft: BudgetPlanDraft = { kind: 'budget-plan', month, overall, items };
    const existing = cur && cur.month === month && (cur.overall || cur.items.length) ? `\nLưu ý: ${monthLabel(month, now)} đã có ngân sách; xác nhận sẽ cập nhật hạn mức theo gợi ý.` : '';
    const lines = [
      `Gợi ý ngân sách ${monthLabel(month, now)} (theo mức chi trung vị ${n} tháng ${h.map((m) => +m.month.slice(5)).join(', ')}, làm tròn lên):`,
      `• Ngân sách tổng: ${money(overall)} (trung vị ${money(medTotal)}/tháng)`,
      ...items.map((x) => `• ${x.categoryName}: ${money(x.limitAmount)} (trung vị ${money(x.median3m)}, TB ${money(x.avg3m)}${x.monthsSeen < n ? `, có chi ${x.monthsSeen}/${n} tháng` : ''})`),
    ];
    const big = items[0]?.categoryName;
    const s = await llmSentence(llm, 'Viết một câu lời khuyên ngắn khi người dùng đặt ngân sách theo gợi ý.',
      [big ? `danh mục chi lớn nhất là ${big}` : '', 'hạn mức gợi ý bằng mức chi thường gặp làm tròn lên', 'người dùng có thể sửa hạn mức trước khi xác nhận'].filter(Boolean),
      'Bạn có thể hạ dần hạn mức ở các mục chi lớn nếu muốn tiết kiệm thêm.');
    lines.push(s.text + existing);
    return { reply: lines.join('\n'), draft, followUps: ['Xác nhận tạo ngân sách', 'Sửa hạn mức ăn uống'], meta: { computed, llm: llmMeta(s), llmText: s.text } };
  },
};
export const run = skill.run;
