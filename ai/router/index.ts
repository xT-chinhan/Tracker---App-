import { cos, embed } from '../lib/ollama.js';
import { fold } from '../lib/text.js';
import type { UserContext } from '../lib/types.js';
import { parse } from '../parser/index.js';

export type Route = { skill: string; by: 'rule' | 'knn' | 'fallback'; score?: number };

const Q = /\b(bao nhieu|nhieu khong|khong|chua|the nao|sao|o dau|nhu nao|khi nao|bao gio|la gi)\b|\?/;
const RULES: [string, RegExp][] = [
  ['huong-dan', /\b(lam sao|lam the nao|cach|huong dan|bam vao dau|o dau|nhu nao|dung sao|che do)\b/],
  ['tien-do-tiet-kiem', /\b(tiet kiem|muc tieu|quy khan cap|ong heo|du tien)\b/],
  ['kiem-tra-ngan-sach', /\b(ngan sach|han muc|budget|vuot muc|con duoc tieu)\b/],
  ['hoi-so-du', /\b(so du|con (bao nhieu|nhieu)( tien)?|tong (cong )?bao nhieu tien|dang co)\b/],
  ['tim-giao-dich', /\b(tim|liet ke|giao dich|nhung khoan|khoan nao|lan (cuoi|gan nhat)|bao nhieu lan|may lan|la gi|bao gio)\b/],
  ['tong-ket-thang', /\b(tong ket|bao cao|(tieu|xai|chi) (het )?bao nhieu|chi nhieu|thu chi|thu nhap)\b/],
];

/** Router bằng luật từ khóa. Câu có số tiền + có nội dung + không phải câu hỏi => ghi-giao-dich. */
export function routeRules(text: string, ctx: UserContext): Route | null {
  const f = fold(text);
  for (const [skill, re] of RULES) if (re.test(f)) return { skill, by: 'rule' };
  const segs = parse(text, ctx);
  if (!Q.test(f) && (segs.some((s) => s.clean.length > 0) || /^(ghi|them)\b/.test(f))) return { skill: 'ghi-giao-dich', by: 'rule' };
  return null;
}

/** kNN trên câu mẫu (pattern semantic-router): vote có trọng số top-k, kèm điểm top-1. */
export class KnnRouter {
  vecs: { skill: string; text: string; v: number[] }[] = [];
  constructor(public model: string, public k = 5) {}
  async fit(bank: Record<string, string[]>) {
    const rows = Object.entries(bank).flatMap(([skill, xs]) => xs.map((text) => ({ skill, text })));
    const vs = await embed(this.model, rows.map((r) => r.text));
    this.vecs = rows.map((r, i) => ({ ...r, v: vs[i] }));
  }
  async route(text: string): Promise<Route & { top1: number; neighbor: string }> {
    const [q] = await embed(this.model, [text]);
    const nn = this.vecs.map((e) => ({ e, s: cos(q, e.v) })).sort((a, b) => b.s - a.s).slice(0, this.k);
    const votes = new Map<string, number>();
    for (const { e, s } of nn) votes.set(e.skill, (votes.get(e.skill) ?? 0) + s);
    const [skill] = [...votes.entries()].sort((a, b) => b[1] - a[1])[0];
    return { skill, by: 'knn', score: nn[0].s, top1: nn[0].s, neighbor: nn[0].e.text };
  }
}

/** Kết hợp: luật trước → kNN → điểm thấp thì hỏi lại. */
export async function routeCombined(text: string, ctx: UserContext, knn: KnnRouter, minScore: number): Promise<Route> {
  const r = routeRules(text, ctx);
  if (r) return r;
  const k = await knn.route(text);
  return k.top1 >= minScore ? k : { skill: 'hoi-lai', by: 'fallback', score: k.top1 };
}
