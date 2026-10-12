import type { ConfigChangeCtx, SkillDef } from '../../lib/contracts.js';
import { parsePeriod } from '../../lib/period.js';
import { adminGuard, int, llmMeta, llmSentence } from '../../lib/skillkit.js';
import { fold } from '../../lib/text.js';

export const SECTION: Record<string, string> = { general: 'Chung', access: 'Đăng ký & truy cập', smtp: 'Email (SMTP)', password: 'Bảo mật', business: 'Nghiệp vụ', mobile: 'Ứng dụng mobile' };
const SECTION_WORDS: [string, RegExp][] = [
  ['smtp', /\b(smtp|email|mail)\b/], ['access', /\b(bao tri|dang ky|dang nhap|truy cap|phien)\b/], ['password', /\b(mat khau|otp|bao mat)\b/],
  ['business', /\b(nghiep vu|ngan sach|tinh nang|csv|vi mac dinh)\b/], ['mobile', /\b(mobile|phien ban|android|ios|cap nhat app)\b/], ['general', /\b(ten app|hotline|ho tro|dieu khoan|chung)\b/],
];
export const KEY: Record<string, string> = {
  appName: 'tên ứng dụng', supportEmail: 'email hỗ trợ', hotline: 'hotline', termsUrl: 'link điều khoản', privacyUrl: 'link quyền riêng tư',
  registrationEnabled: 'cho phép đăng ký', sessionDays: 'số ngày giữ phiên', loginMaxAttempts: 'số lần đăng nhập tối đa', loginWindowMinutes: 'cửa sổ giới hạn đăng nhập (phút)',
  maintenanceEnabled: 'chế độ bảo trì', maintenanceMessage: 'thông điệp bảo trì', maintenanceEndsAt: 'giờ kết thúc bảo trì',
  host: 'máy chủ SMTP', port: 'cổng SMTP', security: 'bảo mật SMTP', user: 'tài khoản SMTP', password: 'mật khẩu SMTP', from: 'địa chỉ gửi',
  minLength: 'độ dài mật khẩu tối thiểu', otpExpiryMinutes: 'hạn mã OTP (phút)', otpMaxAttempts: 'số lần nhập OTP', otpResendSeconds: 'thời gian chờ gửi lại OTP (giây)',
  budgetWarningPercent: 'ngưỡng cảnh báo ngân sách (%)', budgetExceededPercent: 'ngưỡng vượt ngân sách (%)', defaultWalletName: 'tên ví mặc định',
  featureSavingGoals: 'tính năng tiết kiệm', featureRecurring: 'tính năng định kỳ', featureTransfers: 'tính năng chuyển tiền', featureCsvExport: 'tính năng xuất CSV', featureQuickTemplates: 'tính năng mẫu nhập nhanh',
  androidLatestVersion: 'phiên bản Android mới nhất', androidMinVersion: 'phiên bản Android tối thiểu', iosLatestVersion: 'phiên bản iOS mới nhất', iosMinVersion: 'phiên bản iOS tối thiểu', releaseNotes: 'ghi chú phát hành',
};
const vnTime = (iso: string) => { const d = new Date(Date.parse(iso) + 7 * 3600000).toISOString(); return `${d.slice(8, 10)}/${d.slice(5, 7)} ${d.slice(11, 16)}`; };
const val = (v: unknown): string => {
  if (v === null || v === undefined || v === '') return '(trống)';
  if (v === true) return 'bật'; if (v === false) return 'tắt';
  if (typeof v === 'string' && /^\d{4}-\d{2}-\d{2}T/.test(v)) return vnTime(v);
  const s = String(v); return s.length > 60 ? `"${s.slice(0, 57)}…"` : typeof v === 'string' ? `"${s}"` : s;
};
export const describe = (c: ConfigChangeCtx) => `${vnTime(c.createdAt)} · ${c.actorName ?? 'Hệ thống'} · ${SECTION[c.section] ?? c.section} › ${KEY[c.key] ?? c.key}: ${c.secret ? 'đã đổi (giá trị ẩn)' : `${val(c.oldValue)} → ${val(c.newValue)}`}`;

export const skill: SkillDef = {
  name: 'tom-tat-cau-hinh', scope: 'ADMIN', output: 'text', providers: ['admin.configHistory'],
  plan: () => [{ provider: 'admin.configHistory', params: { limit: 50 } }],
  async run({ input, context, llm, now }) {
    const g = adminGuard(input, context.principal); if (g) return g;
    let h = context['admin.configHistory'];
    if (!h) return { reply: 'Chưa lấy được lịch sử cấu hình, thử lại sau.', meta: { error: 'missing admin.configHistory' } };
    const f = fold(input);
    const p = parsePeriod(input, now);
    const sec = SECTION_WORDS.find(([, re]) => re.test(f))?.[0];
    const scope: string[] = [];
    if (p) { h = h.filter((c) => { const d = new Date(Date.parse(c.createdAt) + 7 * 3600000).toISOString().slice(0, 10); return d >= p.from && d < p.to; }); scope.push(p.label); }
    if (sec) { h = h.filter((c) => c.section === sec); scope.push(`mục ${SECTION[sec]}`); }
    const where = scope.length ? ` (${scope.join(', ')})` : '';
    if (!h.length) return { reply: `Không có thay đổi cấu hình nào${where}.`, meta: { llm: llmMeta(null) } };
    const by = new Map<string, number>();
    for (const c of h) by.set(c.actorName ?? 'Hệ thống', (by.get(c.actorName ?? 'Hệ thống') ?? 0) + 1);
    const lines = [
      `${int(h.length)} thay đổi cấu hình gần nhất${where}, theo người sửa: ${[...by].map(([a, n]) => `${a} ${int(n)}`).join(', ')}.`,
      ...h.slice(0, 12).map((c) => `• ${describe(c)}`),
    ];
    if (h.length > 12) lines.push(`… và ${int(h.length - 12)} thay đổi cũ hơn.`);
    const notable = h.filter((c) => /^feature|maintenance|registrationEnabled|loginMaxAttempts|minLength|password/.test(c.key)).map((c) => `${KEY[c.key] ?? c.key}${c.secret ? ' đã đổi' : typeof c.newValue === 'boolean' ? (c.newValue ? ' được bật' : ' bị tắt') : ' được sửa'}`);
    const s = await llmSentence(llm, 'Viết một câu tóm tắt cho quản trị viên những thay đổi cấu hình đáng chú ý.', notable.length ? [...new Set(notable)].slice(0, 5) : ['chỉ có thay đổi nhỏ'], 'Hãy rà lại các thay đổi về bảo mật và tính năng để chắc chắn đúng ý.');
    lines.push(s.text);
    return { reply: lines.join('\n'), followUps: ['Chỉ các thay đổi về SMTP', 'Thay đổi trong tuần này'], meta: { computed: [h.length, ...[...by.values()], Math.max(0, h.length - 12)], llm: llmMeta(s), llmText: s.text } };
  },
};
export const run = skill.run;
