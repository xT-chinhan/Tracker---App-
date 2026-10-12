/** Tiện ích dùng chung cho các skill (Track B). Thuần; chỉ `llmSentence`/`llmJson` gọi model qua `Llm` được truyền vào. */
import type { ChatMsg } from './ollama.js';
import { chat } from './ollama.js';
import type { Llm, Principal, SkillResult } from './contracts.js';
import { fold } from './text.js';

/** Adapter Ollama cho interface `Llm` (gemma2:2b, temperature 0, xem lib/ollama.ts). */
export const ollamaLlm: Llm = { chat: (m, f, n) => chat(m, f, n ?? 120) };

// ───────── định dạng số (số trong câu trả lời CHỈ đi qua các hàm này) ─────────
export const money = (n: number) => `${n < 0 ? '−' : ''}${Math.abs(Math.round(n)).toLocaleString('vi-VN')}đ`;
export const pct = (n: number) => `${(Math.round(n * 10) / 10).toLocaleString('vi-VN')}%`;
export const int = (n: number) => Math.round(n).toLocaleString('vi-VN');

// ───────── tìm tên trong câu (bỏ dấu, hoa thường) ─────────
const ALIAS: Record<string, string[]> = {
  'mb bank': ['mb', 'mbbank', 'mb bank', 'quan doi'],
  techcombank: ['tcb', 'techcombank', 'techcom'],
  vietcombank: ['vcb', 'vietcombank'],
  'tien mat': ['tien mat', 'cash', 'vi tien', 'tien trong vi'],
  momo: ['momo', 'mo mo'],
  zalopay: ['zalopay', 'zalo pay', 'zlp'],
  shopeepay: ['shopeepay', 'shopee pay', 'spay'],
};
const has = (f: string, w: string) => new RegExp(`(^|[^a-z0-9])${w.replace(/\s+/g, '\\s*')}($|[^a-z0-9])`).test(f);

/** Tên (ví/danh mục/mục tiêu) được nhắc trong câu; khớp dài nhất trước. */
export function findName(text: string, names: string[], aliases: Record<string, string[]> = ALIAS): string | null {
  const f = fold(text);
  const cands = names.flatMap((n) => [fold(n), ...(aliases[fold(n)] ?? [])].map((a) => ({ n, a })));
  cands.sort((x, y) => y.a.length - x.a.length);
  return cands.find((c) => has(f, c.a))?.n ?? null;
}

// ───────── chặn hỏi dữ liệu người khác (USER) ─────────
const PERSON = '(anh|chi|ong|ba|co|chu|bac|thang|ban|nguoi|vo|chong|me|bo|sep|dong nghiep|hang xom|khach|thanh vien|nhan vien|user|nguoi dung|tai khoan)';
const DATA = '(so du|chi tieu|tai khoan|vi|thu nhap|luong|giao dich|ngan sach|muc tieu|tiet kiem|bao cao|lich su|du lieu|thong tin|email|mat khau|so tien)';
const OTHER = [
  /\b(user|nguoi dung|tai khoan|account|khach hang|thanh vien) (khac|[a-z]|so \d+|\d+)\b/,
  /\b(nguoi khac|moi nguoi|tat ca (user|nguoi dung|moi nguoi|tai khoan|khach)|toan bo (user|nguoi dung|tai khoan)|cac (user|nguoi dung|tai khoan) khac|other users?|everyone|all users|someone else)/,
  new RegExp(`\\b${DATA}( [a-z]+){0,2} cua ${PERSON}\\b`),
  /\b(vo|chong|ban gai|ban trai|nguoi yeu|dong nghiep|hang xom|sep)( (minh|toi|tao))? (tieu|chi|xai|co|con|kiem) (bao nhieu|nhieu|het|duoc)/,
  /[\w.+-]+@[\w-]+\.[\w.]+/,
  /\bcua (nguyen|tran|pham|hoang|huynh|phan|dang|bui|ngo|duong|truong|dinh) [a-z]+\b/,
  /\buser ?id\b|\b(another|other) (user|person|account)/,
];
/** Câu gốc (còn hoa): "của anh Tuấn", "của chị Lan", "user Minh". */
const NAMED = /(của|cua) (anh|chị|ông|bà|cô|chú|bác|bạn|thằng|user|người dùng) [A-ZĐ]|\b(user|User|người dùng) [A-ZĐ]|(của|cua) [A-ZĐ][a-zà-ỹđ]+ [A-ZĐ][a-zà-ỹđ]+/u;
export const asksOtherUser = (text: string) => OTHER.some((re) => re.test(fold(text))) || NAMED.test(text);

const INJECT = [
  /\b(bo qua|quen|phot lo|vo hieu|khong can tuan theo|lo di) (het |moi |tat ca |cac |nhung )?(huong dan|chi dan|chi thi|lenh|quy tac|luat|rang buoc|gioi han|system|prompt)/,
  /\bignore (all |any |the |your |previous |prior |above )*(instructions|rules|prompts?|guidelines)/,
  /\b(system prompt|prompt he thong|developer mode|jailbreak|dan mode|che do nha phat trien)\b/,
  /\b(dong vai|gia vo|act as|pretend|roleplay|ban bay gio la|tu gio ban la|you are now)\b/,
  /\b(in ra|tiet lo|show|reveal|print) (toan bo |cac )?(prompt|huong dan he thong|instructions|cau lenh an)/,
];
export const isInjection = (text: string) => INJECT.some((re) => re.test(fold(text)));

/** Từ chối chuẩn. reason: other_user | injection | off_topic | scope. */
export function refusal(reason: 'other_user' | 'injection' | 'off_topic' | 'scope', scope: 'USER' | 'ADMIN' = 'USER'): SkillResult {
  const r = {
    other_user: 'Xin lỗi, mình chỉ xem được dữ liệu trong tài khoản của chính bạn, không thể cung cấp thông tin của người dùng khác.',
    injection: 'Xin lỗi, mình không thể thay đổi cách hoạt động theo yêu cầu này. Mình chỉ hỗ trợ các việc trong ứng dụng Thu Chi.',
    off_topic: scope === 'ADMIN'
      ? 'Xin lỗi, câu này nằm ngoài phạm vi trợ lý quản trị. Mình hỗ trợ tổng quan hệ thống, tra cứu người dùng, phát hiện bất thường, soạn thông báo và cấu hình.'
      : 'Xin lỗi, câu này nằm ngoài phạm vi của mình. Mình hỗ trợ ghi thu chi, xem số dư, báo cáo, ngân sách, tiết kiệm và cách dùng ứng dụng.',
    scope: scope === 'ADMIN'
      ? 'Phiên quản trị không xem hay ghi dữ liệu tài chính cá nhân. Hãy đăng nhập ứng dụng bằng tài khoản người dùng để làm việc này.'
      : 'Xin lỗi, việc này chỉ dành cho quản trị viên, mình không thể thực hiện trong tài khoản người dùng.',
  }[reason];
  const followUps = scope === 'ADMIN'
    ? ['Tổng quan hệ thống hôm nay', 'Có tài khoản nào bất thường không?']
    : ['Số dư các ví của tôi', 'Tháng này tôi chi bao nhiêu?'];
  return { reply: r, followUps, meta: { refused: reason } };
}

/** Chặn chung đặt đầu mọi skill USER (phòng khi router lọt). */
export function userGuard(input: string, p: Principal): SkillResult | null {
  if (p.role !== 'USER') return refusal('scope', 'ADMIN');
  if (isInjection(input)) return refusal('injection');
  if (asksOtherUser(input)) return refusal('other_user');
  return null;
}
export function adminGuard(input: string, p: Principal): SkillResult | null {
  if (p.role !== 'ADMIN') return refusal('scope', 'USER');
  if (isInjection(input)) return refusal('injection', 'ADMIN');
  return null;
}

// ───────── model: 1–2 câu nhận xét, KHÔNG được có số ─────────
const NUMBER_WORDS = /\b(mot|hai|ba|bon|nam|sau|bay|tam|chin|muoi|tram|nghin|ngan|trieu|ty|ti|phan tram|chuc|nua|k)\b/;
const VI_CHARS = /[ăâđêôơưáàảãạấầẩẫậắằẳẵặéèẻẽẹếềểễệíìỉĩịóòỏõọốồổỗộớờởỡợúùủũụứừửữựýỳỷỹỵ]/i;

/** Kiểm câu do model viết: tiếng Việt, ngắn, không chứa số (kể cả số viết bằng chữ), không link/email. */
export function checkSentence(s: string, maxLen = 220): string | null {
  const t = s.trim();
  if (!t) return 'rỗng';
  if (t.length > maxLen) return 'quá dài';
  if (/\d/.test(t)) return 'có chữ số';
  if (NUMBER_WORDS.test(fold(t).replace(/\bnam (nay|ngoai|sau|truoc)\b/g, ''))) return 'có số viết bằng chữ';
  if (/https?:|www\.|@/.test(t)) return 'có link/email';
  if (!VI_CHARS.test(t)) return 'không phải tiếng Việt';
  return null;
}

export interface Sentence { text: string; accepted: boolean | null; ms: number; calls: number; reason?: string }

/**
 * Model viết 1 câu nhận xét/khuyên từ các DỮ KIỆN ĐỊNH TÍNH (không đưa số cho model, để nó không có số mà chép).
 * Không đạt `checkSentence` → dùng `fallback` (câu do code chọn).
 */
export async function llmSentence(llm: Llm, task: string, facts: string[], fallback: string): Promise<Sentence> {
  const msgs: ChatMsg[] = [
    { role: 'system', content: 'Bạn là trợ lý tài chính cá nhân, nói tiếng Việt có dấu, thân thiện, ngắn gọn. Viết đúng MỘT câu (tối đa 30 từ). TUYỆT ĐỐI không viết con số, số tiền, phần trăm hay ngày tháng. Không bịa thông tin ngoài dữ kiện. Chỉ trả JSON.' },
    { role: 'user', content: `Việc: ${task}\nDữ kiện:\n${facts.map((f) => `- ${f}`).join('\n')}` },
  ];
  const schema = { type: 'object', properties: { sentence: { type: 'string' } }, required: ['sentence'] };
  try {
    const r = await llm.chat(msgs, schema, 90);
    const j = parseJson(r.content);
    const s = typeof j?.sentence === 'string' ? j.sentence.trim() : '';
    const bad = checkSentence(s);
    return bad ? { text: fallback, accepted: false, ms: r.ms, calls: 1, reason: bad } : { text: s, accepted: true, ms: r.ms, calls: 1 };
  } catch (e) {
    return { text: fallback, accepted: false, ms: 0, calls: 1, reason: String(e) };
  }
}

/** Gọi model với schema nhỏ, trả object hoặc null (không retry: ca khó thì code lùi về mặc định). */
export async function llmJson<T = any>(llm: Llm, system: string, user: string, schema: object, numPredict = 120, shots: [string, unknown][] = []): Promise<{ data: T | null; ms: number }> {
  const msgs: ChatMsg[] = [{ role: 'system', content: system }];
  for (const [u, a] of shots) msgs.push({ role: 'user', content: u }, { role: 'assistant', content: JSON.stringify(a) });
  msgs.push({ role: 'user', content: user });
  try {
    const r = await llm.chat(msgs, schema, numPredict);
    return { data: parseJson(r.content), ms: r.ms };
  } catch {
    return { data: null, ms: 0 };
  }
}

export function parseJson(s: string): any {
  const a = s.indexOf('{'), b = s.lastIndexOf('}');
  if (a < 0 || b < a) return null;
  try { return JSON.parse(s.slice(a, b + 1).replace(/,\s*([}\]])/g, '$1')); } catch { return null; }
}

export const llmMeta = (s: Sentence | null) => (s ? { calls: s.calls, ms: Math.round(s.ms), accepted: s.accepted } : { calls: 0, ms: 0, accepted: null });
