import { expect, test } from '@playwright/test'
import { loginAsAdmin, settled, shot, state } from './helpers'

const PAGES = [
  ['/', 'Tổng quan'],
  ['/users', 'Người dùng'],
  ['/transactions', 'Giao dịch'],
  ['/categories', 'Danh mục hệ thống'],
  ['/broadcasts', 'Thông báo hệ thống'],
  ['/account', 'Tài khoản'],
] as const

for (const [w, h, label, sidebar] of [[1440, 900, 'desktop', 248], [1024, 768, 'tablet', 72]] as const) {
  test(`bố cục ${label} ${w}px: sidebar ${sidebar}px, không tràn ngang`, async ({ page }) => {
    await page.setViewportSize({ width: w, height: h })
    await loginAsAdmin(page)
    for (const [path, title] of [...PAGES, [`/users/${state().users.an.id}`, state().users.an.name] as const, ['/khong-co-trang', 'Không tìm thấy trang'] as const]) {
      await page.goto(path)
      await expect(page.locator('main')).toContainText(title)
      await settled(page)
      const overflow = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth)
      expect(overflow, `${path} tràn ngang`).toBeLessThanOrEqual(0)
      expect(Math.round((await page.getByTestId('sidebar').boundingBox())!.width)).toBe(sidebar)
      // Không có top bar: tiêu đề trang 30px đậm nằm ngay đầu nội dung
      const h1 = page.locator('main h1').first()
      if (!path.startsWith('/khong')) expect(await h1.evaluate((el) => [getComputedStyle(el).fontSize, getComputedStyle(el).fontWeight])).toEqual(['30px', '700'])
      if (label === 'tablet') await shot(page, `08-tablet-${path === '/' ? 'overview' : path.slice(1).replace(/\/[0-9a-f-]{36}$/, '-detail')}`)
    }
  })
}

test('design tokens: nền ngà, font Be Vietnam Pro, mục nav đang chọn nền trắng', async ({ page }) => {
  await loginAsAdmin(page)
  const body = await page.evaluate(() => [getComputedStyle(document.body).backgroundColor, getComputedStyle(document.body).fontFamily])
  expect(body[0]).toBe('rgb(247, 246, 243)')
  expect(body[1]).toContain('Be Vietnam Pro')
  expect(await page.evaluate(() => document.fonts.check('600 16px "Be Vietnam Pro"', 'Ước'))).toBe(true)
  const active = page.getByRole('link', { name: 'Tổng quan', exact: true })
  await expect(active).toHaveAttribute('aria-current', 'page')
  expect(await active.evaluate((el) => getComputedStyle(el).backgroundColor)).toBe('rgb(255, 255, 255)')
  // Nút chính là viên thuốc đen
  await page.goto('/categories')
  const primary = page.getByTestId('cat-create')
  const [bg, radius, height] = await primary.evaluate((el) => [getComputedStyle(el).backgroundColor, parseFloat(getComputedStyle(el).borderRadius), (el as HTMLElement).offsetHeight] as const)
  expect(bg).toBe('rgb(17, 17, 17)')
  expect(radius).toBeGreaterThanOrEqual(height / 2)
  expect(height).toBe(40)
})
