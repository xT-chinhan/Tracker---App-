/**
 * Ảnh chụp 1440×900 (viewport, không full page) của từng màn để so với design/admin-mockup/shots/*.png.
 * Ghi vào E2E_REAL_SHOTS (mặc định /tmp/admin-real-shots).
 */
import fs from 'node:fs'
import path from 'node:path'
import { expect, test, type Page } from '@playwright/test'
import { ADMIN_EMAIL, ADMIN_PASSWORD, adminToken, apiOk, settled, state } from './helpers'

const DIR = process.env.E2E_REAL_SHOTS ?? '/tmp/admin-real-shots'
const snap = async (page: Page, name: string) => {
  fs.mkdirSync(DIR, { recursive: true })
  await page.waitForTimeout(350)
  await page.screenshot({ path: path.join(DIR, `${name}.png`) })
}

test.describe.configure({ mode: 'serial' })

test('ảnh so sánh với mockup', async ({ page }) => {
  test.setTimeout(120_000)
  const { users, currentMonth } = state()

  // 01 Đăng nhập
  await page.goto('/login')
  await page.getByLabel('Email').fill(ADMIN_EMAIL)
  await page.getByLabel('Mật khẩu', { exact: true }).fill(ADMIN_PASSWORD)
  await snap(page, '01-dang-nhap')

  // 11 Đang tải (skeleton Tổng quan)
  await page.route('**/api/admin/overview', async (r) => { await new Promise((x) => setTimeout(x, 2500)); await r.continue() })
  await page.getByRole('button', { name: 'Đăng nhập' }).click()
  await expect(page.getByTestId('loading')).toBeVisible()
  await snap(page, '11-dang-tai')
  await settled(page)
  await page.unrouteAll({ behavior: 'wait' })

  // 02 Tổng quan, hover tháng áp chót
  const chart = page.getByTestId('trend-chart')
  const box = (await chart.boundingBox())!
  await page.mouse.move(box.x + 52 + (box.width - 60) * (4.5 / 6), box.y + box.height * 0.6)
  await expect(page.getByTestId('chart-tip')).toBeVisible()
  await snap(page, '02-tong-quan')
  await page.mouse.move(0, 0)

  // 03 Người dùng + menu dòng thứ 3
  await page.goto('/users')
  await settled(page)
  await page.getByTestId('user-actions').nth(2).click()
  await expect(page.getByRole('menu')).toBeVisible()
  await snap(page, '03-nguoi-dung')
  // 04 Xác nhận khóa
  await page.getByRole('menuitem', { name: /Khóa tài khoản|Mở khóa/ }).click()
  await expect(page.getByRole('alertdialog')).toBeVisible()
  await snap(page, '04-xac-nhan-khoa')
  await page.getByRole('alertdialog').getByRole('button', { name: 'Hủy' }).click()

  // 05 Chi tiết người dùng
  await page.goto(`/users/${users.an.id}`)
  await settled(page)
  await expect(page.getByTestId('recent-tx').getByTestId('tx-row')).toHaveCount(4)
  await snap(page, '05-chi-tiet-nguoi-dung')

  // 06 Giao dịch
  await page.goto('/transactions')
  await settled(page)
  await snap(page, '06-giao-dich')

  // 07 Danh mục + panel sửa "Ăn uống"
  await page.goto('/categories')
  await settled(page)
  await page.locator('[data-testid="cat-row"][data-name="Ăn uống"]').getByTestId('cat-edit').click()
  await snap(page, '07-danh-muc')

  // 08 Thông báo (đang soạn, chưa gửi)
  await page.goto('/broadcasts')
  await settled(page)
  await page.getByLabel('Tiêu đề').fill('Bảo trì hệ thống tối 25/09')
  await page.getByLabel('Nội dung').fill('Ứng dụng tạm ngừng đồng bộ từ 23:00 đến 23:30 ngày 25/09 để nâng cấp. Giao dịch ghi trong lúc này sẽ tự đồng bộ lại sau đó.')
  await expect(page.getByTestId('draft-saved')).toBeVisible()
  await snap(page, '08-thong-bao')
  await page.getByLabel('Tiêu đề').fill('')
  await page.getByLabel('Nội dung').fill('')
  await expect(page.getByTestId('draft-saved')).toHaveCount(0)

  // 09 Tài khoản (nhập lại chưa khớp)
  await page.goto('/account')
  await page.getByLabel('Mật khẩu hiện tại').fill('admin123')
  await page.getByLabel('Mật khẩu mới', { exact: true }).fill('matkhau-moi-1')
  await page.getByLabel('Nhập lại mật khẩu mới').fill('matkhau-moi-2')
  await page.getByTestId('save-password').click()
  await expect(page.getByTestId('pw-error')).toBeVisible()
  await page.getByLabel('Họ và tên').focus()
  await snap(page, '09-tai-khoan')

  // 10 Empty state
  await page.goto(`/transactions?userId=${users.dung.id}&month=${currentMonth}&q=${encodeURIComponent('hoàn tiền')}`)
  await expect(page.getByTestId('empty')).toBeVisible()
  await page.getByTestId('tx-search').focus()
  await snap(page, '10-trang-thai-trong')

  // 12 Toast thành công (Hoàn tác) + toast lỗi backend
  const admin = await adminToken()
  await apiOk('PATCH', `/admin/users/${users.dung.id}`, admin, { status: 'LOCKED' })
  await page.goto(`/users?q=${encodeURIComponent(users.dung.email)}`)
  await settled(page)
  await page.getByTestId('user-actions').first().click()
  await page.getByRole('menuitem', { name: 'Mở khóa' }).click()
  await page.getByRole('alertdialog').getByRole('button', { name: 'Mở khóa' }).click()
  await expect(page.getByTestId('toast-success')).toBeVisible()
  await page.getByTestId('users-search').fill(ADMIN_EMAIL)
  await expect(page.getByTestId('user-row')).toHaveCount(1)
  await page.locator(`[data-testid="user-row"][data-email="${ADMIN_EMAIL}"]`).getByTestId('user-actions').click()
  await page.getByRole('menuitem', { name: 'Hạ quyền quản trị' }).click()
  await page.getByRole('alertdialog').getByRole('button', { name: 'Hạ quyền' }).click()
  await page.getByTestId('users-search').fill('')
  await expect(page.getByTestId('user-row')).toHaveCount(10)
  await expect(page.getByTestId('toast-error')).toBeVisible()
  await page.mouse.move(0, 0)
  await snap(page, '12-toast-loi')

  // 13 Người dùng ở 1024×768
  await page.setViewportSize({ width: 1024, height: 768 })
  await page.goto('/users')
  await settled(page)
  await snap(page, '13-nguoi-dung-1024')
})

test.afterAll(async () => {
  // đảm bảo dung mở khóa dù test giữa chừng lỗi
  await apiOk('PATCH', `/admin/users/${state().users.dung.id}`, await adminToken(), { status: 'ACTIVE' })
})
