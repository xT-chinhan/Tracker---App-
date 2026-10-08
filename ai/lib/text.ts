/** Bỏ dấu + hạ chữ thường, giữ nguyên độ dài chuỗi (mỗi ký tự -> 1 ký tự) để vị trí match dùng lại được trên câu gốc. */
export function fold(s: string): string {
  let out = '';
  for (const ch of s.toLowerCase()) {
    const base = ch === 'đ' ? 'd' : ch.normalize('NFD').replace(/[̀-ͯ]/g, '');
    out += base.length === 1 ? base : ch.length === 1 ? ch : ' ';
  }
  return out;
}

export const tokens = (s: string) => fold(s).split(/[^a-z0-9]+/).filter(Boolean);

/** Tên ngắn khớp "lỏng": bỏ dấu, chứa nhau hoặc trùng ≥ 50% token. */
export function titleMatch(pred: string, gold: string): boolean {
  const a = tokens(pred), b = tokens(gold);
  if (!a.length || !b.length) return false;
  const sa = a.join(' '), sb = b.join(' ');
  if (sa.includes(sb) || sb.includes(sa)) return true;
  const inter = b.filter((t) => a.includes(t)).length;
  return inter / Math.max(a.length, b.length) >= 0.5;
}
