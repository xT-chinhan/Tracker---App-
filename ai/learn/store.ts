import { cos, embed } from '../lib/ollama.js';

/** Một ví dụ đã được user xác nhận/sửa: đoạn khoản → tên + danh mục đúng. */
export interface Example { text: string; clean: string; title: string; categoryName: string; source: 'seed' | 'confirm' | 'edit' }

/** Kho ví dụ của MỘT user, tra kNN bằng embedding của `clean`. */
export class ExampleBank {
  items: (Example & { vec?: number[] })[] = [];
  constructor(public embedModel: string) {}

  async add(ex: Example) {
    if (this.items.some((e) => e.clean === ex.clean && e.categoryName === ex.categoryName)) return false;
    const [vec] = await embed(this.embedModel, [ex.clean || ex.text]);
    this.items.push({ ...ex, vec });
    return true;
  }

  async nearest(clean: string, k: number) {
    const [q] = await embed(this.embedModel, [clean]);
    return this.items.map((e) => ({ e, s: cos(q, e.vec!) })).sort((a, b) => b.s - a.s).slice(0, k);
  }
}

const STOP = new Set(['mua', 'di', 'cho', 'voi', 'o', 'cua', 'nhan', 'dong', 'va', 'het', 'bi', 'lam', 'nay', 'qua', 'hom']);

/**
 * Từ khóa ứng viên của một khoản trên `clean`, bỏ số và từ dừng.
 * - 'syllable': unigram + bigram (bản đầu — tiếng Việt 1 âm tiết ≠ 1 từ nên sinh luật rác kiểu "may", "gia", "the").
 * - 'bigram'  : chỉ bigram; unigram chỉ khi cả khoản chỉ có 1 âm tiết (vd. "grab", "netflix").
 */
export type KeyMode = 'syllable' | 'bigram';
export let KEY_MODE: KeyMode = 'bigram';
export const setKeyMode = (m: KeyMode) => (KEY_MODE = m);

export function keys(clean: string): string[] {
  const t = clean.split(' ').filter((w) => w && !/^\d+$/.test(w));
  const content = t.filter((w) => !STOP.has(w));
  const bi = t.slice(1).map((w, i) => `${t[i]} ${w}`).filter((b) => !b.split(' ').every((w) => STOP.has(w)));
  const uni = KEY_MODE === 'syllable' ? content.filter((w) => w.length > 1) : content.length === 1 ? content : [];
  return [...new Set([...bi, ...uni])];
}

/**
 * Sổ luật "từ khóa → danh mục" học từ nhãn người dùng (pattern transaction-categorizer + bộ đếm ACE).
 * Luật bật khi một key có ≥ minSupport lần và ≥ minPrecision về cùng một danh mục; tắt khi có hại nhiều hơn có ích.
 */
export class RuleBook {
  counts = new Map<string, Map<string, number>>();
  stats = new Map<string, { helpful: number; harmful: number }>();
  constructor(public minSupport = 3, public minPrecision = 0.85) {}

  observe(clean: string, categoryName: string) {
    for (const k of keys(clean)) {
      const m = this.counts.get(k) ?? new Map();
      m.set(categoryName, (m.get(categoryName) ?? 0) + 1);
      this.counts.set(k, m);
    }
  }

  /** Luật đang bật cho key (nếu có). */
  rule(k: string): { categoryName: string; support: number } | null {
    const m = this.counts.get(k);
    if (!m) return null;
    const total = [...m.values()].reduce((a, b) => a + b, 0);
    const [cat, n] = [...m.entries()].sort((a, b) => b[1] - a[1])[0];
    const st = this.stats.get(k);
    if (st && st.harmful >= 2 && st.harmful > st.helpful) return null;
    return n >= this.minSupport && n / total >= this.minPrecision ? { categoryName: cat, support: n } : null;
  }

  /** Luật khớp tốt nhất: ưu tiên bigram, rồi support cao. */
  match(clean: string): { key: string; categoryName: string } | null {
    const hits = keys(clean).map((k) => ({ k, r: this.rule(k) })).filter((x) => x.r);
    hits.sort((a, b) => b.k.split(' ').length - a.k.split(' ').length || b.r!.support - a.r!.support);
    return hits[0] ? { key: hits[0].k, categoryName: hits[0].r!.categoryName } : null;
  }

  feedback(key: string, helpful: boolean) {
    const st = this.stats.get(key) ?? { helpful: 0, harmful: 0 };
    helpful ? st.helpful++ : st.harmful++;
    this.stats.set(key, st);
  }

  active() {
    return [...this.counts.keys()].map((k) => ({ k, r: this.rule(k) })).filter((x) => x.r).map((x) => `${x.k} → ${x.r!.categoryName} (${x.r!.support})`);
  }
}
