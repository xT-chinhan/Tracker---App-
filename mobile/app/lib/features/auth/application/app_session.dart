import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/public_config.dart';
import '../data/auth_models.dart';

enum AppSessionStatus {
  unknown,
  authenticated,
  unauthenticated,
  maintenance,
  updateRequired,
}

class AppSessionController extends ChangeNotifier {
  AppSessionStatus status = AppSessionStatus.unknown;
  PublicConfig? config;
  AppUser? user;
  String? notice;
  MobilePlatformConfig? requiredUpdate;
  MobilePlatformConfig? optionalUpdate;

  void loading() {
    status = AppSessionStatus.unknown;
    notice = null;
    notifyListeners();
  }

  void authenticate({required AppUser value, PublicConfig? publicConfig}) {
    user = value;
    if (publicConfig != null) config = publicConfig;
    status = AppSessionStatus.authenticated;
    notice = null;
    requiredUpdate = null;
    notifyListeners();
  }

  void updateUser(AppUser value) {
    user = value;
    notifyListeners();
  }

  void unauthenticate({PublicConfig? publicConfig, String? message}) {
    user = null;
    if (publicConfig != null) config = publicConfig;
    status = AppSessionStatus.unauthenticated;
    notice = message;
    requiredUpdate = null;
    notifyListeners();
  }

  void maintain(PublicConfig value) {
    config = value;
    status = AppSessionStatus.maintenance;
    requiredUpdate = null;
    optionalUpdate = null;
    notifyListeners();
  }

  void requireUpdate(PublicConfig value, MobilePlatformConfig platform) {
    config = value;
    requiredUpdate = platform;
    status = AppSessionStatus.updateRequired;
    notifyListeners();
  }

  void setOptionalUpdate(MobilePlatformConfig? platform) {
    optionalUpdate = platform;
    notifyListeners();
  }

  void expire(String message) {
    unauthenticate(publicConfig: config, message: message);
  }

  void updateConfig(PublicConfig value) {
    config = value;
    notifyListeners();
  }

  void showNotice(String message) {
    notice = message;
    notifyListeners();
  }

  void clearNotice() {
    if (notice == null) return;
    notice = null;
    notifyListeners();
  }
}

final appSessionProvider = Provider<AppSessionController>((ref) {
  final controller = AppSessionController();
  ref.onDispose(controller.dispose);
  return controller;
});
