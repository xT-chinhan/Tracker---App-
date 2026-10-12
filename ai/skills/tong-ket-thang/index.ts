import type { LlmClient, MonthSummaryData, PeriodSummaryData, Skill } from '../../lib/contracts.js';
import { dm, monthLabel, monthOf, parsePeriod, shiftMonth, vnDay } from '../../lib/period.js';
import { fetchP, llmMeta, llmSentence, money, pct, userGuard } from '../../lib/skillkit.js';

const r1 = (x: number) => Math.round(x * 10) / 10;
const signed = (n: number) => (n > 0 ? '+' : '') + money(n);
const TASK = 'Viết một câu nhận xét ngắn về tình hình thu chi, có thể kèm một lời khuyên nhẹ nhàng.';
/** top 3 danh mục chi kèm % (code tính trên tổng chi) */
function top(xs: { name: string; amount: number }[], total: number, computed: number[]) {
  return xs.slice(0, 3).map((c) => { const p = r1((c.amount / (total || 1)) * 100); computed.push(p); return `${c.name} ${money(c.amount)} (${pct(p)})`; }).join(', ');
}

export const skill: Skill = {
  name: 'tong-ket-thang', scope: 'USER', description: 'Tổng kết thu chi theo tháng / tuần / khoảng ngày, so với tháng trước', context: [],
  async run({ input, context, llm, now }) {
    const g = userGuard(input, context.principal); if (g) return g;
    const p = parsePeriod(input, now);
    if (p && p.kind !== 'month') {
      const s = await fetchP<PeriodSummaryData>(context, 'periodSummary', { from: p.from, to: p.to });
      if (s) return period(s, p.label, llm);
      // backend chưa có periodSummary → tổng kết tháng chứa khoảng đó, nói rõ
      const r = await month(context, p.from.slice(0, 7), now, llm, input);
      return { ...r, reply: `Mình chưa tổng kết riêng được "${p.label}", đây là cả ${monthLabel(p.from.slice(0, 7), now)}:\n${r.reply}` };
    }
    return month(context, p?.month ?? monthOf(now), now, llm, input);
  },
};
export const run = skill.run;

async function month(context: Parameters<Skill['run']>[0]['context'], m: string, now: string, llm: LlmClient, _input: string) {
  const r = await fetchP<MonthSummaryData>(context, 'monthSummary', { month: m, limit: 10 });
  if (!r) return { reply: 'Mình chưa lấy được số liệu, bạn thử lại sau nhé.', meta: { error: 'missing monthSummary' } };
  const label = monthLabel(m, now);
  const isCur = m === monthOf(now);
  const head = `${label[0].toUpperCase()}${label.slice(1)}${isCur ? ` (tính đến ${dm(new Date(vnDay(now)).toISOString().slice(0, 10))})` : ''}`;
  if (!r.income && !r.expense) return { reply: `${head}: chưa có giao dịch thu chi nào.`, followUps: ['Ghi giao dịch', 'Tổng kết tháng trước'], meta: { llm: llmMeta(null) } };
  const computed: number[] = [];
  const lines = [`${head}: thu ${money(r.income)}, chi ${money(r.expense)}, chênh lệch ${signed(r.net)}.`];
  if (r.topExpenses.length) lines.push(`Chi nhiều nhất: ${top(r.topExpenses, r.expense, computed)}.`);
  const prevM = shiftMonth(m, -1);
  const prev = await fetchP<MonthSummaryData>(context, 'monthSummary', { month: prevM });
  let trend: 'increase' | 'decrease' | 'stable' | null = null;
  if (prev && prev.expense > 0) {
    const ch = r1(((r.expense - prev.expense) / prev.expense) * 100); computed.push(Math.abs(ch));
    trend = ch > 5 ? 'increase' : ch < -5 ? 'decrease' : 'stable'; // cùng quy ước ±5% của /stats/report
    const verb = trend === 'increase' ? 'tăng' : trend === 'decrease' ? 'giảm' : 'gần như không đổi';
    lines.push(`So với ${monthLabel(prevM, now)} (${money(prev.expense)}): chi ${verb}${trend === 'stable' ? '' : ` ${pct(Math.abs(ch))}`}${isCur ? ', lưu ý tháng này chưa hết' : ''}.`);
  }
  if (r.largestExpense) lines.push(`Khoản chi lớn nhất: ${r.largestExpense.title} ${money(r.largestExpense.amount)} (${dm(r.largestExpense.date)}).`);
  const facts = [
    r.net >= 0 ? 'thu nhiều hơn chi' : 'chi nhiều hơn thu',
    trend ? `chi tiêu ${trend === 'increase' ? 'tăng' : trend === 'decrease' ? 'giảm' : 'ổn định'} so với tháng trước` : 'chưa có số liệu tháng trước',
    r.topExpenses[0] ? `danh mục chi nhiều nhất là ${r.topExpenses[0].name}` : '',
    isCur ? 'tháng này chưa kết thúc' : 'tháng đã kết thúc',
  ].filter(Boolean);
  const s = await llmSentence(llm, TASK, facts, r.net >= 0 ? 'Bạn đang chi tiêu trong khả năng, cứ giữ nhịp này nhé.' : 'Chi đang vượt thu, bạn thử xem lại các khoản lớn nhé.');
  lines.push(s.text);
  return { reply: lines.join('\n'), followUps: ['Ngân sách tháng này thế nào?', 'Mẹo tiết kiệm cho tôi'], meta: { computed, llm: llmMeta(s), llmText: s.text } };
}

async function period(s: PeriodSummaryData, label: string, llm: LlmClient) {
  const head = label[0].toUpperCase() + label.slice(1);
  if (!s.income && !s.expense) return { reply: `${head}: chưa có giao dịch thu chi nào.`, meta: { llm: llmMeta(null) } };
  const computed: number[] = [];
  const lines = [`${head}: chi ${money(s.expense)} (${s.expenseCount} khoản), thu ${money(s.income)} (${s.incomeCount} khoản).`];
  if (s.topExpenses.length) lines.push(`Chi nhiều nhất: ${top(s.topExpenses, s.expense, computed)}.`);
  const sent = await llmSentence(llm, TASK, [s.net >= 0 ? 'thu nhiều hơn chi' : 'chi nhiều hơn thu', s.topExpenses[0] ? `chi nhiều nhất cho ${s.topExpenses[0].name}` : ''].filter(Boolean),
    s.net >= 0 ? 'Khoảng thời gian này bạn thu nhiều hơn chi.' : 'Khoảng thời gian này bạn chi nhiều hơn thu.');
  lines.push(sent.text);
  return { reply: lines.join('\n'), followUps: ['Tổng kết cả tháng này'], meta: { computed, llm: llmMeta(sent), llmText: sent.text } };
}
