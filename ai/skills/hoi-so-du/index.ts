import type { SkillDef } from '../../lib/contracts.js';
import { findName, money, userGuard } from '../../lib/skillkit.js';
import { fold } from '../../lib/text.js';

/** Tên ví/ngân hàng phổ biến: nhắc tới mà user không có → báo không có ví đó (không đoán). */
const KNOWN = ['mb bank', 'techcombank', 'vietcombank', 'bidv', 'vietinbank', 'agribank', 'tpbank', 'vpbank', 'acb', 'sacombank', 'momo', 'zalopay', 'shopeepay', 'viettel money', 'tien mat'];
const KNOWN_LABEL: Record<string, string> = { 'mb bank': 'MB Bank', 'tien mat': 'Tiền mặt', momo: 'MoMo', zalopay: 'ZaloPay', shopeepay: 'ShopeePay', 'viettel money': 'Viettel Money', tpbank: 'TPBank', vpbank: 'VPBank', acb: 'ACB', bidv: 'BIDV' };

export const skill: SkillDef = {
  name: 'hoi-so-du', scope: 'USER', output: 'text', providers: ['user.balance'],
  plan: () => [{ provider: 'user.balance' }],
  async run({ input, context }) {
    const g = userGuard(input, context.principal); if (g) return g;
    const b = context['user.balance'];
    if (!b) return { reply: 'Mình chưa lấy được số dư, bạn thử lại sau nhé.', meta: { error: 'missing user.balance' } };
    const active = b.wallets.filter((w) => !w.isArchived);
    const name = findName(input, b.wallets.map((w) => w.name));
    if (name) {
      const w = b.wallets.find((x) => x.name === name)!;
      return {
        reply: `Ví ${w.name} hiện còn ${money(w.balance)}${w.isArchived ? ' (ví đã lưu trữ)' : ''}.` + (active.length > 1 ? ` Tổng ${active.length} ví: ${money(b.total)}.` : ''),
        followUps: ['Tháng này tôi chi bao nhiêu?', `Giao dịch gần đây của ví ${w.name}`],
        meta: { computed: [active.length] },
      };
    }
    const f = fold(input);
    const missing = KNOWN.find((k) => new RegExp(`(^|[^a-z])${k.replace(' ', '\\s*')}($|[^a-z])`).test(f));
    const list = active.slice().sort((a, c) => c.balance - a.balance).map((w) => `• ${w.name}: ${money(w.balance)}`).join('\n');
    if (missing) {
      return {
        reply: `Bạn chưa có ví ${KNOWN_LABEL[missing] ?? missing} trong ứng dụng. Các ví hiện có:\n${list}`,
        followUps: ['Làm sao thêm ví mới?'],
      };
    }
    if (!active.length) return { reply: 'Bạn chưa có ví nào. Hãy tạo ví trong Cài đặt › Ví.', followUps: ['Làm sao thêm ví mới?'] };
    const sav = b.savings > 0 ? `\nNgoài ra ${money(b.savings)} đang nằm trong các mục tiêu tiết kiệm (không tính vào số dư ví).` : '';
    return {
      reply: `Tổng số dư ${active.length} ví: ${money(b.total)}.\n${list}${sav}`,
      followUps: ['Tháng này tôi chi bao nhiêu?', 'Ngân sách tháng này còn bao nhiêu?'],
      meta: { computed: [active.length] },
    };
  },
};
export const run = skill.run;
