/**
 * Mẫu email (HTML + text). Cùng phong cách app: nền trắng ngà, chữ gần đen, một màu nhấn duy nhất (đen).
 * Viết bằng bảng + style inline để Gmail / Outlook / app mail điện thoại hiển thị giống nhau; không ảnh ngoài.
 */

export interface MailContent {
  subject: string;
  html: string;
  text: string;
}

interface Brand {
  appName: string;
  supportEmail?: string | null;
}

const C = {
  bg: '#F7F6F3',
  card: '#FFFFFF',
  ink: '#111111',
  muted: '#6F6E69',
  faint: '#A9A8A3',
  line: '#ECEBE7',
  chip: '#F3F2EE',
  warnBg: '#FBF3DB',
  warn: '#956400',
};
const FONT = "-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif";

const TAGLINE = 'Tiền rõ ràng, sống nhẹ nhàng';

/** Logo TrackerX (lưới ô 3×3: 5 ô trắng thành chữ T, 2 ô góc xám) dựng bằng bảng — Gmail / Outlook không hiện SVG. */
function logoGrid() {
  const cell = (on: string | null) => `<td width="7" height="7" style="width:7px;height:7px;${on ? `background:${on};border-radius:2px;` : ''}font-size:0;line-height:0">&nbsp;</td>`;
  const W = '#FFFFFF', G = '#5E5D59';
  const rows = [[W, W, W], [null, W, null], [G, W, G]];
  const gap = '<td width="2" style="width:2px;font-size:0;line-height:0">&nbsp;</td>';
  const tr = (r: (string | null)[]) => `<tr>${r.map(cell).join(gap)}</tr>`;
  const vgap = '<tr><td colspan="5" height="2" style="height:2px;font-size:0;line-height:0">&nbsp;</td></tr>';
  return `<table role="presentation" cellpadding="0" cellspacing="0" style="margin:0 auto">${rows.map(tr).join(vgap)}</table>`;
}

const esc = (s: string) => s.replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]!);

/** 0912345678 → 0912 ••• 678 */
export function maskPhone(phone: string) {
  return phone.length >= 7 ? `${phone.slice(0, 4)} ••• ${phone.slice(-3)}` : phone;
}

/** Giờ VN dạng "08:41, 20/10/2026" */
export function vnTime(d: Date) {
  const v = new Date(d.getTime() + 7 * 3600_000);
  const p = (n: number) => String(n).padStart(2, '0');
  return `${p(v.getUTCHours())}:${p(v.getUTCMinutes())}, ${p(v.getUTCDate())}/${p(v.getUTCMonth() + 1)}/${v.getUTCFullYear()}`;
}

function layout(b: Brand, o: { preheader: string; title: string; body: string }) {
  const help = b.supportEmail
    ? `Cần hỗ trợ? Trả lời email này hoặc viết cho <a href="mailto:${esc(b.supportEmail)}" style="color:${C.muted};text-decoration:underline">${esc(b.supportEmail)}</a>.`
    : 'Email tự động, vui lòng không trả lời.';
  return `<!doctype html>
<html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="color-scheme" content="light only"><title>${esc(o.title)}</title></head>
<body style="margin:0;padding:0;background:${C.bg};-webkit-text-size-adjust:100%">
<div style="display:none;max-height:0;overflow:hidden;opacity:0;color:${C.bg}">${esc(o.preheader)}&#8203;&nbsp;&#8203;&nbsp;&#8203;&nbsp;</div>
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:${C.bg}">
<tr><td align="center" style="padding:40px 16px">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:520px">
    <tr><td style="padding:0 4px 20px">
      <table role="presentation" cellpadding="0" cellspacing="0"><tr>
        <td width="40" height="40" align="center" valign="middle" style="width:40px;height:40px;background:${C.ink};border-radius:9px">${logoGrid()}</td>
        <td style="padding-left:12px">
          <div style="font:700 17px/1.2 ${FONT};color:${C.ink};letter-spacing:-0.3px">${esc(b.appName)}</div>
          <div style="font:400 12.5px/1.4 ${FONT};color:${C.muted}">${TAGLINE}</div>
        </td>
      </tr></table>
    </td></tr>
    <tr><td style="background:${C.card};border:1px solid ${C.line};border-radius:20px;padding:36px 32px">
      <h1 style="margin:0 0 12px;font:700 24px/1.3 ${FONT};color:${C.ink};letter-spacing:-0.5px">${esc(o.title)}</h1>
      ${o.body}
    </td></tr>
    <tr><td style="padding:22px 8px 0;font:400 12.5px/1.6 ${FONT};color:${C.faint}">
      ${help}<br>© ${new Date().getFullYear()} ${esc(b.appName)} · Ứng dụng quản lý thu chi cá nhân
    </td></tr>
  </table>
</td></tr></table>
</body></html>`;
}

const p = (html: string, extra = '') => `<p style="margin:0 0 16px;font:400 15px/1.6 ${FONT};color:${C.muted};${extra}">${html}</p>`;

/** Ô mã 6 số: mỗi chữ số một ô, đủ to để đọc trên điện thoại; bấm giữ chọn được cả dãy trên mọi app mail. */
function codeBox(code: string) {
  const cells = code
    .split('')
    .map((d) => `<td align="center" style="width:46px;height:58px;background:${C.chip};border-radius:12px;font:700 28px/58px ${FONT};color:${C.ink}">${d}</td>`)
    .join('<td style="width:8px"></td>');
  return `<table role="presentation" cellpadding="0" cellspacing="0" style="margin:8px 0 22px"><tr>${cells}</tr></table>`;
}

function infoRow(label: string, value: string) {
  return `<tr><td style="padding:12px 0;border-top:1px solid ${C.line};font:400 14px/1.4 ${FONT};color:${C.muted}">${esc(label)}</td>
<td align="right" style="padding:12px 0;border-top:1px solid ${C.line};font:600 14px/1.4 ${FONT};color:${C.ink}">${esc(value)}</td></tr>`;
}

function notMe(b: Brand) {
  return `<div style="margin-top:22px;padding:14px 16px;background:${C.warnBg};border-radius:12px;font:400 13.5px/1.6 ${FONT};color:${C.warn}">
<b style="font-weight:600">Không phải bạn?</b> Đổi mật khẩu ngay trong app (Cài đặt › Đổi mật khẩu)${b.supportEmail ? ` và báo cho chúng tôi qua ${esc(b.supportEmail)}` : ''}.</div>`;
}

export function resetOtpMail(b: Brand, o: { otp: string; minutes: number; name?: string }): MailContent {
  const title = 'Mã đặt lại mật khẩu';
  const body =
    p(`${o.name ? `Chào ${esc(o.name)}, b` : 'B'}ạn vừa yêu cầu đặt lại mật khẩu ${esc(b.appName)}. Nhập mã dưới đây trong app:`) +
    codeBox(o.otp) +
    p(`Mã có hiệu lực trong <b style="color:${C.ink};font-weight:600">${o.minutes} phút</b> và chỉ dùng được một lần.`, 'margin-bottom:0') +
    `<div style="margin-top:22px;padding-top:18px;border-top:1px solid ${C.line};font:400 13.5px/1.6 ${FONT};color:${C.faint}">Nếu không phải bạn yêu cầu, hãy bỏ qua email này — mật khẩu của bạn vẫn giữ nguyên. Đừng chia sẻ mã cho bất kỳ ai, kể cả người tự xưng là nhân viên ${esc(b.appName)}.</div>`;
  return {
    subject: `${o.otp} là mã đặt lại mật khẩu ${b.appName}`,
    html: layout(b, { preheader: `Mã ${o.otp}, hiệu lực ${o.minutes} phút. Đừng chia sẻ mã cho ai.`, title, body }),
    text: `${title}\n\nMã OTP của bạn: ${o.otp}\nHiệu lực ${o.minutes} phút, dùng một lần.\n\nNếu không phải bạn yêu cầu, hãy bỏ qua email này. Đừng chia sẻ mã cho bất kỳ ai.\n\n${b.appName}`,
  };
}

export function phoneLinkedMail(b: Brand, o: { name: string; phone: string; at: Date; replaced?: string | null }): MailContent {
  const title = o.replaced ? 'Số điện thoại đã được đổi' : 'Đã gắn số điện thoại';
  const rows = [
    ...(o.replaced ? [infoRow('Số cũ', maskPhone(o.replaced))] : []),
    infoRow(o.replaced ? 'Số mới' : 'Số điện thoại', maskPhone(o.phone)),
    infoRow('Thời gian', vnTime(o.at)),
  ].join('');
  const body =
    p(`Chào ${esc(o.name)}, số điện thoại dưới đây vừa được xác thực và gắn vào tài khoản ${esc(b.appName)} của bạn. Từ giờ bạn có thể dùng số này để lấy lại mật khẩu.`) +
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin-top:4px;border-bottom:1px solid ${C.line}">${rows}</table>` +
    notMe(b);
  return {
    subject: `${title} · ${b.appName}`,
    html: layout(b, { preheader: `${maskPhone(o.phone)} vừa được gắn vào tài khoản của bạn.`, title, body }),
    text: `${title}\n\n${o.replaced ? `Số cũ: ${maskPhone(o.replaced)}\nSố mới` : 'Số điện thoại'}: ${maskPhone(o.phone)}\nThời gian: ${vnTime(o.at)}\n\nKhông phải bạn? Đổi mật khẩu ngay trong app.\n\n${b.appName}`,
  };
}

export function phoneRemovedMail(b: Brand, o: { name: string; phone: string; at: Date }): MailContent {
  const title = 'Đã gỡ số điện thoại';
  const body =
    p(`Chào ${esc(o.name)}, số điện thoại dưới đây vừa được gỡ khỏi tài khoản ${esc(b.appName)} của bạn. Bạn vẫn lấy lại mật khẩu được qua email này.`) +
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin-top:4px;border-bottom:1px solid ${C.line}">${infoRow('Số điện thoại', maskPhone(o.phone))}${infoRow('Thời gian', vnTime(o.at))}</table>` +
    notMe(b);
  return {
    subject: `${title} · ${b.appName}`,
    html: layout(b, { preheader: `${maskPhone(o.phone)} không còn gắn với tài khoản của bạn.`, title, body }),
    text: `${title}\n\nSố điện thoại: ${maskPhone(o.phone)}\nThời gian: ${vnTime(o.at)}\n\nKhông phải bạn? Đổi mật khẩu ngay trong app.\n\n${b.appName}`,
  };
}

export function passwordResetByPhoneMail(b: Brand, o: { name: string; phone: string; at: Date }): MailContent {
  const title = 'Mật khẩu vừa được đặt lại';
  const body =
    p(`Chào ${esc(o.name)}, mật khẩu ${esc(b.appName)} của bạn vừa được đặt lại bằng số điện thoại đã gắn. Mọi thiết bị đang đăng nhập đã được đăng xuất.`) +
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin-top:4px;border-bottom:1px solid ${C.line}">${infoRow('Xác thực bằng', `SMS từ ${maskPhone(o.phone)}`)}${infoRow('Thời gian', vnTime(o.at))}</table>` +
    `<div style="margin-top:22px;padding:14px 16px;background:${C.warnBg};border-radius:12px;font:400 13.5px/1.6 ${FONT};color:${C.warn}">
<b style="font-weight:600">Không phải bạn?</b> Ai đó đang cầm điện thoại của bạn. Dùng “Quên mật khẩu” bằng email này để lấy lại tài khoản${b.supportEmail ? `, rồi báo cho chúng tôi qua ${esc(b.supportEmail)}` : ''}.</div>`;
  return {
    subject: `${title} · ${b.appName}`,
    html: layout(b, { preheader: `Đặt lại bằng SMS từ ${maskPhone(o.phone)} lúc ${vnTime(o.at)}.`, title, body }),
    text: `${title}\n\nXác thực bằng: SMS từ ${maskPhone(o.phone)}\nThời gian: ${vnTime(o.at)}\n\nKhông phải bạn? Dùng "Quên mật khẩu" bằng email để lấy lại tài khoản.\n\n${b.appName}`,
  };
}
