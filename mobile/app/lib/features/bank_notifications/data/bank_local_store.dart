import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../application/bank_mapping.dart';

/// Trạng thái tính năng lưu trên máy (không gửi lên máy chủ).
abstract interface class BankLocalStore {
  Future<bool> readEnabled();
  Future<void> writeEnabled(bool value);

  /// Người dùng đã đọc và đồng ý thông báo về dữ liệu (prominent disclosure) hay chưa.
  Future<bool> readConsent();
  Future<void> writeConsent(bool value);

  Future<List<PendingBankTransaction>> readPending();
  Future<void> writePending(List<PendingBankTransaction> items);

  /// Khóa đã xử lý (xác nhận / bỏ qua) → thời điểm, giữ 30 ngày để chống trùng.
  Future<Map<String, int>> readProcessed();
  Future<void> writeProcessed(Map<String, int> keys);

  /// Ngân hàng → id ví người dùng đã chọn.
  Future<Map<String, String>> readWalletMap();
  Future<void> writeWalletMap(Map<String, String> map);

  /// Xóa toàn bộ (tắt tính năng, đăng xuất).
  Future<void> clearAll();
}

class SecureBankLocalStore implements BankLocalStore {
  SecureBankLocalStore({FlutterSecureStorage? storage})
    : _s = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _s;
  static const _enabled = 'bank.enabled';
  static const _consent = 'bank.consent';
  static const _pending = 'bank.pending';
  static const _processed = 'bank.processed';
  static const _wallets = 'bank.wallets';

  Future<dynamic> _json(String key) async {
    final raw = await _s.read(key: key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> readEnabled() async => (await _s.read(key: _enabled)) == 'true';

  @override
  Future<void> writeEnabled(bool value) =>
      _s.write(key: _enabled, value: '$value');

  @override
  Future<bool> readConsent() async => (await _s.read(key: _consent)) == 'true';

  @override
  Future<void> writeConsent(bool value) =>
      _s.write(key: _consent, value: '$value');

  @override
  Future<List<PendingBankTransaction>> readPending() async {
    final list = await _json(_pending);
    if (list is! List) return [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(PendingBankTransaction.fromJson)
        .toList();
  }

  @override
  Future<void> writePending(List<PendingBankTransaction> items) => _s.write(
    key: _pending,
    value: jsonEncode(items.map((e) => e.toJson()).toList()),
  );

  @override
  Future<Map<String, int>> readProcessed() async {
    final m = await _json(_processed);
    if (m is! Map) return {};
    return m.map((k, v) => MapEntry('$k', (v as num).toInt()));
  }

  @override
  Future<void> writeProcessed(Map<String, int> keys) =>
      _s.write(key: _processed, value: jsonEncode(keys));

  @override
  Future<Map<String, String>> readWalletMap() async {
    final m = await _json(_wallets);
    if (m is! Map) return {};
    return m.map((k, v) => MapEntry('$k', '$v'));
  }

  @override
  Future<void> writeWalletMap(Map<String, String> map) =>
      _s.write(key: _wallets, value: jsonEncode(map));

  @override
  Future<void> clearAll() async {
    for (final k in [_pending, _processed, _wallets]) {
      await _s.delete(key: k);
    }
  }
}
