import { expect, test } from '@playwright/test'
import { loginAsAdmin, shot, state } from './helpers'

const PAGES = [
  ['/', 'Tổng quan'],
  ['/users', 'Người dùng'],
  ['/transactions', 'Giao dịch'],
  ['/categories', 'Danh mục hệ thống'],
  ['/account', 'Tài khoản'],
] as const

for (const [w, h, label] of [[1440, 900, 'desktop'], [820, 1180, 'tablet']] as const) {
  test(`bố cục ${label} ${w}px: không tràn ngang`, async ({ page }) => {
    await page.setViewportSize({ width: w, height: h })
    await loginAsAdmin(page)
    for (const [path, title] of [...PAGES, [`/users/${state().users.an.id}`, state().users.an.name] as const]) {
      await page.goto(path)
      await expect(page.getByRole('heading', { name: title }).first()).toBeVisible()
      await expect(page.getByTestId('loading')).toHaveCount(0)
      const overflow = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth)
      expect(overflow, `${path} tràn ngang`).toBeLessThanOrEqual(0)
      if (label === 'tablet') await shot(page, `08-tablet-${path === '/' ? 'overview' : path.slice(1).replace(/\/[0-9a-f-]{36}$/, '-detail')}`)
    }
  })
}
