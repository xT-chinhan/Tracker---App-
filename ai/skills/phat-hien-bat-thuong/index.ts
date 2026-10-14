import type { AdminAnomaliesData, Skill, UserActivityRow } from '../../lib/contracts.js';
import { dmy } from '../../lib/period.js';
import { adminGuard, fetchP, int, llmMeta, llmSentence } from '../../lib/skillkit.js';
import { detect } from './rules.js';

const KIND = { 'spend-spike': 'chi tiêu tăng vọt', 'big-expense': 'khoản chi lớn bất thường', 'tx-burst': 'số giao dịch dồn dập', 'failed-logins': 'đăng nhập sai nhiều lần' };

export const skill: Skill = {
  name: 'phat-hien-bat-thuong', scope: 'ADMIN', description: 'Phát hiện bất thường bằng luật (chi tăng vọt, khoản chi lớn, giao dịch dồn dập, đăng nhập sai)', context: [],
  async run({ input, context, llm, now }) {
    const g = adminGuard(input, context.principal); if (g) return g;
    const users = await fetchP<UserActivityRow[]>(context, 'adminUserActivity');
    if (!users) {
      // Backend chưa có adminUserActivity → chỉ báo được phần adminAnomalies sẵn có
      const a = await fetchP<AdminAnomaliesData>(context, 'adminAnomalies');
      if (!a) return { reply: 'Chưa lấy được dữ liệu hoạt động, thử lại sau.', meta: { error: 'missing adminUserActivity/adminAnomalies' } };
      const busy = a.mostActive24h.map((x) => `• ${x.email}: ${int(x.transactions)} giao dịch trong 24 giờ`);
      return { reply: [`Tài khoản đang bị khóa: ${int(a.lockedUsers)}.`, busy.length ? `Ghi giao dịch dồn dập trong 24 giờ:\n${busy.join('\n')}` : 'Không thấy tài khoản nào ghi dồn dập trong 24 giờ.', 'Lưu ý: chưa có dữ liệu chi tiêu theo người dùng nên chưa kiểm tra được chi tăng vọt / khoản chi lớn.'].join('\n'), meta: { degraded: true, llm: llmMeta(null) } };
    }
    const { flags, median, day } = detect(users, now);
    const computed = [median, day, ...flags.flatMap((f) => f.numbers)];
    const byUser = new Map<string, typeof flags>();
    for (const f of flags) byUser.set(f.userId, [...(byUser.get(f.userId) ?? []), f]);
    const locked = users.filter((u) => u.status === 'LOCKED');
    const lines: string[] = [];
    if (!byUser.size) lines.push(`Không thấy bất thường theo các luật hiện có (chi tăng vọt, khoản chi lớn, giao dịch dồn dập) trên ${int(users.length)} tài khoản.`);
    else {
      lines.push(`Phát hiện ${int(byUser.size)} tài khoản có dấu hiệu bất thường (xếp theo mức độ):`);
      const top = [...byUser.values()].slice(0, 6);
      for (const fs of top) lines.push(`• ${fs[0].name} (${fs[0].email}): ${fs.map((f) => `${KIND[f.kind]} — ${f.reason}`).join('; ')}.`);
      if (byUser.size > top.length) lines.push(`… và ${int(byUser.size - top.length)} tài khoản khác.`);
      computed.push(byUser.size - top.length);
    }
    if (locked.length) lines.push(`Đang bị khóa: ${locked.map((u) => `${u.name} (${u.email}, đăng nhập cuối ${u.lastLoginAt ? dmy(new Date(new Date(u.lastLoginAt as any).getTime() + 7 * 3600000).toISOString().slice(0, 10)) : 'chưa có'})`).join(', ')}.`);
    if (!users.some((u) => u.failedLogins24h !== undefined)) lines.push('Lưu ý: hệ thống chưa ghi nhận số lần đăng nhập sai nên chưa kiểm tra được dấu hiệu dò mật khẩu.');
    const kinds = [...new Set(flags.map((f) => KIND[f.kind]))];
    const s = await llmSentence(llm, 'Viết một câu tóm tắt ngắn cho quản trị viên về các dấu hiệu bất thường, nhắc rằng cần xem chi tiết trước khi xử lý.',
      [kinds.length ? `loại dấu hiệu: ${kinds.join(', ')}` : 'không có dấu hiệu bất thường', locked.length ? 'có tài khoản đang bị khóa' : ''].filter(Boolean),
      byUser.size ? 'Nên xem chi tiết từng tài khoản trước khi quyết định khóa.' : 'Hệ thống chưa có dấu hiệu cần xử lý.');
    lines.push(s.text);
    const first = [...byUser.values()][0]?.[0];
    return { reply: lines.join('\n'), followUps: first ? [`Đề xuất khóa ${first.email}`, 'Tổng quan hệ thống'] : ['Tổng quan hệ thống'], meta: { computed, flags: flags.map((f) => ({ email: f.email, kind: f.kind })), llm: llmMeta(s), llmText: s.text } };
  },
};
export const run = skill.run;
