import { chromium } from 'playwright'
const S = (n) => `/tmp/ocrdbg/m/${n}.png`
const IMG = process.argv[2]
const b = await chromium.launch(); const p = await b.newPage({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 2 })
p.on('filechooser', (fc) => fc.setFiles(IMG)); p.on('console', (m) => { if (m.type() === 'error' || /exception|error/i.test(m.text())) console.log('CONSOLE', m.text().slice(0, 300)) }); p.on('pageerror', (e) => console.log('PAGEERR', e.message.slice(0, 300)))
await p.goto('http://localhost:8090/'); await p.waitForTimeout(5000)
await p.mouse.click(195, 266); await p.keyboard.type('chinhan.ocr@test.local')
await p.mouse.click(195, 358); await p.keyboard.type('ocrtest123')
await p.mouse.click(195, 684); await p.waitForTimeout(5000)
await p.mouse.move(195, 800); await p.mouse.down(); await p.waitForTimeout(900); await p.mouse.up(); await p.waitForTimeout(1200)
await p.mouse.click(195, 600); await p.waitForTimeout(2000)
await p.screenshot({ path: S('03-sheet') })
const y = Number(process.argv[3] || 0)
if (y) {
  await p.mouse.click(195, y); await p.waitForTimeout(1500)
  await p.screenshot({ path: S('04-reading') })
  await p.waitForTimeout(32000)
  await p.screenshot({ path: S('05-result') })
  const sy = Number(process.argv[4] || 0)
  if (sy > 0) { await p.mouse.click(137, sy); await p.waitForTimeout(3500); await p.screenshot({ path: S('06-sua') }) }
}
await b.close()
