import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../auth/application/app_session.dart';
import '../../categories/data/category_models.dart';
import '../../categories/data/category_repository.dart';
import '../../history/application/history_service.dart';
import '../../home/application/home_service.dart';
import '../../wallets/data/wallet_models.dart';
import '../../wallets/data/wallet_repository.dart';
import '../data/bank_local_store.dart';
import '../data/bank_notification_bridge.dart';
import '../data/bank_notification_parser.dart';
import '../data/raw_notification.dart';
import 'bank_mapping.dart';

final bankNotificationBridgeProvider = Provider<BankNotificationBridge>(
  (ref) => BankNotificationBridge(),
);
final bankLocalStoreProvider = Provider<BankLocalStore>(
  (ref) => SecureBankLocalStore(),
);

class BankNotificationsState {
  const BankNotificationsState({
    this.loaded = false,
    this.enabled = false,
    this.consent = false,
    this.permissionGranted = false,
    this.batteryUnrestricted = false,
    this.pending = const [],
    this.categories = const [],
    this.wallets = const [],
    this.walletMap = const {},
    this.busy = false,
    this.error,
  });

  final bool loaded;

  /// Người dùng bật trong Cài đặt của app.
  final bool enabled;
  final bool consent;
  final bool permissionGranted;
  final bool batteryUnrestricted;
  final List<PendingBankTransaction> pending;
  final List<CategoryItem> categories;
  final List<WalletItem> wallets;
  final Map<String, String> walletMap;
  final bool busy;
  final String? error;

  /// Đang thực sự đọc thông báo.
  bool get active => enabled && permissionGranted;

  BankNotificationsState copyWith({
    bool? loaded,
    bool? enabled,
    bool? consent,
    bool? permissionGranted,
    bool? batteryUnrestricted,
    List<PendingBankTransaction>? pending,
    List<CategoryItem>? categories,
    List<WalletItem>? wallets,
    Map<String, String>? walletMap,
    bool? busy,
    String? error,
    bool clearError = false,
  }) => BankNotificationsState(
    loaded: loaded ?? this.loaded,
    enabled: enabled ?? this.enabled,
    consent: consent ?? this.consent,
    permissionGranted: permissionGranted ?? this.permissionGranted,
    batteryUnrestricted: batteryUnrestricted ?? this.batteryUnrestricted,
    pending: pending ?? this.pending,
    categories: categories ?? this.categories,
    wallets: wallets ?? this.wallets,
    walletMap: walletMap ?? this.walletMap,
    busy: busy ?? this.busy,
    error: clearError ? null : error ?? this.error,
  );
}

final bankNotificationsProvider =
    NotifierProvider<BankNotificationsController, BankNotificationsState>(
      BankNotificationsController.new,
    );

/// Công tắc quản trị (`features.bankNotifications`) + chỉ Android.
bool bankFeatureAvailable(Ref ref) =>
    bankNotificationsSupported &&
    (ref.read(appSessionProvider).config?.features.bankNotifications ?? false);

class BankNotificationsController extends Notifier<BankNotificationsState> {
  StreamSubscription<RawNotification>? _sub;

  /// Xử lý thông báo tuần tự: nhiều thông báo đến cùng lúc không được ghi đè danh sách chờ của nhau.
  Future<void> _queue = Future.value();

  BankNotificationBridge get _bridge =>
      ref.read(bankNotificationBridgeProvider);
  BankLocalStore get _store => ref.read(bankLocalStoreProvider);

  @override
  BankNotificationsState build() {
    // Đăng xuất / xóa tài khoản: tắt phía Android và xóa mọi dữ liệu chờ trên máy
    final session = ref.read(appSessionProvider);
    void onSession() {
      if (session.status == AppSessionStatus.unauthenticated && state.enabled) {
        setEnabled(false).ignore();
      }
    }

    session.addListener(onSession);
    ref.onDispose(() {
      session.removeListener(onSession);
      _sub?.cancel();
    });
    return const BankNotificationsState();
  }

  /// Gọi khi app mở / quay lại foreground. Admin tắt tính năng → dừng và xóa dữ liệu chờ.
  Future<void> sync() async {
    if (!bankFeatureAvailable(ref)) {
      if (state.enabled) await setEnabled(false);
      state = state.copyWith(loaded: true);
      return;
    }
    final enabled = await _store.readEnabled();
    state = state.copyWith(
      loaded: true,
      enabled: enabled,
      consent: await _store.readConsent(),
      pending: await _store.readPending(),
      walletMap: await _store.readWalletMap(),
      permissionGranted: await _bridge.isPermissionGranted(),
      batteryUnrestricted: await _bridge.isIgnoringBatteryOptimizations(),
    );
    if (!state.enabled) return;
    await _bridge.setEnabled(true);
    await _ingest(await _bridge.getSaved());
    await _bridge.clearSaved();
    _sub ??= _bridge.stream.listen((n) => _ingest([n]));
  }

  Future<void> giveConsent() async {
    await _store.writeConsent(true);
    state = state.copyWith(consent: true);
  }

  Future<void> setEnabled(bool value) async {
    await _store.writeEnabled(value);
    await _bridge.setEnabled(value);
    if (!value) {
      await _sub?.cancel();
      _sub = null;
      await _bridge.clearSaved();
      await _store.clearAll();
      state = state.copyWith(enabled: false, pending: [], walletMap: {});
      return;
    }
    state = state.copyWith(enabled: true);
    await sync();
  }

  Future<void> openPermissionSettings() => _bridge.openPermissionSettings();
  Future<void> openAppDetails() => _bridge.openAppDetails();
  Future<void> openBatterySettings() => _bridge.openBatterySettings();

  /// Bóc tách, bỏ khoản trùng / đã xử lý, thêm vào danh sách chờ.
  Future<void> _ingest(List<RawNotification> raws) =>
      _serial(() => _ingestNow(raws));

  /// Chạy lần lượt mọi thao tác đọc-sửa-ghi danh sách chờ.
  Future<void> _serial(Future<void> Function() task) =>
      _queue = _queue.then((_) => task()).catchError((_) {});

  Future<void> _ingestNow(List<RawNotification> raws) async {
    if (raws.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final processed = await _store.readProcessed()
      ..removeWhere((_, at) => now - at > 30 * 86400000);
    final pending = [...state.pending];
    final seen = {...processed.keys, ...pending.map((p) => p.key)};
    for (final raw in raws) {
      final parsed = BankNotificationParser.parse(raw);
      if (parsed == null) continue;
      final item = toPending(parsed, packageName: raw.packageName);
      if (item == null || !seen.add(item.key)) continue;
      pending.insert(0, item);
    }
    pending.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    await _store.writeProcessed(processed);
    await _store.writePending(pending);
    state = state.copyWith(pending: pending);
  }

  /// Danh mục + ví để ghép khi xác nhận.
  Future<void> loadReferences() async {
    try {
      final cats = await ref.read(categoryRepositoryProvider).getCategories();
      final wallets = await ref.read(walletRepositoryProvider).getWallets();
      state = state.copyWith(
        categories: cats,
        wallets: wallets.items,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        error: 'Không tải được danh mục / ví. Kéo xuống để thử lại.',
      );
    }
  }

  CategoryItem? categoryFor(PendingBankTransaction t) =>
      pickCategory(state.categories, t);
  WalletItem? walletFor(PendingBankTransaction t) =>
      pickWallet(state.wallets, t, state.walletMap);

  Future<void> _markProcessed(Iterable<PendingBankTransaction> items) {
    final keys = items.map((e) => e.key).toSet();
    return _serial(() => _removePending(keys));
  }

  Future<void> _removePending(Set<String> keys) async {
    final processed = await _store.readProcessed();
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final k in keys) {
      processed[k] = now;
    }
    final pending = state.pending.where((p) => !keys.contains(p.key)).toList();
    await _store.writeProcessed(processed);
    await _store.writePending(pending);
    state = state.copyWith(pending: pending);
  }

  Future<void> rememberWallet(String bank, String walletId) async {
    final map = {...state.walletMap, bank: walletId};
    await _store.writeWalletMap(map);
    state = state.copyWith(walletMap: map);
  }

  Map<String, dynamic> _body(
    PendingBankTransaction t,
    CategoryItem category,
    WalletItem wallet,
  ) => {
    'categoryId': category.id,
    'walletId': wallet.id,
    'amount': t.amount,
    'title': t.title,
    'note': 'Từ thông báo ${t.bank}',
    'occurredAt': t.occurredAt.toUtc().toIso8601String(),
  };

  void _refreshMoneyScreens() {
    ref.read(homeControllerProvider.notifier).load(refresh: true);
    ref.invalidate(historyProvider);
  }

  /// Ghi một khoản (người dùng đã xác nhận). Trả về thông báo lỗi hoặc null.
  Future<String?> confirm(
    PendingBankTransaction t, {
    required CategoryItem category,
    required WalletItem wallet,
  }) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      await ref
          .read(dioProvider)
          .post<Map<String, dynamic>>(
            'transactions',
            data: _body(t, category, wallet),
          );
      await rememberWallet(t.bank, wallet.id);
      await _markProcessed([t]);
      _refreshMoneyScreens();
      return null;
    } catch (e) {
      return 'Không ghi được giao dịch. Vui lòng thử lại.';
    } finally {
      state = state.copyWith(busy: false);
    }
  }

  /// Ghi mọi khoản đã đủ ví + danh mục trong một lần (tất cả hoặc không).
  Future<String?> confirmAll() async {
    final ready = <(PendingBankTransaction, CategoryItem, WalletItem)>[];
    for (final t in state.pending) {
      final c = categoryFor(t), w = walletFor(t);
      if (c != null && w != null) ready.add((t, c, w));
    }
    if (ready.isEmpty) return 'Chọn ví cho từng khoản trước khi xác nhận.';
    state = state.copyWith(busy: true, clearError: true);
    try {
      for (var i = 0; i < ready.length; i += 100) {
        final chunk = ready.skip(i).take(100);
        await ref
            .read(dioProvider)
            .post<dynamic>(
              'transactions/bulk',
              data: {
                'items': chunk.map((e) => _body(e.$1, e.$2, e.$3)).toList(),
              },
            );
      }
      await _markProcessed(ready.map((e) => e.$1));
      _refreshMoneyScreens();
      return null;
    } catch (_) {
      return 'Không ghi được các giao dịch. Vui lòng thử lại.';
    } finally {
      state = state.copyWith(busy: false);
    }
  }

  Future<void> skip(PendingBankTransaction t) => _markProcessed([t]);

  /// Chỉ chế độ thử (BANK_DEMO): giả lập thông báo vừa đến.
  void injectDemo(RawNotification n) => _bridge.injectDemo(n);
}
