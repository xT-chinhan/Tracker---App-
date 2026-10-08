import fs from 'node:fs'
import { expect, test, type Page } from '@playwright/test'
import { adminToken, apiOk, loginAsAdmin, num, pick, settled, shot, state, vnd } from './helpers'

const sub = (page: Page) => page.getByTestId('page-sub')
const typeTab = (page: Page, name: string) => page.getByTestId('filter-type').getByRole('tab', { name, exact: true })

test('giao dịch: lọc theo người dùng, ví, loại, tháng, tìm kiếm + phân trang', async ({ page }) => {
  const { users, an, suffix, currentMonth, expected } = state()
  await loginAsAdmin(page)
  await page.getByRole('link', { name: 'Giao dịch', exact: true }).click()
  await expect(page.getByRole('heading', { name: 'Giao dịch' })).toBeVisible()
  await expect(page.getByTestId('tx-row')).toHaveCount(10)
  const total = (await apiOk<{ total: number }>('GET', '/admin/transactions?limit=1', await adminToken())).total
  expect(total).toBe(expected.transactions.total)
  await expect(sub(page)).toHaveText(`${num(total)} giao dịch trên toàn hệ thống`)
  await expect(page.getByTestId('pagination-info')).toHaveText(`1–10 trong ${num(total)}`)
  await expect(page.getByTestId('category-chip').first()).toBeVisible()
  await expect(page.getByRole('columnheader', { name: 'Ví' })).toBeVisible()
  // Lọc ví chỉ bật khi đã chọn người dùng
  await expect(page.getByTestId('filter-wallet')).toBeDisabled()
  await shot(page, '05-transactions')

  // Người dùng
  await pick(page, 'filter-user', new RegExp(users.an.email.replace(/\./g, '\\.')))
  await expect(sub(page)).toHaveText(`${an.txCount} giao dịch khớp bộ lọc`)
  await expect(page.getByTestId('filter-user')).toContainText(users.an.name)
  await expect(page.getByTestId('tx-user').filter({ hasNotText: users.an.name })).toHaveCount(0)
  await expect(page.getByTestId('pagination-info')).toHaveText(`1–10 trong ${an.txCount}`)
  await page.getByRole('button', { name: 'Trang 3' }).click()
  await expect(page.getByTestId('pagination-info')).toHaveText(`21–${an.txCount} trong ${an.txCount}`)
  await expect(page.getByTestId('tx-row')).toHaveCount(an.txCount - 20)

  // Ví (bật sau khi chọn người dùng, chỉ liệt kê ví của người đó)
  await expect(page.getByTestId('filter-wallet')).toBeEnabled()
  await page.getByTestId('filter-wallet').click()
  await expect(page.getByRole('option')).toHaveCount(an.wallets.length + 1)
  await page.keyboard.press('Escape')
  for (const w of an.wallets) {
    await pick(page, 'filter-wallet', w.name)
    await expect(page).toHaveURL(new RegExp(`walletId=${w.id}`))
    await expect(sub(page)).toHaveText(`${w.txCount} giao dịch khớp bộ lọc`)
    await expect(page.getByTestId('tx-wallet').filter({ hasNotText: w.name })).toHaveCount(0)
  }
  // ví + loại Thu: MB Bank chỉ có lương
  await pick(page, 'filter-wallet', 'MB Bank')
  await typeTab(page, 'Thu').click()
  await expect(page.getByTestId('tx-title').first()).toBeVisible()
  await expect(page.getByTestId('tx-title').filter({ hasNotText: /^Lương/ })).toHaveCount(0)
  await pick(page, 'filter-wallet', 'Tất cả ví')
  await expect(page).not.toHaveURL(/walletId=/)

  // Loại: Thu (quay về trang 1)
  await expect(sub(page)).toHaveText(`${an.incomeCount} giao dịch khớp bộ lọc`)
  await expect(page.getByTestId('pagination-info')).toHaveText(`1–${an.incomeCount} trong ${an.incomeCount}`)
  for (const a of await page.getByTestId('tx-amount').allTextContents()) expect(a.startsWith('+')).toBe(true)
  await typeTab(page, 'Chi').click()
  await expect(sub(page)).toHaveText(`${an.txCount - an.incomeCount} giao dịch khớp bộ lọc`)
  for (const a of await page.getByTestId('tx-amount').allTextContents()) expect(a.startsWith('−')).toBe(true)
  await typeTab(page, 'Tất cả').click()

  // Tháng: kèm tổng thu/chi của tháng (từ xu hướng của người dùng)
  const [y, m] = currentMonth.split('-')
  const cur = an.trend[an.trend.length - 1]
  await pick(page, 'filter-month', `Tháng ${Number(m)}/${y}`)
  await expect(sub(page)).toHaveText(`${an.currentMonthCount} giao dịch khớp bộ lọc · thu ${vnd(cur.income)} · chi ${vnd(cur.expense)}`)
  await expect(page).toHaveURL(new RegExp(`month=${currentMonth}`))
  // Bộ lọc nằm trên URL => reload giữ nguyên
  await page.reload()
  await expect(sub(page)).toContainText(`${an.currentMonthCount} giao dịch khớp bộ lọc`)
  await shot(page, '05-transactions-filtered')

  // Bỏ người dùng => ví bị khóa lại, chỉ còn lọc tháng (thu/chi toàn hệ thống)
  await page.getByRole('button', { name: 'Bỏ lọc người dùng' }).click()
  await expect(page.getByTestId('filter-wallet')).toBeDisabled()
  const sys = expected.trend[expected.trend.length - 1]
  const monthTotal = (await apiOk<{ total: number }>('GET', `/admin/transactions?limit=1&month=${currentMonth}`, await adminToken())).total
  await expect(sub(page)).toHaveText(`${num(monthTotal)} giao dịch trong tháng ${Number(m)}/${y} · thu ${vnd(sys.income)} · chi ${vnd(sys.expense)}`)
  await pick(page, 'filter-month', 'Mọi thời gian')

  // Tìm theo ghi chú
  await page.getByTestId('tx-search').fill(`uniqlo ${suffix}`)
  await expect(page.getByTestId('tx-row')).toHaveCount(1)
  await expect(sub(page)).toHaveText('1 giao dịch khớp bộ lọc')
  const r = page.getByTestId('tx-row')
  await expect(r.getByTestId('tx-title')).toHaveText('Mua áo khoác')
  await expect(r.getByTestId('tx-user')).toHaveText(users.an.name)
  await expect(r.getByTestId('tx-wallet')).toHaveText('MoMo')
  await expect(r.getByTestId('tx-amount')).toHaveText(`−${vnd(1_750_000)}`)
  const chip = r.getByTestId('category-chip')
  await expect(chip).toHaveText('Mua sắm')
  // Bong bóng/chip danh mục luôn xám (màu chỉ dùng cho ý nghĩa)
  expect(await chip.evaluate((el) => getComputedStyle(el).backgroundColor)).toBe('rgb(241, 240, 236)')

  // Không có kết quả => empty state, Xóa bộ lọc đưa về toàn bộ
  await page.getByTestId('tx-search').fill(`khong-co-${suffix}`)
  await expect(page.getByTestId('empty')).toContainText('Không có giao dịch nào khớp bộ lọc')
  await expect(page.getByTestId('empty')).toContainText(`chứa “khong-co-${suffix}”`)
  await page.getByTestId('empty').getByRole('button', { name: 'Xóa bộ lọc' }).click()
  await expect(sub(page)).toHaveText(`${num(total)} giao dịch trên toàn hệ thống`)
  await expect(page.getByTestId('tx-search')).toHaveValue('')
})

test('giao dịch: empty state khi lọc người dùng + từ khóa + tháng', async ({ page }) => {
  const { users, currentMonth } = state()
  await loginAsAdmin(page)
  await page.goto(`/transactions?userId=${users.dung.id}&month=${currentMonth}&q=${encodeURIComponent('hoàn tiền')}`)
  const [y, m] = currentMonth.split('-')
  await expect(page.getByTestId('empty')).toContainText(`${users.dung.name} không có giao dịch nào chứa “hoàn tiền” trong tháng ${Number(m)}/${y}`)
  await expect(page.getByTestId('page-sub')).toHaveText('0 giao dịch khớp bộ lọc')
  await expect(page.getByTestId('export-csv')).toBeDisabled()
})

test('giao dịch: xuất CSV theo bộ lọc', async ({ page }) => {
  const { users, an } = state()
  await loginAsAdmin(page)
  await page.goto(`/transactions?userId=${users.an.id}`)
  await settled(page)
  const [dl] = await Promise.all([page.waitForEvent('download'), page.getByTestId('export-csv').click()])
  expect(dl.suggestedFilename()).toBe('giao-dich.csv')
  const text = fs.readFileSync((await dl.path())!, 'utf8')
  const lines = text.replace(/^﻿/, '').trim().split('\r\n')
  expect(lines[0]).toBe('"Ngày","Giờ","Người dùng","Email","Nội dung","Ghi chú","Danh mục","Loại","Ví","Số tiền"')
  expect(lines).toHaveLength(an.txCount + 1)
  expect(lines.filter((l) => l.includes('"Mua áo khoác"'))[0]).toContain('"MoMo","-1750000"')
  await expect(page.getByText(`Đã xuất ${an.txCount} giao dịch`)).toBeVisible()
})

test('giao dịch: lọc theo người dùng qua link từ bảng', async ({ page }) => {
  const { users } = state()
  await loginAsAdmin(page)
  await page.goto(`/transactions?userId=${users.chi.id}`)
  await expect(page.getByTestId('page-sub')).toHaveText('5 giao dịch khớp bộ lọc')
  await page.getByTestId('tx-user').first().click()
  await expect(page).toHaveURL(new RegExp(`/users/${users.chi.id}`))
  await expect(page.getByTestId('detail-name')).toHaveText(users.chi.name)
})
