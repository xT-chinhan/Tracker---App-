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
