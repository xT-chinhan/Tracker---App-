import type { SkillDef } from '../../lib/contracts.js';
import { findAmounts } from '../../parser/money.js';
import { money } from '../../lib/skillkit.js';
import { fold } from '../../lib/text.js';

export const skill: SkillDef = {
  name: 'hoi-lai', scope: 'BOTH', output: 'text', providers: [],
  plan: () => [],
  async run({ input, context }) {
    const admin = context.principal.role === 'ADMIN';
    const f = fold(input);
    const amt = admin ? [] : findAmounts(f);
    let ask: string;
    if (amt.length === 1 && f.replace(/[^a-z]/g, '').length <= 6) ask = `${money(amt[0].amount)} này là khoản chi hay thu, cho việc gì? Ví dụ: "ăn trưa ${money(amt[0].amount)}".`;
    else if (/\b(cai (do|kia|nay|luc nay|hoi nay)|thang kia|con cai|the con)\b/.test(f)) ask = 'Bạn đang nói tới việc nào? Mình chưa có ngữ cảnh trước đó, bạn nói rõ giúp mình nhé.';
    else ask = admin ? 'Bạn muốn mình làm gì? Ví dụ: xem tổng quan hệ thống, tìm người dùng, kiểm tra bất thường, soạn thông báo.' : 'Bạn muốn mình làm gì? Ví dụ: ghi một khoản chi, xem số dư, tổng kết tháng, kiểm tra ngân sách.';
    const followUps = admin ? ['Tổng quan hệ thống', 'Có bất thường gì không?', 'Soạn thông báo bảo trì'] : ['Số dư các ví', 'Tháng này tôi chi bao nhiêu?', 'Ghi cà phê 30k'];
    return { reply: ask, askBack: ask, followUps, meta: { computed: amt.map((a) => a.amount) } };
  },
};
export const run = skill.run;
