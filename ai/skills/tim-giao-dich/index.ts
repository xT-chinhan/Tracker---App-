import type { BalanceData, CategoryRow, Skill, TxFilterPayload } from '../../lib/contracts.js';
import { findAmounts } from '../../parser/money.js';
import { dm, monthOf, parsePeriod, shiftMonth } from '../../lib/period.js';
import { fetchP, findName, llmJson, money, userGuard } from '../../lib/skillkit.js';
import { fold } from '../../lib/text.js';
import shots from './examples.json' with { type: 'json' };

const STOP = new Set(('tim kiem liet ke xem lai cho minh toi em giup cac nhung khoan giao dich gd chi tieu thu nhap tien vao ra nao gi la bao nhieu lan may ' +
  'khi gio cuoi gan nhat day hom qua nay kia tuan thang nam truoc roi ngay tren duoi hon tu den toi trong bang qua vi tra the voi co khong da duoc ' +
  'thu hai ba tu nam sau bay chu nhat k tr trieu nghin ngan d dong lon nho it nhieu nhat lan va hay di cua o tai mot vay a nhe ha ne search find show list ' +
  'transactions transaction last week month the of in my me from to for about on at since what did i spend spent all any').split(' '));
const SYS = 'Trích TỪ KHÓA để tìm trong tiêu đề giao dịch: tên món, cửa hàng, dịch vụ, người nhận (1-3 từ, giữ nguyên chữ trong câu). Không lấy thời gian, số tiền, tên ví, tên danh mục, các từ "giao dịch", "khoản". Không có thì để rỗng. Chỉ trả JSON.';
const SCHEMA = { type: 'object', properties: { keyword: { type: 'string' } }, required: ['keyword'] };

export const skill: Skill = {
  name: 'tim-giao-dich', scope: 'USER', description: 'Biến câu hỏi thành bộ lọc giao dịch (thời gian, danh mục, ví, từ khóa, số tiền)', context: ['categories', 'balance'],
  async run({ input, context, llm, now }) {
    const g = userGuard(input, context.principal); if (g) return g;
    const cats = (await fetchP<CategoryRow[]>(context, 'categories')) ?? [];
    const wallets = ((await fetchP<BalanceData>(context, 'balance'))?.wallets ?? []).map((w) => w.name);
    const f = fold(input);
    const draft: TxFilterPayload = { target: 'transactions' };
    const crit: string[] = [];

    const p = parsePeriod(input, now);
    if (p) { draft.from = p.from; draft.to = p.to; if (p.kind === 'month') draft.month = p.month; }
    if (/\b(thu nhap|khoan thu|tien vao|nhan duoc|duoc nhan|income)\b/.test(f)) draft.type = 'INCOME';
    else if (/\b(khoan chi|chi tieu|da chi|chi nhung|chi gi|chi het|tieu|xai|expense|spent?)\b/.test(f)) draft.type = 'EXPENSE';
    const wallet = findName(input, wallets);
    if (wallet) draft.walletName = wallet;
    const cat = findName(input, cats.map((c) => c.name), {});
    if (cat) { draft.categoryName = cat; draft.type = cats.find((c) => c.name === cat)!.type; }

    // Số tiền: che phần ngày trước khi tìm tiền (vd "15/9" không phải tiền)
    // "bang" (trả bằng) bị parser tiền đọc thành "ba ng" = 3 nghìn → che trước (báo Track A)
    const fm = f.replace(/\bbang\b/g, '    ').replace(/\b\d{1,2}[/-]\d{1,2}([/-]\d{4})?\b/g, (m) => ' '.repeat(m.length)).replace(/\b(thang|tuan|ngay|thu|lan|quy|nam) \d+\b/g, (m) => ' '.repeat(m.length)).replace(/\b\d+ (ngay|tuan|thang|lan)\b/g, (m) => ' '.repeat(m.length));
    const amts = findAmounts(fm);
    if (amts.length) {
      const before = (i: number) => fm.slice(Math.max(0, amts[i].start - 22), amts[i].start);
      if (amts.length >= 2 && /\btu\b/.test(before(0))) { draft.minAmount = amts[0].amount; draft.maxAmount = amts[1].amount; }
      else {
        const b = before(0), a = fm.slice(amts[0].end, amts[0].end + 14);
        if (/(tren|hon|lon hon|it nhat|toi thieu|>|over|above|tu)\s*$/.test(b) || /^\s*(tro len|tro lai|\+)/.test(a)) draft.minAmount = amts[0].amount;
        else if (/(duoi|nho hon|khong qua|it hon|toi da|<|under|below)\s*$/.test(b) || /^\s*(tro xuong|do lai)/.test(a)) draft.maxAmount = amts[0].amount;
        else { draft.minAmount = amts[0].amount; draft.maxAmount = amts[0].amount; }
      }
    }

    // Từ khóa: chỉ hỏi model khi còn từ "lạ" sau khi bỏ từ dừng / ví / danh mục / số
    // Từ "lạ": bỏ từ dừng, tên ví (+ bí danh), và cụm tên danh mục đã khớp
    const known = new Set(wallets.flatMap((n) => fold(n).split(/\s+/)).concat(['momo', 'mb', 'tcb', 'vcb', 'mat']));
    const fr = cat ? fm.replace(fold(cat), ' '.repeat(cat.length)) : fm;
    const rest = fr.replace(/[^a-z\s]/g, ' ').split(/\s+/).filter((w) => w && !STOP.has(w) && !known.has(w));
    let llmMs = 0, llmCalls = 0, accepted: boolean | null = null;
    if (rest.length) {
      const r = await llmJson<{ keyword: string }>(llm, SYS, `Câu: «${input}»`, SCHEMA, 24, shots.map((s) => [`Câu: «${s.input}»`, { keyword: s.keyword }]));
      llmMs = r.ms; llmCalls = 1;
      let k = (r.data?.keyword ?? '').trim();
      // Model hỏng (không có JSON hợp lệ) → lùi về cụm từ lạ liền nhau trong câu (lấy lại chữ có dấu từ câu gốc)
      if (typeof r.data?.keyword !== 'string' && rest.length <= 3) {
        const i = f.indexOf(rest.join(' '));
        if (i >= 0) k = input.slice(i, i + rest.join(' ').length);
      }
      const kf = fold(k);
      const ok = k && k.length <= 30 && !/\d/.test(k) && f.includes(kf) && !kf.split(/\s+/).every((w) => STOP.has(w) || known.has(w))
        && !cats.some((c) => fold(c.name) === kf) && !wallets.some((w) => fold(w) === kf)
        && !(draft.categoryName && fold(draft.categoryName) === kf) && !(wallet && fold(wallet) === kf);
      accepted = k ? !!ok : null;
      if (ok) draft.q = k;
    }

    if (draft.from) crit.push(p!.kind === 'day' ? `ngày ${dm(draft.from)}` : `${p!.label} (${dm(draft.from)}–${dm(new Date(Date.parse(draft.to!) - 86400000).toISOString().slice(0, 10))})`);
    if (draft.type && !draft.categoryName) crit.push(draft.type === 'INCOME' ? 'khoản thu' : 'khoản chi');
    if (draft.categoryName) crit.push(`danh mục ${draft.categoryName}`);
    if (draft.walletName) crit.push(`ví ${draft.walletName}`);
    if (draft.q) crit.push(`có chữ "${draft.q}"`);
    if (draft.minAmount && draft.minAmount === draft.maxAmount) crit.push(`số tiền ${money(draft.minAmount)}`);
    else {
      if (draft.minAmount) crit.push(`từ ${money(draft.minAmount)}`);
      if (draft.maxAmount) crit.push(`đến ${money(draft.maxAmount)}`);
    }
    if (!crit.length) {
      const m = monthOf(now);
      draft.from = `${m}-01`; draft.to = `${shiftMonth(m, 1)}-01`; draft.month = m;
      return { reply: 'Mình sẽ liệt kê giao dịch tháng này (bạn có thể nói rõ thời gian, danh mục, ví hoặc số tiền để lọc hẹp hơn).', draft: { kind: 'search_filter', payload: draft }, followUps: ['Giao dịch trên 500k tháng này', 'Hôm qua tôi chi những gì?'], meta: { llm: { calls: llmCalls, ms: Math.round(llmMs), accepted } } };
    }
    return { reply: `Mình sẽ tìm giao dịch: ${crit.join(' · ')}.`, draft: { kind: 'search_filter', payload: draft }, followUps: ['Tổng kết tháng này'], meta: { llm: { calls: llmCalls, ms: Math.round(llmMs), accepted } } };
  },
};
export const run = skill.run;
