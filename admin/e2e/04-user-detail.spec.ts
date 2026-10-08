import { expect, test } from '@playwright/test'
import { adminToken, apiOk, loginAsAdmin, money, num, shot, state } from './helpers'

test('chi tiết người dùng: hồ sơ, số liệu, xu hướng, giao dịch', async ({ page }) => {
  const { users, an } = state()
  await loginAsAdmin(page)
  await page.goto(`/users?q=${encodeURIComponent(users.an.email)}`)
  await page.locator(`[data-email="${users.an.email}"]`).getByRole('link').first().click()
  await expect(page).toHaveURL(new RegExp(`/users/${users.an.id}`))

  await expect(page.getByTestId('detail-name')).toHaveText(users.an.name)
  await expect(page.getByTestId('detail-email')).toHaveText(users.an.email)
  await expect(page.getByTestId('fin-balance')).toHaveText(money(an.balance))
  await expect(page.getByTestId('fin-income')).toHaveText(money(an.income))
  await expect(page.getByTestId('fin-expense')).toHaveText(money(an.expense))
  await expect(page.getByTestId('fin-savings')).toHaveText(money(an.savings))
  await expect(page.getByTestId('count-transactions')).toHaveText(num(an.txCount))
  await expect(page.getByTestId('count-budgets')).toHaveText(num(an.budgets))
  await expect(page.getByTestId('count-goals')).toHaveText(num(an.goals))
  await expect(page.getByTestId('count-categories')).toHaveText('0')
  // balance = thu - chi - tiết kiệm
  expect(an.balance).toBe(an.income - an.expense - an.savings)

  // Xu hướng 6 tháng của API khớp số seed
  const detail = await apiOk<{ trend: { month: string; income: number; expense: number; net: number }[] }>(
    'GET', `/admin/users/${users.an.id}`, await adminToken(),
  )
  expect(detail.trend).toEqual(an.trend.map((t) => ({ ...t, net: t.income - t.expense })))
  await expect(page.getByTestId('trend-chart').locator('.recharts-bar-rectangle').first()).toBeVisible()

  // Danh sách giao dịch của user (10/trang)
  await expect(page.getByTestId('tx-row')).toHaveCount(10)
  await expect(page.getByTestId('pagination-info')).toHaveText(`1–10 / ${an.txCount}`)
  await shot(page, '04-user-detail')
  await page.getByRole('button', { name: 'Trang sau' }).click()
  await expect(page.getByTestId('pagination-info')).toHaveText(`11–20 / ${an.txCount}`)
  await page.getByRole('button', { name: 'Trang sau' }).click()
  await expect(page.getByTestId('pagination-info')).toHaveText(`21–${an.txCount} / ${an.txCount}`)
  await expect(page.getByTestId('tx-row').last()).toContainText('Lương cũ')
})

test('chi tiết người dùng: khóa / mở khóa ngay trên trang', async ({ page }) => {
  const { chi } = state().users
  await loginAsAdmin(page)
  await page.goto(`/users/${chi.id}`)
  await page.getByTestId('detail-lock-btn').click()
  await page.getByRole('alertdialog').getByRole('button', { name: 'Khóa tài khoản' }).click()
  await expect(page.getByText(`Đã khóa ${chi.name}`)).toBeVisible()
  await expect(page.getByTestId('detail-lock-btn')).toHaveText(/Mở khóa/)
  await page.getByTestId('detail-lock-btn').click()
  await page.getByRole('alertdialog').getByRole('button', { name: 'Mở khóa' }).click()
  await expect(page.getByTestId('detail-lock-btn')).toHaveText(/Khóa tài khoản/)
})

test('chi tiết người dùng không tồn tại => báo lỗi', async ({ page }) => {
  await loginAsAdmin(page)
  await page.goto('/users/00000000-0000-4000-8000-000000000000')
  await expect(page.getByTestId('error')).toContainText('Không tìm thấy người dùng')
})
