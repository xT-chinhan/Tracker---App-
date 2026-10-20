import { expect, test } from '@playwright/test'
import { adminToken, apiOk, loginAsAdmin, num, relogin, settled, shot, state, type Overview } from './helpers'

interface Notif { title: string; body: string; type: string; broadcastId: string | null }
interface Bc { id: string; title: string; recipients: number; createdById: string }

test('thông báo: soạn, xem trước, gửi tới user đang hoạt động (user bị khóa không nhận), lịch sử', async ({ page }) => {
  const { suffix, users } = state()
  const admin = await adminToken()
  const title = `Bảo trì hệ thống ${suffix}`
  const body = `Ứng dụng tạm ngừng đồng bộ từ 23:00 đến 23:30 để nâng cấp (${suffix}).`

  // Khóa dung trước khi gửi
  await apiOk('PATCH', `/admin/users/${users.dung.id}`, admin, { status: 'LOCKED' })
  try {
    const o = await apiOk<Overview>('GET', '/admin/overview', admin)
    await loginAsAdmin(page)
    await page.getByRole('link', { name: 'Thông báo', exact: true }).click()
    await expect(page.getByRole('heading', { name: 'Thông báo hệ thống' })).toBeVisible()
    await expect(page.getByTestId('bc-audience')).toHaveText(`Tất cả người dùng đang hoạt động · ${num(o.users.active)} người`)
    await expect(page.getByText(`${num(o.users.locked)} tài khoản đã khóa sẽ không nhận`)).toBeVisible()

    // Bỏ trống => lỗi inline, không gửi
    await page.getByTestId('bc-send').click()
    await expect(page.getByText('Nhập tiêu đề thông báo')).toBeVisible()
    await expect(page.getByText('Nhập nội dung thông báo')).toBeVisible()
    await expect(page.getByRole('alertdialog')).toHaveCount(0)

    // Soạn: bộ đếm ký tự + xem trước trực tiếp + bản nháp tự lưu
    await page.getByLabel('Tiêu đề').fill(title)
    await page.getByLabel('Nội dung').fill(body)
    await expect(page.getByText(`${title.length}/120`)).toBeVisible()
    await expect(page.getByText(`${body.length}/2000`)).toBeVisible()
    const phone = page.getByTestId('phone-preview')
    await expect(phone).toContainText(title)
    await expect(phone).toContainText(body)
    await expect(phone).toContainText('Vừa xong · Từ đội ngũ TrackerX')
    await page.getByRole('tab', { name: 'Đẩy' }).click()
    await expect(phone).toContainText('THU CHI')
    await expect(phone).toContainText(title)
    await page.getByRole('tab', { name: 'Trong app' }).click()
    await expect(page.getByTestId('draft-saved')).toContainText('Bản nháp tự lưu lúc')
    await page.reload()
    await expect(page.getByLabel('Tiêu đề')).toHaveValue(title)
    await expect(page.getByLabel('Nội dung')).toHaveValue(body)
    await shot(page, '09-broadcasts-compose')

    // Gửi (có xác nhận)
    await page.getByTestId('bc-send').click()
    const dlg = page.getByRole('alertdialog')
    await expect(dlg).toContainText(`Gửi thông báo tới ${num(o.users.active)} người?`)
    await expect(dlg).toContainText(title)
    await dlg.getByRole('button', { name: 'Gửi thông báo' }).click()
    await expect(page.getByText(`Đã gửi thông báo tới ${num(o.users.active)} người`)).toBeVisible()
    await expect(page.getByLabel('Tiêu đề')).toHaveValue('')
    await expect(page.getByTestId('draft-saved')).toHaveCount(0)

    // API: số người nhận = số user ACTIVE
    const hist = await apiOk<{ items: Bc[] }>('GET', '/admin/broadcasts?limit=5', admin)
    const sent = hist.items.find((b) => b.title === title)!
    expect(sent.recipients).toBe(o.users.active)
    // Lịch sử trên trang: dòng đầu là thông báo vừa gửi
    const first = page.getByTestId('bc-row').first()
    await expect(first).toHaveAttribute('data-title', title)
    await expect(first.getByTestId('bc-recipients')).toHaveText(num(o.users.active))
    await expect(first).toContainText('Administrator')
  } finally {
    await apiOk('PATCH', `/admin/users/${users.dung.id}`, admin, { status: 'ACTIVE' })
  }

  // User đang hoạt động nhận được, user bị khóa lúc gửi thì không
  const anN = await apiOk<{ items: Notif[] }>('GET', '/notifications?limit=50', users.an.token)
  expect(anN.items.some((n) => n.title === title && n.type === 'BROADCAST' && n.body === body)).toBe(true)
  const dungN = await apiOk<{ items: Notif[] }>('GET', '/notifications?limit=50', await relogin(users.dung))
  expect(dungN.items.some((n) => n.title === title)).toBe(false)
})

test('thông báo: lịch sử 5 dòng, "Xem cả" mở toàn bộ', async ({ page }) => {
  const admin = await adminToken()
  const { suffix } = state()
  for (let i = 1; i <= 5; i++) await apiOk('POST', '/admin/broadcasts', admin, { title: `Tin ${i} ${suffix}`, body: `Nội dung ${i}` })
  const total = (await apiOk<{ total: number }>('GET', '/admin/broadcasts?limit=1', admin)).total
  expect(total).toBeGreaterThanOrEqual(6)
  await loginAsAdmin(page)
  await page.goto('/broadcasts')
  await settled(page)
  await expect(page.getByTestId('bc-row')).toHaveCount(5)
  await expect(page.getByTestId('bc-row').first()).toHaveAttribute('data-title', `Tin 5 ${suffix}`)
  // "Trước đó" trên điện thoại = thông báo gần nhất
  await expect(page.getByTestId('phone-preview')).toContainText(`Tin 5 ${suffix}`)
  await page.getByTestId('bc-toggle-all').click()
  await expect(page.getByTestId('bc-row')).toHaveCount(Math.min(total, 100))
  await page.getByTestId('bc-toggle-all').click()
  await expect(page.getByTestId('bc-row')).toHaveCount(5)
})
