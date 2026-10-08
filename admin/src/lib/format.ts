const TZ = 'Asia/Ho_Chi_Minh'
const num = new Intl.NumberFormat('vi-VN')
const dmy = new Intl.DateTimeFormat('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric', timeZone: TZ })
const hm = new Intl.DateTimeFormat('vi-VN', { hour: '2-digit', minute: '2-digit', hour12: false, timeZone: TZ })
const weekday = new Intl.DateTimeFormat('vi-VN', { weekday: 'long', timeZone: TZ })
const ymd = new Intl.DateTimeFormat('en-CA', { year: 'numeric', month: '2-digit', day: '2-digit', timeZone: TZ })

/** Dấu trừ thật (U+2212) cho số âm, như mockup. */
const MINUS = '−'

export const formatNumber = (v: number) => num.format(v)
/** 1234567 -> "1.234.567đ"; số âm -> "−1.234.567đ" */
export const formatVND = (v: number) => `${v < 0 ? MINUS : ''}${num.format(Math.abs(v))}đ`
/** Số tiền có dấu theo loại: thu "+…", chi "−…" */
export const formatSigned = (v: number, income: boolean) => `${income ? '+' : MINUS}${num.format(Math.abs(v))}đ`
/** Nhãn trục: 0 · 500 k · 10 tr · 2,5 tỷ */
export const formatAxis = (v: number) => {
  const f = (x: number, unit: string) => `${new Intl.NumberFormat('vi-VN', { maximumFractionDigits: 1 }).format(x)} ${unit}`
  if (Math.abs(v) >= 1e9) return f(v / 1e9, 'tỷ')
  if (Math.abs(v) >= 1e6) return f(v / 1e6, 'tr')
  if (Math.abs(v) >= 1e3) return f(v / 1e3, 'k')
  return num.format(v)
}

export const formatDate = (iso: string | number | Date) => dmy.format(new Date(iso))
/** "22/09" (Intl vi-VN cho ngày+tháng ra "22-09" nên cắt từ dd/MM/yyyy) */
export const formatDayMonth = (iso: string | number | Date) => dmy.format(new Date(iso)).slice(0, 5)
export const formatTime = (iso: string | number | Date) => hm.format(new Date(iso))
/** "Thứ Ba 22/09/2026" */
export const formatWeekdayDate = (d: string | number | Date) => {
  const w = weekday.format(new Date(d))
  return `${w.charAt(0).toUpperCase()}${w.slice(1)} ${dmy.format(new Date(d))}`
}
export const isToday = (iso: string) => ymd.format(new Date(iso)) === ymd.format(new Date())
/** Hôm nay -> "09:12", ngày khác -> "21/09" */
export const formatShortWhen = (iso: string) => (isToday(iso) ? formatTime(iso) : formatDayMonth(iso))

/** "2026-03" -> "T3" */
export const formatMonthShort = (m: string) => `T${Number(m.split('-')[1])}`
/** "2026-03" -> "Tháng 3/2026" */
export const formatMonthLong = (m: string) => {
  const [y, mo] = m.split('-')
  return `Tháng ${Number(mo)}/${y}`
}
/** Tháng hiện tại theo giờ VN, dạng YYYY-MM */
export const currentMonth = () => ymd.format(new Date()).slice(0, 7)
/** Ngày hôm nay theo giờ VN, dạng dd/MM */
export const todayDayMonth = () => formatDayMonth(new Date())

export const initials = (name: string) =>
  name.trim().split(/\s+/).slice(-2).map((w) => w[0]?.toUpperCase()).join('') || '?'

export const ROLE_LABEL = { ADMIN: 'Quản trị', USER: 'Người dùng' } as const
export const STATUS_LABEL = { ACTIVE: 'Hoạt động', LOCKED: 'Đã khóa' } as const
export const TYPE_LABEL = { INCOME: 'Thu', EXPENSE: 'Chi' } as const
export const WALLET_TYPE_LABEL = { CASH: 'Tiền mặt', BANK: 'Ngân hàng', EWALLET: 'Ví điện tử' } as const
export const GOAL_STATUS_LABEL = {
  ACTIVE: 'Đang tiết kiệm',
  COMPLETED: 'Đã đạt mục tiêu',
  WITHDRAWN: 'Đã rút (hoàn thành)',
  EARLY_WITHDRAWN: 'Rút trước hạn',
} as const
