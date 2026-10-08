import { expect, test, type Page } from '@playwright/test'
import { ADMIN_EMAIL, adminToken, apiCall, apiOk, loginAsAdmin, num, pick, relogin, settled, shot, state, type Overview } from './helpers'

const search = async (page: Page, q: string) => {
  await page.getByTestId('users-search').fill(q)
  await expect.poll(() => new URL(page.url()).searchParams.get('q')).toBe(q.trim() || null)
  await settled(page)
}
const row = (page: Page, email: string) => page.locator(`[data-testid="user-row"][data-email="${email}"]`)
const action = async (page: Page, email: string, item: string | RegExp) => {
  await row(page, email).getByTestId('user-actions').click()
  await page.getByRole('menuitem', { name: item }).click()
}
const statusChip = (page: Page, name: RegExp) => page.getByTestId('filter-status').getByRole('button', { name })

test.beforeEach(async ({ page }) => {
  await loginAsAdmin(page)
  await page.getByRole('link', { name: 'Người dùng', exact: true }).click()
  await expect(page.getByRole('heading', { name: 'Người dùng' })).toBeVisible()
})

test('tiêu đề + chip trạng thái hiện đúng số đếm', async ({ page }) => {
  const o = await apiOk<Overview>('GET', '/admin/overview', await adminToken())
  await expect(page.getByTestId('page-sub')).toHaveText(`${num(o.users.total)} tài khoản · ${num(o.users.active)} hoạt động · ${num(o.users.locked)} đã khóa`)
  await expect(statusChip(page, /^Hoạt động/)).toHaveText(`Hoạt động ${num(o.users.active)}`)
  await expect(statusChip(page, /^Đã khóa/)).toHaveText(`Đã khóa ${num(o.users.locked)}`)
  await expect(statusChip(page, /^Tất cả/)).toHaveAttribute('aria-pressed', 'true')
  // bảng: cột đầy đủ ở desktop, dòng 56px
  for (const h of ['Người dùng', 'Vai trò', 'Trạng thái', 'Giao dịch', 'Mục tiêu', 'Ngày tham gia']) {
    await expect(page.getByRole('columnheader', { name: h, exact: true })).toBeVisible()
  }
  const h = await page.getByTestId('user-row').first().evaluate((el) => el.getBoundingClientRect().height)
  expect(Math.round(h)).toBe(56)
})

test('tìm kiếm + phân trang', async ({ page }) => {
  const { suffix, fillers } = state()
  const total = 5 + fillers
  await search(page, suffix)
  await expect(page.getByTestId('page-sub')).toHaveText(`${total} tài khoản phù hợp`)
  await expect(page.getByTestId('user-row')).toHaveCount(10)
  await expect(page.getByTestId('pagination-info')).toHaveText(`1–10 trong ${total}`)
  await expect(page.getByRole('button', { name: 'Trang 1' })).toHaveAttribute('aria-current', 'page')
  await expect(page.getByRole('button', { name: 'Trang 2' })).toBeVisible()
  await expect(page.getByRole('button', { name: 'Trang trước' })).toBeDisabled()
  await shot(page, '03-users')
  await page.getByRole('button', { name: 'Trang sau' }).click()
  await expect(page.getByTestId('pagination-info')).toHaveText(`11–${total} trong ${total}`)
  await expect(page.getByTestId('user-row')).toHaveCount(total - 10)
  await expect(page).toHaveURL(/page=2/)
  await expect(page.getByRole('button', { name: 'Trang sau' })).toBeDisabled()
  await page.getByRole('button', { name: 'Trang 1' }).click()
  await expect(page.getByTestId('pagination-info')).toHaveText(`1–10 trong ${total}`)

  // Tìm theo tên (không phân biệt hoa thường)
  await search(page, 'nguyễn văn an')
  await expect(row(page, state().users.an.email)).toBeVisible()
  // Không có kết quả => empty state có nút xóa bộ lọc
  await search(page, `khong-ton-tai-${suffix}`)
  await expect(page.getByTestId('empty')).toContainText('Không tìm thấy người dùng')
  await shot(page, '03-users-empty')
  await page.getByTestId('empty').getByRole('button', { name: 'Xóa bộ lọc' }).click()
  await expect(page.getByTestId('users-search')).toHaveValue('')
  await expect(page.getByTestId('user-row')).toHaveCount(10)
})

test('lọc theo vai trò và trạng thái', async ({ page }) => {
  const { suffix, users, fillers } = state()
  await search(page, suffix)
  await pick(page, 'filter-role', 'Quản trị')
  await expect(page.getByTestId('user-row')).toHaveCount(1)
  await expect(row(page, users.admin2.email)).toBeVisible()
  await expect(row(page, users.admin2.email).getByTestId('role-badge')).toHaveText('Quản trị')
  await expect(page.getByTestId('filter-role')).toContainText('Vai trò: Quản trị')
  await pick(page, 'filter-role', 'Người dùng')
  await expect(page.getByTestId('page-sub')).toHaveText(`${4 + fillers} tài khoản phù hợp`)
  await pick(page, 'filter-role', 'Tất cả')
  await statusChip(page, /^Đã khóa/).click()
  await expect(statusChip(page, /^Đã khóa/)).toHaveAttribute('aria-pressed', 'true')
  await expect(page.getByTestId('empty')).toBeVisible()
  await statusChip(page, /^Hoạt động/).click()
  await expect(page.getByTestId('page-sub')).toHaveText(`${5 + fillers} tài khoản phù hợp`)
  await expect(page).toHaveURL(/status=ACTIVE/)
})

test('khóa user => token bị 403; mở khóa => token cũ 401, đăng nhập lại được', async ({ page }) => {
  const { dung } = state().users
  expect((await apiCall('GET', '/me', dung.token)).status).toBe(200)
  await search(page, dung.email)
  await action(page, dung.email, 'Khóa tài khoản')
  const dlg = page.getByRole('alertdialog')
  await expect(dlg).toContainText(`Khóa tài khoản ${dung.name}?`)
  await expect(dlg).toContainText(dung.email)
  await expect(dlg).toContainText('0 giao dịch · 0 mục tiêu')
  await shot(page, '03-users-confirm-lock')
  await dlg.getByRole('button', { name: 'Khóa tài khoản' }).click()
  await expect(page.getByText(`Đã khóa ${dung.name}`)).toBeVisible()
  await expect(row(page, dung.email)).toContainText('Đã khóa')

  const r = await apiCall<{ message: string }>('GET', '/me', dung.token)
  expect(r.status).toBe(403)
  expect(r.data.message).toBe('Tài khoản đã bị khóa')
  expect((await apiCall('POST', '/auth/login', undefined, { email: dung.email, password: dung.password })).status).toBe(403)

  // Lọc "Đã khóa" thấy đúng user
  await statusChip(page, /^Đã khóa/).click()
  await expect(page.getByTestId('user-row')).toHaveCount(1)
  await statusChip(page, /^Tất cả/).click()

  await action(page, dung.email, 'Mở khóa')
  await page.getByRole('alertdialog').getByRole('button', { name: 'Mở khóa' }).click()
  await expect(page.getByText(`Đã mở khóa ${dung.name}`)).toBeVisible()
  await expect(row(page, dung.email)).toContainText('Hoạt động')
  // Token cũ đã bị vô hiệu khi khóa (tokenVersion) => 401, đăng nhập lại thì dùng được
  const old = await apiCall<{ message: string }>('GET', '/me', dung.token)
  expect(old.status).toBe(401)
  expect((await apiCall('GET', '/me', await relogin(dung))).status).toBe(200)
})

test('toast Hoàn tác trả lại trạng thái cũ', async ({ page }) => {
  const { dung } = state().users
  dung.token = await relogin(dung)
  await search(page, dung.email)
  await action(page, dung.email, 'Khóa tài khoản')
  await page.getByRole('alertdialog').getByRole('button', { name: 'Khóa tài khoản' }).click()
  const toast = page.getByTestId('toast-success').filter({ hasText: `Đã khóa ${dung.name}` })
  await expect(toast).toBeVisible()
  expect((await apiCall('GET', '/me', dung.token)).status).toBe(403)
  await toast.getByRole('button', { name: 'Hoàn tác' }).click()
  await expect(page.getByText(`Đã hoàn tác thay đổi cho ${dung.name}`)).toBeVisible()
  await expect(row(page, dung.email)).toContainText('Hoạt động')
  expect((await apiCall('GET', '/me', await relogin(dung))).status).toBe(200)
})

test('cấp quyền / hạ quyền quản trị', async ({ page }) => {
  const { binh } = state().users
  expect((await apiCall('GET', '/admin/overview', binh.token)).status).toBe(403)
  await search(page, binh.email)
  await action(page, binh.email, 'Cấp quyền quản trị')
  await expect(page.getByRole('alertdialog')).toContainText(`Cấp quyền quản trị cho ${binh.name}?`)
  await page.getByRole('alertdialog').getByRole('button', { name: 'Cấp quyền' }).click()
  await expect(page.getByText(`Đã cấp quyền quản trị cho ${binh.name}`)).toBeVisible()
  await expect(row(page, binh.email)).toContainText('Quản trị')
  expect((await apiCall('GET', '/admin/overview', binh.token)).status).toBe(200)

  await action(page, binh.email, 'Hạ quyền quản trị')
  await page.getByRole('alertdialog').getByRole('button', { name: 'Hạ quyền' }).click()
  await expect(page.getByText(`Đã hạ quyền ${binh.name}`)).toBeVisible()
  await expect(row(page, binh.email).getByTestId('role-badge')).toHaveText('Người dùng')
  expect((await apiCall('GET', '/admin/overview', binh.token)).status).toBe(403)
})

test('không thể tự khóa / tự hạ quyền chính mình (toast lỗi từ backend)', async ({ page }) => {
  await search(page, ADMIN_EMAIL)
  await expect(row(page, ADMIN_EMAIL)).toContainText('(bạn)')
  await action(page, ADMIN_EMAIL, 'Khóa tài khoản')
  await page.getByRole('alertdialog').getByRole('button', { name: 'Khóa tài khoản' }).click()
  const err = page.getByTestId('toast-error').first()
  await expect(err).toContainText('Không khóa được tài khoản')
  await expect(err).toContainText('Không thể tự khóa hoặc tự hạ quyền chính mình')
  await shot(page, '03-users-self-lock')
  await expect(row(page, ADMIN_EMAIL)).toContainText('Hoạt động')
  await err.getByRole('button', { name: 'Đóng' }).click()
  await expect(page.getByTestId('toast-error')).toHaveCount(0)

  await action(page, ADMIN_EMAIL, 'Hạ quyền quản trị')
  await page.getByRole('alertdialog').getByRole('button', { name: 'Hạ quyền' }).click()
  await expect(page.getByTestId('toast-error')).toContainText('Không thể tự khóa hoặc tự hạ quyền chính mình')
  await expect(row(page, ADMIN_EMAIL)).toContainText('Quản trị')
  // vẫn còn đăng nhập
  await page.reload()
  await expect(page.getByRole('heading', { name: 'Người dùng' })).toBeVisible()
})

test('tablet 1024: sidebar thành rail, ẩn cột Mục tiêu/Ngày tham gia, ngày nằm cạnh email', async ({ page }) => {
  const { an } = state().users
  await page.setViewportSize({ width: 1024, height: 768 })
  await search(page, an.email)
  expect(Math.round((await page.getByTestId('sidebar').boundingBox())!.width)).toBe(72)
  await expect(page.getByRole('columnheader', { name: 'Mục tiêu' })).toBeHidden()
  await expect(page.getByRole('columnheader', { name: 'Ngày tham gia' })).toBeHidden()
  await expect(row(page, an.email)).toContainText(/· \d\d\/\d\d/)
  // nav vẫn dùng được (aria-label) và menu tài khoản trong rail có Đăng xuất
  await page.getByRole('link', { name: 'Giao dịch', exact: true }).click()
  await expect(page.getByRole('heading', { name: 'Giao dịch' })).toBeVisible()
  await page.getByTestId('user-menu').click()
  await expect(page.getByRole('menuitem', { name: 'Đăng xuất' })).toBeVisible()
  await page.keyboard.press('Escape')
})
