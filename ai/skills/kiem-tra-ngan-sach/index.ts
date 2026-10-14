import type { BudgetRow, BudgetsData, Skill } from '../../lib/contracts.js';
import { daysLeftInMonth, monthLabel, monthOf, parseMonth } from '../../lib/period.js';
import { fetchP, findName, llmMeta, llmSentence, money, pct, userGuard } from '../../lib/skillkit.js';

const STATUS = { ok: 'trong hạn mức', warning: 'sắp chạm hạn mức', exceeded: 'đã vượt hạn mức' } as const;
const CAT_ALIAS: Record<string, string[]> = {
  'an uong': ['an uong', 'an', 'do an', 'an sang', 'an trua', 'an toi', 'cafe', 'ca phe', 'tra sua'],
  'di chuyen': ['di chuyen', 'xang', 'grab', 'xe', 'di lai'],
  'mua sam': ['mua sam', 'shopping', 'shopee', 'quan ao'],
  'giai tri': ['giai tri', 'choi', 'phim', 'game'],
  'hoa don': ['hoa don', 'dien nuoc', 'tien dien', 'tien nuoc', 'internet'],
};

type BudgetLine = BudgetRow & { remaining: number };
const withRemaining = (b: BudgetRow): BudgetLine => ({ ...b, remaining: b.limit - b.spent });

function line(b: BudgetLine): string {
  const name = b.categoryName ?? 'Ngân sách tổng';
  if (b.remaining < 0) return `${name}: đã chi ${money(b.spent)} / ${money(b.limit)} (${pct(b.percentage)}), vượt ${money(-b.remaining)}.`;
  return `${name}: đã chi ${money(b.spent)} / ${money(b.limit)} (${pct(b.percentage)}), còn ${money(b.remaining)}${b.status !== 'ok' ? ', sắp chạm hạn mức' : ''}.`;
}

export const skill: Skill = {
  name: 'kiem-tra-ngan-sach', scope: 'USER', description: 'Tình trạng ngân sách, cảnh báo, mỗi ngày còn chi được bao nhiêu', context: [],
  async run({ input, context, llm, now }) {
    const g = userGuard(input, context.principal); if (g) return g;
    const raw = await fetchP<BudgetsData>(context, 'budgets', { month: parseMonth(input, now) ?? monthOf(now) });
    if (!raw) return { reply: 'Mình chưa lấy được ngân sách, bạn thử lại sau nhé.', meta: { error: 'missing budgets' } };
    const b = { month: raw.month, overall: raw.overall ? withRemaining(raw.overall) : null, items: raw.items.map(withRemaining) };
    const label = monthLabel(b.month, now);
    if (!b.overall && !b.items.length) {
      return { reply: `Bạn chưa đặt ngân sách nào cho ${label}.`, followUps: ['Gợi ý ngân sách cho tôi', 'Cách tạo ngân sách'], meta: { llm: llmMeta(null) } };
    }
    const daysLeft = daysLeftInMonth(b.month, now);
    // còn lại / vượt = limit − spent (code tính) → được phép xuất hiện
    const computed: number[] = [daysLeft, ...[b.overall, ...b.items].filter(Boolean).map((x) => x!.remaining)];
    const perDay = (x: BudgetLine) => {
      if (!daysLeft || x.remaining <= 0) return '';
      const v = Math.floor(x.remaining / daysLeft); computed.push(v, x.remaining);
      return ` Mỗi ngày còn chi được khoảng ${money(v)} (còn ${daysLeft} ngày).`;
    };
    // Hỏi một danh mục cụ thể
    const allNames = b.items.map((x) => x.categoryName!);
    const cat = findName(input, allNames, CAT_ALIAS);
    const lines: string[] = [];
    let focus: BudgetLine | null = null;
    if (cat) {
      focus = b.items.find((x) => x.categoryName === cat)!;
      lines.push(`Ngân sách ${label} — ${line(focus)}${perDay(focus)}`);
    } else {
      const asked = findName(input, ['Nhà ở', 'Hóa đơn', 'Sức khỏe', 'Giáo dục', 'Gia đình', 'Du lịch', 'Hiếu hỉ', 'Chi khác', 'Ăn uống', 'Di chuyển', 'Mua sắm', 'Giải trí'], CAT_ALIAS);
      if (asked) lines.push(`Bạn chưa đặt ngân sách riêng cho ${asked} trong ${label}.`);
      if (b.overall) { focus = b.overall; lines.push(`Ngân sách tổng ${label}: ${line(b.overall).replace(/^Ngân sách tổng: /, '')}${perDay(b.overall)}`); }
      const bad = b.items.filter((x) => x.status !== 'ok').sort((x, y) => y.percentage - x.percentage);
      const ok = b.items.filter((x) => x.status === 'ok');
      for (const x of bad) lines.push(`• ${line(x)}`);
      if (ok.length) lines.push(`• Trong hạn mức: ${ok.map((x) => `${x.categoryName} ${pct(x.percentage)}`).join(', ')}.`);
    }
    const worst = b.items.filter((x) => x.status === 'exceeded').map((x) => x.categoryName);
    const warn = b.items.filter((x) => x.status === 'warning').map((x) => x.categoryName);
    const facts = [
      focus ? `ngân sách đang hỏi ${STATUS[focus.status]}` : '',
      worst.length ? `đã vượt ngân sách: ${worst.join(', ')}` : 'không có ngân sách nào bị vượt',
      warn.length ? `sắp chạm hạn mức: ${warn.join(', ')}` : '',
      daysLeft ? 'tháng chưa kết thúc' : 'tháng đã kết thúc',
    ].filter(Boolean);
    const fb = worst.length ? `Bạn đã vượt ngân sách ${worst.join(', ')}, nên hạn chế chi thêm cho các mục này.` : warn.length ? 'Một vài ngân sách sắp chạm hạn mức, bạn chi tiêu chậm lại một chút nhé.' : 'Ngân sách đang ổn, cứ giữ nhịp chi tiêu này nhé.';
    const s = await llmSentence(llm, 'Viết một câu nhắc nhở hoặc động viên về ngân sách.', facts, fb);
    lines.push(s.text);
    return { reply: lines.join('\n'), followUps: ['Tháng này tôi chi nhiều nhất vào đâu?', 'Mẹo tiết kiệm cho tôi'], meta: { computed, llm: llmMeta(s), llmText: s.text } };
  },
};
export const run = skill.run;
