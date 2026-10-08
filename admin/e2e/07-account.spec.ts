import { expect, test } from '@playwright/test'
import { apiCall, apiOk, login, relogin, shot, state } from './helpers'

test('tài khoản: đổi tên, đổi mật khẩu (lỗi inline) rồi đăng nhập lại', async ({ page }) => {
  const { admin2 } = state().users
  const { suffix } = state()
  const newName = `Quản Trị Đổi Tên ${suffix}`
  const newPw = `newpass-${suffix}`
  // token trong state có thể đã mất hiệu lực (admin2 bị khóa/mở khóa ở 01-auth) => lấy token mới
  const token = await relogin(admin2)
  await login(page, admin2.email, admin2.password)
  await expect(page.getByRole('heading', { name: 'Tổng quan' })).toBeVisible()
  await page.getByRole('link', { name: 'Tài khoản', exact: true }).click()
  await expect(page.getByLabel('Họ và tên')).toHaveValue(admin2.name)
  await expect(page.getByLabel('Email đăng nhập')).toHaveValue(admin2.email)
  await expect(page.getByLabel('Email đăng nhập')).toBeDisabled()
  await expect(page.getByTestId('save-name')).toBeDisabled() // chưa đổi gì
  await shot(page, '07-account')

  await page.getByLabel('Họ và tên').fill(newName)
  await page.getByTestId('save-name').click()
  await expect(page.getByText('Đã cập nhật tên hiển thị')).toBeVisible()
  await expect(page.getByTestId('me-name')).toHaveText(newName)
  await expect(page.getByTestId('account-name')).toHaveText(newName)
  expect((await apiOk<{ name: string }>('GET', '/me', token)).name).toBe(newName)
  await page.reload()
  await expect(page.getByTestId('me-name')).toHaveText(newName)

  const current = page.getByLabel('Mật khẩu hiện tại')
  const next = page.getByLabel('Mật khẩu mới', { exact: true })
  const confirm = page.getByLabel('Nhập lại mật khẩu mới')
  // bỏ trống
  await page.getByTestId('save-password').click()
  await expect(page.getByTestId('pw-error').first()).toHaveText('Nhập mật khẩu hiện tại')
  // sai mật khẩu hiện tại (lỗi backend hiện dưới ô hiện tại)
  await current.fill('sai-mat-khau')
  await next.fill(newPw)
  await confirm.fill(newPw)
  await page.getByTestId('save-password').click()
  await expect(page.getByTestId('pw-error')).toHaveText('Mật khẩu hiện tại không đúng')
  await expect(current).toHaveAttribute('aria-invalid', 'true')
  // xác nhận không khớp
  await current.fill(admin2.password)
  await confirm.fill(newPw + 'x')
  await page.getByTestId('save-password').click()
  await expect(page.getByTestId('pw-error')).toHaveText('Mật khẩu nhập lại chưa khớp')
  await expect(confirm).toHaveAttribute('aria-invalid', 'true')
  await shot(page, '07-account-mismatch')
  // quá ngắn
  await next.fill('123')
  await confirm.fill('123')
  await page.getByTestId('save-password').click()
  await expect(page.getByTestId('pw-error')).toContainText('ít nhất 6 ký tự')
  // hiện mật khẩu
  await page.getByRole('button', { name: 'Hiện mật khẩu' }).nth(1).click()
  await expect(next).toHaveAttribute('type', 'text')
  // đúng
  await next.fill(newPw)
  await confirm.fill(newPw)
  await page.getByTestId('save-password').click()
  await expect(page.getByText('Đã đổi mật khẩu')).toBeVisible()
  await expect(current).toHaveValue('')
  await expect(page.getByTestId('pw-error')).toHaveCount(0)
  // Token cũ bị vô hiệu, admin web đã lưu token mới nên vẫn đăng nhập
  expect((await apiCall('GET', '/me', token)).status).toBe(401)
  await page.reload()
  await expect(page.getByRole('heading', { name: 'Tài khoản' })).toBeVisible()
  await page.getByRole('link', { name: 'Người dùng', exact: true }).click()
  await expect(page.getByRole('heading', { name: 'Người dùng' })).toBeVisible()
  await expect(page).toHaveURL(/\/users$/)

  // đăng xuất, mật khẩu cũ không dùng được, mật khẩu mới vào được
  await page.getByRole('button', { name: 'Đăng xuất' }).click()
  await expect(page).toHaveURL(/\/login/)
  await login(page, admin2.email, admin2.password)
  await expect(page.getByTestId('login-error')).toHaveText('Email hoặc mật khẩu không đúng')
  await login(page, admin2.email, newPw)
  await expect(page.getByRole('heading', { name: 'Tổng quan' })).toBeVisible()
  await expect(page.getByTestId('me-name')).toHaveText(newName)
  expect((await apiCall('POST', '/auth/login', undefined, { email: admin2.email, password: newPw })).status).toBe(200)
})
