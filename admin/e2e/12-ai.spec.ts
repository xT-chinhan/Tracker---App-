import { expect, test } from '@playwright/test'
import { adminToken, API_URL, apiCall, apiOk, loginAsAdmin, settled, shot, state } from './helpers'

type Draft = { id: string; status: string; kind: string; result: { recipients?: number } | null }
type Conv = { id: string; messages: { role: string; draft: Draft | null }[] }

test('trợ lý AI: sidebar có nhóm Trợ lý, màn chào có gợi ý', async ({ page }) => {
  await loginAsAdmin(page)
  const nav = page.getByTestId('nav-ai')
  await expect(nav.getByRole('link', { name: 'Trợ lý AI' })).toBeVisible()
  await expect(nav.getByRole('link', { name: 'Trung tâm học' })).toBeVisible()
  await nav.getByRole('link', { name: 'Trợ lý AI' }).click()
  await expect(page).toHaveURL(/\/assistant$/)
  await expect(page.getByTestId('ai-welcome')).toBeVisible()
  await expect(page.getByTestId('ai-suggestion')).toHaveCount(4)
  await expect(page.getByTestId('ai-send')).toBeDisabled()
})

test('trợ lý AI: nháp thông báo → mở trình soạn đã điền sẵn → gửi bằng xác nhận nháp', async ({ page }) => {
  const token = await adminToken()
  const before = (await apiOk<{ total: number }>('GET', '/admin/broadcasts?limit=1', token)).total
  await loginAsAdmin(page)
  await page.goto('/assistant')
  await page.getByTestId('ai-input').fill('soạn thông báo cho tất cả người dùng về việc nâng cấp trợ lý AI tối nay')
  await page.keyboard.press('Enter')
  await expect(page).toHaveURL(/\/assistant\/[0-9a-f-]{36}$/)
  const convId = page.url().split('/').pop()!
  const card = page.getByTestId('ai-draft')
  await expect(card).toContainText('Nháp thông báo')
  await expect(page.getByTestId('ai-msg-assistant').first()).toHaveAttribute('data-skill', 'soan-thong-bao')
  // "Gửi"/"Hủy" là nút của thẻ nháp, không lặp thành chip
  await expect(page.getByTestId('ai-followup').filter({ hasText: /^Gửi$/ })).toHaveCount(0)
  await expect(page.getByTestId('ai-conv').first()).toHaveAttribute('data-title', /.+/)
  await shot(page, '12-ai-draft-broadcast')

  await page.getByTestId('ai-draft-open').click()
  await expect(page).toHaveURL(/\/broadcasts$/)
  await expect(page.getByTestId('bc-ai-note')).toBeVisible()
  await expect(page.locator('#bc-title')).not.toHaveValue('')
  const title = `Tin AI e2e ${Date.now()}`
  await page.locator('#bc-title').fill(title)
  await page.getByTestId('bc-send').click()
  await page.getByRole('alertdialog').getByRole('button', { name: 'Gửi thông báo' }).click()
  await expect(page.getByTestId('toast-success')).toContainText('Đã gửi thông báo tới')
  await expect(page.getByTestId('bc-ai-note')).toHaveCount(0)

  // Gửi đúng 1 thông báo, nháp chuyển EDITED (đã sửa tiêu đề) để trợ lý học
  expect((await apiOk<{ total: number }>('GET', '/admin/broadcasts?limit=1', token)).total).toBe(before + 1)
  const conv = await apiOk<Conv>('GET', `/ai/conversations/${convId}`, token)
  const d = conv.messages.find((m) => m.draft)!.draft!
  expect(d.status).toBe('EDITED')
  expect(d.result?.recipients).toBeGreaterThan(0)

  await page.goto(`/assistant/${convId}`)
  await expect(page.getByTestId('ai-draft')).toContainText('Đã sửa và xác nhận')
  await expect(page.getByTestId('ai-draft-open')).toHaveCount(0)
})

test('trợ lý AI: đề xuất khóa → hộp xác nhận có lý do điền sẵn → khóa qua nháp', async ({ page }) => {
  const token = await adminToken()
  const email = `ai.victim.${Date.now()}@e2e.test`
  const reg = await apiOk<{ user: { id: string } }>('POST', '/auth/register', undefined, { email, password: 'victim123', name: 'Nạn Nhân AI' })
  const id = reg.user.id
  try {
    for (let i = 0; i < 10; i++) await apiCall('POST', '/auth/login', undefined, { email, password: `sai-${i}` })
    await loginAsAdmin(page)
    await page.goto('/assistant')
    await page.getByTestId('ai-input').fill(`đề xuất khóa tài khoản ${email}`)
    await page.getByTestId('ai-send').click()
    const card = page.getByTestId('ai-draft')
    await expect(card).toContainText('Đề xuất khóa')
    await expect(card).toContainText(email)
    await page.getByTestId('ai-draft-lock').click()
    const dialog = page.getByTestId('ai-lock-dialog')
    await expect(dialog).toContainText('Khóa tài khoản Nạn Nhân AI?')
    await expect(dialog).toContainText('Trợ lý AI')
    await expect(page.getByTestId('ai-lock-reason')).toHaveValue(/đăng nhập sai/)
    await shot(page, '12-ai-lock-dialog')
    await page.getByTestId('ai-lock-reason').fill('Đăng nhập sai liên tục (e2e)')
    await page.getByTestId('ai-lock-confirm').click()
    await expect(page.getByTestId('toast-success')).toContainText('Đã khóa')
    expect((await apiOk<{ status: string }>('GET', `/admin/users/${id}`, token)).status).toBe('LOCKED')
    await expect(page.getByTestId('ai-draft-lock')).toHaveCount(0)
  } finally {
    await apiCall('PATCH', `/admin/users/${id}`, token, { status: 'ACTIVE' })
  }
})

test('trợ lý AI: lưu trữ / khôi phục / xóa cuộc trò chuyện', async ({ page }) => {
  const token = await adminToken()
  const c = await apiOk<{ id: string }>('POST', '/ai/conversations', token, { title: 'Cuộc để dọn e2e' })
  await loginAsAdmin(page)
  await page.goto(`/assistant/${c.id}`)
  await expect(page.getByTestId('ai-chat-title')).toHaveText('Cuộc để dọn e2e')
  await page.getByTestId('ai-chat-menu').click()
  await page.getByRole('menuitem', { name: 'Lưu trữ' }).click()
  await expect(page).toHaveURL(/\/assistant$/)
  await expect(page.locator('[data-testid=ai-conv][data-title="Cuộc để dọn e2e"]')).toHaveCount(0)
  await page.getByTestId('ai-archived').click()
  const row = page.locator('[data-testid=ai-conv][data-title="Cuộc để dọn e2e"]')
  await expect(row).toBeVisible()
  await row.hover()
  await row.getByTestId('ai-conv-menu').click()
  await page.getByRole('menuitem', { name: 'Xóa' }).click()
  await page.getByRole('alertdialog').getByRole('button', { name: 'Xóa' }).click()
  await expect(page.getByTestId('toast-success').filter({ hasText: 'Đã xóa cuộc trò chuyện' })).toBeVisible()
  expect((await apiCall('GET', `/ai/conversations/${c.id}`, token)).status).toBe(404)
})

test('cấu hình › trợ lý AI: tắt trợ lý = tắt ở Nghiệp vụ, chat bị khóa, không đăng xuất', async ({ page }) => {
  const token = await adminToken()
  try {
    await loginAsAdmin(page)
    await page.goto('/settings/tro-ly')
    await settled(page)
    await expect(page.getByTestId('ai-status')).toHaveText('Đang chạy')
    await page.getByTestId('in-ai.enabled').click()
    await expect(page.getByTestId('savebar-count')).toHaveText('1 thay đổi chưa lưu')
    await page.getByTestId('savebar-save').click()
    await expect(page.getByTestId('toast-success')).toContainText('Đã lưu cấu hình')
    await expect(page.getByTestId('ai-status')).toHaveText('Đang tắt')
    const cfg = await apiOk<{ values: { ai: { enabled: boolean }; business: { featureAi: boolean } } }>('GET', '/admin/config', token)
    expect([cfg.values.ai.enabled, cfg.values.business.featureAi]).toEqual([false, false])

    await page.getByTestId('snav-nghiep-vu').click()
    await expect(page.getByTestId('in-ai.enabled')).toHaveAttribute('aria-checked', 'false')

    await page.goto('/assistant')
    await expect(page.getByTestId('ai-disabled')).toBeVisible()
    await expect(page.getByTestId('ai-input')).toBeDisabled()
    // 403 FEATURE_DISABLED của API trợ lý không làm admin bị đăng xuất
    const r = await page.evaluate(async (api) => {
      const t = localStorage.getItem('admin.token')
      const res = await fetch(`${api}/ai/conversations`, { method: 'POST', headers: { Authorization: `Bearer ${t}`, 'Content-Type': 'application/json' }, body: '{}' })
      return res.status
    }, API_URL)
    expect(r).toBe(403)
    // Gọi qua client của trang (cùng hàm request) cũng không đăng xuất
    await page.getByTestId('ai-new').click()
    await expect(page).toHaveURL(/\/assistant$/)
    expect(await page.evaluate(() => localStorage.getItem('admin.token'))).not.toBeNull()
  } finally {
    await apiOk('PATCH', '/admin/config', token, { ai: { enabled: true } })
  }
})

test('cấu hình › trợ lý AI: kiểm tra kết nối báo lỗi rõ khi sai địa chỉ', async ({ page }) => {
  await loginAsAdmin(page)
  await page.goto('/settings/tro-ly')
  await settled(page)
  await page.getByTestId('provider-ollama').click()
  await page.getByTestId('in-ai.ollamaUrl').fill('http://127.0.0.1:9')
  await page.getByTestId('ollama-test').click()
  await expect(page.getByTestId('ollama-result')).toContainText('Không kết nối được')
  await page.getByTestId('in-ai.ollamaUrl').fill('localhost')
  await expect(page.getByTestId('row-ai.ollamaUrl').getByTestId('field-error')).toHaveText('Link phải bắt đầu bằng http:// hoặc https://')
  await expect(page.getByTestId('savebar-save')).toBeDisabled()
  await page.getByTestId('savebar-cancel').click()
  await shot(page, '12-ai-settings')
})

test('trung tâm học: KPI, biểu đồ / bảng, đề xuất, lượt chạy đêm', async ({ page }) => {
  const token = await adminToken()
  await apiOk('POST', '/admin/ai/learning/run', token)
  await loginAsAdmin(page)
  await page.getByTestId('nav-ai').getByRole('link', { name: 'Trung tâm học' }).click()
  await expect(page.getByRole('heading', { name: 'Trung tâm học' })).toBeVisible()
  await expect(page.getByTestId('privacy-note')).toBeVisible()
  for (const k of ['kpi-accept', 'kpi-messages', 'kpi-latency', 'kpi-asks']) await expect(page.getByTestId(k)).toBeVisible()
  // Các test trước đã xác nhận nháp → biểu đồ có dữ liệu, chuyển được sang dạng bảng
  await expect(page.getByTestId('acceptance-chart')).toBeVisible()
  await page.getByTestId('acceptance-toggle').click()
  await expect(page.getByTestId('acceptance-table')).toContainText('Soạn thông báo')
  await expect(page.getByTestId('proposals-card')).toBeVisible()
  await shot(page, '12-ai-learning')

  await page.getByTestId('tab-runs').click()
  await expect(page).toHaveURL(/\/learning\/luot-chay$/)
  await expect(page.getByTestId('run-row').first()).toContainText('Chạy tay')
  await expect(page.getByTestId('run-detail')).toContainText('Luật chung')
})

test('trung tâm học: tab Đọc ảnh chỉ có số tổng hợp; cấu hình có thẻ Đọc ảnh', async ({ page }) => {
  await loginAsAdmin(page)
  await page.goto('/learning')
  await page.getByTestId('tab-ocr').click()
  await expect(page).toHaveURL(/\/learning\/doc-anh$/)
  await expect(page.getByTestId('privacy-note')).toContainText('Ảnh bị xóa ngay sau khi đọc')
  for (const k of ['ocr-kpi-total', 'ocr-kpi-accept', 'ocr-kpi-latency', 'ocr-kpi-unreadable', 'ocr-daily-card', 'ocr-reasons-card']) await expect(page.getByTestId(k)).toBeVisible()
  await page.goto('/settings/tro-ly')
  await expect(page.getByTestId('row-ai.ocrEnabled')).toBeVisible()
  await expect(page.getByTestId('ocr-store')).toContainText('Không lưu')
  await expect(page.getByTestId('row-ai.ocrDailyLimitPerUser').locator('input')).toHaveValue('20')
})

test('chi tiết người dùng: thẻ Trợ lý AI chỉ có số đếm', async ({ page }) => {
  const token = await adminToken()
  const me = await apiOk<{ id: string }>('GET', '/me', token)
  await loginAsAdmin(page)
  await page.goto(`/users/${me.id}`)
  const card = page.getByTestId('ai-usage-card')
  await expect(card).toContainText('Tin nhắn')
  await expect(card).toContainText('Xác nhận không sửa')
  await expect(card).toContainText('Không hiển thị nội dung tin nhắn')
  await page.goto(`/users/${state().users.an.id}`)
  await expect(page.getByTestId('ai-usage-card')).toBeVisible()
})
