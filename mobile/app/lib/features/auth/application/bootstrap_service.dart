import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/config/config_repository.dart';
import '../../../core/formatting/version_compare.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/network_providers.dart';
import '../../../core/storage/token_store.dart';
import '../data/auth_repository.dart';
import 'app_session.dart';

typedef PackageVersionLoader = Future<String> Function();

final packageVersionLoaderProvider = Provider<PackageVersionLoader>(
  (ref) =>
      () async => (await PackageInfo.fromPlatform()).version,
);

class BootstrapService {
  const BootstrapService(
    this._configRepository,
    this._authRepository,
    this._tokenStore,
    this._session,
    this._loadVersion,
    this._platform,
  );

  final ConfigRepository _configRepository;
  final AuthRepository _authRepository;
  final TokenStore _tokenStore;
  final AppSessionController _session;
  final PackageVersionLoader _loadVersion;
  final TargetPlatform _platform;

  Future<void> start() async {
    _session.loading();
    final config = await _configRepository.fetch();
    final version = await _loadVersion();
    final platformConfig = _platform == TargetPlatform.iOS
        ? config.mobile.ios
        : config.mobile.android;

    if (config.maintenance.enabled) {
      _session.maintain(config);
      return;
    }
    if (VersionCompare.compare(platformConfig.minVersion, version) > 0) {
      _session.requireUpdate(config, platformConfig);
      return;
    }

    final optional =
        VersionCompare.compare(platformConfig.latestVersion, version) > 0
        ? platformConfig
        : null;
    final token = await _tokenStore.read();
    if (token == null || token.isEmpty) {
      _session.unauthenticate(publicConfig: config);
      _session.setOptionalUpdate(optional);
      return;
    }

    try {
      final user = await _authRepository.me();
      _session.authenticate(value: user, publicConfig: config);
      _session.setOptionalUpdate(optional);
    } on ApiException catch (error) {
      if (error.isUnauthorized || error.isAccountLocked) {
        await _tokenStore.clear();
        _session.unauthenticate(publicConfig: config, message: error.message);
        return;
      }
      rethrow;
    }
  }

  Future<void> refreshConfig() async {
    final config = await _configRepository.fetch();
    if (config.maintenance.enabled) {
      _session.maintain(config);
      return;
    }

    final version = await _loadVersion();
    final platformConfig = _platform == TargetPlatform.iOS
        ? config.mobile.ios
        : config.mobile.android;
    if (VersionCompare.compare(platformConfig.minVersion, version) > 0) {
      _session.requireUpdate(config, platformConfig);
      return;
    }

    _session.updateConfig(config);
    _session.setOptionalUpdate(
      VersionCompare.compare(platformConfig.latestVersion, version) > 0
          ? platformConfig
          : null,
    );
  }
}

final bootstrapServiceProvider = Provider<BootstrapService>((ref) {
  return BootstrapService(
    ref.watch(configRepositoryProvider),
    ref.watch(authRepositoryProvider),
    ref.watch(tokenStoreProvider),
    ref.watch(appSessionProvider),
    ref.watch(packageVersionLoaderProvider),
    defaultTargetPlatform,
  );
});
