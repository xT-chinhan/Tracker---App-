import 'dart:async';

import 'package:dio/dio.dart';

import 'package:app/core/config/public_config.dart';
import 'package:app/core/network/network_providers.dart';
import 'package:app/features/notifications/application/balance_undo.dart';
import 'package:app/features/auth/application/app_session.dart';
import 'package:app/features/bank_notifications/application/bank_mapping.dart';
import 'package:app/features/bank_notifications/application/bank_notifications_controller.dart';
import 'package:app/features/bank_notifications/data/bank_local_store.dart';
import 'package:app/features/bank_notifications/data/bank_notification_bridge.dart';
import 'package:app/features/bank_notifications/data/mock_bank_samples.dart';
import 'package:app/features/bank_notifications/data/raw_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

class _FakeBridge extends BankNotificationBridge {
  final live = StreamController<RawNotification>.broadcast();
  List<RawNotification> saved = [];
  bool? enabled;
  var cleared = 0;

  @override
  Stream<RawNotification> get stream => live.stream;
  @override
  Future<bool> isPermissionGranted() async => true;
  @override
  Future<bool> isIgnoringBatteryOptimizations() async => true;
  @override
  Future<void> setEnabled(bool value) async => enabled = value;
  @override
  Future<List<RawNotification>> getSaved() async => List.of(saved);
  @override
  Future<void> clearSaved() async {
    cleared++;
    saved = [];
  }
}

class _MemoryStore implements BankLocalStore {
  bool enabled = false, consent = false;
  List<PendingBankTransaction> pending = [];
  Map<String, int> processed = {};
  Map<String, String> wallets = {};
  bool autoRecord = false;
  int threshold = defaultAutoRecordThreshold;
  List<AutoRecordedTransaction> autoRecorded = [];
  Map<String, ProcessedBankTransaction> processedMeta = {};

  @override
  Future<bool> readEnabled() async => enabled;
  @override
  Future<void> writeEnabled(bool v) async => enabled = v;
  @override
  Future<bool> readConsent() async => consent;
  @override
  Future<void> writeConsent(bool v) async => consent = v;
  @override
  Future<List<PendingBankTransaction>> readPending() async => List.of(pending);
  @override
  Future<void> writePending(List<PendingBankTransaction> v) async =>
      pending = List.of(v);
  @override
  Future<Map<String, int>> readProcessed() async => Map.of(processed);
  @override
  Future<void> writeProcessed(Map<String, int> v) async =>
      processed = Map.of(v);
  @override
  Future<Map<String, String>> readWalletMap() async => Map.of(wallets);
  @override
  Future<void> writeWalletMap(Map<String, String> v) async =>
      wallets = Map.of(v);
  @override
  Future<Map<String, ProcessedBankTransaction>> readProcessedMeta() async =>
      Map.of(processedMeta);
  @override
  Future<void> writeProcessedMeta(
    Map<String, ProcessedBankTransaction> v,
  ) async => processedMeta = Map.of(v);
  @override
  Future<bool> readAutoRecord() async => autoRecord;
  @override
  Future<void> writeAutoRecord(bool v) async => autoRecord = v;
  @override
  Future<int> readThreshold() async => threshold;
  @override
  Future<void> writeThreshold(int v) async => threshold = v;
  @override
  Future<List<AutoRecordedTransaction>> readAutoRecorded() async =>
      List.of(autoRecorded);
  @override
  Future<void> writeAutoRecorded(List<AutoRecordedTransaction> v) async =>
      autoRecorded = List.of(v);
  @override
  Future<void> clearAll() async {
    pending = [];
    processed = {};
    processedMeta = {};
    wallets = {};
    autoRecord = false;
    autoRecorded = [];
  }
}

class _MemoryUndone implements UndoneStore {
  Set<String> ids = {};
  @override
  Future<Set<String>> read() async => Set.of(ids);
  @override
  Future<void> write(Set<String> v) async => ids = Set.of(v);
}

/// Máy chủ giả: danh mục, ví, ghi giao dịch.
class _FakeServer {
  final posts = <Map<String, dynamic>>[];
  var failPosts = false;

  Dio dio() {
    final dio = Dio(BaseOptions(baseUrl: 'http://fake/api/'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) {
          Response<dynamic> ok(Object? data, [int code = 200]) =>
              Response<dynamic>(
                requestOptions: o,
                data: data,
                statusCode: code,
              );
          if (o.method == 'GET' && o.path == 'categories') {
            return h.resolve(
              ok([
                {'id': 'c-food', 'name': 'Ăn uống', 'type': 'EXPENSE'},
                {'id': 'c-other', 'name': 'Chi khác', 'type': 'EXPENSE'},
                {'id': 'c-in', 'name': 'Thu khác', 'type': 'INCOME'},
              ]),
            );
          }
          if (o.method == 'GET' && o.path == 'wallets') {
            return h.resolve(
              ok({
                'totalBalance': 0,
                'items': [
                  {'id': 'w-mb', 'name': 'MB Bank', 'type': 'BANK'},
                ],
              }),
            );
          }
          if (o.method == 'POST' && o.path == 'transactions') {
            if (failPosts) {
              return h.reject(
                DioException(
                  requestOptions: o,
                  response: Response<dynamic>(
                    requestOptions: o,
                    statusCode: 500,
                  ),
                  type: DioExceptionType.badResponse,
                ),
              );
            }
            posts.add(Map<String, dynamic>.from(o.data as Map));
            return h.resolve(ok({'id': 'tx-${posts.length}'}, 201));
          }
          return h.reject(
            DioException(
              requestOptions: o,
              response: Response<dynamic>(requestOptions: o, statusCode: 404),
              type: DioExceptionType.badResponse,
            ),
          );
        },
      ),
    );
    return dio;
  }
}

RawNotification _copy(
  RawNotification n, {
  String? id,
  String? packageName,
  int shiftMs = 0,
}) => RawNotification(
  id: id ?? '${n.id}-copy',
  packageName: packageName ?? n.packageName,
  title: n.title,
  text: n.text,
  subText: n.subText,
  timestamp: n.timestamp + shiftMs,
  isBankNotification: n.isBankNotification,
);

void main() {
  late _FakeBridge bridge;
  late _MemoryStore store;
  late ProviderContainer c;
  late _FakeServer server;

  setUp(() {
    server = _FakeServer();
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    bridge = _FakeBridge();
    store = _MemoryStore()..enabled = true;
    final session = AppSessionController()
      ..config = publicConfigFixture().copyWith(
        features: const FeatureConfig(bankNotifications: true),
      );
    c = ProviderContainer(
      overrides: [
        bankNotificationBridgeProvider.overrideWithValue(bridge),
        bankLocalStoreProvider.overrideWithValue(store),
        appSessionProvider.overrideWithValue(session),
        dioProvider.overrideWithValue(server.dio()),
        undoneStoreProvider.overrideWithValue(_MemoryUndone()),
      ],
    );
  });

  tearDown(() {
    c.dispose();
    debugDefaultTargetPlatformOverride = null;
  });

  test('lấy thông báo giữ lúc app đóng rồi xóa bộ đệm phía Android', () async {
    bridge.saved = [
      MockBankSamples.vietcombankDebit,
      MockBankSamples.momoPayment,
    ];
    await c.read(bankNotificationsProvider.notifier).sync();
    expect(c.read(bankNotificationsProvider).pending, hasLength(2));
    expect(bridge.cleared, 1);
    expect(store.pending, hasLength(2));
  });

  test(
    'nhiều thông báo đến cùng lúc: giữ đủ, không ghi đè nhau, không trùng',
    () async {
      final ctrl = c.read(bankNotificationsProvider.notifier);
      await ctrl.sync();
      final samples = MockBankSamples.bankSamples;
      for (final n in [...samples, ...samples]) {
        bridge.live.add(n);
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final keys = c
          .read(bankNotificationsProvider)
          .pending
          .map((p) => p.key)
          .toSet();
      expect(c.read(bankNotificationsProvider).pending.length, keys.length);
      expect(keys.length, greaterThanOrEqualTo(samples.length - 2));
    },
  );

  test('admin tắt tính năng → dừng, xóa dữ liệu chờ', () async {
    bridge.saved = [MockBankSamples.vietcombankDebit];
    await c.read(bankNotificationsProvider.notifier).sync();
    c.read(appSessionProvider).config = publicConfigFixture();
    await c.read(bankNotificationsProvider.notifier).sync();
    expect(c.read(bankNotificationsProvider).pending, isEmpty);
    expect(bridge.enabled, isFalse);
    expect(store.pending, isEmpty);
  });

  test('bỏ qua một khoản thì khoản đó không quay lại', () async {
    bridge.saved = [MockBankSamples.vietcombankDebit];
    final ctrl = c.read(bankNotificationsProvider.notifier);
    await ctrl.sync();
    await ctrl.skip(c.read(bankNotificationsProvider).pending.single);
    bridge.saved = [MockBankSamples.vietcombankDebit];
    await ctrl.sync();
    expect(c.read(bankNotificationsProvider).pending, isEmpty);
  });

  test('đăng xuất → tắt và xóa dữ liệu chờ trên máy', () async {
    bridge.saved = [MockBankSamples.vietcombankDebit];
    await c.read(bankNotificationsProvider.notifier).sync();
    c.read(appSessionProvider).unauthenticate();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(store.enabled, isFalse);
    expect(store.pending, isEmpty);
    expect(bridge.enabled, isFalse);
  });

  test(
    'cùng một khoản báo qua app ngân hàng và SMS trong 3 phút: chỉ giữ một',
    () async {
      final push = MockBankSamples.mbbankDebit;
      bridge.saved = [
        push,
        _copy(
          push,
          packageName: 'com.google.android.apps.messaging',
          shiftMs: 90000,
        ),
      ];
      await c.read(bankNotificationsProvider.notifier).sync();
      expect(c.read(bankNotificationsProvider).pending, hasLength(1));
      expect(
        c.read(bankNotificationsProvider).pending.single.packageName,
        push.packageName,
      );
    },
  );

  test(
    'tự động ghi: khoản đủ ví + danh mục được ghi, khoản thiếu ví vẫn chờ',
    () async {
      store.autoRecord = true;
      bridge.saved = [
        MockBankSamples.mbbankDebit,
        MockBankSamples.vietcombankDebit,
      ];
      await c.read(bankNotificationsProvider.notifier).sync();
      final st = c.read(bankNotificationsProvider);
      expect(server.posts, hasLength(1));
      expect(server.posts.single['source'], 'bank_auto');
      expect(server.posts.single['walletId'], 'w-mb');
      expect(st.autoRecorded, hasLength(1));
      expect(st.autoRecorded.single.transactionId, 'tx-1');
      expect(server.posts.single['externalRef'], st.autoRecorded.single.key);
      expect(st.pending, hasLength(1));
      expect(
        c
            .read(bankNotificationsProvider.notifier)
            .blockReason(st.pending.single),
        startsWith('Chưa chọn ví cho'),
      );
      expect(store.autoRecorded, hasLength(1));
      // SMS của chính khoản đã tự ghi đến sau: không ghi lần hai
      bridge.saved = [
        _copy(
          MockBankSamples.mbbankDebit,
          packageName: 'com.google.android.apps.messaging',
          shiftMs: 60000,
        ),
      ];
      await c.read(bankNotificationsProvider.notifier).sync();
      expect(server.posts, hasLength(1));
      expect(c.read(bankNotificationsProvider).pending, hasLength(1));
      // chờ Trang chủ tải lại xong (gọi sau khi tự ghi) trước khi hủy container
      await Future<void>.delayed(const Duration(milliseconds: 50));
    },
  );

  test('tự động ghi: lỗi máy chủ → để lại trong Chờ xác nhận', () async {
    store.autoRecord = true;
    server.failPosts = true;
    bridge.saved = [MockBankSamples.mbbankDebit];
    await c.read(bankNotificationsProvider.notifier).sync();
    expect(c.read(bankNotificationsProvider).autoRecorded, isEmpty);
    expect(c.read(bankNotificationsProvider).pending, hasLength(1));
  });

  test('tắt tự động ghi: không gọi máy chủ khi nhận thông báo', () async {
    bridge.saved = [MockBankSamples.mbbankDebit];
    await c.read(bankNotificationsProvider.notifier).sync();
    expect(server.posts, isEmpty);
    expect(c.read(bankNotificationsProvider).pending, hasLength(1));
  });

  test(
    'push đã xác nhận tay → SMS cùng số tiền đến sau 1 phút: không thêm vào chờ',
    () async {
      final push = MockBankSamples.mbbankDebit;
      bridge.saved = [push];
      final ctrl = c.read(bankNotificationsProvider.notifier);
      await ctrl.sync();
      await ctrl.loadReferences();
      final t = c.read(bankNotificationsProvider).pending.single;
      final err = await ctrl.confirm(
        t,
        category: ctrl.categoryFor(t)!,
        wallet: ctrl.walletFor(t)!,
      );
      expect(err, isNull);
      expect(server.posts.single['source'], 'bank_manual');
      expect(server.posts.single['externalRef'], t.key);
      expect(store.processedMeta.keys, contains(t.key));
      bridge.saved = [
        _copy(
          push,
          packageName: 'com.google.android.apps.messaging',
          shiftMs: 60000,
        ),
      ];
      await ctrl.sync();
      expect(c.read(bankNotificationsProvider).pending, isEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 50));
    },
  );

  test('khoản đã bỏ qua cũng chặn bản SMS trùng trong 3 phút', () async {
    final push = MockBankSamples.mbbankDebit;
    bridge.saved = [push];
    final ctrl = c.read(bankNotificationsProvider.notifier);
    await ctrl.sync();
    await ctrl.skip(c.read(bankNotificationsProvider).pending.single);
    bridge.saved = [
      _copy(
        push,
        packageName: 'com.google.android.apps.messaging',
        shiftMs: 90000,
      ),
    ];
    await ctrl.sync();
    expect(c.read(bankNotificationsProvider).pending, isEmpty);
  });
}
