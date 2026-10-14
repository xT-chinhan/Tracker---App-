import type { UserContext } from '../../lib/types.js';

// Gợi ý ngắn cho danh mục hệ thống + vài danh mục user hay tạo. Danh mục khác chỉ hiện tên.
const HINTS: Record<string, string> = {
  'Ăn uống': 'ăn, uống, cà phê, trà sữa, nhậu, nhà hàng, đi chợ, siêu thị, thực phẩm (rau, thịt, cá, gạo, trứng, trái cây…) kể cả khi có chữ "mua"',
  'Di chuyển': 'xăng, grab, be, taxi, gửi xe, vé xe, sửa xe',
  'Mua sắm': 'quần áo, giày, mỹ phẩm, đồ điện tử, đồ gia dụng, đơn shopee/lazada; KHÔNG gồm đồ ăn, thực phẩm, thuốc, đồ cho con',
  'Hóa đơn': 'điện, nước, internet, cước điện thoại, nạp tiền điện thoại',
  'Nhà ở': 'tiền nhà, thuê phòng, phí chung cư, sửa nhà',
  'Sức khỏe': 'khám bệnh, thuốc, bảo hiểm y tế, gym',
  'Giáo dục': 'học phí, sách, khóa học',
  'Giải trí': 'phim, game, karaoke, netflix, spotify',
  'Chi khác': 'cắt tóc, lì xì cho người khác, từ thiện, photo, phạt; chi không rõ loại',
  'Hiếu hỉ': 'đám cưới, đám tang, mừng, phúng viếng',
  'Du lịch': 'khách sạn, vé máy bay, tour',
  'Gia đình': 'gửi/cho/biếu bố mẹ ông bà; bỉm, tã, sữa bột, đồ chơi, đồ cho con',
  'Lương': 'lương tháng',
  'Thưởng': 'thưởng, KPI, thưởng Tết',
  'Đầu tư': 'lãi, cổ tức, chứng khoán',
  'Được tặng': 'người khác cho/tặng/lì xì mình',
  'Thu khác': 'bán đồ, hoàn tiền, cashback, freelance, dạy kèm, làm thêm, tiền công',
};

export function categoryBlock(ctx: UserContext): string {
  const line = (t: string) =>
    ctx.categories.filter((c) => c.type === t).map((c) => `- ${c.name}${HINTS[c.name] ? `: ${HINTS[c.name]}` : ''}`).join('\n');
  return `Danh mục CHI:\n${line('EXPENSE')}\nDanh mục THU:\n${line('INCOME')}`;
}

/** V1–V4: model chỉ đặt tên ngắn + chọn danh mục cho từng khoản đã tách sẵn. */
export const systemV1 = (ctx: UserContext) =>
  `Bạn là trợ lý ghi sổ thu chi. Với MỖI khoản, trả về:
- title: tên ngắn 1-4 từ tiếng Việt có dấu, viết hoa chữ đầu, không chứa số tiền/ngày/ví.
- categoryName: đúng MỘT tên trong danh sách.
${categoryBlock(ctx)}
Nhận lương, thưởng, được cho, bán đồ, lãi, hoàn tiền là THU; còn lại là CHI.
Chữ "mua" KHÔNG có nghĩa là Mua sắm: chọn danh mục theo MÓN được mua (mua rau → Ăn uống, mua thuốc → Sức khỏe).
Khoản ghi (THU) thì chỉ chọn danh mục THU.
Chỉ trả JSON.`;

/** tags[i] = 'THU' | 'CHI' | undefined — tín hiệu thu/chi của parser, ghi kèm từng khoản. */
export const userV1 = (text: string, segs: string[], tags: (string | undefined)[] = []) =>
  `Câu: «${text}»\nCác khoản:\n${segs.map((s, i) => `${i + 1}. ${s}${tags[i] ? ` (${tags[i]})` : ''}`).join('\n')}`;

/** V0: model tự làm hết (tiền, ngày, ví, loại). */
export const systemV0 = (ctx: UserContext, todayIso: string, weekday: string) =>
  `Bạn là trợ lý ghi sổ thu chi. Hôm nay là ${weekday} ${todayIso}.
Tách câu thành các giao dịch. Mỗi giao dịch:
- title: tên ngắn 1-4 từ có dấu.
- amount: số đồng (VND), số nguyên. k = nghìn, tr/củ = triệu, 1tr2 = 1.200.000, lít/xị = 100.000.
- categoryName: đúng MỘT tên trong danh sách. ${categoryBlock(ctx)}
- type: INCOME nếu là khoản thu, EXPENSE nếu là khoản chi.
- date: YYYY-MM-DD (hôm qua = ngày trước hôm nay; không nói thì là hôm nay).
- walletName: một trong ${ctx.wallets.map((w) => w.name).join(', ')} nếu câu có nhắc, không thì null.
Nếu câu không có số tiền hoặc không rõ là khoản gì thì ask = true và items rỗng.
Chỉ trả JSON.`;
