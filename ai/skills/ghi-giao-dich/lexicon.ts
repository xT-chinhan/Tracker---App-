/**
 * Từ điển danh mục bằng code (độ chính xác cao, chạy SAU luật học được của user, TRƯỚC model).
 * Chỉ chốt khi chắc:
 *  - Ăn uống: MỌI từ nội dung của khoản đều là thực phẩm/đồ ăn/đi chợ hoặc món ăn, đồ uống làm sẵn
 *    (sau khi bỏ "mua", "ở chợ", từ chỉ lượng / buổi). "mua rau 20k", "cf 45k", "cơm trưa 55k" → Ăn uống;
 *    "mua dầu gội 90k", "nồi cơm điện 900k" → không chốt (có từ không phải đồ ăn) → model.
 *  - Gia đình: đồ riêng cho con nhỏ (bỉm, tã, sữa bột, đồ chơi).
 *  - Sức khỏe: thuốc (trừ thuốc lá), khám bệnh/răng/mắt…, nha khoa, xét nghiệm.
 *  - Thu: loại thu lấy theo tín hiệu của parser (lương / thưởng / đầu tư / được tặng / thu khác).
 * So khớp trên chuỗi còn dấu; câu không dấu chỉ dùng các từ mà bản bỏ dấu không nhập nhằng.
 */
import { fold } from '../../lib/text.js';
import type { UserContext } from '../../lib/types.js';
import type { IncomeKind } from '../../parser/cues.js';
import type { Segment } from '../../parser/index.js';

// Từ/cụm thực phẩm (còn dấu). Cụm nhiều âm tiết được ưu tiên khớp trước.
const FOOD = `rau|rau muống|rau cải|rau củ|củ quả|thịt|thịt heo|thịt lợn|thịt bò|thịt gà|thịt vịt|ba chỉ|sườn|cá|cá thu|cá hồi|cá lóc|tôm|cua|ghẹ|mực|ốc|nghêu|sò|hến|
trứng|trứng gà|trứng vịt|gạo|nếp|bún|bún tươi|phở khô|mì gói|mì tôm|miến|đậu phụ|đậu hũ|đậu|giá|nấm|hành|tỏi|ớt|gừng|sả|chanh|gia vị|
nước mắm|dầu ăn|nước tương|xì dầu|đường|muối|bột ngọt|mắm|tương ớt|
trái cây|hoa quả|cam|quýt|táo|chuối|xoài|nho|dưa hấu|bưởi|ổi|lê|thanh long|sầu riêng|măng cụt|vải|nhãn|dưa|cà chua|khoai|khoai tây|khoai lang|bí|bầu|mướp|cà rốt|bắp cải|súp lơ|dưa leo|bắp|
sữa chua|sữa tươi|bánh|bánh mì|bánh kẹo|kẹo|bia|nước ngọt|nước suối|đồ ăn|thức ăn|thực phẩm|đồ ăn vặt|đi chợ|tiền chợ|chợ|hải sản|thịt cá|
cf|cafe|cà phê|cafê|trà|trà sữa|trà đá|trà chanh|nước mía|sinh tố|nước ép|đồ uống|nước uống|
cơm|cơm trưa|cơm tấm|cơm gà|cơm văn phòng|cơm bụi|phở|phở bò|bún bò|bún chả|bún riêu|bún đậu|hủ tiếu|mì quảng|bánh cuốn|bánh xèo|xôi|cháo|lẩu|gà rán|pizza|
ăn|ăn sáng|ăn trưa|ăn tối|ăn vặt|ăn uống|bữa sáng|bữa trưa|bữa tối`
  .replace(/\s*\n\s*/g, '|').split('|').filter(Boolean);
// Bản bỏ dấu dùng cho câu không dấu: chỉ cụm không nhập nhằng (bỏ "ca" = cá/cà/ca, "bo" = bò/bố, "cho" = chợ/cho, "trung" = trứng/Trung…)
const FOOD_PLAIN = 'rau|rau muong|rau cu|cu qua|thit|thit heo|thit lon|thit bo|thit ga|thit vit|ba chi|suon|ca thu|ca hoi|ca loc|tom|muc|trung ga|trung vit|gao|mi goi|mi tom|dau phu|dau hu|nuoc mam|dau an|trai cay|hoa qua|ca chua|ca rot|khoai tay|khoai lang|bap cai|dua hau|sua chua|sua tuoi|banh|banh mi|banh keo|keo|bia|nuoc ngot|do an|thuc an|thuc pham|di cho|tien cho|hai san|cf|cafe|ca phe|tra sua|tra da|tra chanh|nuoc mia|sinh to|nuoc ep|com|com trua|com tam|com ga|com van phong|com bui|pho|pho bo|bun bo|bun cha|bun rieu|bun dau|hu tieu|mi quang|banh cuon|banh xeo|xoi|chao|ga ran|pizza|an sang|an trua|an toi|an vat|bua sang|bua trua|bua toi'.split('|');
// Từ không mang nội dung khi nói chuyện đi chợ / ăn uống (động từ, lượng, nơi chốn, buổi).
const GLUE = new Set('mua đi ra về ở tại ngoài thêm cho nhà về nhà ký kí kg ki lô lạng cân bó gói hộp lốc thùng lon chai túi bịch vỉ quả trái con cái miếng phần nửa và với vs tiền sáng trưa chiều tối khuya ly cốc tô bát suất'.split(' '));
const GLUE_PLAIN = new Set('mua di ra ve o tai ngoai them nha ky ki kg ki lo can goi hop loc thung lon chai tui bich vi qua trai con mieng phan nua va voi vs tien sang trua chieu toi khuya ly coc to bat suat'.split(' '));

/** Phủ chuỗi bằng các cụm trong từ điển (tham lam, cụm dài trước). Trả về true nếu mọi từ nội dung đều được phủ. */
function covered(words: string[], dict: string[], glue: Set<string>): boolean {
  const phrases = [...dict].sort((a, b) => b.split(' ').length - a.split(' ').length);
  let i = 0, hit = 0;
  while (i < words.length) {
    const p = phrases.find((ph) => { const t = ph.split(' '); return t.every((w, k) => words[i + k] === w); });
    if (p) { i += p.split(' ').length; hit++; continue; }
    if (glue.has(words[i]) || /^\d+(?:kg|g|ký|kí|ky|ki|lạng|lang)?$/u.test(words[i])) { i++; continue; }
    return false;
  }
  return hit > 0;
}

const KIDS = /(?<![\p{L}])(bỉm|tã|sữa bột|đồ chơi)(?![\p{L}])/u;
const KIDS_PLAIN = /\b(bim|sua bot|do choi)\b/;
const HEALTH = /(?<![\p{L}])(thuốc(?! lá)|khám|nha khoa|xét nghiệm|tiêm|vắc xin|bệnh viện|phòng khám)(?![\p{L}])/u;
const HEALTH_PLAIN = /\b(thuoc(?! la)|kham benh|kham rang|kham mat|nha khoa|xet nghiem|benh vien|phong kham)\b/;

const has = (ctx: UserContext, name: string) => ctx.categories.find((c) => fold(c.name) === fold(name))?.name;

/** Danh mục chốt bằng từ điển cho một khoản CHI (hoặc chưa rõ thu/chi), hoặc null để model quyết. */
export function lexiconCategory(seg: Segment, ctx: UserContext): { categoryName: string; why: string } | null {
  if (seg.dir?.dir === 'INCOME') return null;
  const words = (seg.dia ? seg.norm : seg.clean).split(' ').filter(Boolean);
  if (seg.dia ? KIDS.test(seg.norm) : KIDS_PLAIN.test(seg.clean)) { const c = has(ctx, 'Gia đình'); if (c) return { categoryName: c, why: 'lexicon:con-nho' }; }
  if (seg.dia ? HEALTH.test(seg.norm) : HEALTH_PLAIN.test(seg.clean)) { const c = has(ctx, 'Sức khỏe'); if (c) return { categoryName: c, why: 'lexicon:suc-khoe' }; }
  if (words.length && covered(words, seg.dia ? FOOD : FOOD_PLAIN, seg.dia ? GLUE : GLUE_PLAIN)) {
    const c = has(ctx, 'Ăn uống'); if (c) return { categoryName: c, why: 'lexicon:thuc-pham' };
  }
  return null;
}

const INCOME_NAME: Record<IncomeKind, string[]> = {
  salary: ['Lương'], bonus: ['Thưởng'], invest: ['Đầu tư', 'Lãi', 'Lãi tiết kiệm'], gift: ['Được tặng', 'Được cho', 'Quà tặng'], other: ['Thu khác', 'Thu nhập khác'],
};

/** Danh mục THU theo tín hiệu parser; lùi dần về "Thu khác" / danh mục thu đầu tiên của user. */
export function incomeCategory(seg: Segment, ctx: UserContext): string | null {
  if (seg.dir?.dir !== 'INCOME') return null;
  for (const n of INCOME_NAME[seg.dir.kind ?? 'other']) { const c = has(ctx, n); if (c) return c; }
  for (const n of INCOME_NAME.other) { const c = has(ctx, n); if (c) return c; }
  return ctx.categories.find((c) => c.type === 'INCOME')?.name ?? null;
}
