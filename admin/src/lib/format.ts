const vnd = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND', maximumFractionDigits: 0 })
const compact = new Intl.NumberFormat('vi-VN', { notation: 'compact', maximumFractionDigits: 1 })
const num = new Intl.NumberFormat('vi-VN')
const date = new Intl.DateTimeFormat('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric', timeZone: 'Asia/Ho_Chi_Minh' })
const dateTime = new Intl.DateTimeFormat('vi-VN', {
  day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit', timeZone: 'Asia/Ho_Chi_Minh',
})

export const formatVND = (v: number) => vnd.format(v)
export const formatCompact = (v: number) => compact.format(v)
export const formatNumber = (v: number) => num.format(v)
export const formatDate = (iso: string) => date.format(new Date(iso))
export const formatDateTime = (iso: string) => dateTime.format(new Date(iso))
/** "2026-03" -> "T3/2026" */
export const formatMonth = (m: string) => {
  const [y, mo] = m.split('-')
  return `T${Number(mo)}/${y}`
}

export const ROLE_LABEL = { ADMIN: 'Quản trị', USER: 'Người dùng' } as const
export const STATUS_LABEL = { ACTIVE: 'Hoạt động', LOCKED: 'Đã khóa' } as const
export const TYPE_LABEL = { INCOME: 'Thu', EXPENSE: 'Chi' } as const
export const GOAL_STATUS_LABEL = {
  ACTIVE: 'Đang tiết kiệm',
  COMPLETED: 'Đã đạt mục tiêu',
  WITHDRAWN: 'Đã rút (hoàn thành)',
  EARLY_WITHDRAWN: 'Rút trước hạn',
} as const

/** Màu biểu đồ đã kiểm tra CVD (thu = teal, chi = rose). */
export const CHART = { income: '#0d9488', expense: '#e11d48' }
export const GOAL_COLORS = { ACTIVE: '#3b82f6', COMPLETED: '#0d9488', WITHDRAWN: '#d97706', EARLY_WITHDRAWN: '#db2777' } as const
