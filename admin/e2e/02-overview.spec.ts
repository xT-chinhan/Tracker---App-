import { expect, test } from '@playwright/test'
import { adminToken, apiOk, loginAsAdmin, money, num, shot, state, type Overview } from './helpers'

test('tổng quan khớp dữ liệu seed (kiểm tra số học)', async ({ page }) => {
  const { expected: e, baseline: b, currentMonth } = state()
  const token = await adminToken()
  // Kiểm tra API trước: số liệu mới = nền + seed
  const api = await apiOk<Overview>('GET', '/admin/overview', token)
  expect(api.users).toEqual(e.users)
  expect(api.transactions).toEqual(e.transactions)
  for (const [k, v] of Object.entries(e.savingGoals)) expect(api.savingGoals[k] ?? 0).toBe(v)
  expect(api.trend).toEqual(e.trend)
  expect(api.users.total).toBe(api.users.active + api.users.locked)
  expect(e.users.total - b.users.total).toBe(16)
  const monthTotal = (await apiOk<{ total: number }>('GET', `/admin/transactions?limit=1&month=${currentMonth}`, token)).total

  await loginAsAdmin(page)
  await expect(page.getByTestId('stat-users-total')).toHaveText(num(e.users.total))
  await expect(page.getByTestId('stat-users-active')).toHaveText(num(e.users.active))
  await expect(page.getByTestId('stat-users-locked')).toHaveText(num(e.users.locked))
  await expect(page.getByTestId('stat-users-new')).toHaveText(`+${num(e.users.new30d)}`)
  await expect(page.getByTestId('stat-tx-total')).toHaveText(num(e.transactions.total))
  await expect(page.getByTestId('stat-tx-new')).toHaveText(num(e.transactions.new30d))
  await expect(page.getByTestId('stat-tx-month')).toHaveText(num(monthTotal))
  await expect(page.getByTestId('stat-income')).toHaveText(money(e.transactions.totalIncome))
  await expect(page.getByTestId('stat-expense')).toHaveText(`−${num(e.transactions.totalExpense)}đ`)
  const net = e.transactions.totalIncome - e.transactions.totalExpense
  await expect(page.getByTestId('stat-net')).toHaveText(`${net >= 0 ? '+' : '−'}${num(Math.abs(net))}đ`)
  // Số người dùng trên sidebar
  await expect(page.getByRole('link', { name: 'Người dùng', exact: true })).toContainText(num(e.users.total))

  const goalsTotal = Object.values(e.savingGoals).reduce((s, v) => s + v, 0)
  await expect(page.getByTestId('goals-total')).toHaveText(num(goalsTotal))
  for (const [k, v] of Object.entries(e.savingGoals)) {
    await expect(page.getByTestId(`goal-${k}`).getByTestId('goal-count')).toHaveText(num(v))
    await expect(page.getByTestId(`goal-${k}`)).toContainText(`${Math.round((v / goalsTotal) * 100)}%`)
  }

  // Đăng ký gần đây: 3 tài khoản mới nhất (filler cuối cùng được tạo sau cùng)
  await expect(page.getByTestId('recent-signups').getByRole('link')).toHaveCount(3)
  await expect(page.getByTestId('recent-signups').getByRole('link').first()).toContainText(`Người dùng thử ${state().fillers}`)

  const chart = page.getByTestId('trend-chart')
  for (const t of e.trend) await expect(chart.getByText(`T${Number(t.month.split('-')[1])}`, { exact: true })).toBeVisible()
  await expect(chart.locator('.recharts-bar-rectangle').first()).toBeVisible()
  await expect(chart.getByText(/^đến \d\d\/\d\d$/)).toBeVisible()
  // Tooltip tháng hiện tại hiển thị đúng số
  const last = e.trend[e.trend.length - 1]
  const box = (await chart.boundingBox())!
  await page.mouse.move(box.x + box.width * 0.93, box.y + box.height * 0.5)
  const tip = page.getByTestId('chart-tip')
  const [y, m] = last.month.split('-')
  await expect(tip).toContainText(`Tháng ${Number(m)}/${y}`)
  await expect(tip).toContainText(`${num(last.income)}đ`)
  await expect(tip).toContainText(`−${num(last.expense)}đ`)
  await expect(tip).toContainText(`${num(Math.abs(last.income - last.expense))}đ`)
  await page.mouse.move(0, 0)
  await shot(page, '02-overview')

  // Xem dạng bảng: đủ 6 tháng, số chính xác
  await page.getByTestId('toggle-table').click()
  const table = page.getByTestId('trend-table')
  for (const t of e.trend) {
    const row = table.locator(`tr[data-month="${t.month}"]`)
    await expect(row).toContainText(`${num(t.income)}đ`)
    await expect(row).toContainText(`−${num(t.expense)}đ`)
  }
  await page.getByTestId('toggle-table').click()
  await expect(page.getByTestId('trend-chart')).toBeVisible()
})

test('tổng quan: skeleton khi đang tải, nút Làm mới tải lại số liệu', async ({ page }) => {
  await loginAsAdmin(page)
  let calls = 0
  await page.route('**/api/admin/overview', async (route) => {
    calls++
    await new Promise((r) => setTimeout(r, 1200))
    await route.continue()
  })
  await page.reload()
  await expect(page.getByTestId('loading')).toBeVisible()
  await expect(page.getByTestId('loading').locator('[data-slot="skeleton"]').first()).toBeVisible()
  await expect(page.getByTestId('stat-users-total')).toBeVisible({ timeout: 10_000 })
  const before = calls
  await page.getByTestId('refresh').click()
  await expect.poll(() => calls).toBeGreaterThan(before)
  await expect(page.getByTestId('page-sub')).toContainText('cập nhật')
})
