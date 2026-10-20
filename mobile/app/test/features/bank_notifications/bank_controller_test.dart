import 'dart:async';

import 'package:app/core/config/public_config.dart';
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
  Future<void> clearAll() async {
    pending = [];
    processed = {};
    wallets = {};
  }
}

void main() {
  late _FakeBridge bridge;
  late _MemoryStore store;
  late ProviderContainer c;

  setUp(() {
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
}
