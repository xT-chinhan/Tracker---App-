/**
 * Router theo scope (Track B): chặn chung → luật theo scope → kNN bge-m3 trên câu mẫu CỦA SCOPE ĐÓ → điểm thấp thì hỏi lại.
 * Phiên USER chỉ có thể ra USER_SKILLS, phiên ADMIN chỉ ra ADMIN_SKILLS (ngoai-pham-vi, hoi-lai dùng chung).
 */
import { cos, embed } from '../lib/ollama.js';
import type { Scope } from '../lib/contracts.js';
import { asksOtherUser, isInjection } from '../lib/skillkit.js';
import { fold } from '../lib/text.js';
import { findAmounts } from '../parser/money.js';
import { ADMIN_ONLY, PERSONAL } from '../skills/ngoai-pham-vi/index.js';
import { BANK, SKILLS_BY_SCOPE } from './bank.js';

export type ScopedRoute = { skill: string; by: 'guard' | 'rule' | 'knn' | 'fallback'; score?: number; reason?: string; neighbor?: string };

const QUESTION = /\b(bao nhieu|nhieu khong|khong|chua|the nao|sao|o dau|nhu nao|khi nao|bao gio|la gi|gi|nao|ai|how|what|when|where|which|why)\b|\?/;

/** Chủ đề ngoài phạm vi phổ biến (cả 2 scope). */
const OFF_TOPIC = /\b(thoi tiet|troi (co )?mua|nhiet do|chuyen cuoi|ke chuyen|bai tho|lam tho|bai hat|hat (mot|di)|gia vang|bitcoin|crypto|co phieu|chung khoan|lai suat|ty gia|ti gia|vay ngan hang|quan (an|nhau|cafe|ca phe|pho)|nau (an|mon)|cong thuc nau|ti so|ty so|bong da|tran dau|viet code|lap trinh|python|javascript|dich (cau|sang|giup)|tong thong|thu tuong|weather|joke|poem|recipe|stock|translate|capital of)\b/;

const USER_RULES: [string, RegExp][] = [
  ['meo-tiet-kiem', /\b(meo|bi quyet|tips?|advice|lam (sao|the nao|cach nao)( de)? (tiet kiem|bot|giam|de danh|chi it|tieu it|con du)|cach (tiet kiem|bot|giam|de danh|tieu it)|(tieu|chi|xai) (nhieu|qua tay|hoang) qua|giam chi tieu|bot chi tieu|save money|spend less)\b/],
  ['goi-y-ngan-sach', /\b(goi y|de xuat|lap|len|tu van|suggest|propose|plan)\b.{0,25}\b(ngan sach|han muc|budget)\b|\b(ngan sach|han muc)\b.{0,25}\b(nen (dat|de|la)|bao nhieu (la )?hop ly)\b|\bnen dat (ngan sach|han muc)/],
  ['tim-giao-dich', /\b(khoan|giao dich)\b.{0,30}\bla (gi|khoan gi)\b/],
  ['huong-dan', /\b(lam sao|lam the nao|cach (nao )?(de )?|huong dan|bam vao dau|bam o dau|o dau|nhu nao|dung sao|che do|tinh nang|how (do|to|can)|where (do|can|is))\b/],
  ['tien-do-tiet-kiem', /\b(tiet kiem|muc tieu|quy (khan cap|du phong)|ong heo|du tien|de danh|saving|savings|goal)\b/],
  ['kiem-tra-ngan-sach', /\b(ngan sach|han muc|budget|vuot muc|lo ngan|con (duoc )?tieu duoc|con duoc tieu|moi ngay (con )?(tieu|chi|xai) (duoc )?bao nhieu)\b/],
  ['hoi-so-du', /\b(so du|balance|con (bao nhieu|nhieu|nhiu|bn)( tien| xien)?|tong (cong )?(bao nhieu )?tien|dang co (tong cong )?bao nhieu|con lai bao nhieu)\b/],
  ['tim-giao-dich', /\b(tim|liet ke|giao dich|nhung khoan|khoan nao|cac khoan|lan (cuoi|gan nhat)|bao nhieu lan|may lan|la khoan gi|bao gio|(chi|tieu|xai|mua) (nhung )?gi|search|find|list|show)\b/],
  ['tong-ket-thang', /\b(tong ket|bao cao|(tieu|xai|chi|thu|kiem|tiet kiem) (het |duoc )?(bao nhieu|nhieu|bn)|chi nhieu|thu chi|thu nhap|so voi thang|du duoc|summary|report|spend|spent)\b/],
];

const ADMIN_RULES: [string, RegExp][] = [
  ['huong-dan-quan-tri', /\b(lam sao|lam the nao|cach (nao )?(de )?|huong dan|bam vao dau|o dau|vao dau|nhu nao|how (do|to|can))\b/],
  ['soan-thong-bao', /\b(soan|viet|draft|nhap|tao|lam)\b.{0,25}\b(thong bao|broadcast|tin nhan|ban tin|announcement)\b|\bthong bao (cho|toi|den) (tat ca|moi nguoi|toan bo|cac)\b/],
  ['de-xuat-khoa', /\b(de xuat khoa|co nen khoa|nen khoa|khoa (giup|luon|ngay|tam|thu|tai khoan|user|nick|acc)|tam khoa|lock|ban (user|account|tai khoan)|suspend)\b/],
  ['tom-tat-cau-hinh', /\b(cau hinh|config|setting|settings)\b.{0,30}\b(lich su|thay doi|doi|sua|tom tat|gan day|changes?|history)\b|\b(lich su|thay doi|ai (da )?(doi|sua|bat|tat)|tom tat|summari[sz]e)\b.{0,30}\b(cau hinh|config|smtp|bao tri)\b/],
  ['nguoi-dung-moi', /\b(nguoi|user|tai khoan|thanh vien|khach) moi\b|\bmoi (dang ky|tao tai khoan)\b|\bchua (ghi|nhap|co) (giao dich|khoan|gi)\b|\bchua dung app\b/],
  ['phat-hien-bat-thuong', /\b(bat thuong|dang ngo|kha nghi|gian lan|tang vot|dot bien|dot ngot|anomal\w*|suspicious|fraud|spam|dau hieu)\b/],
  ['tra-cuu-nguoi-dung', /\b(tim|tra cuu|liet ke|danh sach|search|find|list|look up)\b.{0,30}\b(user|users|nguoi dung|tai khoan|account|accounts|quan tri vien|admin)\b|[\w.]+@[\w-]+\.|\b(bi khoa|dang bi khoa|locked)\b|\b(user|nguoi dung|tai khoan) (nao )?ten\b/],
  ['tong-quan-he-thong', /\b(tong quan|bao nhieu (user|nguoi dung|tai khoan|giao dich|thanh vien)|thong ke|toan (bo )?he thong|overview|dashboard|tinh hinh)\b/],
];

/** Câu ghi giao dịch: có số tiền + không phải câu hỏi (giống luật ghi-giao-dich của router cũ, chỉ dùng parser tiền). */
function looksLikeRecord(f: string): boolean {
  if (QUESTION.test(f) || f.includes('%')) return false;
  const a = findAmounts(f.replace(/\b(quan|phuong|so nha|lau|tang|phong|xe|tuyen|ban) \d+\b/g, ' '));
  const words = f.replace(/[^a-z\s]/g, ' ').split(/\s+/).filter((w) => w.length > 1 && !/^(k|tr|trieu|nghin|ngan|cu|d|dong)$/.test(w));
  return (a.length > 0 && words.length > 0) || /^(ghi|them|nhap) (giup |cho |lai )?(minh |toi |em )?(khoan|chi|thu|tien|giao dich)?/.test(f);
}

/** Chặn chung + luật theo scope. null = để kNN quyết. */
export function routeRulesScoped(text: string, scope: Scope): ScopedRoute | null {
  const f = fold(text);
  if (isInjection(text)) return { skill: 'ngoai-pham-vi', by: 'guard', reason: 'injection' };
  if (OFF_TOPIC.test(f)) return { skill: 'ngoai-pham-vi', by: 'rule', reason: 'off_topic' };
  // Chỉ có số tiền ("300k", "50 nghìn?") → hỏi lại
  if (/^[\s\d.,?]*(k|nghin|ngan|tr|trieu|cu|d|dong|vnd)?[\s?!.]*$/.test(f) && /\d/.test(f)) return { skill: 'hoi-lai', by: 'rule' };
  if (scope === 'USER') {
    if (asksOtherUser(text)) return { skill: 'ngoai-pham-vi', by: 'guard', reason: 'other_user' };
    if (ADMIN_ONLY.test(f)) return { skill: 'ngoai-pham-vi', by: 'guard', reason: 'scope' };
    for (const [skill, re] of USER_RULES) if (re.test(f)) return { skill, by: 'rule' };
    if (looksLikeRecord(f)) return { skill: 'ghi-giao-dich', by: 'rule' };
    return null;
  }
  if (PERSONAL.test(f)) return { skill: 'ngoai-pham-vi', by: 'guard', reason: 'scope' };
  for (const [skill, re] of ADMIN_RULES) if (re.test(f)) return { skill, by: 'rule' };
  if (looksLikeRecord(f)) return { skill: 'ngoai-pham-vi', by: 'guard', reason: 'scope' };
  return null;
}

/** kNN theo scope: vote có trọng số top-k trên câu mẫu của scope đó. */
export class ScopedKnn {
  vecs: Record<Scope, { skill: string; text: string; v: number[] }[]> = { USER: [], ADMIN: [] };
  constructor(public model = 'bge-m3', public k = 5) {}
  async fit(bank = BANK) {
    for (const scope of ['USER', 'ADMIN'] as Scope[]) {
      const rows = Object.entries(bank[scope]).flatMap(([skill, xs]) => xs.map((text) => ({ skill, text })));
      const vs = await embed(this.model, rows.map((r) => r.text));
      this.vecs[scope] = rows.map((r, i) => ({ ...r, v: vs[i] }));
    }
    return this;
  }
  async route(text: string, scope: Scope): Promise<{ skill: string; top1: number; neighbor: string }> {
    const [q] = await embed(this.model, [text]);
    const nn = this.vecs[scope].map((e) => ({ e, s: cos(q, e.v) })).sort((a, b) => b.s - a.s).slice(0, this.k);
    const votes = new Map<string, number>();
    for (const { e, s } of nn) votes.set(e.skill, (votes.get(e.skill) ?? 0) + s);
    const [skill] = [...votes.entries()].sort((a, b) => b[1] - a[1])[0];
    return { skill, top1: nn[0].s, neighbor: nn[0].e.text };
  }
}

export const DEFAULT_THRESHOLD = 0.6;

export async function routeScoped(text: string, scope: Scope, knn: ScopedKnn | null, threshold = DEFAULT_THRESHOLD, useRules = true): Promise<ScopedRoute> {
  const r = useRules ? routeRulesScoped(text, scope) : null;
  let out: ScopedRoute;
  if (r) out = r;
  else if (!knn) out = { skill: 'hoi-lai', by: 'fallback' };
  else {
    const k = await knn.route(text, scope);
    out = k.top1 >= threshold ? { skill: k.skill, by: 'knn', score: k.top1, neighbor: k.neighbor } : { skill: 'hoi-lai', by: 'fallback', score: k.top1, neighbor: k.neighbor };
  }
  // Bất biến: không bao giờ ra skill ngoài scope.
  if (!SKILLS_BY_SCOPE[scope].includes(out.skill)) out = { skill: 'ngoai-pham-vi', by: 'guard', reason: 'scope' };
  return out;
}
