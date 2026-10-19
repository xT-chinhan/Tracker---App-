/**
 * Skill built-in + registry. Skill từ `ai/` (Track A/B) nạp lúc khởi động và GHI ĐÈ built-in cùng tên (xem ai.external.ts).
 * Built-in ở đây là bản tối thiểu, tất định (trừ ghi-giao-dich dùng LLM) để API chạy được trước khi Track B xong.
 */
import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { monthOf, shiftMonth } from '../common/time';
import { aiLib, loadExternalSkills, type AiUserContext } from './ai.external';
import { chatJson } from './ai.llm';
import { accentedClean, fmtVnd, fold, ruleKeys } from './ai.text';
import type { ChatMsg, Principal, Skill, SkillResult } from './ai.types';

/* ============================== tiện ích ============================== */

const cap = (s: string) => s.replace(/^\p{L}/u, (c) => c.toUpperCase());
const vnDay = (iso: string) => {
  const [y, m, d] = iso.slice(0, 10).split('-');
  return `${d}/${m}${y === String(new Date().getFullYear()) ? '' : `/${y}`}`;
};

/** "tháng 9", "tháng 9/2025", "tháng trước", "tháng sau" → YYYY-MM (mặc định tháng hiện tại, giờ VN). */
export function monthFromText(text: string, now: string, preferPast = true): string {
  const f = fold(text);
  const cur = monthOf(new Date(now));
  if (/\bthang (truoc|roi)\b/.test(f)) return shiftMonth(cur, -1);
  if (/\bthang (sau|toi)\b/.test(f)) return shiftMonth(cur, 1);
  const m = /\bthang (\d{1,2})(?:\s*[/-]\s*(\d{4}))?\b/.exec(f);
  if (m && +m[1] >= 1 && +m[1] <= 12) {
    const mm = String(+m[1]).padStart(2, '0');
    if (m[2]) return `${m[2]}-${mm}`;
    const y = +cur.slice(0, 4);
    const cand = `${y}-${mm}`;
    return preferPast && cand > cur ? `${y - 1}-${mm}` : cand;
  }
  return cur;
}

const EMAIL_RE = /[^\s@<>()"',;:]+@[^\s@<>()"',;:]+\.[a-z]{2,}/i;

/* ============================== ghi-giao-dich (dùng ai/ parser + prompt + schema) ============================== */

interface RuleRow { id: string; scope: string; pattern: string; value: string; support: number }
interface SimRow { input: string; output: any; scope: string; score: number }

const ASK_REPLY: Record<'transfer' | 'loan' | 'empty', { reply: string; followUps: string[] }> = {
  transfer: { reply: 'Đây là chuyển tiền giữa các ví của bạn, không phải khoản thu/chi. Bạn ghi ở màn Chuyển tiền (nhấn giữ nút ＋) để số dư hai ví đúng nhé.', followUps: ['số dư các ví'] },
  loan: { reply: 'Khoản vay / cho vay / trả nợ chưa ghi được bằng trợ lý. Nếu đây là chi tiêu thật, bạn nói rõ hơn, ví dụ "trả tiền điện 500k".', followUps: ['trả tiền điện 500k'] },
  empty: { reply: 'Khoản này là gì vậy? Bạn thêm nội dung giúp mình, ví dụ "ăn trưa 50k" hoặc "đổ xăng 80k".', followUps: ['ăn trưa 50k', 'đổ xăng 80k'] },
};

/**
 * Pipeline Track A (ai/skills/ghi-giao-dich, xem SKILL.md) với dữ liệu học trong DB:
 *  parser (tiền/ngày/ví/tín hiệu thu-chi, hỏi lại khi chuyển ví / vay nợ / thiếu nội dung)
 *  → chốt danh mục bằng code: luật đã học (không trái tín hiệu thu/chi) → tín hiệu THU → từ điển
 *  → kNN few-shot → LLM điền title + danh mục với enum RIÊNG từng khoản → hậu kiểm (loại theo danh mục, tiền/ngày/ví theo parser).
 */
const ghiGiaoDich: Skill = {
  name: 'ghi-giao-dich',
  scope: 'USER',
  description: 'Ghi khoản thu/chi từ câu tự nhiên (nhiều khoản một lúc) thành nháp để xác nhận',
  context: ['userContext'],
  async run({ input, context, llm, now }) {
    const lib = await aiLib();
    if (!lib) return { reply: 'Chức năng ghi giao dịch bằng AI chưa sẵn sàng trên máy chủ. Bạn ghi tay giúp mình nhé.', askBack: true, meta: { unavailable: true } };
    const uctx: AiUserContext = { ...(context.data.userContext as AiUserContext), now };
    const { segs: all, ask } = lib.analyze(input, uctx);
    const segs = all.slice(0, 20);
    if (!segs.length) return { reply: 'Bạn muốn ghi khoản gì, bao nhiêu tiền? Ví dụ: "cà phê 45k hôm qua trả momo".', askBack: true, followUps: ['cà phê 45k', 'ăn trưa 50k hôm qua'] };
    if (ask) return { ...ASK_REPLY[ask], askBack: true, meta: { reason: ask } };
    const catType = new Map(uctx.categories.map((c) => [c.name, c.type]));
    const names = (t?: 'INCOME' | 'EXPENSE') => uctx.categories.filter((c) => !t || c.type === t).map((c) => c.name);
    // Khóa luật + câu kNN giữ như cũ (luật / embedding đã lưu trong DB dựa trên chuỗi này)
    const acc = segs.map((s) => accentedClean(s.text, s.clean));

    // 1) Luật học được (user trước, rồi chung) — chỉ dùng khi loại thu/chi của luật không trái tín hiệu parser
    const rules = await context.get<RuleRow[]>('userRules', { kind: 'category', skill: 'ghi-giao-dich' });
    const hits = acc.map((a, i) => {
      const keys = ruleKeys(a);
      const dir = segs[i].dir?.dir;
      const cands = rules.filter((r) => keys.includes(r.pattern) && catType.has(r.value) && (!dir || catType.get(r.value) === dir));
      return cands.sort((x, y) => y.pattern.split(' ').length - x.pattern.split(' ').length)[0] ?? null;
    });
    // 2) Tín hiệu THU → danh mục thu; 3) từ điển (thực phẩm đi chợ / đồ cho con / sức khỏe)
    const decided = segs.map((s, i): { categoryName: string; by: string } | null => {
      if (hits[i]) return { categoryName: hits[i]!.value, by: 'rule' };
      const inc = lib.incomeCategory(s, uctx);
      if (inc) return { categoryName: inc, by: `income:${s.dir?.kind ?? 'other'}` };
      const lex = lib.lexiconCategory(s, uctx);
      return lex ? { categoryName: lex.categoryName, by: lex.why } : null;
    });
    // Enum riêng từng khoản: đã chốt → đúng 1 danh mục; có tín hiệu thu/chi → chỉ danh mục loại đó; còn lại → tất cả
    const allowed = segs.map((s, i) => (decided[i] ? [decided[i]!.categoryName] : names(s.dir?.dir)));

    // 4) kNN few-shot từ kho ví dụ (riêng user + chung), chỉ lấy ví dụ có danh mục hợp lệ
    const sims = await context.get<SimRow[][]>('similarExamples', { skill: 'ghi-giao-dich', texts: acc.map((a, i) => a || segs[i].text), k: 5 });
    const picked: SimRow[] = [];
    for (let r = 0; picked.length < 5 && r < 5; r++)
      for (const l of sims) {
        const x = l[r];
        if (x && x.score >= 0.3 && catType.has(x.output?.categoryName) && !picked.some((p) => p.input === x.input) && picked.length < 5) picked.push(x);
      }
    picked.sort((a, b) => a.score - b.score);

    // 5) LLM chỉ đặt tên ngắn + chọn danh mục trong enum của từng khoản; tiền/ngày/ví do parser
    const msgs: ChatMsg[] = [
      { role: 'system', content: lib.systemV1(uctx) },
      ...picked.flatMap((ex): ChatMsg[] => [
        { role: 'user', content: lib.userV1(ex.input, [ex.input]) },
        { role: 'assistant', content: JSON.stringify({ items: [{ title: ex.output.title, categoryName: ex.output.categoryName }] }) },
      ]),
      { role: 'user', content: lib.userV1(input, segs.map((s) => s.text), segs.map((s) => (s.dir?.dir === 'INCOME' ? 'THU' : undefined))) },
    ];
    const canon = (name: unknown) => (typeof name === 'string' ? uctx.categories.find((c) => fold(c.name) === fold(name.trim()))?.name : undefined);
    const r = await chatJson(llm, msgs, lib.schemaV1(uctx, segs.length, allowed), (raw) => {
      // qwen3.5 hay bỏ lớp {items: [...]} khi chỉ có 1 khoản → chấp nhận object / mảng trần
      const j = Array.isArray(raw) ? { items: raw } : raw && !Array.isArray(raw.items) && (raw.title !== undefined || raw.categoryName !== undefined) ? { items: [raw] } : raw;
      if (!Array.isArray(j.items) || j.items.length !== segs.length) throw new Error(`cần đúng ${segs.length} khoản`);
      const bad = j.items.findIndex((x: any, i: number) => !allowed[i].includes(canon(x.categoryName) ?? ''));
      if (bad >= 0) throw new Error(`categoryName "${j.items[bad].categoryName}" của khoản ${bad + 1} phải là một trong: ${allowed[bad].join(', ')}`);
      return j.items.map((x: any) => ({ title: String(x.title ?? '').trim(), categoryName: canon(x.categoryName)! }));
    }, { numPredict: 60 + 40 * segs.length });
    const llmOut: { title: string; categoryName: string }[] | null = r.value;
    const stats = { calls: r.calls, ms: Math.round(r.ms), promptTokens: r.promptTokens, evalTokens: r.evalTokens, retried: r.retried, error: r.error };

    // 6) Hậu kiểm: code đã chốt thắng model; model hỏng → Thu khác / Chi khác theo tín hiệu parser
    let fallback = 0;
    const items = segs.map((s, i) => {
      let categoryName = decided[i]?.categoryName ?? llmOut?.[i]?.categoryName;
      if (!categoryName || !catType.has(categoryName)) {
        const want = s.dir?.dir === 'INCOME' ? 'Thu khác' : 'Chi khác';
        categoryName = catType.has(want) ? want : allowed[i][0] ?? uctx.categories[0].name;
        fallback++;
      }
      // model nhỏ hay chép số tiền / ví / ngày vào tên ("Cà phê 45k", "Cơm trưa ví") → bỏ bằng bộ tìm của parser
      const title = lib.cleanTitle(llmOut?.[i]?.title || '', s, uctx).slice(0, 120) || cap(acc[i] || s.text);
      return { title, amount: s.amount, categoryName, type: catType.get(categoryName)!, date: s.date, walletName: s.walletName, source: s.text, clean: acc[i], ruleId: hits[i]?.id ?? null };
    });
    const lines = items.map((it) => `• ${it.title} — ${fmtVnd(it.amount)} · ${it.categoryName} · ${vnDay(it.date)}${it.walletName ? ` · ${it.walletName}` : ''}`);
    return {
      reply: `Mình ghi nháp ${items.length} khoản:\n${lines.join('\n')}\nBấm Xác nhận để lưu, hoặc sửa trước khi lưu.`,
      draft: { kind: 'transactions', payload: { items } },
      meta: { ...stats, shots: picked.length, rules: hits.map((h) => h?.pattern ?? null), decidedBy: decided.map((d) => d?.by ?? null), fallback },
    };
  },
};

/* ============================== doc-hoa-don (đọc ảnh hóa đơn / chuyển khoản) ============================== */

// Không đưa tên người dùng vào prompt: model sẽ tự điền tên đó vào sai ô người chuyển / người nhận.
const OCR_PROMPT =
  'Đây là ảnh hóa đơn mua hàng hoặc ảnh chụp màn hình giao dịch ngân hàng / ví điện tử ở Việt Nam. ' +
  'Trả JSON: {"kind": "receipt" nếu là hóa đơn cửa hàng, "transfer" nếu là chuyển khoản / thanh toán qua ngân hàng hoặc ví, ' +
  '"amount": TỔNG số tiền, số nguyên đồng (16,900 hay 16.900 đều là 16900), "date": "YYYY-MM-DD", ' +
  '"merchant": tên cửa hàng (hóa đơn), "recipient": tên người / đơn vị NHẬN tiền (trên màn hình chuyển tiền thành công là tên in đậm ngay dưới số tiền), ' +
  '"sender": tên ở dòng "Từ tài khoản" / người chuyển (nếu có), "note": nguyên văn dòng "Nội dung", "bank": tên ngân hàng hoặc ví hiển thị trên ảnh}. Trường nào không thấy thì để chuỗi rỗng. Chỉ trả JSON.';

/** Gỡ khối ```json, lấy object đầu tiên. */
function ocrJson(content: string): Record<string, unknown> {
  const a = content.indexOf('{'), b = content.lastIndexOf('}');
  if (a < 0 || b < a) return {};
  try {
    const j = JSON.parse(content.slice(a, b + 1));
    return j && typeof j === 'object' ? j : {};
  } catch {
    return {};
  }
}

const str = (v: unknown) => (typeof v === 'string' ? v.trim() : '');
/** So tên không dấu, không phân biệt hoa thường, bỏ khoảng trắng ("NGUYEN CHI NHAN" ≈ "Nguyễn Chí Nhân"). */
const sameName = (a: string, b: string) => !!a && !!b && fold(a).replace(/[^a-z0-9]/g, '') === fold(b).replace(/[^a-z0-9]/g, '');
/** Nội dung chuyển khoản dạng mã ("HIHIIDK0EK49P6CFC") không dùng làm tên khoản. */
const looksLikeCode = (s: string) => !s || (!/\s/.test(s) && /\d/.test(s) && s.length > 8);
/** Nội dung chuyển khoản không dùng làm tiêu đề được: mã giao dịch, nội dung mặc định của ngân hàng ("<tên> chuyen tien"). */
const uselessNote = (s: string, names: string[]) =>
  looksLikeCode(s) || /chuy[eể]n (tien|tiền)|chuyen khoan|chuyển khoản/i.test(fold(s)) || names.some((n) => n && fold(s).includes(fold(n)));

const docHoaDon: Skill = {
  name: 'doc-hoa-don',
  scope: 'USER',
  description: 'Đọc ảnh hóa đơn / ảnh chụp màn hình chuyển khoản thành nháp giao dịch để xác nhận',
  context: ['userContext'],
  async run(args) {
    const { context, llm, now, image } = args;
    if (!image) return { reply: 'Bạn gửi ảnh hóa đơn hoặc ảnh chụp màn hình chuyển khoản giúp mình nhé.', askBack: true };
    if (!llm.vision) return { reply: 'Máy chủ chưa hỗ trợ đọc ảnh. Bạn ghi tay giúp mình nhé.', askBack: true, meta: { unavailable: true } };
    const uctx = context.data.userContext as AiUserContext;
    const user = context.principal.name;
    const r = await llm.vision(OCR_PROMPT, image);
    const j = ocrJson(r.content);
    // model đôi khi trả chuỗi "50,000" / "16.900 VND": dấu phân cách hàng nghìn ở VN, bỏ hết ký tự không phải số
    const amount = Math.abs(Math.round(typeof j.amount === 'string' ? Number(j.amount.replace(/\D/g, '')) : Number(j.amount) || 0));
    const today = new Date(new Date(now).getTime() + 7 * 3600_000).toISOString().slice(0, 10);
    const dateRaw = str(j.date).slice(0, 10);
    const date = /^\d{4}-\d{2}-\d{2}$/.test(dateRaw) && !Number.isNaN(Date.parse(dateRaw)) && dateRaw <= today ? dateRaw : today;
    const ocr = { kind: str(j.kind), amount, date, merchant: str(j.merchant), sender: str(j.sender), recipient: str(j.recipient), note: str(j.note), bank: str(j.bank) };
    const meta = { ocr, ms: Math.round(r.ms), promptTokens: r.promptTokens, evalTokens: r.evalTokens };
    if (amount <= 0) {
      return {
        reply: 'Mình chưa đọc được số tiền trong ảnh. Bạn chụp lại rõ phần tổng tiền, hoặc ghi tay giúp mình.',
        askBack: true, followUps: ['ghi tay'], meta: { ...meta, unreadable: true },
      };
    }
    // Thu hay chi do CODE quyết: ảnh chuyển khoản mà người dùng là người nhận → THU; còn lại → CHI
    const income = ocr.kind === 'transfer' && sameName(ocr.recipient, user) && !sameName(ocr.sender, user);
    const counterpart = income ? ocr.sender : ocr.kind === 'transfer' ? ocr.recipient || ocr.merchant : ocr.merchant || ocr.recipient;
    const title = (income ? `Nhận tiền ${counterpart || ''}` : ocr.kind === 'transfer' && !uselessNote(ocr.note, [user, ocr.sender, ocr.recipient]) ? ocr.note : counterpart || 'Giao dịch từ ảnh').trim().slice(0, 120);

    // Danh mục: mượn ghi-giao-dich (luật đã học, kNN, model) trên câu dựng từ ảnh; tiền / ngày / loại lấy từ ảnh
    let categoryName: string | undefined;
    try {
      const g = await ghiGiaoDich.run({ ...args, input: `${income ? 'nhận tiền ' : ''}${title} ${amount}` });
      const it = (g.draft?.payload as any)?.items?.[0];
      if (it?.categoryName) categoryName = it.categoryName;
    } catch {
      // không gợi ý được danh mục → dùng mặc định bên dưới
    }
    const typeOf = new Map(uctx.categories.map((c) => [c.name, c.type]));
    const want = income ? 'INCOME' : 'EXPENSE';
    if (!categoryName || typeOf.get(categoryName) !== want) {
      const fb = income ? 'Thu khác' : 'Chi khác';
      categoryName = typeOf.has(fb) ? fb : uctx.categories.find((c) => c.type === want)?.name;
    }
    // Ví: khớp tên ngân hàng / ví trên ảnh với ví của người dùng ("VietinBank" ↔ "Vietinbank", "MB Bank"); không khớp → ví mặc định
    const bank = fold(ocr.bank).replace(/[^a-z0-9]/g, '');
    const wallet = bank ? uctx.wallets.find((w) => { const n = fold(w.name).replace(/[^a-z0-9]/g, ''); return n.length > 1 && (bank.includes(n) || n.includes(bank)); }) : undefined;
    const item = {
      title, amount, categoryName, type: want, date, walletName: wallet?.name ?? null,
      note: [ocr.kind === 'transfer' && ocr.note ? `ND: ${ocr.note}` : '', 'Đọc từ ảnh'].filter(Boolean).join(' · ').slice(0, 500),
      source: '[ảnh]', clean: fold(title), ruleId: null,
    };
    const line = `• ${title} — ${fmtVnd(amount)} · ${categoryName} · ${vnDay(date)}${wallet ? ` · ${wallet.name}` : ''}`;
    return {
      reply: `Mình đọc được từ ảnh${ocr.bank ? ` (${ocr.bank})` : ''}:\n${line}\n${income ? 'Đây là khoản tiền bạn nhận. ' : ''}Bấm Xác nhận để lưu, hoặc sửa trước khi lưu.`,
      draft: { kind: 'transactions', payload: { items: [item] } },
      meta,
    };
  },
};

/* ============================== skill tra cứu (tất định) ============================== */

const hoiSoDu: Skill = {
  name: 'hoi-so-du',
  scope: 'USER',
  description: 'Số dư tổng và từng ví',
  context: ['balance'],
  async run({ input, context }) {
    const b = context.data.balance as { total: number; savings: number; wallets: { name: string; balance: number }[] };
    const f = fold(input);
    const one = b.wallets.find((w) => f.includes(fold(w.name)));
    if (one) return { reply: `Ví ${one.name} còn ${fmtVnd(one.balance)}.`, followUps: ['tổng số dư', 'tháng này tiêu bao nhiêu'] };
    const lines = b.wallets.map((w) => `• ${w.name}: ${fmtVnd(w.balance)}`);
    return { reply: `Tổng số dư: ${fmtVnd(b.total)}\n${lines.join('\n')}${b.savings ? `\nĐang gửi tiết kiệm: ${fmtVnd(b.savings)}` : ''}`, followUps: ['tháng này tiêu bao nhiêu'] };
  },
};

const tongKetThang: Skill = {
  name: 'tong-ket-thang',
  scope: 'USER',
  description: 'Tổng thu, chi, chênh lệch và danh mục chi nhiều nhất của một tháng',
  async run({ input, context, now }) {
    const s = await context.get<any>('monthSummary', { month: monthFromText(input, now) });
    const top = s.topExpenses.map((c: any) => `• ${c.name}: ${fmtVnd(c.amount)}`).join('\n');
    return { reply: `Tháng ${s.month.slice(5)}/${s.month.slice(0, 4)}: thu ${fmtVnd(s.income)}, chi ${fmtVnd(s.expense)}, ${s.net >= 0 ? 'dư' : 'âm'} ${fmtVnd(Math.abs(s.net))}.${top ? `\nChi nhiều nhất:\n${top}` : ''}`, followUps: ['ngân sách tháng này thế nào'] };
  },
};

const kiemTraNganSach: Skill = {
  name: 'kiem-tra-ngan-sach',
  scope: 'USER',
  description: 'Tình hình ngân sách tháng (tổng + theo danh mục)',
  async run({ input, context, now }) {
    const b = await context.get<any>('budgets', { month: monthFromText(input, now) });
    if (!b.overall && !b.items.length) return { reply: `Tháng ${b.month} bạn chưa đặt ngân sách nào. Thử "đặt ngân sách ăn uống 3 triệu".`, followUps: ['đặt ngân sách tổng 10 triệu'] };
    const f = fold(input);
    const rows = [...(b.overall ? [{ ...b.overall, categoryName: 'Tổng' }] : []), ...b.items].filter((x: any) => !b.items.some((i: any) => f.includes(fold(i.categoryName))) || f.includes(fold(x.categoryName)));
    const st = (s: string) => (s === 'exceeded' ? 'VƯỢT' : s === 'warning' ? 'sắp hết' : 'ổn');
    return { reply: rows.map((x: any) => `• ${x.categoryName}: ${fmtVnd(x.spent)} / ${fmtVnd(x.limit)} (${x.percentage}%, ${st(x.status)})`).join('\n') };
  },
};

const tienDoTietKiem: Skill = {
  name: 'tien-do-tiet-kiem',
  scope: 'USER',
  description: 'Tiến độ các mục tiêu tiết kiệm',
  context: ['savingGoals'],
  async run({ context }) {
    const gs = (context.data.savingGoals as any[]).filter((g) => g.status === 'ACTIVE' || g.status === 'COMPLETED');
    if (!gs.length) return { reply: 'Bạn chưa có mục tiêu tiết kiệm nào đang chạy.' };
    return { reply: gs.map((g) => `• ${g.name}: ${fmtVnd(g.saved)} / ${fmtVnd(g.target)} (${g.progress}%)${g.status === 'ACTIVE' && g.dailyRequired ? `, cần ~${fmtVnd(g.dailyRequired)}/ngày` : ''}`).join('\n') };
  },
};

const SEARCH_FILLER = /\b(tim|kiem|liet ke|xem lai|xem|giao dich|cac|nhung|khoan|cua|toi|minh|cho|thang nay|thang truoc|thang \d{1,2}|tuan nay|tuan truoc|hom nay|hom qua|gan day|du lieu|tat ca|het|di|nao|la gi|o dau|bao nhieu|lan|chi|tieu)\b/g;

const timGiaoDich: Skill = {
  name: 'tim-giao-dich',
  scope: 'USER',
  description: 'Tìm giao dịch theo từ khóa / tháng',
  async run({ input, context, now }) {
    const f = fold(input);
    // Từ khóa lấy trên câu gốc (còn dấu) theo vị trí các từ không phải từ đệm trong bản bỏ dấu (fold giữ nguyên độ dài)
    const kept = f.replace(new RegExp(EMAIL_RE.source, 'gi'), (m) => ' '.repeat(m.length)).replace(SEARCH_FILLER, (m) => ' '.repeat(m.length));
    const q = [...kept.matchAll(/[a-z0-9]+/g)].map((m) => input.slice(m.index!, m.index! + m[0].length)).join(' ').trim() || undefined;
    const month = /\bthang\b/.test(f) ? monthFromText(input, now) : undefined;
    const r = await context.get<{ total: number; items: any[] }>('searchTransactions', { q, month, limit: 5 });
    const lines = r.items.map((t) => `• ${vnDay(new Date(new Date(t.occurredAt).getTime() + 7 * 3600_000).toISOString())} ${t.title} — ${t.type === 'INCOME' ? '+' : '-'}${fmtVnd(t.amount)} (${t.categoryName})`);
    return {
      reply: r.total ? `Có ${r.total} giao dịch${q ? ` khớp "${q}"` : ''}${month ? ` trong tháng ${month}` : ''}:\n${lines.join('\n')}${r.total > 5 ? '\n…' : ''}` : `Không thấy giao dịch nào${q ? ` khớp "${q}"` : ''}.`,
      draft: r.total ? { kind: 'search_filter', payload: { target: 'transactions', q: q ?? null, month: month ?? null } } : undefined,
    };
  },
};

const datNganSach: Skill = {
  name: 'dat-ngan-sach',
  scope: 'USER',
  description: 'Đặt ngân sách tháng (tổng hoặc theo danh mục) thành nháp để xác nhận',
  context: ['userContext'],
  async run({ input, context, now }) {
    const lib = await aiLib();
    const uctx: AiUserContext = { ...(context.data.userContext as AiUserContext), now };
    const amount = lib?.analyze(input, uctx).segs[0]?.amount;
    if (!amount) return { reply: 'Bạn muốn đặt ngân sách bao nhiêu? Ví dụ "đặt ngân sách ăn uống 3 triệu tháng này".', askBack: true };
    const f = fold(input);
    const cat = uctx.categories.filter((c) => c.type === 'EXPENSE').sort((a, b) => b.name.length - a.name.length).find((c) => f.includes(fold(c.name)));
    const month = monthFromText(input, now, false);
    const item = { categoryName: cat?.name ?? null, month, limitAmount: amount };
    return {
      reply: `Nháp ngân sách ${cat ? `"${cat.name}"` : 'tổng'} tháng ${month}: ${fmtVnd(amount)}. Xác nhận để lưu nhé.`,
      draft: { kind: 'budgets', payload: { items: [item] } },
    };
  },
};

const huongDan: Skill = {
  name: 'huong-dan',
  scope: 'USER',
  description: 'Hướng dẫn dùng app',
  async run() {
    return {
      reply: 'Mình giúp được: ghi thu chi ("cà phê 45k, grab 30k hôm qua"), hỏi số dư, tổng kết tháng, kiểm tra / đặt ngân sách, tìm giao dịch, tiến độ tiết kiệm. Các thao tác trong app nằm ở tab Cài đặt và nút ＋.',
      followUps: ['số dư hiện tại', 'tháng này tiêu bao nhiêu'],
    };
  },
};

const ngoaiPhamVi: Skill = {
  name: 'ngoai-pham-vi',
  scope: 'ANY',
  description: 'Câu hỏi ngoài phạm vi thu chi',
  async run() {
    return { reply: 'Câu này nằm ngoài phạm vi của mình. Mình chỉ giúp về thu chi, ngân sách và tiết kiệm của bạn thôi.', followUps: ['số dư hiện tại', 'ghi cà phê 30k'] };
  },
};

const hoiLai: Skill = {
  name: 'hoi-lai',
  scope: 'ANY',
  description: 'Hỏi lại khi chưa rõ ý',
  async run() {
    return { reply: 'Mình chưa rõ ý bạn. Bạn muốn ghi một khoản thu/chi, hay xem số dư / tổng kết tháng?', askBack: true, followUps: ['ghi cà phê 30k', 'số dư hiện tại', 'tháng này tiêu bao nhiêu'] };
  },
};

/* ============================== skill admin ============================== */

const adminTongQuan: Skill = {
  name: 'tong-quan-he-thong',
  scope: 'ADMIN',
  description: 'Tổng quan hệ thống (số user, giao dịch)',
  context: ['adminOverview'],
  async run({ context }) {
    const o = context.data.adminOverview as any;
    return { reply: `Người dùng: ${o.users.total} (${o.users.active} hoạt động, ${o.users.locked} khóa, ${o.users.new30d} mới 30 ngày). Giao dịch: ${o.transactions.total} (${o.transactions.new30d} trong 30 ngày).` };
  },
};

const adminTimUser: Skill = {
  name: 'tra-cuu-nguoi-dung',
  scope: 'ADMIN',
  description: 'Tìm người dùng theo email / tên',
  async run({ input, context }) {
    const q = EMAIL_RE.exec(input)?.[0] ?? input.replace(/^.*?\b(tìm|tim|kiếm|kiem)\b\s*(user|người dùng|nguoi dung|tài khoản|tai khoan)?\s*/iu, '').trim();
    const r = await context.get<any>('adminUsersSearch', { q, limit: 5 });
    if (!r.total) return { reply: `Không thấy người dùng nào khớp "${q}".` };
    return { reply: `${r.total} người dùng khớp "${q}":\n${r.items.map((u: any) => `• ${u.name} <${u.email}> ${u.role}${u.status === 'LOCKED' ? ' (đang khóa)' : ''}`).join('\n')}`, draft: { kind: 'search_filter', payload: { target: 'users', q } } };
  },
};

const adminKhoaUser: Skill = {
  name: 'de-xuat-khoa',
  scope: 'ADMIN',
  description: 'Khóa tài khoản người dùng (nháp, cần xác nhận)',
  async run({ input, context }) {
    const email = EMAIL_RE.exec(input)?.[0];
    if (!email) return { reply: 'Bạn muốn khóa tài khoản nào? Cho mình email.', askBack: true };
    const r = await context.get<any>('adminUsersSearch', { q: email, limit: 5 });
    const u = r.items.find((x: any) => x.email.toLowerCase() === email.toLowerCase());
    if (!u) return { reply: `Không có tài khoản ${email}.` };
    if (u.status === 'LOCKED') return { reply: `${email} đang bị khóa rồi.` };
    return { reply: `Nháp: khóa tài khoản ${u.name} <${u.email}>. Mọi phiên đăng nhập của họ sẽ hết hiệu lực. Xác nhận?`, draft: { kind: 'lock_user', payload: { userId: u.id, email: u.email, name: u.name } } };
  },
};

const adminGuiThongBao: Skill = {
  name: 'soan-thong-bao',
  scope: 'ADMIN',
  description: 'Soạn thông báo gửi mọi người dùng (nháp, cần xác nhận)',
  async run({ input }) {
    const body = input.replace(/^.*?\b(gửi|gui)\s+(thông báo|thong bao|broadcast)\b\s*(cho\s+(tất cả|tat ca|mọi người|moi nguoi)\s*)?[:,-]?\s*/iu, '').trim();
    if (!body) return { reply: 'Nội dung thông báo là gì?', askBack: true };
    const [t, ...rest] = body.split(/\s*[:\n]\s*/);
    const title = (rest.length ? t : body.split(/[.!?]/)[0]).slice(0, 120);
    const text = (rest.length ? rest.join(': ') : body).slice(0, 2000);
    return { reply: `Nháp thông báo cho mọi người dùng đang hoạt động:\n«${title}» — ${text}\nXác nhận để gửi.`, draft: { kind: 'broadcast', payload: { title, body: text } } };
  },
};

const adminBatThuong: Skill = {
  name: 'phat-hien-bat-thuong',
  scope: 'ADMIN',
  description: 'Dấu hiệu bất thường (user ghi quá nhiều trong 24h, số tài khoản khóa)',
  context: ['adminAnomalies'],
  async run({ context }) {
    const a = context.data.adminAnomalies as any;
    const busy = a.mostActive24h.map((x: any) => `• ${x.email}: ${x.transactions} giao dịch/24h`).join('\n');
    return { reply: `Tài khoản đang khóa: ${a.lockedUsers}.${busy ? `\nGhi nhiều bất thường:\n${busy}` : '\nKhông thấy user nào ghi bất thường trong 24h.'}` };
  },
};

const adminLichSuCauHinh: Skill = {
  name: 'tom-tat-cau-hinh',
  scope: 'ADMIN',
  description: 'Các thay đổi cấu hình gần đây',
  context: ['adminConfigHistory'],
  async run({ context }) {
    const xs = context.data.adminConfigHistory as any[];
    if (!xs.length) return { reply: 'Chưa có thay đổi cấu hình nào.' };
    return { reply: xs.slice(0, 8).map((c) => `• ${c.section}.${c.key}: ${JSON.stringify(c.oldValue)} → ${JSON.stringify(c.newValue)} (${c.actor?.name ?? 'Hệ thống'})`).join('\n') };
  },
};

/** Tên cũ (đợt 1) đã bỏ — skill ngoài trùng tên bị bỏ qua */
export const DEPRECATED_ALIASES = ['admin-tong-quan', 'admin-tim-user', 'admin-khoa-user', 'admin-gui-thong-bao', 'admin-bat-thuong', 'admin-lich-su-cau-hinh'];

export const BUILTIN_SKILLS: Skill[] = [
  ghiGiaoDich, docHoaDon, hoiSoDu, tongKetThang, kiemTraNganSach, tienDoTietKiem, timGiaoDich, datNganSach, huongDan, ngoaiPhamVi, hoiLai,
  adminTongQuan, adminTimUser, adminKhoaUser, adminGuiThongBao, adminBatThuong, adminLichSuCauHinh,
];

/* ============================== registry ============================== */

@Injectable()
export class SkillRegistry implements OnModuleInit {
  private readonly logger = new Logger('AiSkills');
  private readonly skills = new Map<string, Skill & { source: 'builtin' | 'ai' }>();

  constructor() {
    for (const s of BUILTIN_SKILLS) this.skills.set(s.name, { ...s, source: 'builtin' });
  }

  async onModuleInit() {
    if (process.env.AI_EXTERNAL_SKILLS === '0') return;
    // Bí danh cũ admin-* của Track B (trỏ sang skill Track B) không cần nữa: router đã dùng tên Track B
    const ext = (await loadExternalSkills()).filter((s) => !DEPRECATED_ALIASES.includes(s.name));
    for (const s of ext) this.skills.set(s.name, Object.assign(Object.create(Object.getPrototypeOf(s)), s, { source: 'ai' as const }));
    if (ext.length) this.logger.log(`Nạp ${ext.length} skill từ ai/: ${ext.map((s) => s.name).join(', ')}`);
    // nạp sẵn thư viện ai/ (parser...) để tin nhắn đầu không chậm
    void aiLib();
  }

  get(name: string) {
    return this.skills.get(name);
  }

  /**
   * Skill dùng được trong hội thoại: chặn CẢ HAI chiều.
   * USER → chỉ hội thoại USER; ADMIN → chỉ hội thoại ADMIN của người đang có role ADMIN; ANY (ngoai-pham-vi, hoi-lai) → cả hai.
   */
  allowed(name: string, p: Principal, convScope: 'USER' | 'ADMIN') {
    const s = this.skills.get(name);
    if (!s) return false;
    const scope = s.scope ?? 'USER';
    if (scope === 'ANY') return true;
    if (scope === 'ADMIN') return convScope === 'ADMIN' && p.role === 'ADMIN';
    return convScope === 'USER';
  }

  list(p: Principal, convScope: 'USER' | 'ADMIN' = p.role === 'ADMIN' ? 'ADMIN' : 'USER') {
    return [...this.skills.values()]
      .filter((s) => this.allowed(s.name, p, convScope))
      .map((s) => ({ name: s.name, scope: s.scope ?? 'ANY', description: s.description ?? '', source: s.source }));
  }

  async run(skill: Skill, args: Parameters<Skill['run']>[0]): Promise<SkillResult> {
    const r = await skill.run(args);
    if (!r || typeof r.reply !== 'string') throw new Error(`Skill ${skill.name} trả kết quả không hợp lệ`);
    return r;
  }
}
