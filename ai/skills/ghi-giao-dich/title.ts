/**
 * Hậu kiểm title do model đặt: gemma2 hay chép số tiền / tên ví / ngày vào title ("Cà phê 45k trả momo").
 * Dùng chính bộ tìm tiền/ngày/ví của parser (nên "iPhone 15", "Lương tháng 9" không bị cắt), bỏ các từ nối
 * còn treo ở cuối ("trả", "ck", "bằng"…). Rỗng thì lùi về đoạn gốc đã làm sạch.
 */
import { fold } from '../../lib/text.js';
import type { UserContext } from '../../lib/types.js';
import { findDates, mask } from '../../parser/date.js';
import type { Segment } from '../../parser/index.js';
import { findAmounts } from '../../parser/money.js';
import { findWallets } from '../../parser/wallet.js';

const DANGLING = /(?:\s+|^)(?:trả|tra|ck|chuyển khoản|chuyen khoan|thanh toán|thanh toan|bằng|bang|qua|vào|vao|từ|tu|hết|het|mất|mat|tiền|tien|ví|vi|thẻ|the|quẹt|quet|hôm|ngày|lúc)$/iu;
// viết hoa chữ đầu, trừ khi từ đầu đã có chữ hoa kiểu thương hiệu ("iPhone")
const cap = (s: string) => (/^\S*\p{Lu}/u.test(s) ? s : s.charAt(0).toUpperCase() + s.slice(1));

export function cleanTitle(title: string, seg: Pick<Segment, 'text'>, ctx: UserContext): string {
  const strip = (s: string) => {
    const t = s.normalize('NFC');
    const f = fold(t);
    if (f.length !== t.length) return t.trim();
    const dates = findDates(f, ctx.now);
    const wallets = findWallets(mask(f, dates), ctx.wallets);
    const amounts = findAmounts(mask(f, [...dates, ...wallets]));
    let out = mask(t, [...dates, ...wallets, ...amounts]).replace(/[()[\]{}:;,.]+/g, ' ').replace(/\s+/g, ' ').trim();
    for (let i = 0; i < 4 && DANGLING.test(out); i++) out = out.replace(DANGLING, '').trim();
    return out.replace(/^(?:và|với|rồi)\s+/iu, '').trim();
  };
  const t = strip(title);
  if (t && /\p{L}/u.test(t)) return cap(t);
  const fb = strip(seg.text);
  return fb ? cap(fb) : title.trim();
}
