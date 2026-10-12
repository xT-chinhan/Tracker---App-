import type { BroadcastDraft, Llm, SkillDef } from '../../lib/contracts.js';
import type { ChatMsg } from '../../lib/ollama.js';
import { adminGuard, int, parseJson } from '../../lib/skillkit.js';
import { fold } from '../../lib/text.js';
import shots from './examples.json' with { type: 'json' };

const SYS = (app: string) => `Bạn soạn thông báo trong ứng dụng quản lý thu chi "${app}" gửi tới TẤT CẢ người dùng.
- Tiếng Việt có dấu, lịch sự, xưng "bạn", ngắn gọn, rõ ràng.
- title: tối đa 80 ký tự, không có dấu chấm cuối.
- body: 2-4 câu, nêu đúng nội dung admin yêu cầu, kết thúc bằng "Trân trọng, đội ngũ ${app}."
- CHỈ dùng các con số, ngày giờ có trong yêu cầu. Không bịa thêm số, ngày, link, email, số điện thoại.
- Không để chỗ trống kiểu [..], {..}, XXX.
Chỉ trả JSON.`;
const SCHEMA = { type: 'object', properties: { title: { type: 'string' }, body: { type: 'string' } }, required: ['title', 'body'] };
const PHISH = /\b(gui|cung cap|nhap|xac nhan|chia se|bao)\b.{0,30}\b(mat khau|otp|ma xac thuc|so the|ma pin|cvv)\b/;
const VI = /[ăâđêôơưáàảãạấầẩẫậắằẳẵặéèẻẽẹếềểễệíìỉĩịóòỏõọốồổỗộớờởỡợúùủũụứừửữựýỳỷỹỵ]/i;
const digitsOf = (s: string) => new Set(s.match(/\d+/g) ?? []);

/** Lỗi của bản nháp (null = đạt). */
export function checkBroadcast(d: { title?: unknown; body?: unknown }, request: string, allowedExtra = ''): string | null {
  const t = typeof d.title === 'string' ? d.title.trim() : '', b = typeof d.body === 'string' ? d.body.trim() : '';
  if (t.length < 5 || t.length > 120) return 'title phải 5–120 ký tự';
  if (b.length < 20 || b.length > 2000) return 'body phải 20–2000 ký tự';
  if (!VI.test(t) || !VI.test(b)) return 'phải là tiếng Việt có dấu';
  if (/[[\]{}<>]|xxx|\.\.\.\s*$/i.test(t + ' ' + b)) return 'còn chỗ trống/placeholder';
  const ok = digitsOf(request + ' ' + allowedExtra);
  const bad = [...digitsOf(t + ' ' + b)].filter((x) => !ok.has(x));
  if (bad.length) return `có số không có trong yêu cầu: ${bad.join(', ')}`;
  if (/https?:|www\.|@/.test(t + b) && !/https?:|www\.|@/.test(request)) return 'có link/email không có trong yêu cầu';
  if (PHISH.test(fold(t + ' ' + b))) return 'yêu cầu người dùng cung cấp mật khẩu/OTP';
  return null;
}

export function stripCommand(s: string): string {
  return s.trim()
    .replace(/^(h[aã]y |giúp |nhờ )?(so[aạ]n|vi[eế]t|t[aạ]o|g[uửư]i|l[aà]m|nh[aá]p|draft)( giúp| hộ| cho)?( (mình|tôi|em))?( (một|1|cái|bản))?( (thông báo|broadcast|tin nhắn|tin|bản tin|announcement))?( (gửi|cho|tới|đến))?( (tất cả|mọi|toàn bộ|các)( người dùng| user| khách hàng| thành viên)?)?( (về|rằng|là|báo|để báo))?[\s:,-]*/i, '')
    .replace(/^(về|rằng|là)\s+/i, '');
}

export const skill: SkillDef = {
  name: 'soan-thong-bao', scope: 'ADMIN', output: 'draft', providers: ['admin.publicConfig', 'admin.broadcasts', 'admin.overview'],
  plan: () => [{ provider: 'admin.publicConfig' }, { provider: 'admin.broadcasts', params: { limit: 5 } }, { provider: 'admin.overview' }],
  async run({ input, context, llm }) {
    const g = adminGuard(input, context.principal); if (g) return g;
    if (PHISH.test(fold(input))) return { reply: 'Mình không soạn thông báo yêu cầu người dùng cung cấp mật khẩu, mã OTP hay thông tin thẻ — đây là mẫu lừa đảo phổ biến.', meta: { refused: 'phishing' } };
    const topic = stripCommand(input);
    if (fold(topic).replace(/[^a-z0-9]/g, '').length < 6) {
      const ask = 'Thông báo về nội dung gì? Ví dụ: "bảo trì hệ thống tối nay", "ra mắt tính năng mẫu nhập nhanh".';
      return { reply: ask, askBack: ask, meta: {} };
    }
    const cfg = context['admin.publicConfig'];
    const app = cfg?.appName ?? 'Thu Chi';
    const { draft, calls, ms, attempts } = await compose(llm, app, input, topic, cfg ? `${cfg.hotline} ${cfg.supportEmail}` : '');
    const recipients = context['admin.overview']?.users.active;
    const dup = (context['admin.broadcasts'] ?? []).find((b) => sim(b.title, draft.title) >= 0.6);
    const lines = [
      'Bản nháp thông báo (CHƯA gửi):',
      `Tiêu đề: ${draft.title}`,
      `Nội dung: ${draft.body}`,
      recipients ? `Khi bạn xác nhận, thông báo sẽ gửi tới ${int(recipients)} người dùng đang hoạt động.` : 'Khi bạn xác nhận, thông báo sẽ gửi tới mọi người dùng đang hoạt động.',
    ];
    if (dup) lines.push(`Lưu ý: đã có thông báo tương tự "${dup.title}".`);
    return { reply: lines.join('\n'), draft, followUps: ['Gửi', 'Viết ngắn hơn', 'Hủy'], meta: { llm: { calls, ms: Math.round(ms), accepted: attempts.length === 0 ? true : attempts.length < calls ? true : false }, attempts } };
  },
};
export const run = skill.run;

async function compose(llm: Llm, app: string, request: string, topic: string, extra: string) {
  const msgs: ChatMsg[] = [{ role: 'system', content: SYS(app) }];
  for (const s of shots) msgs.push({ role: 'user', content: `Yêu cầu của admin: «${s.input}»` }, { role: 'assistant', content: JSON.stringify(s.draft) });
  msgs.push({ role: 'user', content: `Yêu cầu của admin: «${request}»` });
  const attempts: string[] = [];
  let calls = 0, ms = 0;
  for (let i = 0; i < 2; i++) {
    try {
      const r = await llm.chat(msgs, SCHEMA, 260);
      calls++; ms += r.ms;
      const j = parseJson(r.content) ?? {};
      const err = checkBroadcast(j, request, extra);
      if (!err) return { draft: { kind: 'broadcast', title: j.title.trim().slice(0, 120), body: j.body.trim().slice(0, 2000) } as BroadcastDraft, calls, ms, attempts };
      attempts.push(err);
      msgs.push({ role: 'assistant', content: r.content }, { role: 'user', content: `Lỗi: ${err}. Viết lại JSON đúng yêu cầu.` });
    } catch (e) { calls++; attempts.push(String(e)); }
  }
  // Lùi về template: dùng nguyên nội dung yêu cầu
  const body0 = topic[0].toUpperCase() + topic.slice(1).replace(/[.!\s]*$/, '.');
  const title = body0.replace(/[.!]$/, '').slice(0, 80);
  return { draft: { kind: 'broadcast', title: `Thông báo: ${title}`.slice(0, 120), body: `Kính gửi bạn, ${body0[0].toLowerCase()}${body0.slice(1)} Cảm ơn bạn đã đồng hành cùng ${app}. Trân trọng, đội ngũ ${app}.` } as BroadcastDraft, calls, ms, attempts };
}

function sim(a: string, b: string) {
  const A = new Set(fold(a).split(/\W+/).filter(Boolean)), B = new Set(fold(b).split(/\W+/).filter(Boolean));
  const i = [...A].filter((x) => B.has(x)).length;
  return i / Math.max(1, Math.min(A.size, B.size));
}
