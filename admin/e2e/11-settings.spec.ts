/**
 * Cấu hình hệ thống: sửa + lưu từng mục, lỗi chặn lưu, Hủy, bảo trì (user nhận 503), gửi email thử, lịch sử, chặn rời trang.
 * Mọi giá trị được khôi phục về ban đầu ở afterAll (chạy lặp được).
 */
import fs from 'node:fs'
import path from 'node:path'
import { expect, test, type Page } from '@playwright/test'
import { ADMIN_EMAIL, adminToken, apiCall, apiOk, fakeSmtp, loginAsAdmin, num, settled, shot } from './helpers'

type Values = Record<string, Record<string, string | number | boolean | null>>
interface Cfg { values: Values; maintenance: { enabled: boolean; message: string; endsAt: string | null }; smtp: { configured: boolean; hasPassword: boolean }; stats: { activeUsers: number } }
interface Hist { items: { section: string; key: string; secret: boolean; oldValue: unknown; newValue: unknown; actor: { email: string } | null }[]; total: number }

const REAL = process.env.E2E_REAL_SHOTS ?? '/tmp/admin-real-shots'
let initial: Values
let admin: string

const getCfg = async () => apiOk<Cfg>('GET', '/admin/config', admin)
const input = (page: Page, key: string) => page.getByTestId(`in-${key}`)
const savebar = (page: Page) => page.getByTestId('savebar')
async function saveAndWait(page: Page) {
  await page.getByTestId('savebar-save').click()
  await expect(page.getByTestId('toast-success').filter({ hasText: 'Đã lưu cấu hình' }).last()).toBeVisible()
  await expect(savebar(page)).toHaveCount(0)
}
async function openSection(page: Page, slug: string, heading: string) {
  await page.getByTestId(`snav-${slug}`).click()
  await expect(page.getByRole('heading', { name: heading, exact: true })).toBeVisible()
}

test.describe.configure({ mode: 'serial' })

test.beforeAll(async () => {
  admin = await adminToken()
  await apiCall('POST', '/admin/config/maintenance', admin, { enabled: false })
  initial = (await getCfg()).values
})

test.afterAll(async () => {
  // dùng lại token admin (không đăng nhập thêm: giới hạn đăng nhập theo email có thể đang bị đổi)
  await apiCall('POST', '/admin/config/maintenance', admin, { enabled: false })
  const body = JSON.parse(JSON.stringify(initial)) as Values
  delete body.smtp.hasPassword
  body.smtp.password = ''
  await apiOk('PATCH', '/admin/config', admin, body)
})

test('chung: sửa có đánh dấu "Trước", lỗi chặn lưu, Hủy khôi phục, Lưu áp dụng ngay cho app', async ({ page }) => {
  await loginAsAdmin(page)
  await page.getByRole('link', { name: 'Cấu hình', exact: true }).click()
  await expect(page).toHaveURL(/\/settings$/)
  await expect(page.getByRole('heading', { name: 'Cấu hình hệ thống' })).toBeVisible()
  await settled(page)
  await expect(page.getByTestId('snav-chung')).toHaveAttribute('aria-current', 'page')
  await expect(input(page, 'general.appName')).toHaveValue(String(initial.general.appName))

  // Sửa 1 trường: chấm đen + "Trước: …" + đếm trên sub-nav + thanh lưu
  await input(page, 'general.supportEmail').fill('hotro@thuchi.vn')
  const row = page.getByTestId('row-general.supportEmail')
  await expect(row).toHaveAttribute('data-changed', 'true')
  await expect(row.getByTestId('was')).toContainText('Trước:')
  await expect(page.getByTestId('snav-chung').getByTestId('nav-count')).toHaveText('1')
  await expect(page.getByTestId('savebar-count')).toHaveText('1 thay đổi chưa lưu')

  // Lỗi inline => nút Lưu bị khóa, thanh lưu nêu rõ lỗi ở đâu
  await input(page, 'general.hotline').fill('028 7300 6868')
  await input(page, 'general.privacyUrl').fill('http://thuchi.vn/bao-mat')
  await expect(page.getByTestId('row-general.privacyUrl').getByRole('alert')).toHaveText('Link phải bắt đầu bằng https://')
  await expect(page.getByTestId('savebar-count')).toHaveText('3 thay đổi chưa lưu')
  await expect(page.getByTestId('savebar-detail')).toContainText('1 lỗi cần sửa trước khi lưu: Chính sách bảo mật')
  await expect(page.getByTestId('savebar-save')).toBeDisabled()
  await shot(page, '11-settings-dirty')

  // Hủy => về giá trị đã lưu
  await page.getByTestId('savebar-cancel').click()
  await expect(savebar(page)).toHaveCount(0)
  await expect(input(page, 'general.supportEmail')).toHaveValue(String(initial.general.supportEmail))
  await expect(input(page, 'general.privacyUrl')).toHaveValue(String(initial.general.privacyUrl))
  await expect(page.getByTestId('changed-dot')).toHaveCount(0)

  // Sửa hợp lệ + Lưu
  await input(page, 'general.appName').fill('Thu Chi E2E')
  await input(page, 'general.supportEmail').fill('hotro@thuchi.vn')
  await input(page, 'general.hotline').fill('028 7300 6868')
  await input(page, 'general.termsUrl').fill('https://thuchi.vn/dieu-khoan')
  await input(page, 'general.privacyUrl').fill('https://thuchi.vn/bao-mat')
  await saveAndWait(page)
  await expect(page.getByTestId('page-sub')).toContainText('Áp dụng cho app Thu Chi E2E trên mọi thiết bị')
  await expect(page.getByTestId('last-saved')).toContainText('bởi')
  const g = (await getCfg()).values.general
  expect(g).toMatchObject({ appName: 'Thu Chi E2E', supportEmail: 'hotro@thuchi.vn', hotline: '028 7300 6868', termsUrl: 'https://thuchi.vn/dieu-khoan', privacyUrl: 'https://thuchi.vn/bao-mat' })
  const pub = await apiOk<{ appName: string; supportEmail: string }>('GET', '/config/public')
  expect(pub.appName).toBe('Thu Chi E2E')
  expect(pub.supportEmail).toBe('hotro@thuchi.vn')
})

test('đăng ký & truy cập, mật khẩu & OTP, nghiệp vụ, ứng dụng: sửa + lưu từng mục, lỗi chéo chặn lưu', async ({ page }) => {
  await loginAsAdmin(page)
  await page.goto('/settings')
  await settled(page)

  // Đăng ký & truy cập
  await openSection(page, 'truy-cap', 'Đăng ký & truy cập')
  await input(page, 'access.registrationEnabled').click()
  await expect(page.getByTestId('row-access.registrationEnabled').getByTestId('was')).toHaveText('Trước: Bật')
  await input(page, 'access.sessionDays').fill('0')
  await expect(page.getByTestId('row-access.sessionDays').getByRole('alert')).toHaveText('Phải từ 1 đến 365')
  await expect(page.getByTestId('savebar-save')).toBeDisabled()
  await input(page, 'access.sessionDays').fill('14')
  await input(page, 'access.loginMaxAttempts').fill('50')
  await input(page, 'access.loginWindowMinutes').fill('15')
  await input(page, 'access.maintenanceMessage').fill('Thu Chi đang nâng cấp hệ thống. Dữ liệu của bạn vẫn an toàn.')
  await expect(page.getByTestId('snav-truy-cap').getByTestId('nav-count')).toHaveText('5')
  await saveAndWait(page)
  let v = (await getCfg()).values
  expect(v.access).toMatchObject({ registrationEnabled: false, sessionDays: 14, loginMaxAttempts: 50, loginWindowMinutes: 15, maintenanceMessage: 'Thu Chi đang nâng cấp hệ thống. Dữ liệu của bạn vẫn an toàn.' })
  const reg = await apiCall<{ code: string }>('POST', '/auth/register', undefined, { email: `closed.${Date.now()}@e2e.test`, password: 'secret123', name: 'X' })
  expect(reg.status).toBe(403)
  expect(reg.data.code).toBe('REGISTRATION_DISABLED')
  await input(page, 'access.registrationEnabled').click()
  // Giờ dự kiến xong: chọn qua ô datetime-local, hiển thị "HH:mm · dd/MM/yyyy", lưu ISO; quá khứ => lỗi; nút X xóa
  await input(page, 'access.maintenanceEndsAt').fill('2020-01-01T08:00')
  await expect(page.getByTestId('row-access.maintenanceEndsAt').getByRole('alert')).toHaveText('Giờ dự kiến xong phải ở tương lai')
  await expect(page.getByTestId('savebar-save')).toBeDisabled()
  await input(page, 'access.maintenanceEndsAt').fill('2031-05-20T23:30')
  await expect(page.getByTestId('endsAt-text')).toHaveText('23:30 · 20/05/2031')
  await saveAndWait(page)
  v = (await getCfg()).values
  expect(v.access.registrationEnabled).toBe(true)
  expect(v.access.maintenanceEndsAt).toBe(new Date('2031-05-20T23:30:00+07:00').toISOString())
  await page.getByTestId('clear-endsAt').click()
  await expect(page.getByTestId('row-access.maintenanceEndsAt').getByTestId('was')).toHaveText('Trước: 23:30 · 20/05/2031')
  await saveAndWait(page)
  expect((await getCfg()).values.access.maintenanceEndsAt).toBeNull()

  // Mật khẩu & OTP: lỗi chéo (chờ gửi lại >= thời hạn mã), tóm tắt theo số đang nhập
  await openSection(page, 'mat-khau', 'Mật khẩu & OTP')
  await input(page, 'password.minLength').fill('8')
  await input(page, 'password.otpExpiryMinutes').fill('1')
  // lỗi gắn vào trường vừa sửa (thời hạn mã) vì 60 giây chờ gửi lại không còn ngắn hơn
  await expect(page.getByTestId('savebar-detail')).toContainText('1 lỗi cần sửa trước khi lưu: OTP hết hạn sau')
  await expect(page.getByTestId('row-password.otpExpiryMinutes').getByRole('alert')).toHaveText('Thời gian chờ gửi lại phải ngắn hơn thời hạn mã')
  await expect(page.getByTestId('savebar-save')).toBeDisabled()
  await input(page, 'password.otpExpiryMinutes').fill('15')
  await input(page, 'password.otpMaxAttempts').fill('3')
  await input(page, 'password.otpResendSeconds').fill('90')
  await expect(page.getByTestId('otp-summary')).toContainText('Mã dùng được trong 15 phút')
  await expect(page.getByTestId('otp-summary')).toContainText('Gửi lại mã sau 90 giây')
  await expect(page.getByTestId('otp-summary')).toContainText('Nhập sai 3 lần thì mã bị hủy')
  await saveAndWait(page)
  v = (await getCfg()).values
  expect(v.password).toEqual({ minLength: 8, otpExpiryMinutes: 15, otpMaxAttempts: 3, otpResendSeconds: 90 })
  const weak = await apiCall<{ message: string }>('POST', '/auth/register', undefined, { email: `weak.${Date.now()}@e2e.test`, password: 'secret1', name: 'W' })
  expect(weak.status).toBe(400)
  expect(weak.data.message).toContain('ít nhất 8 ký tự')

  // Nghiệp vụ: thanh xem trước theo ngưỡng, ví mặc định, tính năng
  await openSection(page, 'nghiep-vu', 'Nghiệp vụ')
  await expect(page.getByTestId('feature-featureSavingGoals')).toContainText('mục tiêu')
  await input(page, 'business.budgetWarningPercent').fill('100')
  await expect(page.getByTestId('budget-card').getByRole('alert')).toHaveText('Ngưỡng cảnh báo phải nhỏ hơn ngưỡng vượt')
  await expect(page.getByTestId('savebar-save')).toBeDisabled()
  await input(page, 'business.budgetWarningPercent').fill('70')
  await input(page, 'business.budgetExceededPercent').fill('110')
  await expect(page.getByTestId('budget-preview-warning')).toHaveText('70%')
  await expect(page.getByTestId('budget-preview-exceeded')).toHaveText('110%')
  await input(page, 'business.defaultWalletName').fill('Ví chính')
  await input(page, 'business.featureQuickTemplates').click()
  await expect(page.getByTestId('feature-featureQuickTemplates')).toContainText('Trước: Bật')
  await saveAndWait(page)
  await expect(page.getByTestId('feature-featureQuickTemplates')).toContainText('Tắt từ')
  v = (await getCfg()).values
  expect(v.business).toMatchObject({ budgetWarningPercent: 70, budgetExceededPercent: 110, defaultWalletName: 'Ví chính', featureQuickTemplates: false })
  const pub = await apiOk<{ features: Record<string, boolean>; budget: { warningPercent: number } }>('GET', '/config/public')
  expect(pub.features.quickTemplates).toBe(false)
  expect(pub.budget.warningPercent).toBe(70)

  // Ứng dụng di động: định dạng phiên bản, tối thiểu không mới hơn mới nhất, xem trước hộp cập nhật
  await openSection(page, 'ung-dung', 'Ứng dụng di động')
  await input(page, 'mobile.androidLatestVersion').fill('1.4')
  await expect(page.getByTestId('platform-android').getByRole('alert')).toHaveText('Phiên bản dạng x.y.z, vd 1.4.0')
  await input(page, 'mobile.androidLatestVersion').fill('1.4.0')
  await input(page, 'mobile.androidMinVersion').fill('1.5.0')
  await expect(page.getByTestId('platform-android').getByRole('alert')).toHaveText('Bản tối thiểu không được mới hơn bản mới nhất')
  await expect(page.getByTestId('savebar-save')).toBeDisabled()
  await input(page, 'mobile.androidMinVersion').fill('1.2.0')
  await input(page, 'mobile.androidStoreUrl').fill('https://play.google.com/store/apps/details?id=vn.thuchi.app')
  await input(page, 'mobile.iosLatestVersion').fill('1.4.0')
  await input(page, 'mobile.iosMinVersion').fill('1.2.0')
  await input(page, 'mobile.iosStoreUrl').fill('https://apps.apple.com/vn/app/thu-chi/id6478123456')
  await input(page, 'mobile.releaseNotes').fill('• Nạp tiền vào mục tiêu ngay từ Trang chủ\n• Xuất giao dịch theo tháng ra CSV\n• Sửa lỗi đồng bộ khi mất mạng')
  const preview = page.getByTestId('update-preview')
  await expect(preview.getByTestId('preview-text')).toHaveText('Bản 1.1.9 trên máy không còn được hỗ trợ. Cập nhật lên 1.4.0 để tiếp tục dùng.')
  await expect(preview.getByTestId('preview-notes')).toContainText('Xuất giao dịch theo tháng ra CSV')
  await preview.getByRole('tab', { name: 'Gợi ý' }).click()
  await expect(preview).toContainText('Để sau')
  await preview.getByRole('tab', { name: 'Bắt buộc' }).click()
  await saveAndWait(page)
  v = (await getCfg()).values
  expect(v.mobile).toMatchObject({ androidLatestVersion: '1.4.0', androidMinVersion: '1.2.0', iosLatestVersion: '1.4.0', iosMinVersion: '1.2.0', iosStoreUrl: 'https://apps.apple.com/vn/app/thu-chi/id6478123456' })
  expect(String(v.mobile.releaseNotes)).toContain('Sửa lỗi đồng bộ khi mất mạng')
  await shot(page, '11-settings-mobile')
})

test('bảo trì: bật sau hộp xác nhận => token user nhận 503, admin vẫn dùng được => tắt', async ({ page }) => {
  const email = `maint.${Date.now()}@e2e.test`
  await apiCall('PATCH', '/admin/config', admin, { password: { minLength: 6 } })
  const user = await apiOk<{ accessToken: string }>('POST', '/auth/register', undefined, { email, password: 'secret123', name: 'Bảo Trì' })
  const cfg = await getCfg()
  await loginAsAdmin(page)
  await page.goto('/settings/truy-cap')
  await settled(page)
  await expect(page.getByTestId('maintenance-badge')).toHaveText('Đang tắt')
  await input(page, 'access.maintenanceMessage').fill('Thu Chi đang bảo trì E2E, quay lại sau ít phút.')
  await page.getByTestId('maintenance-switch').click()
  const dlg = page.getByTestId('maintenance-dialog')
  await expect(dlg).toContainText('Bật chế độ bảo trì?')
  await expect(dlg).toContainText(`${num(cfg.stats.activeUsers)} người dùng đang hoạt động`)
  await expect(dlg).toContainText('Không hẹn giờ, tắt bằng tay')
  await expect(dlg.getByTestId('maintenance-dialog-message')).toHaveText('Thu Chi đang bảo trì E2E, quay lại sau ít phút.')
  // Hủy => không bật
  await dlg.getByRole('button', { name: 'Hủy' }).click()
  expect((await getCfg()).maintenance.enabled).toBe(false)
  // Bật thật
  await page.getByTestId('maintenance-switch').click()
  await page.getByTestId('maintenance-confirm').click()
  await expect(page.getByTestId('toast-success').filter({ hasText: 'Đã bật chế độ bảo trì' })).toBeVisible()
  await expect(page.getByTestId('maintenance-banner')).toBeVisible()
  await expect(page.getByTestId('maintenance-badge')).toContainText('Đang bật')
  await expect(page.getByTestId('settings-nav').getByTestId('nav-maintenance-dot')).toBeVisible()
  await expect(page.getByTestId('maintenance-switch')).toHaveAttribute('data-state', 'checked')
  await expect(savebar(page)).toHaveCount(0) // nội dung đã lưu cùng lúc bật

  const me = await apiCall<{ code: string; message: string }>('GET', '/me', user.accessToken)
  expect(me.status).toBe(503)
  expect(me.data.code).toBe('MAINTENANCE')
  expect(me.data.message).toBe('Thu Chi đang bảo trì E2E, quay lại sau ít phút.')
  const login = await apiCall<{ code: string }>('POST', '/auth/login', undefined, { email, password: 'secret123' })
  expect(login.status).toBe(503)
  expect((await apiCall('GET', '/admin/overview', admin)).status).toBe(200)
  const pub = await apiOk<{ maintenance: { enabled: boolean } }>('GET', '/config/public')
  expect(pub.maintenance.enabled).toBe(true)
  // Bảng quản trị vẫn dùng bình thường
  await page.getByRole('link', { name: 'Người dùng', exact: true }).click()
  await settled(page)
  await expect(page.getByTestId('user-row').first()).toBeVisible()

  // Tắt bằng nút trên banner
  await page.goto('/settings/truy-cap')
  await page.getByTestId('maintenance-off').click()
  await expect(page.getByTestId('toast-success').filter({ hasText: 'Đã tắt chế độ bảo trì' })).toBeVisible()
  await expect(page.getByTestId('maintenance-banner')).toHaveCount(0)
  await expect(page.getByTestId('maintenance-badge')).toHaveText('Đang tắt')
  expect((await apiCall('GET', '/me', user.accessToken)).status).toBe(200)
})

test('email SMTP: chưa cấu hình => banner + nút gửi thử khóa; máy chủ không chạy => lỗi rõ; máy chủ chạy => thành công; mật khẩu không hiện lại', async ({ page }) => {
  await apiOk('PATCH', '/admin/config', admin, { smtp: { host: '', password: '' } })
  await loginAsAdmin(page)
  await page.goto('/settings/email')
  await settled(page)
  await expect(page.getByTestId('smtp-status')).toHaveText('Chưa cấu hình')
  await expect(page.getByTestId('smtp-banner')).toContainText('OTP chỉ ghi log')
  await expect(page.getByTestId('smtp-test')).toBeDisabled()

  // Cấu hình tới cổng không có máy chủ
  await input(page, 'smtp.host').fill('127.0.0.1')
  await input(page, 'smtp.port').fill('2599')
  await page.getByTestId('in-smtp.security').getByRole('tab', { name: 'Không mã hóa' }).click()
  await input(page, 'smtp.user').fill('no-reply@thuchi.vn')
  await input(page, 'smtp.password').fill('MatKhau-SMTP-123')
  await input(page, 'smtp.from').fill('Thu Chi <no-reply@thuchi.vn>')
  await expect(page.getByTestId('smtp-test')).toBeDisabled() // còn thay đổi chưa lưu
  await saveAndWait(page)
  await expect(page.getByTestId('smtp-status')).toHaveText('Đã cấu hình')
  await expect(page.getByTestId('smtp-banner')).toHaveCount(0)
  await expect(page.getByTestId('smtp-password-saved')).toContainText('Đã lưu')
  await expect(page.getByTestId('in-smtp.password')).toHaveCount(0)
  const raw = await apiCall('GET', '/admin/config', admin)
  expect(JSON.stringify(raw.data)).not.toContain('MatKhau-SMTP-123')

  await page.getByTestId('smtp-test').click()
  const result = page.getByTestId('smtp-result')
  await expect(result).toHaveAttribute('data-ok', 'false')
  await expect(result).toContainText('Gửi thất bại')
  await expect(result).toContainText('ECONNREFUSED')
  await expect(page.getByTestId('toast-error').filter({ hasText: 'Gửi email thử thất bại' })).toBeVisible()

  // Máy chủ SMTP giả => gửi thành công, dùng mật khẩu đã lưu (giải mã đúng)
  const smtp = await fakeSmtp()
  try {
    await input(page, 'smtp.port').fill(String(smtp.port))
    await saveAndWait(page)
    await page.getByTestId('smtp-test').click()
    await expect(result).toHaveAttribute('data-ok', 'true')
    await expect(result).toContainText('Gửi thành công')
    await expect(result).toContainText('250')
    await expect(page.getByTestId('toast-success').filter({ hasText: 'Đã gửi email thử' })).toContainText(ADMIN_EMAIL)
    expect(smtp.mails).toHaveLength(1)
    expect(smtp.mails[0].auth).toEqual({ user: 'no-reply@thuchi.vn', pass: 'MatKhau-SMTP-123' })
    expect(smtp.mails[0].raw).toContain(ADMIN_EMAIL)
    await shot(page, '11-settings-smtp-ok')
  } finally {
    await smtp.close()
  }

  // Thay mật khẩu: ô nhập hiện ra, "Giữ mật khẩu cũ" bỏ thay đổi
  await page.getByTestId('smtp-password-replace').click()
  await input(page, 'smtp.password').fill('mat-khau-moi')
  await expect(page.getByTestId('savebar-count')).toHaveText('1 thay đổi chưa lưu')
  await page.getByRole('button', { name: 'Giữ mật khẩu cũ' }).click()
  await expect(savebar(page)).toHaveCount(0)
  await expect(page.getByTestId('smtp-password-saved')).toBeVisible()
})

test('lịch sử: dòng mới nhất đúng người / cũ → mới, bí mật ẩn, lọc theo mục, phân trang', async ({ page }) => {
  const h = await apiOk<Hist>('GET', '/admin/config/history?limit=50', admin)
  expect(h.total).toBeGreaterThan(8)
  await loginAsAdmin(page)
  await page.goto('/settings/lich-su')
  await settled(page)
  await expect(page.getByRole('heading', { name: 'Lịch sử thay đổi', exact: true })).toBeVisible()
  await expect(page.getByTestId('history-chip-all')).toContainText(num(h.total))
  const rows = page.getByTestId('history-row')
  await expect(rows).toHaveCount(8)
  await expect(page.getByTestId('pagination-info')).toHaveText(`1–8 trong ${num(h.total)} thay đổi`)
  await expect(rows.first().getByTestId('history-actor')).toHaveText('Administrator')

  // Lọc Email: có dòng mật khẩu SMTP bí mật
  await page.getByTestId('history-chip-smtp').click()
  await expect(rows.first()).toBeVisible()
  const smtpRows = await rows.evaluateAll((els) => els.map((e) => e.getAttribute('data-key')))
  expect(smtpRows.every((k) => k?.startsWith('smtp.'))).toBe(true)
  const pw = page.locator('[data-testid="history-row"][data-key="smtp.password"]').first()
  await expect(pw).toContainText('Bí mật, không hiển thị')
  await expect(pw).not.toContainText('MatKhau')
  // Lọc Chung: giá trị cũ gạch ngang -> mới
  await page.getByTestId('history-chip-general').click()
  const appRow = page.locator('[data-testid="history-row"][data-key="general.appName"]').first()
  await expect(appRow.getByTestId('history-diff')).toContainText('Thu Chi E2E')
  await expect(appRow).toContainText('Chung')
  // Phân trang
  await page.getByTestId('history-chip-all').click()
  await page.getByRole('button', { name: 'Trang 2', exact: true }).click()
  await expect(page.getByTestId('pagination-info')).toContainText(`9–${Math.min(16, h.total)} trong`)
  await shot(page, '11-settings-history')
})

test('thay đổi chưa lưu: chuyển mục giữ nháp, rời trang phải xác nhận', async ({ page }) => {
  await loginAsAdmin(page)
  await page.goto('/settings')
  await settled(page)
  await input(page, 'general.hotline').fill('1900 1234')
  await openSection(page, 'nghiep-vu', 'Nghiệp vụ')
  await expect(page.getByTestId('savebar-count')).toHaveText('1 thay đổi chưa lưu')
  await expect(page.getByTestId('snav-chung').getByTestId('nav-count')).toHaveText('1')
  await openSection(page, 'chung', 'Chung')
  await expect(input(page, 'general.hotline')).toHaveValue('1900 1234')

  // Rời trang => hỏi; Hủy thì ở lại, nháp còn nguyên
  await page.getByRole('link', { name: 'Tổng quan', exact: true }).click()
  const dlg = page.getByRole('alertdialog')
  await expect(dlg).toContainText('Rời trang khi chưa lưu?')
  await expect(dlg).toContainText('1 thay đổi chưa lưu sẽ bị bỏ.')
  await dlg.getByRole('button', { name: 'Hủy' }).click()
  await expect(page).toHaveURL(/\/settings/)
  await expect(input(page, 'general.hotline')).toHaveValue('1900 1234')
  // Rời trang thật
  await page.getByRole('link', { name: 'Tổng quan', exact: true }).click()
  await page.getByRole('alertdialog').getByRole('button', { name: 'Rời trang' }).click()
  await expect(page.getByRole('heading', { name: 'Tổng quan' })).toBeVisible()
  await page.getByRole('link', { name: 'Cấu hình', exact: true }).click()
  await settled(page)
  await expect(input(page, 'general.hotline')).toHaveValue('028 7300 6868')
  await expect(savebar(page)).toHaveCount(0)
})

test('ảnh so sánh với mockup 14a–14j', async ({ page }) => {
  test.setTimeout(120_000)
  fs.mkdirSync(REAL, { recursive: true })
  const snap = async (name: string) => { await page.waitForTimeout(350); await page.screenshot({ path: path.join(REAL, `${name}.png`) }) }
  // Dữ liệu giống mockup
  await apiOk('PATCH', '/admin/config', admin, {
    general: { appName: 'Thu Chi', supportEmail: 'support@thuchi.vn', hotline: '1900 6868', termsUrl: 'https://thuchi.vn/dieu-khoan', privacyUrl: 'https://thuchi.vn/bao-mat' },
    access: { maintenanceMessage: 'Thu Chi đang nâng cấp hệ thống, dự kiến xong lúc 23:30 tối nay. Dữ liệu của bạn vẫn an toàn.', sessionDays: 30 },
    password: { minLength: 8, otpExpiryMinutes: 10, otpMaxAttempts: 5, otpResendSeconds: 60 },
    business: { budgetWarningPercent: 80, budgetExceededPercent: 100, defaultWalletName: 'Tiền mặt' },
  })
  await loginAsAdmin(page)
  await page.goto('/settings')
  await settled(page)
  await snap('14-cau-hinh-a-chung')

  // 14h: thay đổi chưa lưu + lỗi
  await input(page, 'general.supportEmail').fill('hotro@thuchi.vn')
  await input(page, 'general.hotline').fill('028 7300 6868')
  await input(page, 'general.privacyUrl').fill('http://thuchi.vn/bao-mat')
  await input(page, 'general.privacyUrl').blur()
  await page.mouse.move(0, 0)
  await snap('14-cau-hinh-h-chua-luu')
  await page.getByTestId('savebar-cancel').click()

  // 14i: hộp xác nhận bảo trì (giờ dự kiến xong = 2 giờ nữa)
  await apiOk('PATCH', '/admin/config', admin, { access: { maintenanceEndsAt: new Date(Date.now() + 2 * 3600_000).toISOString() } })
  await page.reload()
  await settled(page)
  await page.getByTestId('snav-truy-cap').click()
  await expect(page.getByTestId('endsAt-text')).toContainText(' · ')
  await page.getByTestId('maintenance-switch').click()
  await expect(page.getByTestId('maintenance-dialog')).toBeVisible()
  await snap('14-cau-hinh-i-xac-nhan-bao-tri')
  // 14b: đang bảo trì
  await page.getByTestId('maintenance-confirm').click()
  await expect(page.getByTestId('maintenance-banner')).toBeVisible()
  await page.waitForTimeout(5600) // toast tự ẩn
  await snap('14-cau-hinh-b-truy-cap-bao-tri')
  await apiOk('POST', '/admin/config/maintenance', admin, { enabled: false })

  // 14c: email đã cấu hình + gửi thử thành công (máy chủ SMTP giả)
  const smtp = await fakeSmtp()
  try {
    await apiOk('PATCH', '/admin/config', admin, { smtp: { host: '127.0.0.1', port: smtp.port, security: 'none', user: 'no-reply@thuchi.vn', password: 'MatKhau-SMTP-123', from: 'Thu Chi <no-reply@thuchi.vn>' } })
    await page.goto('/settings/email')
    await settled(page)
    await page.getByTestId('smtp-test').click()
    await expect(page.getByTestId('smtp-result')).toHaveAttribute('data-ok', 'true')
    await page.mouse.move(0, 0)
    await snap('14-cau-hinh-c-email-smtp')
  } finally {
    await smtp.close()
  }

  await page.goto('/settings/mat-khau')
  await settled(page)
  await snap('14-cau-hinh-d-mat-khau-otp')
  await page.goto('/settings/nghiep-vu')
  await settled(page)
  await snap('14-cau-hinh-e-nghiep-vu')
  await page.goto('/settings/ung-dung')
  await settled(page)
  await snap('14-cau-hinh-f-ung-dung')
  await page.goto('/settings/lich-su')
  await settled(page)
  await expect(page.getByTestId('history-row').first()).toBeVisible()
  await snap('14-cau-hinh-g-lich-su')

  // 14j: 1024×768, email chưa cấu hình
  await apiOk('PATCH', '/admin/config', admin, { smtp: { host: '', port: 587, security: 'starttls', user: '', password: '', from: '' } })
  await page.setViewportSize({ width: 1024, height: 768 })
  await page.goto('/settings/email')
  await settled(page)
  await snap('14-cau-hinh-j-email-1024')
})
