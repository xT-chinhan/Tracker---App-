import type { CategoryAmount, MonthReportCtx, PeriodSummaryCtx, SkillDef } from '../../lib/contracts.js';
import { dm, monthLabel, monthOf, parsePeriod, vnDay } from '../../lib/period.js';
import { llmMeta, llmSentence, money, pct, userGuard } from '../../lib/skillkit.js';
import { fold } from '../../lib/text.js';

const signed = (n: number) => (n > 0 ? '+' : '') + money(n);
const top = (cats: CategoryAmount[], k = 3) => cats.slice(0, k).map((c) => `${c.categoryName} ${money(c.amount)} (${pct(c.percentage)})`).join(', ');
const TASK = 'Viết một câu nhận xét ngắn về tình hình thu chi, có thể kèm một lời khuyên nhẹ nhàng.';

export const skill: SkillDef = {
  name: 'tong-ket-thang', scope: 'USER', output: 'text', providers: ['user.monthReport', 'user.periodSummary'],
  plan(input, now) {
    const p = parsePeriod(input, now);
    if (!p || p.kind === 'month') return [{ provider: 'user.monthReport', params: { month: p?.month ?? monthOf(now) } }];
    return [{ provider: 'user.periodSummary', params: { from: p.from, to: p.to } }];
  },
  async run({ input, context, llm, now }) {
    const g = userGuard(input, context.principal); if (g) return g;
    const r = context['user.monthReport'], s = context['user.periodSummary'];
    if (r) return month(r, input, now, llm);
    if (s) return period(s, input, now, llm);
    return { reply: 'Mình chưa lấy được số liệu, bạn thử lại sau nhé.', meta: { error: 'missing context' } };
  },
};
export const run = skill.run;

async function month(r: MonthReportCtx, input: string, now: string, llm: any) {
  const label = monthLabel(r.month, now);
  const isCur = r.month === monthOf(now);
  const head = `${label[0].toUpperCase()}${label.slice(1)}${isCur ? ` (tính đến ${dm(new Date(vnDay(now)).toISOString().slice(0, 10))})` : ''}`;
  if (!r.income && !r.expense) {
    return { reply: `${head}: chưa có giao dịch thu chi nào.`, followUps: ['Ghi giao dịch', 'Tổng kết tháng trước'], meta: { llm: llmMeta(null) } };
  }
  const lines = [`${head}: thu ${money(r.income)}, chi ${money(r.expense)}, chênh lệch ${signed(r.net)}.`];
  if (r.expenseByCategory.length) lines.push(`Chi nhiều nhất: ${top(r.expenseByCategory)}.`);
  if (/thu nhap|thu vao|kiem duoc|luong/.test(fold(input)) && r.incomeByCategory.length) lines.push(`Nguồn thu: ${top(r.incomeByCategory)}.`);
  const c = r.comparison.expense;
  const prevLabel = monthLabel(r.comparison.previousMonth, now);
  if (c.previous > 0 && c.percentageChange !== null) {
    const verb = c.trend === 'increase' ? 'tăng' : c.trend === 'decrease' ? 'giảm' : 'gần như không đổi';
    lines.push(`So với ${prevLabel} (${money(c.previous)}): chi ${verb}${c.trend === 'stable' ? '' : ` ${pct(Math.abs(c.percentageChange))}`}${isCur ? ', lưu ý tháng này chưa hết' : ''}.`);
  }
  if (r.largestExpense) lines.push(`Khoản chi lớn nhất: ${r.largestExpense.title} ${money(r.largestExpense.amount)} (${dm(r.largestExpense.date)}).`);
  const facts = [
    r.net >= 0 ? 'thu nhiều hơn chi' : 'chi nhiều hơn thu',
    c.previous > 0 ? `chi tiêu ${c.trend === 'increase' ? 'tăng' : c.trend === 'decrease' ? 'giảm' : 'ổn định'} so với tháng trước` : 'chưa có số liệu tháng trước',
    r.expenseByCategory[0] ? `danh mục chi nhiều nhất là ${r.expenseByCategory[0].categoryName}` : '',
    isCur ? 'tháng này chưa kết thúc' : 'tháng đã kết thúc',
  ].filter(Boolean);
  const fb = r.net >= 0 ? 'Bạn đang chi tiêu trong khả năng, cứ giữ nhịp này nhé.' : 'Chi đang vượt thu, bạn thử xem lại các khoản lớn nhé.';
  const s = await llmSentence(llm, TASK, facts, fb);
  lines.push(s.text);
  return { reply: lines.join('\n'), followUps: ['Ngân sách tháng này thế nào?', 'Mẹo tiết kiệm cho tôi'], meta: { llm: llmMeta(s), llmText: s.text } };
}

async function period(s: PeriodSummaryCtx, input: string, now: string, llm: any) {
  const p = parsePeriod(input, now)!;
  const head = p.label[0].toUpperCase() + p.label.slice(1);
  if (!s.income && !s.expense) return { reply: `${head}: chưa có giao dịch thu chi nào.`, meta: { llm: llmMeta(null) } };
  const lines = [`${head}: chi ${money(s.expense)} (${s.expenseCount} khoản), thu ${money(s.income)} (${s.incomeCount} khoản).`];
  if (s.expenseByCategory.length) lines.push(`Chi nhiều nhất: ${top(s.expenseByCategory)}.`);
  const fb = s.net >= 0 ? 'Khoảng thời gian này bạn thu nhiều hơn chi.' : 'Khoảng thời gian này bạn chi nhiều hơn thu.';
  const sent = await llmSentence(llm, TASK, [s.net >= 0 ? 'thu nhiều hơn chi' : 'chi nhiều hơn thu', s.expenseByCategory[0] ? `chi nhiều nhất cho ${s.expenseByCategory[0].categoryName}` : ''].filter(Boolean), fb);
  lines.push(sent.text);
  return { reply: lines.join('\n'), followUps: ['Tổng kết cả tháng này'], meta: { llm: llmMeta(sent), llmText: sent.text } };
}
