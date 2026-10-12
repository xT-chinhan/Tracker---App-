/**
 * Tín hiệu bằng code trên một khoản (không LLM):
 *  - sentenceIntent: câu là chuyển tiền giữa ví của chính user / vay–nợ → HỎI LẠI (không phải chi tiêu).
 *  - direction: khoản THU hay CHI, kèm gợi ý loại thu (lương / thưởng / đầu tư / được tặng / thu khác).
 * Mỗi mẫu viết trên chuỗi CÒN DẤU; mẫu bỏ dấu chỉ dùng khi câu không có dấu, và chỉ gồm các cụm không nhập nhằng
 * ("ban" = bán/bạn/bàn, "no" = nợ/nó, "muon" = mượn/muốn, "lai" = lãi/lại, "thuong" = thưởng/thường nên bị siết lại).
 */

export type Dir = 'INCOME' | 'EXPENSE';
export type IncomeKind = 'salary' | 'bonus' | 'invest' | 'gift' | 'other';
export interface DirCue { dir: Dir; kind?: IncomeKind; cue: string }

type Pat = { acc?: RegExp; plain?: RegExp };
const test = (p: Pat, n: string, f: string, dia: boolean) => {
  const m = (dia ? p.acc && n.match(p.acc) : (p.plain ?? p.acc) && f.match((p.plain ?? p.acc)!)) || null;
  return m ? m[0] : null;
};

// ---- chuyển tiền giữa ví / vay nợ (cả câu) ----
const LOAN: Pat = {
  acc: /(?<![\p{L}])(vay|mượn|nợ|trả nợ|trả góp nợ)(?![\p{L}])/u,
  plain: /\b(cho vay|vay tien|di vay|vay ngan hang|tra no|cho muon|muon tien|no tien)\b|^\s*vay\b/,
};
const WITHDRAW: Pat = { acc: /(?<![\p{L}])rút(?![\p{L}])/u, plain: /\brut\b/ };
const MOVE: Pat = { acc: /(?<![\p{L}])(chuyển|chuyển khoản|ck|nạp)(?![\p{L}])/u, plain: /\b(chuyen|chuyen khoan|ck|nap)\b/ };

/**
 * f: câu đã fold(); n: câu normVi(); wallets: các ví của user được nhắc trong câu (theo thứ tự).
 * Trả về lý do cần hỏi lại, hoặc null.
 */
export function sentenceIntent(n: string, f: string, dia: boolean, walletSpans: { walletName: string; start: number; end: number }[]): 'transfer' | 'loan' | null {
  if (test(LOAN, n, f, dia)) return 'loan';
  const distinct = new Set(walletSpans.map((w) => w.walletName));
  if (test(WITHDRAW, n, f, dia)) return 'transfer'; // rút tiền (ATM / ví → tiền mặt)
  if (test(MOVE, n, f, dia)) {
    if (distinct.size >= 2) return 'transfer'; // chuyển từ ví A sang ví B
    // nạp/chuyển VÀO một ví của chính mình ("nạp 200k vào ví momo", "chuyển về mb"), không có người nhận
    if (!/\bcho\b/.test(f) && walletSpans.some((w) => /\b(vao|sang|ve)\b/.test(f.slice(Math.max(0, w.start - 12), w.end)))) return 'transfer';
  }
  return null;
}

// ---- THU / CHI cho từng khoản ----
// n, f: đoạn của khoản, đã che ngày/ví, tiền thay bằng "#".
const PERSON = 'mẹ|má|mạ|bố|ba|cha|tía|ông|bà|ông bà|anh|chị|em|cô|chú|dì|bác|cậu|mợ|thím|sếp|vợ|chồng|người yêu|ny|bạn|công ty|khách';
const PERSON_PLAIN = 'me|ma|bo|ba|cha|tia|ong|ong ba|anh|chi|co|chu|di|bac|cau|sep|vo|chong|ny|cong ty|khach';
const W = '(?<![\\p{L}])'; // ranh giới từ cho chuỗi có dấu
const E = '(?![\\p{L}])';
const re = (s: string) => new RegExp(s.replaceAll('\\b<', W).replaceAll('>\\b', E), 'u');

/** Câu bắt đầu bằng động từ chi tiêu → CHI (thắng mọi tín hiệu thu phía sau: "trả lương", "mua … được"). */
const EXPENSE_START: Pat = {
  acc: re(`^\\s*(?:\\b<(?:mua|trả|đóng|nạp|tốn|tiêu|biếu|mừng|phúng|viếng|gửi|ck cho|chuyển cho|chuyển khoản cho|cho)>\\b\\s+(?!thuê)|lì xì\\s+(?!#|$))`),
  plain: /^\s*(?:(?:mua|tra|dong|nap|ton|tieu|bieu|mung|gui|ck cho|chuyen cho|cho)\b\s+(?!thue)|li xi\s+(?!#|$))/,
};

const INCOME: [IncomeKind, Pat][] = [
  ['bonus', { acc: re(`\\b<(?:được thưởng|đc thưởng|dc thưởng|nhận thưởng|tiền thưởng|thưởng)>\\b`), plain: /\b(?:duoc thuong|dc thuong|nhan thuong|tien thuong|thuong (?:tet|kpi|nong|du an|quy|thang|le|trung thu|cuoi nam))\b|^thuong\b/ }],
  ['salary', { acc: re(`\\b<lương>\\b`), plain: /\bluong\b/ }],
  ['invest', { acc: re(`\\b<(?:lãi|cổ tức|chốt lời|lời chứng khoán|lời cổ phiếu)>\\b`), plain: /\b(?:lai tiet kiem|lai suat|tien lai|lai (?:chung khoan|co phieu|crypto|coin|quy|tien gui)|co tuc|chot loi)\b/ }],
  ['gift', {
    acc: re(`\\b<(?:được|đc|dc|nhận)>\\b(?:\\s+\\S+){0,3}?\\s+\\b<(?:cho|tặng|biếu|lì xì|mừng)>\\b|^\\s*(?:${PERSON})(?:\\s+\\S+){0,2}?\\s+(?:cho|tặng|biếu|lì xì|gửi cho|chuyển cho|ck cho|gửi|chuyển)\\s*(?:#|mình|em|con|tôi|tao)`),
    plain: new RegExp(`\\b(?:duoc|dc|nhan)\\b(?:\\s+\\S+){0,3}?\\s+\\b(?:cho|tang|bieu|li xi|lixi|mung)\\b|^\\s*(?:${PERSON_PLAIN})(?:\\s+\\S+){0,2}?\\s+(?:cho|tang|bieu|li xi|gui cho|chuyen cho|ck cho|gui|chuyen)\\s*(?:#|minh|em|con|toi|tao)`),
  }],
  ['other', {
    acc: re(`\\b<(?:bán|thanh lý|pass|hoàn tiền|hoàn|cashback|refund|freelance|làm thêm|tiền công|hoa hồng|cho thuê|trúng|thu tiền|khách trả)>\\b|\\b<(?:được|đc|dc)>\\b\\s*#`),
    plain: /^(?:ban|thanh ly|pass)\b|\bban\b.*\b(?:duoc|dc)\b|\b(?:thanh ly|hoan tien|hoan|cashback|refund|freelance|lam them|tien cong|hoa hong|cho thue|trung|thu tien|khach tra)\b|\b(?:duoc|dc)\s*#/,
  }],
];

const EXPENSE_ANY: Pat = {
  acc: re(`\\b<(?:mua|trả|đóng|tốn|hết|mất|tiêu|nạp|ck cho|chuyển cho|biếu|mừng)>\\b`),
  plain: /\b(?:mua|tra|dong|ton|het|mat|tieu|nap|ck cho|chuyen cho|bieu|mung)\b/,
};

export function direction(n: string, f: string, dia: boolean): DirCue | null {
  const s = test(EXPENSE_START, n, f, dia);
  if (s) return { dir: 'EXPENSE', cue: s.trim() };
  for (const [kind, p] of INCOME) {
    const m = test(p, n, f, dia);
    // "trúng thưởng" là thu khác, không phải thưởng từ công việc
    if (m && kind === 'bonus' && /trúng thưởng|trung thuong/.test(dia ? n : f)) continue;
    if (m) return { dir: 'INCOME', kind, cue: m.trim() };
  }
  const e = test(EXPENSE_ANY, n, f, dia);
  return e ? { dir: 'EXPENSE', cue: e.trim() } : null;
}

/** Từ không mang nội dung: nếu cả khoản chỉ còn các từ này thì không biết tiền cho việc gì → hỏi lại. */
const EMPTY_ACC = new Set('đưa trả tiêu hết mất tốn chuyển khoản ck tiền cho nó người ta mình em tao nay rồi luôn nhé à ơi thôi chi ra vào đi làm gì cái đồ nhiều ít quá'.split(' '));
// bản bỏ dấu: không có "cho" (= chợ) và "do" (= đồ/đỏ/đó)
const EMPTY_PLAIN = new Set('dua tra tieu het mat ton chuyen khoan ck tien no nguoi ta minh em tao nay roi luon nhe a oi thoi chi ra vao di lam gi cai nhieu it qua'.split(' '));
export const isEmptyContent = (seg: { clean: string; norm: string; dia: boolean }) =>
  seg.dia ? seg.norm.split(' ').filter(Boolean).every((w) => EMPTY_ACC.has(w)) : seg.clean.split(' ').filter(Boolean).every((w) => EMPTY_PLAIN.has(w));
