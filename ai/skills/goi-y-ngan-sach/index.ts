import type { BudgetItemPayload, BudgetsData, MonthSummaryData, Skill } from '../../lib/contracts.js';
import { monthLabel, monthOf, parseMonth, shiftMonth } from '../../lib/period.js';
import { fetchP, llmMeta, llmSentence, money, userGuard } from '../../lib/skillkit.js';
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

export const skill: Skill = {
  name: 'goi-y-ngan-sach', scope: 'USER', description: 'Gợi ý ngân sách từ chi tiêu 3 tháng gần nhất (nháp)', context: [],
  async run({ input, context, llm, now }) {
    const g = userGuard(input, context.principal); if (g) return g;
    // Chi theo danh mục từng tháng: monthSummary.topExpenses (xin backend trả đủ theo `limit`; hiện cắt 5 mục)
    const hs = await Promise.all(history(now).map((m) => fetchP<MonthSummaryData>(context, 'monthSummary', { month: m, limit: 20 })));
    if (hs.some((x) => !x)) return { reply: 'Mình chưa lấy được lịch sử chi tiêu, bạn thử lại sau nhé.', meta: { error: 'missing monthSummary' } };
    const h = hs.map((x) => ({ month: x!.month, expense: x!.expense, expenseByCategory: x!.topExpenses.map((c) => ({ categoryName: c.name, amount: c.amount })) }));
    const explicit = target(input, now);
    const curB = await fetchP<BudgetsData>(context, 'budgets', { month: monthOf(now) });
    const hasCur = !!curB && (!!curB.overall || curB.items.length > 0);
    // Không nói tháng: tháng này chưa có ngân sách → gợi ý tháng này, có rồi → tháng sau
    const month = explicit ?? (hasCur ? shiftMonth(monthOf(now), 1) : monthOf(now));
    const cur = month === monthOf(now) ? curB : await fetchP<BudgetsData>(context, 'budgets', { month });
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
    computed.push(medTotal, overall, ...items.flatMap((x) => [x.avg3m, x.median3m, x.limitAmount, x.monthsSeen]));
    const payload: { items: BudgetItemPayload[] } = {
      items: [{ categoryName: null, month, limitAmount: overall, median3m: medTotal }, ...items.map((x) => ({ categoryName: x.categoryName, month, limitAmount: x.limitAmount, median3m: x.median3m, avg3m: x.avg3m, monthsSeen: x.monthsSeen }))],
    };
    const existing = cur && (cur.overall || cur.items.length) ? `\nLưu ý: ${monthLabel(month, now)} đã có ngân sách; xác nhận sẽ cập nhật hạn mức theo gợi ý.` : '';
    const lines = [
      `Gợi ý ngân sách ${monthLabel(month, now)} (theo mức chi trung vị ${n} tháng ${h.map((m) => +m.month.slice(5)).join(', ')}, làm tròn lên):`,
      `• Ngân sách tổng: ${money(overall)} (trung vị ${money(medTotal)}/tháng)`,
      ...items.map((x) => `• ${x.categoryName}: ${money(x.limitAmount)} (trung vị ${money(x.median3m)}, TB ${money(x.avg3m)}${x.monthsSeen < n ? `, có chi ${x.monthsSeen} trong ${n} tháng` : ''})`),
    ];
    const big = items[0]?.categoryName;
    const s = await llmSentence(llm, 'Viết một câu lời khuyên ngắn khi người dùng đặt ngân sách theo gợi ý.',
      [big ? `danh mục chi lớn nhất là ${big}` : '', 'hạn mức gợi ý bằng mức chi thường gặp làm tròn lên', 'người dùng có thể sửa hạn mức trước khi xác nhận'].filter(Boolean),
      'Bạn có thể hạ dần hạn mức ở các mục chi lớn nếu muốn tiết kiệm thêm.');
    lines.push(s.text + existing);
    return { reply: lines.join('\n'), draft: { kind: 'budgets', payload }, followUps: ['Xác nhận tạo ngân sách', 'Sửa hạn mức ăn uống'], meta: { computed, llm: llmMeta(s), llmText: s.text } };
  },
};
export const run = skill.run;
