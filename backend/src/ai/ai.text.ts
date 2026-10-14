/** Tiện ích chữ + vector cho trợ lý AI (không phụ thuộc Nest). */

/** Bỏ dấu + chữ thường, giữ nguyên độ dài (giống ai/lib/text.ts → vị trí khớp dùng lại được trên câu gốc). */
export function fold(s: string): string {
  let out = '';
  for (const ch of s.toLowerCase()) {
    const base = ch === 'đ' ? 'd' : ch.normalize('NFD').replace(/[̀-ͯ]/g, '');
    out += base.length === 1 ? base : ch.length === 1 ? ch : ' ';
  }
  return out;
}

/** Chuẩn hóa CÒN DẤU: NFC, chữ thường, bỏ ký tự lạ, gộp khoảng trắng. Khóa của luật / ví dụ ("cưới tuấn" ≠ "cuối tuần"). */
export function norm(s: string): string {
  return s.normalize('NFC').toLowerCase().replace(/[^\p{L}\p{N}\s]/gu, ' ').replace(/\s+/g, ' ').trim();
}

/**
 * Bản "clean" còn dấu của một khoản: lấy các từ của câu gốc mà dạng bỏ dấu nằm trong `clean` (parser đã bỏ tiền/ngày/ví/từ đệm).
 * Giữ thứ tự, khớp lần lượt.
 */
export function accentedClean(text: string, clean: string): string {
  const want = clean.split(' ').filter(Boolean);
  const out: string[] = [];
  let i = 0;
  for (const tok of norm(text).split(' ')) {
    if (i < want.length && fold(tok) === want[i]) {
      out.push(tok);
      i++;
    }
  }
  return i === want.length ? out.join(' ') : clean;
}

const STOP = new Set(['mua', 'di', 'cho', 'voi', 'o', 'cua', 'nhan', 'dong', 'va', 'het', 'bi', 'lam', 'nay', 'qua', 'hom']);

/** Từ khóa ứng viên (giống ai/learn/store.ts chế độ bigram) nhưng trên chuỗi CÒN DẤU; từ dừng so sánh sau khi bỏ dấu. */
export function ruleKeys(cleanAccented: string): string[] {
  const t = cleanAccented.split(' ').filter((w) => w && !/^\d+$/.test(w));
  const stop = (w: string) => STOP.has(fold(w));
  const content = t.filter((w) => !stop(w));
  const bi = t.slice(1).map((w, i) => `${t[i]} ${w}`).filter((b) => !b.split(' ').every(stop));
  const uni = content.length === 1 ? content : [];
  return [...new Set([...bi, ...uni])];
}

/* ---------- vector ---------- */

export function l2(v: number[]): number[] {
  const n = Math.hypot(...v) || 1;
  return v.map((x) => x / n);
}

export const cos = (a: ArrayLike<number>, b: ArrayLike<number>) => {
  let s = 0;
  const n = Math.min(a.length, b.length);
  for (let i = 0; i < n; i++) s += a[i] * b[i];
  return s;
};

/** Float32 little-endian ↔ Bytes (Prisma). */
export function toBytes(v: number[]): Uint8Array<ArrayBuffer> {
  return new Uint8Array(Float32Array.from(v).buffer);
}

export function fromBytes(b: Uint8Array): Float32Array {
  // bản sao offset 0 (Buffer của pg có thể lệch offset, Float32Array cần bội số 4)
  return new Float32Array(new Uint8Array(b).buffer);
}

/** Làm tròn số tiền về 1 chữ số có nghĩa (ẩn danh hóa). */
export function roundAmount(n: number): number {
  if (!n) return 0;
  const p = 10 ** Math.floor(Math.log10(Math.abs(n)));
  return Math.round(n / p) * p;
}

export const fmtVnd = (n: number) => `${Math.round(n).toLocaleString('vi-VN')}đ`;
