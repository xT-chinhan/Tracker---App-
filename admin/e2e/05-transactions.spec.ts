import { expect, test } from '@playwright/test'
import { adminToken, apiOk, loginAsAdmin, pick, shot, state } from './helpers'

test('giao dịch: lọc theo người dùng, loại, tháng, tìm kiếm + phân trang', async ({ page }) => {
  const { users, an, suffix, currentMonth, expected } = state()
  await loginAsAdmin(page)
  await page.getByRole('link', { name: 'Giao dịch' }).click()
  await expect(page.getByRole('heading', { name: 'Giao dịch' })).toBeVisible()
  await expect(page.getByTestId('tx-row')).toHaveCount(15)
  const total = (await apiOk<{ total: number }>('GET', '/admin/transactions?limit=1', await adminToken())).total
  expect(total).toBe(expected.transactions.total)
  await expect(page.getByTestId('pagination-info')).toHaveText(`1–15 / ${total.toLocaleString('vi-VN')}`)
  await expect(page.getByTestId('category-chip').first()).toBeVisible()
  await shot(page, '05-transactions')

  // Người dùng
  await pick(page, 'filter-user', new RegExp(users.an.email.replace(/\./g, '\\.')))
  await expect(page.getByText(`${an.txCount} giao dịch phù hợp`)).toBeVisible()
  await expect(page.getByTestId('tx-user').filter({ hasNotText: users.an.name })).toHaveCount(0)
  await expect(page.getByTestId('pagination-info')).toHaveText(`1–15 / ${an.txCount}`)
  await page.getByRole('button', { name: 'Trang sau' }).click()
  await expect(page.getByTestId('pagination-info')).toHaveText(`16–${an.txCount} / ${an.txCount}`)
  await expect(page.getByTestId('tx-row')).toHaveCount(an.txCount - 15)

  // Loại: Thu (quay về trang 1)
  await pick(page, 'filter-type', 'Thu')
  await expect(page.getByText(`${an.incomeCount} giao dịch phù hợp`)).toBeVisible()
  await expect(page.getByTestId('pagination-info')).toHaveText(`1–${an.incomeCount} / ${an.incomeCount}`)
  for (const a of await page.getByTestId('tx-amount').allTextContents()) expect(a.startsWith('+')).toBe(true)
  await pick(page, 'filter-type', 'Chi')
  await expect(page.getByText(`${an.txCount - an.incomeCount} giao dịch phù hợp`)).toBeVisible()
  for (const a of await page.getByTestId('tx-amount').allTextContents()) expect(a.startsWith('−')).toBe(true)
  await pick(page, 'filter-type', 'Thu & chi')

  // Tháng
  const [y, m] = currentMonth.split('-')
  await pick(page, 'filter-month', `Tháng ${Number(m)}/${y}`)
  await expect(page.getByText(`${an.currentMonthCount} giao dịch phù hợp`)).toBeVisible()
  await expect(page).toHaveURL(new RegExp(`month=${currentMonth}`))
  // Bộ lọc nằm trên URL => reload giữ nguyên
  await page.reload()
  await expect(page.getByText(`${an.currentMonthCount} giao dịch phù hợp`)).toBeVisible()
  await shot(page, '05-transactions-filtered')

  // Xóa lọc, tìm kiếm theo ghi chú
  await page.getByRole('button', { name: 'Xóa lọc' }).click()
  await expect(page.getByText(`${total.toLocaleString('vi-VN')} giao dịch phù hợp`)).toBeVisible()
  await page.getByTestId('tx-search').fill(`uniqlo ${suffix}`)
  await expect(page.getByTestId('tx-row')).toHaveCount(1)
  await expect(page.getByText('1 giao dịch phù hợp')).toBeVisible()
  const r = page.getByTestId('tx-row')
  await expect(r.getByTestId('tx-title')).toHaveText('Mua áo khoác')
  await expect(r.getByTestId('tx-user')).toHaveText(users.an.name)
  const chip = r.getByTestId('category-chip')
  await expect(chip).toHaveText('Mua sắm')
  expect(await chip.evaluate((el) => getComputedStyle(el).color)).toBe('rgb(168, 85, 247)') // #A855F7

  // Tìm theo tiêu đề + không có kết quả
  await page.getByTestId('tx-search').fill(`khong-co-${suffix}`)
  await expect(page.getByTestId('empty')).toBeVisible()
})

test('giao dịch: lọc theo người dùng qua link từ bảng', async ({ page }) => {
  const { users } = state()
  await loginAsAdmin(page)
  await page.goto(`/transactions?userId=${users.chi.id}`)
  await expect(page.getByText('5 giao dịch phù hợp')).toBeVisible()
  await page.getByTestId('tx-user').first().click()
  await expect(page).toHaveURL(new RegExp(`/users/${users.chi.id}`))
  await expect(page.getByTestId('detail-name')).toHaveText(users.chi.name)
})
