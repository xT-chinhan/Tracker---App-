/** Khoảng tin cậy 95% Wilson cho tỉ lệ k/n, trả về phần trăm (1 chữ số thập phân). */
export function wilson(k: number, n: number, z = 1.96): [number, number] {
  if (!n) return [0, 0];
  const p = k / n, d = 1 + (z * z) / n;
  const c = (p + (z * z) / (2 * n)) / d, h = (z * Math.sqrt((p * (1 - p)) / n + (z * z) / (4 * n * n))) / d;
  return [Math.round(1000 * Math.max(0, c - h)) / 10, Math.round(1000 * Math.min(1, c + h)) / 10];
}

export const pct = (k: number, n: number) => (n ? Math.round((1000 * k) / n) / 10 : 0);
/** "79.7 [75.1–83.6]" */
export const ci = (k: number, n: number) => { const [lo, hi] = wilson(k, n); return `${pct(k, n)} [${lo}–${hi}]`; };

/**
 * McNemar chính xác (hai phía) cho hai hệ chấm trên CÙNG một tập: b = A đúng/B sai, c = A sai/B đúng.
 * Dùng để biết chênh lệch giữa hai biến thể là thật hay nhiễu (mạnh hơn so hai khoảng Wilson chồng nhau).
 */
export function mcnemar(a: boolean[], b: boolean[]) {
  let onlyA = 0, onlyB = 0;
  a.forEach((x, i) => { if (x && !b[i]) onlyA++; if (!x && b[i]) onlyB++; });
  const n = onlyA + onlyB, k = Math.min(onlyA, onlyB);
  let p = 0, c = 1;
  for (let i = 0; i <= n; i++) { if (i <= k) p += c; c = (c * (n - i)) / (i + 1); }
  p = Math.min(1, (2 * p) / 2 ** n);
  return { onlyA, onlyB, p: n ? Math.round(p * 1e4) / 1e4 : 1 };
}
