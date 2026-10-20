import type { ReplyBlock, Skill, UserActivityRow } from '../../lib/contracts.js';
import { dmy, parsePeriod } from '../../lib/period.js';
import { adminGuard, fetchP, int, vnHm } from '../../lib/skillkit.js';
import { fold } from '../../lib/text.js';

const DAY = 86400000;
const vnDate = (iso: string) => new Date(new Date(iso).getTime() + 7 * 3600000).toISOString().slice(0, 10);

/**
 * Người dùng mới đăng ký trong khoảng thời gian (mặc định 30 ngày) và ai trong số đó chưa ghi giao dịch nào.
 * Chỉ đọc số liệu (adminUserActivity), không gọi model → trả lời ngay. Mockup admin A10b.
 */
export const skill: Skill = {
  name: 'nguoi-dung-moi', scope: 'ADMIN', description: 'Người dùng mới đăng ký và ai chưa ghi giao dịch nào', context: [],
  async run({ input, context, now }) {
    const g = adminGuard(input, context.principal); if (g) return g;
    const users = await fetchP<UserActivityRow[]>(context, 'adminUserActivity');
    if (!users) return { reply: 'Chưa lấy được dữ liệu người dùng, thử lại sau.', meta: { error: 'missing adminUserActivity' } };
    const p = parsePeriod(input, now);
    const from = p?.from ?? vnDate(new Date(new Date(now).getTime() - 30 * DAY).toISOString());
    const to = p?.to ?? '9999-12-31';
    const label = p?.label ?? '30 ngày qua';
    const fresh = users.filter((u) => u.role === 'USER' && vnDate(u.createdAt) >= from && vnDate(u.createdAt) < to)
      .sort((a, b) => b.createdAt.localeCompare(a.createdAt));
    const onlyIdle = !/\b(tat ca|danh sach nguoi dung moi|ai moi dang ky|bao nhieu nguoi moi)\b/.test(fold(input));
    const idle = fresh.filter((u) => u.txCount30d === 0);
    const show = onlyIdle ? idle : fresh;
    const computed = [fresh.length, idle.length, Math.max(0, show.length - 10)];
    if (!fresh.length) return { reply: `Không có người dùng mới đăng ký trong ${label}.`, followUps: ['Tổng quan hệ thống'], meta: { computed } };

    const head = `Có ${int(idle.length)} trên ${int(fresh.length)} người đăng ký trong ${label} chưa ghi giao dịch nào.`;
    const fmt = (u: UserActivityRow) => `${u.name} (${u.email}), đăng ký ${dmy(vnDate(u.createdAt))}, ${u.txCount30d ? `${int(u.txCount30d)} giao dịch` : 'chưa ghi giao dịch'}`;
    const lines = [head, ...show.slice(0, 10).map((u) => `• ${fmt(u)}`)];
    if (show.length > 10) lines.push(`… và ${int(show.length - 10)} người khác.`);
    const note = 'Thông báo hệ thống hiện chỉ gửi được tới mọi người dùng, chưa gửi riêng cho nhóm này.';
    if (idle.length) lines.push(note);

    const blocks: ReplyBlock[] = [{ type: 'text', text: `Có **${int(idle.length)} trên ${int(fresh.length)}** người đăng ký trong ${label} chưa ghi giao dịch nào.` }];
    if (show.length) {
      blocks.push({
        type: 'table', columns: ['Người dùng', 'Đăng ký', 'Đăng nhập cuối', 'Giao dịch'], align: ['left', 'left', 'left', 'right'],
        rows: show.slice(0, 10).map((u) => [`${u.name}\n${u.email}`, dmy(vnDate(u.createdAt)).slice(0, 5), u.lastLoginAt ? `${dmy(vnDate(u.lastLoginAt)).slice(0, 5)} · ${vnHm(u.lastLoginAt)}` : 'Chưa mở lại', int(u.txCount30d)]),
        links: show.slice(0, 10).map((u) => `/users/${u.id}`),
        more: show.length > 10 ? `… và ${int(show.length - 10)} người khác` : undefined,
      });
    }
    if (idle.length) blocks.push({ type: 'text', text: note });
    blocks.push({ type: 'source', text: `Từ bảng người dùng và giao dịch · ${label} · lúc ${vnHm(now)}` });
    return {
      reply: lines.join('\n'), blocks,
      followUps: idle.length ? ['Soạn thông báo hướng dẫn ghi giao dịch đầu tiên', 'Tổng quan hệ thống'] : ['Tổng quan hệ thống'],
      meta: { computed, llm: { calls: 0, ms: 0, accepted: null } },
    };
  },
};
export const run = skill.run;
