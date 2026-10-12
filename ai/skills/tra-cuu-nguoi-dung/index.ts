import type { SkillDef, UserFilterDraft } from '../../lib/contracts.js';
import { adminGuard, llmJson } from '../../lib/skillkit.js';
import { fold } from '../../lib/text.js';
import shots from './examples.json' with { type: 'json' };

const SYS = 'Trích TÊN hoặc một phần email của người dùng cần tìm (giữ nguyên chữ trong câu). Không lấy trạng thái, vai trò, các từ "user", "người dùng", "tài khoản". Không có thì để rỗng. Chỉ trả JSON.';
const STOP = new Set('tim tra cuu kiem xem cho toi minh liet ke danh sach cac nhung user users nguoi dung tai khoan account khach hang thanh vien nao co ten la bi khoa da khoa dang hoat dong active locked admin quan tri vien thuong role trang thai email mail gmail o trong he thong hien tat ca moi find search list show with named the all by of va hay giup ai voi nick'.split(' '));

export const skill: SkillDef = {
  name: 'tra-cuu-nguoi-dung', scope: 'ADMIN', output: 'draft', providers: [],
  plan: () => [],
  async run({ input, context, llm }) {
    const g = adminGuard(input, context.principal); if (g) return g;
    const f = fold(input);
    const d: UserFilterDraft = { kind: 'user-filter' };
    if (/\b(bi khoa|da khoa|dang khoa|locked|banned|khoa)\b/.test(f) && !/\bmo khoa\b/.test(f)) d.status = 'LOCKED';
    else if (/\b(dang hoat dong|active|con hoat dong)\b/.test(f)) d.status = 'ACTIVE';
    if (/\b(admin|quan tri|quan tri vien)\b/.test(f)) d.role = 'ADMIN';
    else if (/\b(nguoi dung thuong|user thuong|role user)\b/.test(f)) d.role = 'USER';
    const email = /[\w.+-]+@[\w-]+(\.[\w-]+)+/.exec(input) ?? /\b[\w.+-]+@[\w.-]*/.exec(input);
    let ms = 0, calls = 0, accepted: boolean | null = null;
    // "tên X" / "named X": lấy cụm tên ngay sau, dừng ở từ trạng thái / hỏi
    const named = /(?:\btên|\bten|\bnamed|\bname)\s+(.+?)(?=\s+(?:bị|bi|đang|dang|không|khong|ko|có|co|ạ|a|nhé|nhe|vậy|vay|ở|o|trong|is|that)(?=\s|$|[?.!,;])|[?.!,;]|$)/iu.exec(input);
    if (email) d.q = email[0];
    else if (named && named[1].trim().length <= 60 && !STOP.has(fold(named[1].trim()))) d.q = named[1].trim();
    else {
      const rest = f.replace(/[^a-z0-9\s]/g, ' ').split(/\s+/).filter((w) => w && !STOP.has(w));
      if (rest.length) {
        const r = await llmJson<{ name: string }>(llm, SYS, `Câu: «${input}»`, { type: 'object', properties: { name: { type: 'string' } }, required: ['name'] }, 24,
          shots.map((s) => [`Câu: «${s.input}»`, { name: s.name }]));
        ms = r.ms; calls = 1;
        const k = (r.data?.name ?? '').trim();
        const ok = !!k && k.length <= 60 && f.includes(fold(k)) && !fold(k).split(/\s+/).every((w) => STOP.has(w));
        accepted = k ? ok : null;
        if (ok) d.q = k;
      }
    }
    const crit = [d.q ? `tên/email chứa "${d.q}"` : '', d.status ? (d.status === 'LOCKED' ? 'đang bị khóa' : 'đang hoạt động') : '', d.role ? (d.role === 'ADMIN' ? 'vai trò quản trị' : 'vai trò người dùng') : ''].filter(Boolean);
    const reply = crit.length ? `Mình sẽ tìm người dùng: ${crit.join(' · ')}.` : 'Mình sẽ liệt kê tất cả người dùng (mới nhất trước). Bạn có thể lọc theo tên, email, trạng thái hoặc vai trò.';
    return { reply, draft: d, followUps: ['Chỉ tài khoản bị khóa', 'Có bất thường gì không?'], meta: { llm: { calls, ms: Math.round(ms), accepted } } };
  },
};
export const run = skill.run;
