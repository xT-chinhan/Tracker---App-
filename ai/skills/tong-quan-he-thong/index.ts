import type { AdminOverviewData, Skill } from '../../lib/contracts.js';
import { monthLabel, monthOf } from '../../lib/period.js';
import { adminGuard, fetchP, int, llmMeta, llmSentence, money, pct } from '../../lib/skillkit.js';

const GOAL = { ACTIVE: 'đang chạy', COMPLETED: 'đã hoàn thành', WITHDRAWN: 'đã rút', EARLY_WITHDRAWN: 'rút sớm' } as Record<string, string>;

export const skill: Skill = {
  name: 'tong-quan-he-thong', scope: 'ADMIN', description: 'Tổng quan hệ thống: người dùng, giao dịch, mục tiêu, xu hướng chi', context: ['adminOverview'],
  async run({ input, context, llm, now }) {
    const g = adminGuard(input, context.principal); if (g) return g;
    const o = await fetchP<AdminOverviewData>(context, 'adminOverview');
    if (!o) return { reply: 'Chưa lấy được số liệu tổng quan, thử lại sau.', meta: { error: 'missing adminOverview' } };
    const computed: number[] = [];
    const lines = [
      `Người dùng: ${int(o.users.total)} tài khoản (${int(o.users.active)} hoạt động, ${int(o.users.locked)} bị khóa), ${int(o.users.new30d)} tài khoản mới trong 30 ngày.`,
      `Giao dịch: ${int(o.transactions.total)} tổng (${int(o.transactions.new30d)} trong 30 ngày); tổng thu ${money(o.transactions.totalIncome)}, tổng chi ${money(o.transactions.totalExpense)}.`,
    ];
    const gs = Object.entries(o.savingGoals).filter(([, n]) => n > 0);
    if (gs.length) lines.push(`Mục tiêu tiết kiệm: ${gs.map(([k, n]) => `${int(n)} ${GOAL[k] ?? k}`).join(', ')}.`);
    const t = o.trend;
    const cur = monthOf(now);
    const full = t.filter((m) => m.month !== cur);
    let trendFact = '';
    if (full.length >= 2) {
      const a = full[full.length - 2], b = full[full.length - 1];
      const ch = a.expense ? Math.round(((b.expense - a.expense) / a.expense) * 1000) / 10 : 0;
      computed.push(Math.abs(ch));
      trendFact = ch > 5 ? 'tổng chi toàn hệ thống tăng so với tháng trước' : ch < -5 ? 'tổng chi toàn hệ thống giảm so với tháng trước' : 'tổng chi toàn hệ thống ổn định';
      lines.push(`Chi toàn hệ thống ${monthLabel(b.month, now)}: ${money(b.expense)} (${ch >= 0 ? 'tăng' : 'giảm'} ${pct(Math.abs(ch))} so với ${monthLabel(a.month, now)}); thu ${money(b.income)}.`);
    }
    const c = t.find((m) => m.month === cur);
    if (c) lines.push(`${monthLabel(cur, now)[0].toUpperCase()}${monthLabel(cur, now).slice(1)} đến nay: thu ${money(c.income)}, chi ${money(c.expense)}.`);
    const facts = [o.users.locked ? 'có một số tài khoản đang bị khóa' : 'không có tài khoản bị khóa', o.users.new30d ? 'có người dùng mới trong tháng qua' : 'không có người dùng mới', trendFact].filter(Boolean);
    const s = await llmSentence(llm, 'Viết một câu nhận xét ngắn cho quản trị viên về tình hình hệ thống.', facts, 'Hệ thống hoạt động bình thường, chưa thấy biến động lớn.');
    lines.push(s.text);
    return { reply: lines.join('\n'), followUps: ['Có tài khoản nào bất thường không?', 'Danh sách tài khoản bị khóa'], meta: { computed, llm: llmMeta(s), llmText: s.text } };
  },
};
export const run = skill.run;
