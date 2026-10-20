/** Kiểm thử không cần Ollama: npm test */
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { test } from 'node:test';
import { stripUnsupported } from '../lib/ollama.js';
import type { UserContext } from '../lib/types.js';
import { RuleBook } from '../learn/store.js';
import { analyze } from '../parser/index.js';
import { normVi } from '../parser/norm.js';
import { incomeCategory, lexiconCategory } from '../skills/ghi-giao-dich/lexicon.js';
import { validDate } from '../skills/ghi-giao-dich/pipeline.js';
import { schemaV0, schemaV1 } from '../skills/ghi-giao-dich/schema.js';

const ctx: UserContext = JSON.parse(readFileSync(new URL('../eval/user-context.json', import.meta.url), 'utf8'));
const seg = (t: string, i = 0) => analyze(t, ctx).segs[i];

// ---------- (c) luật học được khóa theo chuỗi còn dấu ----------
test('luật "cuối tuần" học từ "cà phê cuối tuần" KHÔNG bắt "đám cưới Tuấn"', () => {
  const rb = new RuleBook(3, 0.85);
  for (const t of ['cà phê cuối tuần 60k', 'cafe cuối tuần 80k', 'cà phê cuối tuần 120k']) rb.observe(seg(t), 'Giải trí');
  assert.equal(rb.match(seg('cà phê cuối tuần 90k'))?.categoryName, 'Giải trí');
  assert.equal(rb.match(seg('đi đám cưới Tuấn mừng 500k')), null);
  assert.equal(rb.match(seg('mừng cưới Tuấn 1tr')), null);
});

test('câu KHÔNG dấu thì lùi về khớp bỏ dấu', () => {
  const rb = new RuleBook(3, 0.85);
  for (const t of ['cà phê cuối tuần 60k', 'cafe cuối tuần 80k', 'cà phê cuối tuần 120k']) rb.observe(seg(t), 'Giải trí');
  const m = rb.match(seg('cafe cuoi tuan 70k'));
  assert.equal(m?.categoryName, 'Giải trí');
  assert.ok(m!.key.startsWith('~'), 'khóa lùi được đánh dấu ~');
});

test('luật học từ câu không dấu không bắt câu có dấu khác nghĩa', () => {
  const rb = new RuleBook(3, 0.85);
  for (const t of ['cafe cuoi tuan 60k', 'cf cuoi tuan 80k', 'ca phe cuoi tuan 50k']) rb.observe(seg(t), 'Giải trí');
  assert.equal(rb.match(seg('đám cưới Tuấn 500k')), null);
  assert.equal(rb.match(seg('cafe cuoi tuan 90k'))?.categoryName, 'Giải trí');
});

test('từ không có dấu sẵn ("netflix") vẫn khớp giữa câu có dấu và không dấu', () => {
  const rb = new RuleBook(3, 0.85);
  for (const t of ['netflix 260k', 'netflix 180k', 'netflix 70k']) rb.observe(seg(t), 'Giải trí');
  assert.equal(rb.match(seg('trả netflix 260k bằng momo hôm qua'))?.categoryName, 'Giải trí');
});

test('API cũ (chuỗi clean bỏ dấu) vẫn chạy', () => {
  const rb = new RuleBook(3, 0.85);
  for (let i = 0; i < 3; i++) rb.observe('tien rac', 'Hóa đơn');
  assert.equal(rb.match('tien rac')?.categoryName, 'Hóa đơn');
});

test('normVi: đặt dấu kiểu cũ/mới về một dạng', () => {
  assert.equal(normVi('Hoà'), normVi('hòa'));
  assert.equal(normVi('khoẻ'), 'khỏe');
  assert.equal(normVi('Hoàng'), 'hoàng');
});

// ---------- (d) không dùng `pattern` trong schema ----------
const walk = (x: unknown, path: string[] = []): string[] =>
  !x || typeof x !== 'object' ? [] : Object.entries(x).flatMap(([k, v]) => [...(k === 'pattern' && typeof v === 'string' ? [[...path, k].join('.')] : []), ...walk(v, [...path, k])]);

test('schema gửi Ollama không có từ khóa `pattern`', () => {
  assert.deepEqual(walk(schemaV0(ctx)), []);
  assert.deepEqual(walk(schemaV1(ctx, 3)), []);
  assert.deepEqual(walk(schemaV1(ctx, 2, [['Lương'], ['Ăn uống', 'Mua sắm']])), []);
});

test('chat() lọc `pattern` trước khi gửi, giữ thuộc tính tên "pattern"', () => {
  const s = { type: 'object', properties: { date: { type: 'string', pattern: '^\\d{4}$' }, pattern: { type: 'string' } } };
  const out = stripUnsupported(s);
  assert.deepEqual(walk(out), []);
  assert.deepEqual((out as any).properties.pattern, { type: 'string' });
  assert.equal((s.properties.date as any).pattern, '^\\d{4}$', 'không đổi object gốc');
});

test('ngày kiểm bằng code', () => {
  assert.equal(validDate('2026-10-08'), '2026-10-08');
  assert.equal(validDate('2026-02-30'), null);
  assert.equal(validDate('08/10/2026'), null);
  assert.equal(validDate(20261008), null);
});

// ---------- (b) tín hiệu thu ----------
test('tín hiệu THU → danh mục thu', () => {
  const cases: [string, string][] = [
    ['dạy guitar được 800k', 'Thu khác'], ['bán laptop cũ được 6tr', 'Thu khác'], ['cashback shopee 30k', 'Thu khác'],
    ['được chị cho 500k', 'Được tặng'], ['được lì xì 300k', 'Được tặng'], ['ba cho 1tr', 'Được tặng'],
    ['được thưởng lễ 1tr', 'Thưởng'], ['lai tiet kiem 300k', 'Đầu tư'], ['nhận lương 12tr', 'Lương'], ['dc hoan 50k', 'Thu khác'],
  ];
  for (const [t, cat] of cases) assert.equal(incomeCategory(seg(t), ctx), cat, t);
});

test('không nhầm chi thành thu', () => {
  for (const t of ['lì xì cho con chị 100k', 'ck cho bố 1tr', 'cho mẹ 2tr', 'an voi ban 120k', 'mua bàn 700k', 'trà sữa 35k'])
    assert.notEqual(seg(t).dir?.dir, 'INCOME', t);
});

// ---------- chuyển tiền / vay nợ / không nội dung → hỏi lại ----------
test('hỏi lại: chuyển giữa ví, vay nợ, không có nội dung', () => {
  for (const [t, why] of [['chuyển 1tr từ momo về mb', 'transfer'], ['rút 500k ở cây atm', 'transfer'], ['nạp 200k vào ví momo', 'transfer'],
    ['cho bạn mượn 300k', 'loan'], ['trả nợ 2tr', 'loan'], ['vay ngân hàng 50tr', 'loan'], ['500k', 'empty'], ['tiêu hết 100k', 'empty']] as const)
    assert.equal(analyze(t, ctx).ask, why, t);
  for (const t of ['ck cho mẹ 1tr bằng mb', 'nạp tiền điện thoại 50k', 'pass lại cái váy 200k', 'chợ 150k', 'được chị cho 500k'])
    assert.equal(analyze(t, ctx).ask, null, t);
});

// ---------- (a) từ điển thực phẩm ----------
test('từ điển: thực phẩm có "mua"/"chợ" → Ăn uống, đồ khác thì để model', () => {
  const cat = (t: string, i = 0) => lexiconCategory(seg(t, i), ctx)?.categoryName ?? null;
  assert.equal(cat('mua cà chua 20k'), 'Ăn uống');
  assert.equal(cat('mua thịt gà 90k ở chợ'), 'Ăn uống');
  assert.equal(cat('mua rau 20k, thịt 85k, cá 60k ở chợ hôm qua', 2), 'Ăn uống');
  assert.equal(cat('mua 2 ký cam 90k'), 'Ăn uống');
  assert.equal(cat('mua tã cho con 350k'), 'Gia đình');
  assert.equal(cat('mua thuốc cảm 65k'), 'Sức khỏe');
  assert.equal(cat('mua ốp điện thoại 90k'), null);
  assert.equal(cat('mua dầu gội 90k'), null);
  assert.equal(cat('mua ca 60k'), null, 'không dấu: "ca" nhập nhằng cá/cà');
  assert.equal(cat('bán rau ngoài chợ được 400k'), null, 'khoản thu không qua từ điển chi');
});

test('từ điển: món ăn / đồ uống làm sẵn → Ăn uống (kể cả teencode, không dấu), có từ khác thì để model', () => {
  const cat = (t: string, i = 0) => lexiconCategory(seg(t, i), ctx)?.categoryName ?? null;
  assert.equal(cat('cf 45k với cơm trưa 55k ví momo'), 'Ăn uống');
  assert.equal(cat('cf 45k với cơm trưa 55k ví momo', 1), 'Ăn uống');
  assert.equal(cat('an sang 30k'), 'Ăn uống');
  assert.equal(cat('cà phê sáng 25k'), 'Ăn uống');
  assert.equal(cat('trà sữa 35k hôm qua'), 'Ăn uống');
  assert.equal(cat('phở bò 50k'), 'Ăn uống');
  assert.equal(cat('nồi cơm điện 900k'), null);
  assert.equal(cat('mua cà phê hạt 200k'), null);
  assert.equal(cat('cafe với khách 150k'), null);
  assert.equal(cat('lau nhà 100k'), null);
});

test('ví: từ nối ("ck", "tra"…) phải đứng riêng, không cắt giữa chữ ("cashba|ck momo")', () => {
  const s = seg('cashback momo 15k');
  assert.equal(s.walletName, 'MoMo');
  assert.equal(s.clean, 'cashback');
  assert.equal(s.dir?.dir, 'INCOME');
  assert.equal(incomeCategory(s, ctx), 'Thu khác');
  assert.equal(seg('grab 38k ck mb').walletName, 'MB Bank');
});

test('"2 ký" là số lượng, không phải tiền', () => {
  const a = analyze('mua 2 ký cam 90k', ctx);
  assert.equal(a.segs.length, 1);
  assert.equal(a.segs[0].amount, 90000);
});

// ---------- so khớp từ đệm trên chuỗi còn dấu (trà/trả, đá/đã) ----------
test('"trà" không bị coi là từ đệm "trả"; "đã" là từ đệm nhưng "đá" thì không', () => {
  assert.equal(seg('trà đá 5k').norm, 'trà đá');
  assert.equal(seg('trà đá 5k').clean, 'tra da');
  assert.equal(seg('trà sữa 35k').norm, 'trà sữa');
  assert.equal(seg('đã trả tiền điện 500k').norm, 'tiền điện');
  assert.equal(seg('đá bóng 100k').norm, 'đá bóng');
  // câu không dấu: lùi về bỏ dấu, "tra sua"/"tra da" vẫn giữ (ngoại lệ), "tra 150k" thì "tra" = trả
  assert.equal(seg('tra da 5k').clean, 'tra da');
  assert.equal(seg('tra sua 35k').clean, 'tra sua');
  assert.equal(seg('tra tien dien 500k').clean, 'tien dien');
});

test('luật học từ "trà đá" khóa theo "trà đá", không theo "đá"', () => {
  const rb = new RuleBook(3, 0.85);
  for (const t of ['trà đá 5k', 'trà đá 3k', 'trà đá 10k']) rb.observe(seg(t), 'Ăn uống');
  assert.equal(rb.match(seg('trà đá 4k'))?.key, 'trà đá');
  assert.equal(rb.match(seg('đá bóng 100k')), null);
});

// ---------- hậu kiểm title ----------
import { cleanTitle } from '../skills/ghi-giao-dich/title.js';
test('title: bỏ tiền / ví / ngày do model chép vào, giữ số không phải tiền', () => {
  const s = { text: 'cà phê 45k trả momo' };
  assert.equal(cleanTitle('Cà phê 45k trả momo', s, ctx), 'Cà phê');
  assert.equal(cleanTitle('Tiền điện 1tr2 ck mb', s, ctx), 'Tiền điện');
  assert.equal(cleanTitle('Phở hôm qua 50k', s, ctx), 'Phở');
  assert.equal(cleanTitle('iPhone 15 Pro', s, ctx), 'iPhone 15 Pro');
  assert.equal(cleanTitle('Lương tháng 9', s, ctx), 'Lương tháng 9');
  assert.equal(cleanTitle('45k', { text: 'trà sữa 45k' }, ctx), 'Trà sữa');
  assert.equal(cleanTitle('', { text: 'bánh mì 20k tiền mặt' }, ctx), 'Bánh mì');
});

test('enum riêng từng khoản: schema chỉ có prefixItems, không kèm items (Ollama sẽ bỏ qua prefixItems)', () => {
  const s: any = schemaV1(ctx, 2, [['Lương'], ['Ăn uống']]);
  assert.equal(s.properties.items.items, undefined);
  assert.equal(s.properties.items.prefixItems.length, 2);
  assert.deepEqual(s.properties.items.prefixItems[0].properties.categoryName.enum, ['Lương']);
});

// ---------- số viết bằng chữ dễ nhầm ----------
import { findAmounts } from '../parser/money.js';
import { fold } from '../lib/text.js';
test('từ trông giống số không bị đọc thành tiền ("bằng", "ba mẹ", "chúc mừng", "trăm năm", "nghìn lẻ một đêm")', () => {
  const amt = (t: string) => findAmounts(fold(t)).map((x) => x.amount);
  for (const t of ['trả bằng momo', 'bằng tiền mặt', 'trả bằng zalopay', 'ba mẹ cho tiền', 'mua ba cái áo', 'chúc mừng sinh nhật', 'trăm năm hạnh phúc', 'nghìn lẻ một đêm', 'năm nay', 'bang ngan hang'])
    assert.deepEqual(amt(t), [], t);
  assert.deepEqual(amt('cà phê 45k trả bằng momo'), [45000]);
  assert.deepEqual(amt('mua cafe hạt 250k bằng zalopay'), [250000]);
  // số viết bằng chữ thật vẫn đọc được
  assert.deepEqual(amt('ba trăm'), [300000]);
  assert.deepEqual(amt('ba chục'), [30000]);
  assert.deepEqual(amt('sáu nghìn'), [6000]);
  assert.deepEqual(amt('nửa củ'), [500000]);
  assert.deepEqual(amt('trà sữa năm chục'), [50000]);
  assert.equal(analyze('mua cafe hạt 250k bằng zalopay', ctx).segs.length, 1);
});

test('"45.000đ" không làm câu không dấu thành câu có dấu', async () => {
  const { hasDiacritics } = await import('../parser/norm.js');
  assert.equal(hasDiacritics('shopee hoan tien 45.000đ'), false);
  assert.equal(hasDiacritics('an trua 45000 đồng'), false);
  assert.equal(hasDiacritics('đi chợ 45k'), true);
  assert.equal(incomeCategory(seg('shopee hoan tien 45.000đ'), ctx), 'Thu khác');
});

test('output model: chấp nhận object đơn / mảng trần (qwen3.5 bỏ lớp items khi có 1 khoản)', async () => {
  const { asItems } = await import('../skills/ghi-giao-dich/pipeline.js');
  assert.deepEqual(asItems({ title: 'Cà phê', categoryName: 'Ăn uống' }), { items: [{ title: 'Cà phê', categoryName: 'Ăn uống' }] });
  assert.deepEqual(asItems([{ title: 'a', categoryName: 'b' }]), { items: [{ title: 'a', categoryName: 'b' }] });
  assert.deepEqual(asItems({ items: [] }), { items: [] });
});
