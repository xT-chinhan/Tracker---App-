import { expect, test } from '@playwright/test'
import { adminToken, apiOk, loginAsAdmin, money, num, settled, shot, state, vnd } from './helpers'

test('chi tiết người dùng: hồ sơ, số liệu, ví, xu hướng, giao dịch gần đây', async ({ page }) => {
  const { users, an } = state()
  await loginAsAdmin(page)
  await page.goto(`/users?q=${encodeURIComponent(users.an.email)}`)
  await page.locator(`[data-email="${users.an.email}"]`).getByRole('link').first().click()
  await expect(page).toHaveURL(new RegExp(`/users/${users.an.id}`))
  await settled(page)

  await expect(page.getByTestId('detail-name')).toHaveText(users.an.name)
  await expect(page.getByTestId('detail-email')).toHaveText(users.an.email)
  await expect(page.getByTestId('status-badge')).toHaveText('Hoạt động')
  await expect(page.getByText(`Số dư · ${an.wallets.length} ví`)).toBeVisible()
  await expect(page.getByTestId('fin-balance')).toHaveText(money(an.balance))
  await expect(page.getByTestId('fin-income')).toHaveText(`+${vnd(an.income)}`)
  await expect(page.getByTestId('fin-expense')).toHaveText(`−${vnd(an.expense)}`)
  await expect(page.getByTestId('fin-savings')).toHaveText(money(an.savings))
  await expect(page.getByTestId('count-transactions')).toHaveText(num(an.txCount))
  await expect(page.getByTestId('count-budgets')).toHaveText(num(an.budgets))
  await expect(page.getByTestId('count-goals')).toHaveText(num(an.goals))
  await expect(page.getByTestId('count-categories')).toHaveText('0')
  await expect(page.getByTestId('last-activity')).not.toHaveText('—')

  // Ví: đúng số ví, đúng số dư từng ví, tổng = số dư
  const detail = await apiOk<{ trend: { month: string; income: number; expense: number; net: number }[]; wallets: { id: string; name: string; balance: number }[]; finance: { balance: number } }>(
    'GET', `/admin/users/${users.an.id}`, await adminToken(),
  )
  await expect(page.getByTestId('wallet-row')).toHaveCount(an.wallets.length)
  for (const w of an.wallets) {
    expect(detail.wallets.find((x) => x.id === w.id)?.balance).toBe(w.balance)
    await expect(page.locator(`[data-testid="wallet-row"][data-name="${w.name}"]`).getByTestId('wallet-balance')).toHaveText(money(w.balance))
  }
  expect(an.wallets.reduce((s, w) => s + w.balance, 0)).toBe(an.balance)
  expect(detail.finance.balance).toBe(an.balance)
  await expect(page.getByTestId('wallets-total')).toHaveText(money(an.balance))
  await expect(page.locator('[data-testid="wallet-row"][data-name="MB Bank"]')).toContainText('Ngân hàng')
  await expect(page.locator('[data-testid="wallet-row"][data-name="MoMo"]')).toContainText('Ví điện tử')

  // Xu hướng 6 tháng của API khớp số seed
  expect(detail.trend).toEqual(an.trend.map((t) => ({ ...t, net: t.income - t.expense })))
  await expect(page.getByTestId('trend-chart').locator('.recharts-bar-rectangle').first()).toBeVisible()

  // 4 giao dịch gần đây + link sang trang Giao dịch đã lọc
  const recent = page.getByTestId('recent-tx').getByTestId('tx-row')
  await expect(recent).toHaveCount(4)
  await expect(recent.first()).toContainText(/Tiền mặt|MoMo|MB Bank/)
  await shot(page, '04-user-detail')
  await page.getByTestId('all-tx-link').click()
  await expect(page).toHaveURL(new RegExp(`/transactions\\?userId=${users.an.id}`))
  await expect(page.getByTestId('pagination-info')).toHaveText(`1–10 trong ${an.txCount}`)
  await page.getByRole('button', { name: 'Trang sau' }).click()
  await expect(page.getByTestId('pagination-info')).toHaveText(`11–20 trong ${an.txCount}`)
  await page.getByRole('button', { name: 'Trang sau' }).click()
  await expect(page.getByTestId('pagination-info')).toHaveText(`21–${an.txCount} trong ${an.txCount}`)
  await expect(page.getByTestId('tx-row').last()).toContainText('Lương cũ')
})

test('chi tiết người dùng: khóa / mở khóa ngay trên trang', async ({ page }) => {
  const { chi } = state().users
  await loginAsAdmin(page)
  await page.goto(`/users/${chi.id}`)
  await page.getByTestId('detail-lock-btn').click()
  await expect(page.getByRole('alertdialog')).toContainText('5 giao dịch · 1 mục tiêu')
  await page.getByRole('alertdialog').getByRole('button', { name: 'Khóa tài khoản' }).click()
  await expect(page.getByText(`Đã khóa ${chi.name}`)).toBeVisible()
  await expect(page.getByTestId('detail-lock-btn')).toHaveText(/Mở khóa/)
  await expect(page.getByTestId('status-badge')).toHaveText('Đã khóa')
  await page.getByTestId('detail-lock-btn').click()
  await page.getByRole('alertdialog').getByRole('button', { name: 'Mở khóa' }).click()
  await expect(page.getByTestId('detail-lock-btn')).toHaveText(/Khóa tài khoản/)
  await expect(page.getByTestId('status-badge')).toHaveText('Hoạt động')
})

test('chi tiết người dùng không tồn tại => báo lỗi', async ({ page }) => {
  await loginAsAdmin(page)
  await page.goto('/users/00000000-0000-4000-8000-000000000000')
  await expect(page.getByTestId('error')).toContainText('Không tìm thấy người dùng')
})
