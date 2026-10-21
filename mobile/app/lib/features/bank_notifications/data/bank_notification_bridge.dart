import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'raw_notification.dart';

/// Chế độ thử trên web (`--dart-define=BANK_DEMO=true`): không có Android, bắn mẫu từ MockBankSamples.
const bool kBankDemo = bool.fromEnvironment('BANK_DEMO');

/// Bản APK "thường" (`TRACKERX_LITE=1 … --dart-define=BANK_NOTIFICATIONS=false`) không khai báo dịch vụ đọc thông báo,
/// để Play Protect (chống lừa đảo nâng cao ở Việt Nam) không chặn khi cài từ Zalo / trình duyệt / quản lý tệp.
const bool kBankNotificationsBuilt = bool.fromEnvironment('BANK_NOTIFICATIONS', defaultValue: true);

/// Tính năng chỉ có trên Android (iOS không cho đọc thông báo của app khác).
bool get bankNotificationsSupported =>
    kBankDemo || (kBankNotificationsBuilt && !kIsWeb && defaultTargetPlatform == TargetPlatform.android);

/// Cầu nối tới `BankNotificationListener` (android/app/src/main/kotlin/vn/thuchi/app/banknotif).
class BankNotificationBridge {
  BankNotificationBridge();

  static const _methods = MethodChannel(
    'vn.thuchi.app/bank_notifications/methods',
  );
  static const _events = EventChannel(
    'vn.thuchi.app/bank_notifications/events',
  );

  final _demo = StreamController<RawNotification>.broadcast();
  bool _demoEnabled = false;
  final List<RawNotification> _demoSaved = [];

  bool get _native => !kBankDemo;

  /// Thông báo mới khi app đang mở.
  Stream<RawNotification> get stream => _native
      ? _events.receiveBroadcastStream().map(
          (e) => RawNotification.fromMap(Map<dynamic, dynamic>.from(e as Map)),
        )
      : _demo.stream;

  Future<T?> _call<T>(String method, [Object? args]) async {
    try {
      return await _methods.invokeMethod<T>(method, args);
    } on PlatformException catch (e) {
      debugPrint('BankNotificationBridge.$method: ${e.message}');
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<bool> isPermissionGranted() async =>
      _native ? await _call<bool>('isPermissionGranted') ?? false : true;

  Future<void> openPermissionSettings() async {
    if (_native) await _call<bool>('openPermissionSettings');
  }

  /// Android 13+: mở thông tin ứng dụng để bật "Cài đặt bị hạn chế" (⋮).
  Future<void> openAppDetails() async {
    if (_native) await _call<bool>('openAppDetails');
  }

  /// Danh sách tối ưu pin (người dùng tự chọn TrackerX → Không tối ưu).
  Future<void> openBatterySettings() async {
    if (_native) await _call<bool>('openBatterySettings');
  }

  Future<bool> isIgnoringBatteryOptimizations() async => _native
      ? await _call<bool>('isIgnoringBatteryOptimizations') ?? false
      : true;

  /// Bật / tắt phía Android: tắt thì service không lưu gì và bộ đệm bị xóa.
  Future<void> setEnabled(bool enabled) async {
    if (_native) {
      await _call<bool>('setEnabled', {'enabled': enabled});
    } else {
      _demoEnabled = enabled;
      if (!enabled) _demoSaved.clear();
    }
  }

  /// Thông báo đã giữ lại lúc app đóng.
  Future<List<RawNotification>> getSaved() async {
    if (!_native) return List.of(_demoSaved);
    final list = await _call<List<dynamic>>('getSavedNotifications') ?? [];
    return list
        .whereType<Map<dynamic, dynamic>>()
        .map(RawNotification.fromMap)
        .toList();
  }

  Future<void> clearSaved() async {
    if (_native) {
      await _call<bool>('clearSavedNotifications');
    } else {
      _demoSaved.clear();
    }
  }

  /// Chỉ chế độ thử: giả lập một thông báo ngân hàng vừa đến.
  void injectDemo(RawNotification n) {
    if (!_demoEnabled) return;
    _demo.add(n);
  }
}
