import fs from 'node:fs'
import path from 'node:path'
import { expect, type Page } from '@playwright/test'

export const API_URL = process.env.E2E_API_URL ?? 'http://localhost:3001/api'
export const ADMIN_EMAIL = process.env.E2E_ADMIN_EMAIL ?? 'admin@thuchi.vn'
export const ADMIN_PASSWORD = process.env.E2E_ADMIN_PASSWORD ?? 'admin123'
export const SHOTS = process.env.E2E_SHOTS ?? '/tmp/admin-shots'
export const STATE_FILE = path.join(import.meta.dirname, '.state.json')

export interface SeedUser { id: string; email: string; name: string; password: string; token: string }
export interface MonthSum { month: string; income: number; expense: number }
export interface State {
  suffix: string
  users: Record<'an' | 'binh' | 'chi' | 'dung' | 'admin2', SeedUser>
  fillers: number
  usedCategory: { id: string; name: string }
  currentMonth: string
  baseline: Overview
  expected: Overview
  an: { income: number; expense: number; savings: number; balance: number; wallets: { id: string; name: string; balance: number; txCount: number }[]; txCount: number; incomeCount: number; currentMonthCount: number; budgets: number; goals: number; trend: MonthSum[] }
}
export interface Overview {
  users: { total: number; active: number; locked: number; new30d: number }
  transactions: { total: number; new30d: number; totalIncome: number; totalExpense: number }
  savingGoals: Record<string, number>
  trend: { month: string; income: number; expense: number; net: number }[]
}

export const state = (): State => JSON.parse(fs.readFileSync(STATE_FILE, 'utf8'))

export async function apiCall<T = unknown>(method: string, p: string, token?: string, body?: unknown): Promise<{ status: number; data: T }> {
  const res = await fetch(API_URL + p, {
    method,
    headers: { ...(body ? { 'Content-Type': 'application/json' } : {}), ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: body ? JSON.stringify(body) : undefined,
  })
  const data = res.status === 204 ? null : await res.json().catch(() => null)
  return { status: res.status, data: data as T }
}

export async function apiOk<T = unknown>(method: string, p: string, token?: string, body?: unknown): Promise<T> {
  const r = await apiCall<T>(method, p, token, body)
  if (r.status >= 400) throw new Error(`${method} ${p} -> ${r.status} ${JSON.stringify(r.data)}`)
  return r.data
}

export async function adminToken(email = ADMIN_EMAIL, password = ADMIN_PASSWORD) {
  return (await apiOk<{ accessToken: string }>('POST', '/auth/login', undefined, { email, password })).accessToken
}

/** Token mới của user seed (token cũ mất hiệu lực sau khi bị khóa / đổi mật khẩu). */
export async function relogin(u: { email: string; password: string }) {
  return (await apiOk<{ accessToken: string }>('POST', '/auth/login', undefined, { email: u.email, password: u.password })).accessToken
}

export async function login(page: Page, email = ADMIN_EMAIL, password = ADMIN_PASSWORD) {
  await page.goto('/login')
  await page.getByLabel('Email').fill(email)
  await page.getByLabel('Mật khẩu', { exact: true }).fill(password)
  await page.getByRole('button', { name: 'Đăng nhập' }).click()
}

export async function loginAsAdmin(page: Page) {
  await login(page)
  await expect(page.getByRole('heading', { name: 'Tổng quan' })).toBeVisible()
}

/** Đợi hết skeleton (data-testid="loading"). */
export const settled = (page: Page) => expect(page.getByTestId('loading')).toHaveCount(0)

/** Chọn 1 option trong Radix Select theo data-testid của trigger. */
export async function pick(page: Page, testId: string, option: string | RegExp) {
  await page.getByTestId(testId).click()
  await page.getByRole('option', { name: option, exact: typeof option === 'string' }).click()
}

export async function shot(page: Page, name: string) {
  fs.mkdirSync(SHOTS, { recursive: true })
  await page.waitForTimeout(400) // chờ animation (chart, dialog)
  await page.screenshot({ path: path.join(SHOTS, `${name}.png`), fullPage: true })
}

/** Khớp số tiền đã format "1.234.567đ" (có thể có dấu + / −). */
export const money = (v: number) => new RegExp(`^[+−]?${vnd(v).replace(/\./g, '\\.')}$`)
export const vnd = (v: number) => `${num(Math.abs(v))}đ`
export const num = (v: number) => new Intl.NumberFormat('vi-VN').format(v)

/**
 * Máy chủ SMTP giả (chỉ đủ lệnh cho nodemailer): nhận thư, ghi lại AUTH PLAIN và nội dung, trả 250.
 * Dùng cho test "Gửi email thử" thành công mà không cần máy chủ thật.
 */
export async function fakeSmtp() {
  const net = await import('node:net')
  const mails: { auth: { user: string; pass: string } | null; raw: string }[] = []
  const server = net.createServer((sock) => {
    let data: string[] | null = null
    let buf = ''
    let auth: { user: string; pass: string } | null = null
    sock.write('220 fake ESMTP\r\n')
    sock.on('data', (chunk) => {
      buf += chunk.toString('utf8')
      let i
      while ((i = buf.indexOf('\r\n')) >= 0) {
        const line = buf.slice(0, i)
        buf = buf.slice(i + 2)
        if (data) {
          if (line === '.') { mails.push({ auth, raw: data.join('\n') }); data = null; sock.write('250 2.0.0 OK queued\r\n') }
          else data.push(line.startsWith('..') ? line.slice(1) : line)
          continue
        }
        const cmd = line.slice(0, 4).toUpperCase()
        if (cmd === 'EHLO') sock.write('250-fake\r\n250-AUTH PLAIN\r\n250 8BITMIME\r\n')
        else if (cmd === 'HELO') sock.write('250 fake\r\n')
        else if (cmd === 'AUTH') {
          const p = Buffer.from(line.split(' ')[2] ?? '', 'base64').toString().split('\0')
          auth = { user: p[1], pass: p[2] }
          sock.write('235 2.7.0 Authentication successful\r\n')
        } else if (cmd === 'DATA') { data = []; sock.write('354 End data with <CR><LF>.<CR><LF>\r\n') }
        else if (cmd === 'QUIT') { sock.write('221 Bye\r\n'); sock.end() }
        else sock.write('250 OK\r\n')
      }
    })
    sock.on('error', () => {})
  })
  await new Promise<void>((res) => server.listen(0, '127.0.0.1', () => res()))
  const port = (server.address() as { port: number }).port
  return { port, mails, close: () => new Promise<void>((res) => server.close(() => res())) }
}
