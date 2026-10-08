// Fetch wrapper + kiểu dữ liệu cho API backend (NestJS).
export const API_URL = (import.meta.env.VITE_API_URL ?? 'http://localhost:3000/api').replace(/\/$/, '')

const TOKEN_KEY = 'admin.token'
const USER_KEY = 'admin.user'

export type Role = 'USER' | 'ADMIN'
export type UserStatus = 'ACTIVE' | 'LOCKED'
export type TxType = 'INCOME' | 'EXPENSE'
export type GoalStatus = 'ACTIVE' | 'COMPLETED' | 'WITHDRAWN' | 'EARLY_WITHDRAWN'

export interface User {
  id: string
  email: string
  name: string
  role: Role
  status: UserStatus
  createdAt: string
  updatedAt: string
}

export interface UserListItem extends User {
  _count: { transactions: number; savingGoals: number }
}

export interface MonthTotal {
  month: string
  income: number
  expense: number
  net: number
}

export interface UserDetail extends User {
  _count: { transactions: number; categories: number; budgets: number; savingGoals: number }
  finance: { balance: number; totalIncome: number; totalExpense: number; savings: number }
  trend: MonthTotal[]
}

export interface Overview {
  users: { total: number; active: number; locked: number; new30d: number }
  transactions: { total: number; new30d: number; totalIncome: number; totalExpense: number }
  savingGoals: Partial<Record<GoalStatus, number>>
  trend: MonthTotal[]
}

export interface CategoryRef {
  id: string
  name: string
  icon: string
  color: string
  type: TxType
}

export interface Transaction {
  id: string
  userId: string
  categoryId: string
  type: TxType
  amount: number
  title: string
  note: string | null
  occurredAt: string
  createdAt: string
  category: CategoryRef
  user: { id: string; email: string; name: string }
}

export interface SystemCategory extends CategoryRef {
  userId: null
  isArchived: boolean
  createdAt: string
  _count: { transactions: number }
}

export interface Paged<T> {
  items: T[]
  total: number
  page: number
  limit: number
}

export class ApiError extends Error {
  status: number
  constructor(status: number, message: string) {
    super(message)
    this.status = status
  }
}

export const auth = {
  token: () => localStorage.getItem(TOKEN_KEY),
  user: (): User | null => {
    try {
      return JSON.parse(localStorage.getItem(USER_KEY) ?? 'null')
    } catch {
      return null
    }
  },
  save(token: string, user: User) {
    localStorage.setItem(TOKEN_KEY, token)
    localStorage.setItem(USER_KEY, JSON.stringify(user))
  },
  setUser(user: User) {
    localStorage.setItem(USER_KEY, JSON.stringify(user))
  },
  clear() {
    localStorage.removeItem(TOKEN_KEY)
    localStorage.removeItem(USER_KEY)
  },
  /** Token còn hạn (đọc `exp` trong JWT, không xác thực chữ ký). */
  isValid(): boolean {
    const token = localStorage.getItem(TOKEN_KEY)
    if (!token) return false
    try {
      const { exp } = JSON.parse(atob(token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/')))
      return typeof exp !== 'number' || exp * 1000 > Date.now()
    } catch {
      return false
    }
  },
}

/** Đăng xuất và về trang đăng nhập (kèm lý do hiển thị ở form). */
export function logout(reason?: string) {
  auth.clear()
  const qs = reason ? `?reason=${encodeURIComponent(reason)}` : ''
  if (!location.pathname.startsWith('/login')) location.assign(`/login${qs}`)
}

type Query = Record<string, string | number | undefined | null>

async function request<T>(method: string, path: string, opts: { body?: unknown; query?: Query; anonymous?: boolean } = {}): Promise<T> {
  const url = new URL(API_URL + path)
  for (const [k, v] of Object.entries(opts.query ?? {})) {
    if (v !== undefined && v !== null && v !== '') url.searchParams.set(k, String(v))
  }
  const headers: Record<string, string> = {}
  if (opts.body !== undefined) headers['Content-Type'] = 'application/json'
  const token = auth.token()
  if (token && !opts.anonymous) headers.Authorization = `Bearer ${token}`

  let res: Response
  try {
    res = await fetch(url, { method, headers, body: opts.body !== undefined ? JSON.stringify(opts.body) : undefined })
  } catch {
    throw new ApiError(0, 'Không kết nối được máy chủ')
  }

  const data = res.status === 204 ? null : await res.json().catch(() => null)
  if (!res.ok) {
    const raw = data?.message
    const message = Array.isArray(raw) ? raw.join(', ') : raw || res.statusText || 'Có lỗi xảy ra'
    if (!opts.anonymous && (res.status === 401 || res.status === 403)) {
      logout(res.status === 401 ? 'expired' : message === 'Tài khoản đã bị khóa' ? 'locked' : 'forbidden')
    }
    throw new ApiError(res.status, message)
  }
  return data as T
}

export const api = {
  login: (email: string, password: string) =>
    request<{ accessToken: string; user: User }>('POST', '/auth/login', { body: { email, password }, anonymous: true }),
  me: () => request<User>('GET', '/me'),
  updateMe: (name: string) => request<User>('PATCH', '/me', { body: { name } }),
  changePassword: (currentPassword: string, newPassword: string) =>
    request<null>('POST', '/me/password', { body: { currentPassword, newPassword } }),

  overview: () => request<Overview>('GET', '/admin/overview'),
  users: (q: { page?: number; limit?: number; q?: string; status?: UserStatus; role?: Role }) =>
    request<Paged<UserListItem>>('GET', '/admin/users', { query: q }),
  user: (id: string) => request<UserDetail>('GET', `/admin/users/${id}`),
  updateUser: (id: string, body: { status?: UserStatus; role?: Role }) => request<User>('PATCH', `/admin/users/${id}`, { body }),
  transactions: (q: { page?: number; limit?: number; userId?: string; type?: TxType; categoryId?: string; month?: string; q?: string }) =>
    request<Paged<Transaction>>('GET', '/admin/transactions', { query: q }),

  categories: (type?: TxType) => request<SystemCategory[]>('GET', '/admin/categories', { query: { type } }),
  createCategory: (body: { name: string; type: TxType; icon: string; color: string }) =>
    request<SystemCategory>('POST', '/admin/categories', { body }),
  updateCategory: (id: string, body: { name?: string; icon?: string; color?: string }) =>
    request<SystemCategory>('PATCH', `/admin/categories/${id}`, { body }),
  deleteCategory: (id: string) => request<{ archived: boolean }>('DELETE', `/admin/categories/${id}`),
  restoreCategory: (id: string) => request<SystemCategory>('POST', `/admin/categories/${id}/restore`),
}
