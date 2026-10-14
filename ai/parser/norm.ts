/**
 * Chuẩn hoá tiếng Việt CÒN DẤU: NFC + chữ thường + đặt dấu thanh kiểu mới (hoà → hòa, thuý → thúy).
 * Giữ nguyên độ dài chuỗi (mỗi ký tự NFC → 1 ký tự) để dùng chung vị trí với fold().
 */
const TONES = '̣̀́̉̃'; // huyền, sắc, hỏi, ngã, nặng

/** oà/oá/oả/oã/oạ, oè…, uỳ… → òa, òe, ùy (chỉ khi là âm cuối của tiếng: "hoàng" giữ nguyên). */
function retone(word: string): string {
  return word.replace(/([ou])([aeyàáảãạèéẻẽẹỳýỷỹỵ])(?![\p{L}])/gu, (m, v: string, w: string) => {
    if (!((v === 'o' && /[ae]/.test(w.normalize('NFD')[0])) || (v === 'u' && w.normalize('NFD')[0] === 'y'))) return m;
    const d = w.normalize('NFD');
    const tone = [...d].find((c) => TONES.includes(c));
    if (!tone) return m;
    return (v + tone).normalize('NFC') + d.replace(tone, '').normalize('NFC');
  });
}

export function normVi(s: string): string {
  const out = retone(s.normalize('NFC').toLowerCase());
  return out.length === s.normalize('NFC').length ? out : s.normalize('NFC').toLowerCase();
}

/** Có dấu tiếng Việt không (kể cả đ). Câu không dấu thì luật/lexicon mới được lùi về so khớp bỏ dấu. */
// Ký hiệu tiền "45.000đ" / "đồng" sau số không tính là gõ có dấu.
export const hasDiacritics = (s: string) =>
  /[^\x00-\x7f]/.test(s.normalize('NFC').replace(/(\d)\s*(?:đồng|đ)(?![\p{L}])/giu, '$1').replace(/[^\p{L}]/gu, ''));
