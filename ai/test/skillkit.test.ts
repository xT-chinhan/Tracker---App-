/** Kiểm thử không cần Ollama: npm test */
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { checkSentence, moneyShort } from '../lib/skillkit.js';

test('câu model viết: chặn khuôn mẫu chưa điền', () => {
  assert.equal(checkSentence('Cấu hình cần cập nhật, các thay đổi nhỏ như [nhập thông tin thay đổi]'), 'có chỗ trống chưa điền');
  assert.equal(checkSentence('Xin chào {tên}, hệ thống ổn định'), 'có chỗ trống chưa điền');
  assert.equal(checkSentence('Hệ thống hoạt động ổn định, chưa thấy biến động lớn.'), null);
});

test('tiền gọn cho thẻ số liệu', () => {
  assert.equal(moneyShort(853654000), '853,7 tr');
  assert.equal(moneyShort(13679739000), '13,68 tỷ');
  assert.equal(moneyShort(45000), '45.000đ');
});
