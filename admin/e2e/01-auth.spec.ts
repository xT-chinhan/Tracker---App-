import { expect, test } from '@playwright/test'
import { ADMIN_EMAIL, adminToken, apiOk, login, loginAsAdmin, shot, state } from './helpers'

const fakeJwt = (payload: object) =>
  `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.${Buffer.from(JSON.stringify(payload)).toString('base64url')}.invalidsignature`

test('đăng nhập: trang login hiển thị đúng', async ({ page }) => {
  await page.goto('/')
  await expect(page).toHaveURL(/\/login$/)
  await expect(page.getByText('Dùng tài khoản quản trị viên để tiếp tục')).toBeVisible()
  await shot(page, '01-login')
})

test('đăng nhập: sai mật khẩu', async ({ page }) => {
  await login(page, ADMIN_EMAIL, 'wrong-password')
  await expect(page.getByTestId('login-error')).toHaveText('Email hoặc mật khẩu không đúng')
  await expect(page).toHaveURL(/\/login/)
  await shot(page, '01-login-error')
})

test('đăng nhập: tài khoản USER hợp lệ vẫn bị từ chối', async ({ page }) => {
  const { an } = state().users
  await login(page, an.email, an.password)
  await expect(page.getByTestId('login-error')).toContainText('không có quyền quản trị')
  await expect(page).toHaveURL(/\/login/)
  expect(await page.evaluate(() => localStorage.getItem('admin.token'))).toBeNull()
})

test('đăng nhập: tài khoản bị khóa', async ({ page }) => {
  const { admin2 } = state().users
  const admin = await adminToken()
  await apiOk('PATCH', `/admin/users/${admin2.id}`, admin, { status: 'LOCKED' })
  try {
    await login(page, admin2.email, admin2.password)
    await expect(page.getByTestId('login-error')).toHaveText('Tài khoản đã bị khóa')
  } finally {
    await apiOk('PATCH', `/admin/users/${admin2.id}`, admin, { status: 'ACTIVE' })
  }
})

test('đăng nhập thành công, đăng xuất, chặn truy cập khi chưa đăng nhập', async ({ page }) => {
  await loginAsAdmin(page)
  await expect(page.getByTestId('me-name')).toBeVisible()
  await page.goto('/users')
  await expect(page.getByRole('heading', { name: 'Người dùng' })).toBeVisible()
  await page.getByTestId('user-menu').click()
  await page.getByRole('menuitem', { name: 'Đăng xuất' }).click()
  await expect(page).toHaveURL(/\/login/)
  expect(await page.evaluate(() => localStorage.getItem('admin.token'))).toBeNull()
  await page.goto('/transactions')
  await expect(page).toHaveURL(/\/login$/)
})

test('token hết hạn => về trang đăng nhập', async ({ page }) => {
  await page.goto('/login')
  await page.evaluate((t) => localStorage.setItem('admin.token', t), fakeJwt({ sub: 'x', exp: Math.floor(Date.now() / 1000) - 60 }))
  await page.goto('/users')
  await expect(page).toHaveURL(/\/login\?reason=expired/)
  await expect(page.getByTestId('login-error')).toContainText('hết hạn')
  await expect.poll(() => page.evaluate(() => localStorage.getItem('admin.token'))).toBeNull()
})

test('token không hợp lệ (server trả 401) => về trang đăng nhập', async ({ page }) => {
  await page.goto('/login')
  await page.evaluate((t) => localStorage.setItem('admin.token', t), fakeJwt({ sub: 'x', exp: Math.floor(Date.now() / 1000) + 3600 }))
  await page.goto('/users')
  await expect(page).toHaveURL(/\/login\?reason=expired/)
  await expect(page.getByTestId('login-error')).toContainText('hết hạn')
  expect(await page.evaluate(() => localStorage.getItem('admin.token'))).toBeNull()
})

test('token của USER thường trong localStorage => bị đẩy ra', async ({ page }) => {
  const { an } = state().users
  await page.goto('/login')
  await page.evaluate((t) => localStorage.setItem('admin.token', t), an.token)
  await page.goto('/')
  await expect(page).toHaveURL(/\/login\?reason=forbidden/)
  await expect(page.getByTestId('login-error')).toContainText('không có quyền')
})

test('admin đang đăng nhập bị khóa => bị đẩy ra với thông báo', async ({ page }) => {
  const { admin2 } = state().users
  await login(page, admin2.email, admin2.password)
  await expect(page.getByRole('heading', { name: 'Tổng quan' })).toBeVisible()
  const admin = await adminToken()
  await apiOk('PATCH', `/admin/users/${admin2.id}`, admin, { status: 'LOCKED' })
  try {
    await page.getByRole('link', { name: 'Người dùng' }).click()
    await expect(page).toHaveURL(/\/login\?reason=locked/)
    await expect(page.getByTestId('login-error')).toHaveText('Tài khoản đã bị khóa.')
  } finally {
    await apiOk('PATCH', `/admin/users/${admin2.id}`, admin, { status: 'ACTIVE' })
  }
})
