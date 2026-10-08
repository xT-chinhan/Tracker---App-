import { expect, test } from '@playwright/test'
import { apiCall, apiOk, login, shot, state } from './helpers'

test('tài khoản: đổi tên, đổi mật khẩu rồi đăng nhập lại', async ({ page }) => {
  const { admin2, } = state().users
  const { suffix } = state()
  const newName = `Quản Trị Đổi Tên ${suffix}`
  const newPw = `newpass-${suffix}`
  await login(page, admin2.email, admin2.password)
  await expect(page.getByRole('heading', { name: 'Tổng quan' })).toBeVisible()
  await page.getByRole('link', { name: 'Tài khoản' }).click()
  await expect(page.getByLabel('Tên hiển thị')).toHaveValue(admin2.name)
  await shot(page, '07-account')

  await page.getByLabel('Tên hiển thị').fill(newName)
  await page.getByTestId('save-name').click()
  await expect(page.getByText('Đã cập nhật tên hiển thị')).toBeVisible()
  await expect(page.getByTestId('me-name')).toHaveText(newName)
  expect((await apiOk<{ name: string }>('GET', '/me', admin2.token)).name).toBe(newName)
  await page.reload()
  await expect(page.getByTestId('me-name')).toHaveText(newName)

  // sai mật khẩu hiện tại
  await page.getByLabel('Mật khẩu hiện tại').fill('sai-mat-khau')
  await page.getByLabel('Mật khẩu mới', { exact: true }).fill(newPw)
  await page.getByLabel('Nhập lại mật khẩu mới').fill(newPw)
  await page.getByTestId('save-password').click()
  await expect(page.getByTestId('pw-error')).toHaveText('Mật khẩu hiện tại không đúng')
  // xác nhận không khớp
  await page.getByLabel('Mật khẩu hiện tại').fill(admin2.password)
  await page.getByLabel('Nhập lại mật khẩu mới').fill(newPw + 'x')
  await page.getByTestId('save-password').click()
  await expect(page.getByTestId('pw-error')).toHaveText('Xác nhận mật khẩu không khớp')
  // quá ngắn
  await page.getByLabel('Mật khẩu mới', { exact: true }).fill('123')
  await page.getByLabel('Nhập lại mật khẩu mới').fill('123')
  await page.getByTestId('save-password').click()
  await expect(page.getByTestId('pw-error')).toContainText('ít nhất 6 ký tự')
  // đúng
  await page.getByLabel('Mật khẩu mới', { exact: true }).fill(newPw)
  await page.getByLabel('Nhập lại mật khẩu mới').fill(newPw)
  await page.getByTestId('save-password').click()
  await expect(page.getByText('Đã đổi mật khẩu')).toBeVisible()
  await expect(page.getByLabel('Mật khẩu hiện tại')).toHaveValue('')

  // đăng xuất, mật khẩu cũ không dùng được, mật khẩu mới vào được
  await page.getByTestId('user-menu').click()
  await page.getByRole('menuitem', { name: 'Đăng xuất' }).click()
  await expect(page).toHaveURL(/\/login/)
  await login(page, admin2.email, admin2.password)
  await expect(page.getByTestId('login-error')).toHaveText('Email hoặc mật khẩu không đúng')
  await login(page, admin2.email, newPw)
  await expect(page.getByRole('heading', { name: 'Tổng quan' })).toBeVisible()
  await expect(page.getByTestId('me-name')).toHaveText(newName)
  expect((await apiCall('POST', '/auth/login', undefined, { email: admin2.email, password: newPw })).status).toBe(200)
})
