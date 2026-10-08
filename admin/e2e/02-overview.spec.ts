import { expect, test } from '@playwright/test'
import { adminToken, apiOk, loginAsAdmin, money, num, shot, state, type Overview } from './helpers'

test('tổng quan khớp dữ liệu seed (kiểm tra số học)', async ({ page }) => {
  const { expected: e, baseline: b } = state()
  // Kiểm tra API trước: số liệu mới = nền + seed
  const api = await apiOk<Overview>('GET', '/admin/overview', await adminToken())
  expect(api.users).toEqual(e.users)
  expect(api.transactions).toEqual(e.transactions)
  for (const [k, v] of Object.entries(e.savingGoals)) expect(api.savingGoals[k] ?? 0).toBe(v)
  expect(api.trend).toEqual(e.trend)
  expect(api.users.total).toBe(api.users.active + api.users.locked)
  expect(e.users.total - b.users.total).toBe(16)

  await loginAsAdmin(page)
  await expect(page.getByTestId('stat-users-total')).toHaveText(num(e.users.total))
  await expect(page.getByTestId('stat-users-active')).toHaveText(num(e.users.active))
  await expect(page.getByTestId('stat-users-locked')).toHaveText(num(e.users.locked))
  await expect(page.getByTestId('stat-users-new')).toHaveText(num(e.users.new30d))
  await expect(page.getByTestId('stat-tx-total')).toHaveText(num(e.transactions.total))
  await expect(page.getByTestId('stat-tx-new')).toHaveText(num(e.transactions.new30d))
  await expect(page.getByTestId('stat-income')).toHaveText(money(e.transactions.totalIncome))
  await expect(page.getByTestId('stat-expense')).toHaveText(money(e.transactions.totalExpense))
  await expect(page.getByTestId('stat-net')).toHaveText(money(e.transactions.totalIncome - e.transactions.totalExpense))

  const goalsTotal = Object.values(e.savingGoals).reduce((s, v) => s + v, 0)
  await expect(page.getByTestId('goals-total')).toHaveText(num(goalsTotal))
  for (const [k, v] of Object.entries(e.savingGoals)) {
    await expect(page.getByTestId(`goal-${k}`).getByTestId('goal-count')).toHaveText(num(v))
  }

  const chart = page.getByTestId('trend-chart')
  for (const t of e.trend) {
    const [y, m] = t.month.split('-')
    await expect(chart.getByText(`T${Number(m)}/${y}`, { exact: true })).toBeVisible()
  }
  await expect(chart.locator('.recharts-bar-rectangle').first()).toBeVisible()
  // Tooltip của tháng hiện tại hiển thị đúng số
  const last = e.trend[e.trend.length - 1]
  const box = (await chart.boundingBox())!
  await page.mouse.move(box.x + box.width * 0.93, box.y + box.height * 0.5)
  const tip = chart.locator('.recharts-tooltip-wrapper')
  await expect(tip).toContainText(num(last.income))
  await expect(tip).toContainText(num(last.expense))
  await page.mouse.move(0, 0)
  await shot(page, '02-overview')
})
