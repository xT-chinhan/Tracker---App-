import type { Skill } from '../../lib/contracts.js';
import { asksOtherUser, isInjection, refusal } from '../../lib/skillkit.js';
import { fold } from '../../lib/text.js';
import { findAmounts } from '../../parser/money.js';

/** Việc của quản trị mà phiên USER hỏi tới (và ngược lại: việc tài chính cá nhân trong phiên ADMIN). */
export const ADMIN_ONLY = /\b(khoa (tai khoan|user|nguoi dung|nick)|mo khoa|broadcast|gui thong bao (cho|toi|den) (tat ca|moi|toan)|tong quan he thong|cau hinh he thong|che do bao tri|bat bao tri|smtp|trang quan tri|quyen admin|nang quyen|ha quyen|danh sach (user|nguoi dung)|tat ca (user|nguoi dung)|lock (user|account)|system overview|(soan|viet|gui|tao) (giup |cho )?(mot )?(thong bao|broadcast) (cho|toi|den|gui)?|broadcast)\b/;
export const PERSONAL = /\b(so du (cua )?(toi|minh|vi)|vi (momo|tien mat)( cua (toi|minh))?|ngan sach cua (toi|minh)|chi tieu cua (toi|minh)|muc tieu (tiet kiem )?cua (toi|minh)|ghi (giup|cho|lai)? ?(toi|minh)? ?(khoan|chi|thu)|my (balance|wallet|budget|spending))\b/;

export const skill: Skill = {
  name: 'ngoai-pham-vi', scope: 'ANY', description: 'Từ chối lịch sự: ngoài phạm vi, dữ liệu người khác, prompt injection, sai phạm vi phiên', context: [],
  async run({ input, context }) {
    const role = context.principal.role;
    const f = fold(input);
    if (isInjection(input)) return refusal('injection', role);
    if (role === 'USER' && ADMIN_ONLY.test(f)) return refusal('scope', 'USER');
    if (role === 'USER' && asksOtherUser(input)) return refusal('other_user', role);
    if (role === 'ADMIN' && (PERSONAL.test(f) || (findAmounts(f).length > 0 && !/\?/.test(f)))) return refusal('scope', 'ADMIN');
    return refusal('off_topic', role);
  },
};
export const run = skill.run;
