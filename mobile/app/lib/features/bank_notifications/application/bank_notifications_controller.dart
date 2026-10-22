import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/vietnam_time.dart';
import '../../../core/network/network_providers.dart';
import '../../auth/application/app_session.dart';
import '../../categories/data/category_models.dart';
import '../../categories/data/category_repository.dart';
import '../../history/application/history_service.dart';
import '../../home/application/home_service.dart';
import '../../notifications/application/balance_undo.dart';
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
    this.autoRecord = false,
    this.threshold = defaultAutoRecordThreshold,
    this.autoRecorded = const [],
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

  /// Tự động ghi vào sổ (theo máy).
  final bool autoRecord;

  /// Khoản từ ngưỡng này trở lên vẫn chờ xác nhận; 0 = Tắt.
  final int threshold;

  /// Khoản đã tự ghi (30 ngày gần nhất, mới nhất trước).
  final List<AutoRecordedTransaction> autoRecorded;
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
    bool? autoRecord,
    int? threshold,
    List<AutoRecordedTransaction>? autoRecorded,
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
    autoRecord: autoRecord ?? this.autoRecord,
    threshold: threshold ?? this.threshold,
    autoRecorded: autoRecorded ?? this.autoRecorded,
    categories: categories ?? this.categories,
    wallets: wallets ?? this.wallets,
    walletMap: walletMap ?? this.walletMap,
    busy: busy ?? this.busy,
    error: clearError ? null : error ?? this.error,
  );
}

/// Khoản tự ghi hôm nay (giờ Việt Nam), bỏ khoản đã hoàn tác.
List<AutoRecordedTransaction> todayAutoRecorded(
  List<AutoRecordedTransaction> all,
  Set<String> undone,
) {
  final now = VietnamTime.now();
  return all.where((a) {
    if (undone.contains(a.transactionId)) return false;
    final d = VietnamTime.fromDateTime(a.recordedAt);
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }).toList();
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
    final cutoff = DateTime.now().toUtc().subtract(const Duration(days: 30));
    state = state.copyWith(
      loaded: true,
      enabled: enabled,
      consent: await _store.readConsent(),
      pending: await _store.readPending(),
      autoRecord: await _store.readAutoRecord(),
      threshold: await _store.readThreshold(),
      autoRecorded: (await _store.readAutoRecorded())
          .where((a) => a.recordedAt.isAfter(cutoff))
          .toList(),
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
      state = state.copyWith(
        enabled: false,
        pending: [],
        walletMap: {},
        autoRecord: false,
        autoRecorded: [],
      );
      return;
    }
    state = state.copyWith(enabled: true);
    await sync();
  }

  /// Bật / tắt Tự động ghi vào sổ (bật chỉ sau khi người dùng đồng ý ở sheet riêng).
  Future<void> setAutoRecord(bool value) async {
    await _store.writeAutoRecord(value);
    state = state.copyWith(autoRecord: value);
  }

  Future<void> setThreshold(int value) async {
    await _store.writeThreshold(value);
    state = state.copyWith(threshold: value);
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
    final meta = await _store.readProcessedMeta()
      ..removeWhere((k, _) => !processed.containsKey(k));
    final pending = [...state.pending];
    final auto = [...state.autoRecorded];
    final seen = {...processed.keys, ...pending.map((p) => p.key)};
    final fresh = <PendingBankTransaction>[];
    for (final raw in raws) {
      final parsed = BankNotificationParser.parse(raw);
      if (parsed == null) continue;
      final item = toPending(parsed, packageName: raw.packageName);
      if (item == null || !seen.add(item.key)) continue;
      // Cùng một khoản báo qua app ngân hàng và SMS: chỉ lấy lần đầu
      if (isDuplicateOfKnown(
        item,
        pending: pending,
        autoRecorded: auto,
        processed: meta.values,
      )) {
        continue;
      }
      pending.insert(0, item);
      fresh.add(item);
    }
    if (state.autoRecord && fresh.isNotEmpty) {
      if (state.categories.isEmpty || state.wallets.isEmpty) {
        await loadReferences();
      }
      var recorded = false;
      for (final t in fresh) {
        final c = categoryFor(t), w = walletFor(t);
        final block = autoRecordBlock(
          t,
          category: c,
          wallet: w,
          threshold: state.threshold,
        );
        if (block != null || c == null || w == null) continue;
        try {
          final res = await ref
              .read(dioProvider)
              .post<Map<String, dynamic>>(
                'transactions',
                data: _body(t, c, w, source: 'bank_auto'),
              );
          final id = res.data?['id'];
          if (id is! String || id.isEmpty) continue;
          auto.insert(
            0,
            AutoRecordedTransaction.of(
              t,
              transactionId: id,
              category: c,
              wallet: w,
            ),
          );
          pending.removeWhere((p) => p.key == t.key);
          processed[t.key] = now;
          meta[t.key] = ProcessedBankTransaction.of(t);
          recorded = true;
        } catch (_) {
          // lỗi mạng / máy chủ: để lại trong Chờ xác nhận
        }
      }
      if (recorded) {
        await _store.writeAutoRecorded(auto);
        _refreshMoneyScreens();
      }
    }
    pending.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    await _store.writeProcessed(processed);
    await _store.writeProcessedMeta(meta);
    await _store.writePending(pending);
    state = state.copyWith(pending: pending, autoRecorded: auto);
  }

  /// Lý do khoản chờ chưa được tự ghi (chỉ khi đang bật Tự động ghi).
  String? blockReason(
    PendingBankTransaction t, {
    CategoryItem? category,
    WalletItem? wallet,
  }) => state.autoRecord
      ? autoRecordBlock(
          t,
          category: category ?? categoryFor(t),
          wallet: wallet ?? walletFor(t),
          threshold: state.threshold,
        )
      : null;

  /// Hoàn tác khoản đã tự ghi: xóa giao dịch, bỏ khỏi danh sách. Trả về lỗi hoặc null.
  Future<String?> undoAuto(AutoRecordedTransaction a) async {
    final err = await ref
        .read(undoneTransactionsProvider.notifier)
        .undo(a.transactionId);
    if (err != null) return err;
    await _serial(() async {
      final list = state.autoRecorded
          .where((x) => x.transactionId != a.transactionId)
          .toList();
      await _store.writeAutoRecorded(list);
      state = state.copyWith(autoRecorded: list);
    });
    return null;
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
    final meta = await _store.readProcessedMeta();
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final k in keys) {
      processed[k] = now;
    }
    for (final p in state.pending) {
      if (keys.contains(p.key)) meta[p.key] = ProcessedBankTransaction.of(p);
    }
    final pending = state.pending.where((p) => !keys.contains(p.key)).toList();
    await _store.writeProcessed(processed);
    await _store.writeProcessedMeta(meta);
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
    WalletItem wallet, {
    String source = 'bank_manual',
  }) => {
    'categoryId': category.id,
    'walletId': wallet.id,
    'amount': t.amount,
    'title': t.title,
    'note': 'Từ thông báo ${t.bank}',
    'occurredAt': t.occurredAt.toUtc().toIso8601String(),
    'source': source,
    'externalRef': t.key.length > 200 ? t.key.substring(0, 200) : t.key,
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
