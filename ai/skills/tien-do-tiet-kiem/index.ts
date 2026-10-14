import type { SavingGoalRow, Skill } from '../../lib/contracts.js';
import { dmy } from '../../lib/period.js';
import { fetchP, llmMeta, llmSentence, money, pct, userGuard } from '../../lib/skillkit.js';
import { fold } from '../../lib/text.js';

/** Dòng savingGoals + phần code tính: còn thiếu, số ngày còn lại (cùng công thức saving-goals.withProgress). */
type GoalCtx = SavingGoalRow & { remaining: number; daysLeft: number; targetAmount: number; savedAmount: number };
const enrich = (g: SavingGoalRow, now: string): GoalCtx => ({
  ...g, targetAmount: g.target, savedAmount: g.saved, remaining: Math.max(g.target - g.saved, 0),
  daysLeft: Math.max(Math.ceil((new Date(g.targetDate as any).getTime() - new Date(now as any).getTime()) / 86400000), 0),
});
const vnDate = (iso: string) => dmy(new Date(new Date(iso as any).getTime() + 7 * 3600000).toISOString().slice(0, 10));
const GENERIC = new Set('muc tieu tiet kiem quy ong heo tien do duoc bao nhieu phan tram roi chua cua minh toi em cac nhung the nao toi dau con bao lau nua thi du de mua di khi nao gio hien co la gop thang nay bo bao gio sao xem cho kiem tra ve'.split(' '));

/** Khớp mục tiêu: mọi token của cụm người dùng nhắc (sau khi bỏ từ chung) có trong tên mục tiêu, hoặc ngược lại. */
function matchGoal(input: string, goals: GoalCtx[]): { goal: GoalCtx | null; mention: string | null } {
  const words = fold(input).replace(/[^a-z0-9\s]/g, ' ').split(/\s+/).filter((w) => w && !GENERIC.has(w));
  if (!words.length) return { goal: null, mention: null };
  let best: { g: GoalCtx; s: number } | null = null;
  for (const g of goals) {
    const gt = fold(g.name).split(/[^a-z0-9]+/).filter(Boolean);
    const s = words.filter((w) => gt.includes(w)).length;
    if (s > 0 && (!best || s > best.s)) best = { g, s };
  }
  return { goal: best?.g ?? null, mention: words.join(' ') };
}

function detail(g: GoalCtx, computed: number[]): string {
  computed.push(g.remaining, g.daysLeft);
  const head = `${g.name}: đã có ${money(g.savedAmount)} / ${money(g.targetAmount)} (${pct(g.progress)})`;
  if (g.status === 'COMPLETED') return `${head}. Mục tiêu đã hoàn thành.`;
  if (g.status === 'WITHDRAWN') return `${g.name}: đã hoàn thành và rút tiền về ví.`;
  if (g.status === 'EARLY_WITHDRAWN') return `${g.name}: đã rút tiền trước hạn, mục tiêu đã đóng.`;
  if (g.daysLeft <= 0) return `${head}, còn thiếu ${money(g.remaining)}; đã quá hạn ${vnDate(g.targetDate)}.`;
  const perMonth = Math.ceil(g.dailyRequired * 30); computed.push(perMonth);
  return `${head}, còn thiếu ${money(g.remaining)}. Hạn ${vnDate(g.targetDate)} (còn ${g.daysLeft} ngày) → cần góp khoảng ${money(g.dailyRequired)}/ngày (~${money(perMonth)}/tháng).`;
}

export const skill: Skill = {
  name: 'tien-do-tiet-kiem', scope: 'USER', description: 'Tiến độ mục tiêu tiết kiệm, cần góp mỗi ngày', context: ['savingGoals'],
  async run({ input, context, llm, now }) {
    const g = userGuard(input, context.principal); if (g) return g;
    const rows = await fetchP<SavingGoalRow[]>(context, 'savingGoals');
    if (!rows) return { reply: 'Mình chưa lấy được mục tiêu tiết kiệm, bạn thử lại sau nhé.', meta: { error: 'missing savingGoals' } };
    const goals = rows.map((x) => enrich(x, now));
    if (!goals.length) return { reply: 'Bạn chưa có mục tiêu tiết kiệm nào. Hãy tạo trong Cài đặt › Tiết kiệm.', followUps: ['Cách tạo mục tiêu tiết kiệm'], meta: { llm: llmMeta(null) } };
    const computed: number[] = [];
    const { goal, mention } = matchGoal(input, goals);
    const open = goals.filter((x) => x.status === 'ACTIVE' || x.status === 'COMPLETED');
    let lines: string[];
    let focus: GoalCtx[];
    if (goal) { lines = [detail(goal, computed)]; focus = [goal]; }
    else {
      const saved = open.reduce((s, x) => s + x.savedAmount, 0), target = open.reduce((s, x) => s + x.targetAmount, 0);
      computed.push(saved, target);
      lines = [
        ...(mention && /\b(muc tieu|tiet kiem|quy|du tien)\b/.test(fold(input)) && mention.split(' ').length <= 4 ? [`Mình không thấy mục tiêu nào khớp "${mention}". Các mục tiêu hiện có:`] : []),
        `Đã tiết kiệm ${money(saved)} trên tổng ${money(target)} của ${open.length} mục tiêu:`,
        ...open.map((x) => `• ${detail(x, computed)}`),
      ];
      focus = open;
    }
    const late = focus.filter((x) => x.status === 'ACTIVE' && x.daysLeft <= 0).map((x) => x.name);
    const near = focus.filter((x) => x.status === 'ACTIVE' && x.progress >= 70).map((x) => x.name);
    const facts = [
      near.length ? `gần đạt: ${near.join(', ')}` : '',
      late.length ? `đã quá hạn: ${late.join(', ')}` : '',
      focus.some((x) => x.status === 'COMPLETED') ? 'có mục tiêu đã hoàn thành' : '',
      'người dùng đang theo dõi tiến độ tiết kiệm',
    ].filter(Boolean);
    const s = await llmSentence(llm, 'Viết một câu động viên ngắn về tiến độ tiết kiệm.', facts, 'Cứ góp đều đặn mỗi tháng, bạn sẽ đạt mục tiêu đúng hạn.');
    lines.push(s.text);
    return { reply: lines.join('\n'), followUps: ['Cách nạp tiền vào mục tiêu', 'Số dư các ví của tôi'], meta: { computed, llm: llmMeta(s), llmText: s.text } };
  },
};
export const run = skill.run;
