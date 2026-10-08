import { expect, test, type Page } from '@playwright/test'
import { adminToken, apiOk, loginAsAdmin, settled, shot, state } from './helpers'

const row = (page: Page, name: string) => page.locator(`[data-testid="cat-row"][data-name="${name}"]`)
const archivedRow = (page: Page, name: string) => page.locator(`[data-testid="archived-row"][data-name="${name}"]`)
const panel = (page: Page) => page.getByTestId('cat-panel')

test('danh mục: thứ tự tiếng Việt, tab Chi/Thu, tìm kiếm', async ({ page }) => {
  await loginAsAdmin(page)
  await page.getByRole('link', { name: 'Danh mục', exact: true }).click()
  await settled(page)
  const api = await apiOk<{ name: string; type: string; isArchived: boolean }[]>('GET', '/admin/categories?type=EXPENSE', await adminToken())
  const names = await page.getByTestId('cat-row').evaluateAll((els) => els.map((e) => e.getAttribute('data-name')))
  expect(names).toEqual(api.filter((c) => !c.isArchived).map((c) => c.name))
  // Ă đứng sau A, trước B/C (không xếp theo mã Unicode)
  expect(names.indexOf('Ăn uống')).toBeGreaterThanOrEqual(0)
  expect(names.indexOf('Ăn uống')).toBeLessThan(names.indexOf('Sức khỏe'))
  expect(names.indexOf('Ăn uống')).toBeLessThan(names.indexOf('Chi khác'))
  await expect(page.getByTestId('tab-expense')).toContainText(String(names.length))
  await expect(page.getByTestId('cat-panel-empty')).toBeVisible()
  await shot(page, '06-categories')

  // Tab Thu: Đ đứng sau D
  await page.getByTestId('tab-income').click()
  await expect(row(page, 'Lương')).toBeVisible()
  await expect(row(page, 'Ăn uống')).toHaveCount(0)
  const income = await page.getByTestId('cat-row').evaluateAll((els) => els.map((e) => e.getAttribute('data-name')))
  if (income.includes('Đầu tư') && income.includes('Được tặng')) {
    expect(income.indexOf('Đầu tư')).toBeLessThan(income.indexOf('Được tặng'))
    expect(income.indexOf('Được tặng')).toBeLessThan(income.indexOf('Lương'))
  }
  await page.getByTestId('tab-expense').click()

  // Tìm kiếm trong tab
  await page.getByLabel('Tìm danh mục').fill('sức')
  await expect(page.getByTestId('cat-row')).toHaveCount(1)
  await expect(row(page, 'Sức khỏe')).toBeVisible()
  await page.getByLabel('Tìm danh mục').fill('khong-co')
  await expect(page.getByTestId('empty')).toContainText('Không có danh mục nào')
  await page.getByLabel('Tìm danh mục').fill('')
})

test('danh mục hệ thống: tạo / trùng tên / sửa / xóa / lưu trữ (Hoàn tác) / khôi phục', async ({ page }) => {
  const { suffix, usedCategory } = state()
  const name = `E2E Cà phê ${suffix}`
  const renamed = `E2E Cà phê sáng ${suffix}`
  await loginAsAdmin(page)
  await page.getByRole('link', { name: 'Danh mục', exact: true }).click()
  await expect(row(page, 'Ăn uống')).toBeVisible()

  // Tạo mới (panel bên phải)
  await page.getByTestId('cat-create').click()
  await expect(panel(page)).toContainText('Thêm danh mục chi')
  await panel(page).getByLabel('Tên danh mục').fill(name)
  await expect(panel(page)).toContainText(name) // xem trước cập nhật ngay
  await panel(page).getByRole('button', { name: 'mugHot' }).click()
  await expect(panel(page).getByRole('button', { name: 'mugHot' })).toHaveAttribute('aria-pressed', 'true')
  await panel(page).getByRole('radio', { name: '#F97316' }).click()
  await expect(panel(page).getByRole('radio', { name: '#F97316' })).toHaveAttribute('aria-checked', 'true')
  await shot(page, '06-categories-form')
  await panel(page).getByTestId('cat-save').click()
  await expect(page.getByText(`Đã tạo danh mục "${name}"`)).toBeVisible()
  await expect(panel(page)).toHaveCount(0)
  await expect(row(page, name)).toHaveAttribute('data-icon', 'mugHot')
  await expect(row(page, name).getByTestId('cat-color')).toHaveText('#F97316')
  await expect(row(page, name).getByTestId('cat-usage')).toHaveText('0 giao dịch')

  // Trùng tên (không phân biệt hoa thường), trùng danh mục có sẵn, tên rỗng
  await page.getByTestId('cat-create').click()
  await panel(page).getByLabel('Tên danh mục').fill(name.toUpperCase())
  await panel(page).getByTestId('cat-save').click()
  await expect(panel(page).getByTestId('cat-form-error')).toContainText('đã tồn tại')
  await expect(panel(page).getByLabel('Tên danh mục')).toHaveAttribute('aria-invalid', 'true')
  await shot(page, '06-categories-duplicate')
  await panel(page).getByLabel('Tên danh mục').fill('ăn uống')
  await panel(page).getByTestId('cat-save').click()
  await expect(panel(page).getByTestId('cat-form-error')).toContainText('Danh mục "ăn uống" đã tồn tại')
  await panel(page).getByLabel('Tên danh mục').fill('   ')
  await panel(page).getByTestId('cat-save').click()
  await expect(panel(page).getByTestId('cat-form-error')).toHaveText('Vui lòng nhập tên danh mục')
  await panel(page).getByRole('button', { name: 'Hủy' }).click()
  await expect(page.getByTestId('cat-panel-empty')).toBeVisible()

  // Sửa
  await row(page, name).getByTestId('cat-edit').click()
  await expect(panel(page)).toContainText('Sửa danh mục')
  await expect(panel(page)).toContainText('Chi · 0 giao dịch đang dùng')
  await expect(panel(page).getByLabel('Tên danh mục')).toHaveValue(name)
  await panel(page).getByLabel('Tên danh mục').fill(renamed)
  await panel(page).getByRole('button', { name: 'utensils' }).click()
  await panel(page).getByRole('radio', { name: '#0EA5E9' }).click()
  await panel(page).getByTestId('cat-save').click()
  await expect(page.getByText(`Đã cập nhật "${renamed}"`)).toBeVisible()
  await expect(row(page, renamed).getByTestId('cat-color')).toHaveText('#0EA5E9')
  await expect(row(page, renamed)).toHaveAttribute('data-icon', 'utensils')
  await expect(row(page, name)).toHaveCount(0)

  // Xóa danh mục chưa dùng => xóa hẳn
  await row(page, renamed).getByTestId('cat-delete').click()
  await expect(page.getByRole('alertdialog')).toContainText('xóa vĩnh viễn')
  await page.getByRole('alertdialog').getByRole('button', { name: 'Xóa vĩnh viễn' }).click()
  await expect(page.getByText(`Đã xóa vĩnh viễn "${renamed}"`)).toBeVisible()
  await expect(row(page, renamed)).toHaveCount(0)
  await expect(archivedRow(page, renamed)).toHaveCount(0)
  const list = await apiOk<{ name: string }[]>('GET', '/admin/categories', await adminToken())
  expect(list.some((c) => c.name === renamed)).toBe(false)

  // Danh mục đang dùng: lưu trữ từ panel => Hoàn tác khôi phục lại
  await expect(row(page, usedCategory.name).getByTestId('cat-usage')).toHaveText('1 giao dịch')
  await row(page, usedCategory.name).getByTestId('cat-edit').click()
  await panel(page).getByTestId('cat-archive').click()
  await expect(page.getByRole('alertdialog')).toContainText('lưu trữ')
  await page.getByRole('alertdialog').getByRole('button', { name: 'Lưu trữ' }).click()
  const toast = page.getByTestId('toast-success').filter({ hasText: `Đã lưu trữ "${usedCategory.name}" vì danh mục đang có giao dịch` })
  await expect(toast).toBeVisible()
  await expect(row(page, usedCategory.name)).toHaveCount(0)
  await expect(archivedRow(page, usedCategory.name)).toContainText('1 giao dịch')
  await expect(archivedRow(page, usedCategory.name)).toContainText('Chi')
  await expect(page.getByTestId('cat-panel-empty')).toBeVisible()
  const userCats = await apiOk<{ id: string }[]>('GET', '/categories', state().users.an.token)
  expect(userCats.some((c) => c.id === usedCategory.id)).toBe(false)
  await toast.getByRole('button', { name: 'Hoàn tác' }).click()
  await expect(page.getByText(`Đã khôi phục "${usedCategory.name}"`)).toBeVisible()
  await expect(row(page, usedCategory.name)).toBeVisible()

  // Lưu trữ từ nút trên dòng, khôi phục bằng nút Khôi phục
  await row(page, usedCategory.name).getByTestId('cat-delete').click()
  await page.getByRole('alertdialog').getByRole('button', { name: 'Lưu trữ' }).click()
  await expect(archivedRow(page, usedCategory.name)).toBeVisible()
  await shot(page, '06-categories-archived')
  await archivedRow(page, usedCategory.name).getByTestId('cat-restore').click()
  await expect(page.getByText(`Đã khôi phục "${usedCategory.name}"`).last()).toBeVisible()
  await expect(archivedRow(page, usedCategory.name)).toHaveCount(0)
  await expect(row(page, usedCategory.name)).toBeVisible()
  expect((await apiOk<{ id: string }[]>('GET', '/categories', state().users.an.token)).some((c) => c.id === usedCategory.id)).toBe(true)

  // dọn: lưu trữ lại danh mục của lần chạy để danh sách hệ thống gọn
  await apiOk('DELETE', `/admin/categories/${usedCategory.id}`, await adminToken())
})
