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

  /// Số tiền / loại / thời điểm của khoản đã xử lý (khóa như [readProcessed]), để chống trùng app ngân hàng + SMS.
  Future<Map<String, ProcessedBankTransaction>> readProcessedMeta();
  Future<void> writeProcessedMeta(Map<String, ProcessedBankTransaction> meta);

  /// Ngân hàng → id ví người dùng đã chọn.
  Future<Map<String, String>> readWalletMap();
  Future<void> writeWalletMap(Map<String, String> map);

  /// Tự động ghi vào sổ (theo từng máy, mặc định tắt).
  Future<bool> readAutoRecord();
  Future<void> writeAutoRecord(bool value);

  /// Ngưỡng "Khoản lớn chờ xác nhận" (đồng); 0 = Tắt; chưa đặt = 5.000.000đ.
  Future<int> readThreshold();
  Future<void> writeThreshold(int value);

  /// Khoản app đã tự ghi (giữ 30 ngày).
  Future<List<AutoRecordedTransaction>> readAutoRecorded();
  Future<void> writeAutoRecorded(List<AutoRecordedTransaction> items);

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
  static const _autoRecord = 'bank.autoRecord';
  static const _threshold = 'bank.threshold';
  static const _autoRecorded = 'bank.autoRecorded';
  static const _processedMeta = 'bank.processedMeta';

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
  Future<Map<String, ProcessedBankTransaction>> readProcessedMeta() async {
    final m = await _json(_processedMeta);
    if (m is! Map) return {};
    final out = <String, ProcessedBankTransaction>{};
    for (final e in m.entries) {
      final p = ProcessedBankTransaction.fromJson('${e.key}', e.value);
      if (p != null) out[p.key] = p;
    }
    return out;
  }

  @override
  Future<void> writeProcessedMeta(Map<String, ProcessedBankTransaction> meta) =>
      _s.write(
        key: _processedMeta,
        value: jsonEncode(meta.map((k, v) => MapEntry(k, v.toJson()))),
      );

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
  Future<bool> readAutoRecord() async =>
      (await _s.read(key: _autoRecord)) == 'true';

  @override
  Future<void> writeAutoRecord(bool value) =>
      _s.write(key: _autoRecord, value: '$value');

  @override
  Future<int> readThreshold() async {
    final raw = await _s.read(key: _threshold);
    return raw == null
        ? defaultAutoRecordThreshold
        : int.tryParse(raw) ?? defaultAutoRecordThreshold;
  }

  @override
  Future<void> writeThreshold(int value) =>
      _s.write(key: _threshold, value: '$value');

  @override
  Future<List<AutoRecordedTransaction>> readAutoRecorded() async {
    final list = await _json(_autoRecorded);
    if (list is! List) return [];
    final out = <AutoRecordedTransaction>[];
    for (final e in list.whereType<Map<String, dynamic>>()) {
      try {
        out.add(AutoRecordedTransaction.fromJson(e));
      } catch (_) {}
    }
    return out;
  }

  @override
  Future<void> writeAutoRecorded(List<AutoRecordedTransaction> items) =>
      _s.write(
        key: _autoRecorded,
        value: jsonEncode(items.map((e) => e.toJson()).toList()),
      );

  @override
  Future<void> clearAll() async {
    for (final k in [
      _pending,
      _processed,
      _processedMeta,
      _wallets,
      _autoRecord,
      _autoRecorded,
    ]) {
      await _s.delete(key: k);
    }
  }
}
