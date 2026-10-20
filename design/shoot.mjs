// Chụp lại ảnh mockup: node design/shoot.mjs <mockup|admin-mockup> [tiền tố data-shot]
// Mobile: phần tử .phone, 2x. Admin: phần tử .frame ở #shoot (zoom 1), 1x. Một trình duyệt, chạy tuần tự.
import { createRequire } from 'node:module'
import { fileURLToPath } from 'node:url'
import path from 'node:path'
const here = path.dirname(fileURLToPath(import.meta.url))
const { chromium } = createRequire(path.join(here, '../admin/package.json'))('playwright')
const [kind = 'mockup', prefix = ''] = process.argv.slice(2)
const mobile = kind === 'mockup'
const b = await chromium.launch()
const p = await b.newPage({ viewport: { width: 1600, height: 1000 }, deviceScaleFactor: mobile ? 2 : 1 })
await p.goto('file://' + path.join(here, kind, 'index.html') + (mobile ? '' : '#shoot'))
await p.reload() // #shoot chỉ đọc khi tải trang
await p.evaluate(() => document.fonts.ready)
await p.waitForTimeout(800)
const sel = mobile ? '.phone[data-shot]' : '.frame[data-shot]'
for (const el of await p.$$(sel)) {
  const name = await el.getAttribute('data-shot')
  if (!name.startsWith(prefix)) continue
  await el.scrollIntoViewIfNeeded()
  await el.screenshot({ path: path.join(here, kind, 'shots', name + '.png'), animations: 'disabled' })
  console.log(name)
}
await b.close()
