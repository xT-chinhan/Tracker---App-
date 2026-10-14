import { cos, embed } from '../lib/ollama.js';
import { fold } from '../lib/text.js';

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

  clone(): ExampleBank {
    const b = new ExampleBank(this.embedModel);
    b.items = [...this.items];
    return b;
  }

  async nearest(clean: string, k: number) {
    const [q] = await embed(this.embedModel, [clean]);
    return this.items.map((e) => ({ e, s: cos(q, e.vec!) })).sort((a, b) => b.s - a.s).slice(0, k);
  }
}

const STOP = new Set(['mua', 'di', 'cho', 'voi', 'o', 'cua', 'nhan', 'dong', 'va', 'het', 'bi', 'lam', 'nay', 'qua', 'hom']);
// cùng danh sách, còn dấu ("chợ" KHÔNG còn là từ dừng như bản bỏ dấu "cho")
const STOP_ACC = new Set(['mua', 'đi', 'cho', 'với', 'ở', 'của', 'nhận', 'đồng', 'và', 'hết', 'bị', 'làm', 'nay', 'qua', 'hôm']);

/**
 * Từ khóa ứng viên của một khoản, bỏ số và từ dừng.
 * - 'syllable': unigram + bigram (bản đầu — tiếng Việt 1 âm tiết ≠ 1 từ nên sinh luật rác kiểu "may", "gia", "the").
 * - 'bigram'  : chỉ bigram; unigram chỉ khi cả khoản chỉ có 1 âm tiết (vd. "grab", "netflix").
 */
export type KeyMode = 'syllable' | 'bigram';
export let KEY_MODE: KeyMode = 'bigram';
export const setKeyMode = (m: KeyMode) => (KEY_MODE = m);

function keysOf(s: string, stop: Set<string>): string[] {
  const t = s.split(' ').filter((w) => w && !/^\d+$/.test(w));
  const content = t.filter((w) => !stop.has(w));
  const bi = t.slice(1).map((w, i) => `${t[i]} ${w}`).filter((b) => !b.split(' ').every((w) => stop.has(w)));
  const uni = KEY_MODE === 'syllable' ? content.filter((w) => w.length > 1) : content.length === 1 ? content : [];
  return [...new Set([...bi, ...uni])];
}

/** Khóa trên chuỗi đã bỏ dấu (`clean`) — giữ cho tương thích. */
export const keys = (clean: string) => keysOf(clean, STOP);

/** Đầu vào của sổ luật: Segment của parser (có `norm` còn dấu) hoặc chuỗi `clean` bỏ dấu (cách cũ). */
export type RuleInput = string | { clean: string; norm: string; dia: boolean };
const FOLD_PREFIX = '~'; // khóa trả về khi khớp lùi theo bản bỏ dấu

/**
 * Sổ luật "từ khóa → danh mục" học từ nhãn người dùng (pattern transaction-categorizer + bộ đếm ACE).
 * Luật bật khi một key có ≥ minSupport lần và ≥ minPrecision về cùng một danh mục; tắt khi có hại nhiều hơn có ích.
 *
 * Khóa luật là chuỗi CÒN DẤU: "cuối tuần" (từ "cà phê cuối tuần") không khớp "cưới Tuấn".
 * Chỉ khi câu người dùng KHÔNG có dấu mới lùi về so khớp bỏ dấu (gộp mọi khóa có cùng dạng bỏ dấu) —
 * khi đó câu vốn đã nhập nhằng, không còn cách nào khác.
 */
export class RuleBook {
  counts = new Map<string, Map<string, number>>(); // khóa còn dấu (hoặc khóa ascii học từ câu không dấu)
  foldCounts = new Map<string, Map<string, number>>(); // gộp theo dạng bỏ dấu, chỉ để khớp câu không dấu
  stats = new Map<string, { helpful: number; harmful: number }>();
  /** Luật gắn cứng (admin duyệt / đề xuất đang kiểm định): khóa → danh mục, bỏ qua ngưỡng support. */
  pinned = new Map<string, string>();
  constructor(public minSupport = 3, public minPrecision = 0.85) {}

  pin(key: string, categoryName: string) { this.pinned.set(key, categoryName); }

  /** Bản sao độc lập (để thử một luật/ví dụ mới mà không đụng sổ thật). */
  clone(): RuleBook {
    const r = new RuleBook(this.minSupport, this.minPrecision);
    const cp = (m: Map<string, Map<string, number>>) => new Map([...m].map(([k, v]) => [k, new Map(v)]));
    r.counts = cp(this.counts); r.foldCounts = cp(this.foldCounts);
    r.stats = new Map([...this.stats].map(([k, v]) => [k, { ...v }]));
    r.pinned = new Map(this.pinned);
    return r;
  }

  private static bump(map: Map<string, Map<string, number>>, k: string, cat: string) {
    const m = map.get(k) ?? new Map();
    m.set(cat, (m.get(cat) ?? 0) + 1);
    map.set(k, m);
  }

  private static keysFor(x: RuleInput): { keys: string[]; folded: boolean } {
    if (typeof x === 'string') return { keys: keys(x), folded: true };
    return x.dia ? { keys: keysOf(x.norm, STOP_ACC), folded: false } : { keys: keys(x.clean), folded: true };
  }

  observe(x: RuleInput, categoryName: string) {
    for (const k of RuleBook.keysFor(x).keys) {
      RuleBook.bump(this.counts, k, categoryName);
      RuleBook.bump(this.foldCounts, fold(k), categoryName);
    }
  }

  /** Luật đang bật cho key (nếu có). Key bắt đầu bằng "~" = tra theo bản bỏ dấu. */
  rule(key: string): { categoryName: string; support: number } | null {
    const pin = key.startsWith(FOLD_PREFIX) ? [...this.pinned].find(([k]) => fold(k) === key.slice(1))?.[1] : this.pinned.get(key);
    if (pin) return { categoryName: pin, support: Infinity };
    const m = key.startsWith(FOLD_PREFIX) ? this.foldCounts.get(key.slice(1)) : this.counts.get(key);
    if (!m) return null;
    const total = [...m.values()].reduce((a, b) => a + b, 0);
    const [cat, n] = [...m.entries()].sort((a, b) => b[1] - a[1])[0];
    const st = this.stats.get(key);
    if (st && st.harmful >= 2 && st.harmful > st.helpful) return null;
    return n >= this.minSupport && n / total >= this.minPrecision ? { categoryName: cat, support: n } : null;
  }

  /** Luật khớp tốt nhất: ưu tiên bigram, rồi support cao. Câu có dấu chỉ khớp khóa còn dấu. */
  match(x: RuleInput): { key: string; categoryName: string } | null {
    const { keys: ks, folded } = RuleBook.keysFor(x);
    const hits = ks.map((k) => (folded ? FOLD_PREFIX + k : k)).map((k) => ({ k, r: this.rule(k) })).filter((x) => x.r);
    const len = (k: string) => k.replace(FOLD_PREFIX, '').split(' ').length;
    hits.sort((a, b) => len(b.k) - len(a.k) || b.r!.support - a.r!.support);
    return hits[0] ? { key: hits[0].k, categoryName: hits[0].r!.categoryName } : null;
  }

  feedback(key: string, helpful: boolean) {
    const st = this.stats.get(key) ?? { helpful: 0, harmful: 0 };
    helpful ? st.helpful++ : st.harmful++;
    this.stats.set(key, st);
  }

  active() {
    return [...new Set([...this.pinned.keys(), ...this.counts.keys()])].map((k) => ({ k, r: this.rule(k) })).filter((x) => x.r).map((x) => `${x.k} → ${x.r!.categoryName} (${x.r!.support})`);
  }
}
