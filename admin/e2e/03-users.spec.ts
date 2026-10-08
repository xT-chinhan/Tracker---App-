import { expect, test, type Page } from '@playwright/test'
import { ADMIN_EMAIL, apiCall, loginAsAdmin, pick, shot, state } from './helpers'

const search = async (page: Page, q: string) => {
  await page.getByTestId('users-search').fill(q)
  await expect.poll(() => new URL(page.url()).searchParams.get('q')).toBe(q.trim())
  await expect(page.getByTestId('loading')).toHaveCount(0)
}
const row = (page: Page, email: string) => page.locator(`[data-testid="user-row"][data-email="${email}"]`)
const action = async (page: Page, email: string, item: string | RegExp) => {
  await row(page, email).getByTestId('user-actions').click()
  await page.getByRole('menuitem', { name: item }).click()
}

test.beforeEach(async ({ page }) => {
  await loginAsAdmin(page)
  await page.getByRole('link', { name: 'Người dùng' }).click()
  await expect(page.getByRole('heading', { name: 'Người dùng' })).toBeVisible()
})

test('tìm kiếm + phân trang', async ({ page }) => {
  const { suffix, fillers } = state()
  const total = 5 + fillers
  await search(page, suffix)
  await expect(page.getByText(`${total} tài khoản phù hợp`)).toBeVisible()
  await expect(page.getByTestId('user-row')).toHaveCount(10)
  await expect(page.getByTestId('pagination-info')).toHaveText(`1–10 / ${total}`)
  await expect(page.getByTestId('pagination-page')).toHaveText('Trang 1/2')
  await shot(page, '03-users')
  await page.getByRole('button', { name: 'Trang sau' }).click()
  await expect(page.getByTestId('pagination-info')).toHaveText(`11–${total} / ${total}`)
  await expect(page.getByTestId('user-row')).toHaveCount(total - 10)
  await expect(page).toHaveURL(/page=2/)
  await page.getByRole('button', { name: 'Trang trước' }).click()
  await expect(page.getByTestId('pagination-page')).toHaveText('Trang 1/2')

  // Tìm theo tên (không phân biệt hoa thường)
  await search(page, 'nguyễn văn an')
  await expect(row(page, state().users.an.email)).toBeVisible()
  // Không có kết quả
  await search(page, `khong-ton-tai-${suffix}`)
  await expect(page.getByTestId('empty')).toBeVisible()
  await shot(page, '03-users-empty')
})

test('lọc theo vai trò và trạng thái', async ({ page }) => {
  const { suffix, users } = state()
  await search(page, suffix)
  await pick(page, 'filter-role', 'Quản trị')
  await expect(page.getByTestId('user-row')).toHaveCount(1)
  await expect(row(page, users.admin2.email)).toBeVisible()
  await pick(page, 'filter-role', 'Người dùng')
  await expect(page.getByText(`${4 + state().fillers} tài khoản phù hợp`)).toBeVisible()
  await pick(page, 'filter-role', 'Mọi vai trò')
  await pick(page, 'filter-status', 'Đã khóa')
  await expect(page.getByTestId('empty')).toBeVisible()
  await pick(page, 'filter-status', 'Hoạt động')
  await expect(page.getByText(`${5 + state().fillers} tài khoản phù hợp`)).toBeVisible()
})

test('khóa user => token của user bị 403, mở khóa => dùng lại được', async ({ page }) => {
  const { dung } = state().users
  expect((await apiCall('GET', '/me', dung.token)).status).toBe(200)
  await search(page, dung.email)
  await action(page, dung.email, 'Khóa tài khoản')
  await expect(page.getByRole('alertdialog')).toContainText('Khóa tài khoản?')
  await shot(page, '03-users-confirm-lock')
  await page.getByRole('alertdialog').getByRole('button', { name: 'Khóa tài khoản' }).click()
  await expect(page.getByText(`Đã khóa ${dung.name}`)).toBeVisible()
  await expect(row(page, dung.email)).toContainText('Đã khóa')

  const r = await apiCall<{ message: string }>('GET', '/me', dung.token)
  expect(r.status).toBe(403)
  expect(r.data.message).toBe('Tài khoản đã bị khóa')
  expect((await apiCall('POST', '/auth/login', undefined, { email: dung.email, password: dung.password })).status).toBe(403)

  // Lọc "Đã khóa" thấy đúng user
  await pick(page, 'filter-status', 'Đã khóa')
  await expect(page.getByTestId('user-row')).toHaveCount(1)
  await pick(page, 'filter-status', 'Mọi trạng thái')

  await action(page, dung.email, 'Mở khóa')
  await page.getByRole('alertdialog').getByRole('button', { name: 'Mở khóa' }).click()
  await expect(page.getByText(`Đã mở khóa ${dung.name}`)).toBeVisible()
  await expect(row(page, dung.email)).toContainText('Hoạt động')
  expect((await apiCall('GET', '/me', dung.token)).status).toBe(200)
})

test('cấp quyền / hạ quyền quản trị', async ({ page }) => {
  const { binh } = state().users
  expect((await apiCall('GET', '/admin/overview', binh.token)).status).toBe(403)
  await search(page, binh.email)
  await action(page, binh.email, 'Cấp quyền quản trị')
  await page.getByRole('alertdialog').getByRole('button', { name: 'Cấp quyền' }).click()
  await expect(page.getByText(`Đã cấp quyền quản trị cho ${binh.name}`)).toBeVisible()
  await expect(row(page, binh.email)).toContainText('Quản trị')
  expect((await apiCall('GET', '/admin/overview', binh.token)).status).toBe(200)

  await action(page, binh.email, 'Hạ quyền quản trị')
  await page.getByRole('alertdialog').getByRole('button', { name: 'Hạ quyền' }).click()
  await expect(page.getByText(`Đã hạ quyền ${binh.name}`)).toBeVisible()
  await expect(row(page, binh.email)).not.toContainText('Quản trị')
  expect((await apiCall('GET', '/admin/overview', binh.token)).status).toBe(403)
})

test('không thể tự khóa / tự hạ quyền chính mình', async ({ page }) => {
  await search(page, ADMIN_EMAIL)
  await expect(row(page, ADMIN_EMAIL)).toContainText('(bạn)')
  await action(page, ADMIN_EMAIL, 'Khóa tài khoản')
  await page.getByRole('alertdialog').getByRole('button', { name: 'Khóa tài khoản' }).click()
  await expect(page.getByText('Không thể tự khóa hoặc tự hạ quyền chính mình')).toBeVisible()
  await shot(page, '03-users-self-lock')
  await expect(row(page, ADMIN_EMAIL)).toContainText('Hoạt động')

  await action(page, ADMIN_EMAIL, 'Hạ quyền quản trị')
  await page.getByRole('alertdialog').getByRole('button', { name: 'Hạ quyền' }).click()
  await expect(page.getByText('Không thể tự khóa hoặc tự hạ quyền chính mình').last()).toBeVisible()
  await expect(row(page, ADMIN_EMAIL)).toContainText('Quản trị')
  // vẫn còn đăng nhập
  await page.reload()
  await expect(page.getByRole('heading', { name: 'Người dùng' })).toBeVisible()
})
