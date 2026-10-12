import type { LockDraft, SkillDef, UserActivity } from '../../lib/contracts.js';
import { adminGuard, int } from '../../lib/skillkit.js';
import { fold } from '../../lib/text.js';
import { detect } from '../phat-hien-bat-thuong/rules.js';

const GENERIC = new Set('de xuat khoa tai khoan user nguoi dung nick account co nen khong cho toi minh giup xem xet ly do vi sao lock ban suspend this the please hay nay do ay nhe di luon tam thoi anh chi em ban'.split(' '));

/** Xác định user đích: email (chính xác) → tên (mọi token của cụm tên có trong tên user). */
export function findTarget(input: string, users: UserActivity[]): { hits: UserActivity[]; mention: string } {
  const email = /[\w.+-]+@[\w-]+(\.[\w-]+)+/.exec(input)?.[0].toLowerCase();
  if (email) return { hits: users.filter((u) => u.email.toLowerCase() === email), mention: email };
  const words = fold(input).replace(/[^a-z0-9\s]/g, ' ').split(/\s+/).filter((w) => w && !GENERIC.has(w));
  if (!words.length) return { hits: [], mention: '' };
  const hits = users.filter((u) => { const t = fold(u.name).split(/\s+/); return words.every((w) => t.includes(w)); });
  return { hits, mention: words.join(' ') };
}

export const skill: SkillDef = {
  name: 'de-xuat-khoa', scope: 'ADMIN', output: 'draft', providers: ['admin.userActivity'],
  plan: () => [{ provider: 'admin.userActivity' }],
  async run({ input, context, now }) {
    const g = adminGuard(input, context.principal); if (g) return g;
    const users = context['admin.userActivity'];
    if (!users) return { reply: 'Chưa lấy được dữ liệu người dùng, thử lại sau.', meta: { error: 'missing admin.userActivity' } };
    const { hits, mention } = findTarget(input, users);
    if (!hits.length) {
      const ask = mention ? `Không tìm thấy tài khoản khớp "${mention}". Bạn cho mình email chính xác nhé.` : 'Bạn muốn đề xuất khóa tài khoản nào? Cho mình email hoặc họ tên.';
      return { reply: ask, askBack: ask, followUps: ['Có tài khoản nào bất thường không?'], meta: {} };
    }
    if (hits.length > 1) {
      const ask = `Có ${int(hits.length)} tài khoản khớp: ${hits.slice(0, 5).map((u) => `${u.name} (${u.email})`).join(', ')}. Bạn chọn email nào?`;
      return { reply: ask, askBack: ask, meta: { computed: [hits.length] } };
    }
    const u = hits[0];
    if (u.id === context.principal.userId) return { reply: 'Không thể đề xuất khóa chính tài khoản của bạn.', meta: { refused: 'self' } };
    if (u.status === 'LOCKED') return { reply: `${u.name} (${u.email}) đã đang bị khóa, không cần đề xuất thêm.`, followUps: ['Danh sách tài khoản bị khóa'], meta: {} };
    if (u.role === 'ADMIN') return { reply: `${u.name} (${u.email}) là quản trị viên. Hãy hạ quyền ở trang Người dùng trước nếu thật sự cần khóa; trợ lý không đề xuất khóa quản trị viên.`, meta: { refused: 'admin-target' } };
    const { flags } = detect(users, now);
    const mine = flags.filter((f) => f.userId === u.id);
    if (!mine.length) {
      return { reply: `Không thấy dấu hiệu bất thường nào của ${u.name} (${u.email}) trong dữ liệu hiện có, nên mình không đề xuất khóa. Nếu có lý do khác (khiếu nại, gian lận), bạn có thể khóa thủ công ở trang Người dùng.`, followUps: ['Có tài khoản nào bất thường không?'], meta: {} };
    }
    const reasons = mine.map((f) => f.reason[0].toUpperCase() + f.reason.slice(1));
    const draft: LockDraft = { kind: 'lock-user', userId: u.id, email: u.email, reasons };
    return {
      reply: `Đề xuất khóa ${u.name} (${u.email}) — CHƯA thực hiện, cần bạn xác nhận:\n${reasons.map((r) => `• ${r}.`).join('\n')}\nKhóa sẽ làm mọi phiên đăng nhập của tài khoản này hết hiệu lực ngay.`,
      draft, followUps: ['Xác nhận khóa', 'Hủy'], meta: { computed: mine.flatMap((f) => f.numbers) },
    };
  },
};
export const run = skill.run;
