import { expect, test, type Page } from '@playwright/test'
import { adminToken, apiOk, loginAsAdmin, shot, state } from './helpers'

const row = (page: Page, name: string) => page.locator(`[data-testid="cat-row"][data-name="${name}"]`)
const archivedRow = (page: Page, name: string) => page.locator(`[data-testid="archived-row"][data-name="${name}"]`)
const dialog = (page: Page) => page.getByRole('dialog')

test('danh mục hệ thống: tạo / trùng tên / sửa / xóa / lưu trữ / khôi phục', async ({ page }) => {
  const { suffix, usedCategory } = state()
  const name = `E2E Cà phê ${suffix}`
  const renamed = `E2E Cà phê sáng ${suffix}`
  await loginAsAdmin(page)
  await page.getByRole('link', { name: 'Danh mục hệ thống' }).click()
  await expect(row(page, 'Ăn uống')).toBeVisible()
  await shot(page, '06-categories')

  // Tab Thu
  await page.getByTestId('tab-income').click()
  await expect(row(page, 'Lương')).toBeVisible()
  await expect(row(page, 'Ăn uống')).toHaveCount(0)
  await page.getByTestId('tab-expense').click()

  // Tạo mới
  await page.getByTestId('cat-create').click()
  await expect(dialog(page)).toContainText('Thêm danh mục chi')
  await dialog(page).getByLabel('Tên danh mục').fill(name)
  await dialog(page).getByRole('button', { name: 'mugHot' }).click()
  await dialog(page).getByRole('button', { name: '#F97316' }).click()
  await shot(page, '06-categories-form')
  await dialog(page).getByTestId('cat-save').click()
  await expect(page.getByText(`Đã tạo danh mục "${name}"`)).toBeVisible()
  await expect(dialog(page)).toHaveCount(0)
  await expect(row(page, name)).toContainText('mugHot')
  await expect(row(page, name)).toContainText('#F97316')
  await expect(row(page, name).getByTestId('cat-usage')).toHaveText('0 giao dịch')

  // Trùng tên (không phân biệt hoa thường) và trùng danh mục có sẵn
  await page.getByTestId('cat-create').click()
  await dialog(page).getByLabel('Tên danh mục').fill(name.toUpperCase())
  await dialog(page).getByTestId('cat-save').click()
  await expect(dialog(page).getByTestId('cat-form-error')).toContainText('đã tồn tại')
  await shot(page, '06-categories-duplicate')
  await dialog(page).getByLabel('Tên danh mục').fill('ăn uống')
  await dialog(page).getByTestId('cat-save').click()
  await expect(dialog(page).getByTestId('cat-form-error')).toContainText('Danh mục "ăn uống" đã tồn tại')
  // màu sai định dạng => lỗi phía client
  await dialog(page).getByLabel('Tên danh mục').fill(`Hợp lệ ${suffix}`)
  await dialog(page).getByLabel('Màu').fill('#12')
  await dialog(page).getByTestId('cat-save').click()
  await expect(dialog(page).getByTestId('cat-form-error')).toHaveText(/#RRGGBB/)
  await dialog(page).getByRole('button', { name: 'Hủy' }).click()
  await expect(row(page, `Hợp lệ ${suffix}`)).toHaveCount(0)

  // Sửa
  await row(page, name).getByTestId('cat-edit').click()
  await expect(dialog(page)).toContainText('Sửa danh mục')
  await expect(dialog(page).getByLabel('Tên danh mục')).toHaveValue(name)
  await dialog(page).getByLabel('Tên danh mục').fill(renamed)
  await dialog(page).getByRole('button', { name: 'utensils' }).click()
  await dialog(page).getByLabel('Màu').fill('#0ea5e9')
  await dialog(page).getByTestId('cat-save').click()
  await expect(page.getByText(`Đã cập nhật "${renamed}"`)).toBeVisible()
  await expect(row(page, renamed)).toContainText('#0EA5E9')
  await expect(row(page, renamed)).toContainText('utensils')
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

  // Xóa danh mục đang dùng => lưu trữ
  await expect(row(page, usedCategory.name).getByTestId('cat-usage')).toHaveText('1 giao dịch')
  await row(page, usedCategory.name).getByTestId('cat-delete').click()
  await expect(page.getByRole('alertdialog')).toContainText('LƯU TRỮ')
  await page.getByRole('alertdialog').getByRole('button', { name: 'Lưu trữ' }).click()
  await expect(page.getByText(`Đã lưu trữ "${usedCategory.name}" vì danh mục đang có giao dịch`)).toBeVisible()
  await expect(row(page, usedCategory.name)).toHaveCount(0)
  await expect(archivedRow(page, usedCategory.name)).toContainText('1 giao dịch')
  await shot(page, '06-categories-archived')
  // user không còn thấy danh mục đã lưu trữ
  const userCats = await apiOk<{ id: string }[]>('GET', '/categories', state().users.an.token)
  expect(userCats.some((c) => c.id === usedCategory.id)).toBe(false)

  // Khôi phục
  await archivedRow(page, usedCategory.name).getByTestId('cat-restore').click()
  await expect(page.getByText(`Đã khôi phục "${usedCategory.name}"`)).toBeVisible()
  await expect(archivedRow(page, usedCategory.name)).toHaveCount(0)
  await expect(row(page, usedCategory.name)).toBeVisible()

  // dọn: lưu trữ lại danh mục của lần chạy để danh sách hệ thống gọn
  await apiOk('DELETE', `/admin/categories/${usedCategory.id}`, await adminToken())
})
