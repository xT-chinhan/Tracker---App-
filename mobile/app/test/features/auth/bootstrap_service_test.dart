import 'package:app/core/config/config_repository.dart';
import 'package:app/core/config/public_config.dart';
import 'package:app/core/network/api_exception.dart';
import 'package:app/core/storage/token_store.dart';
import 'package:app/features/auth/application/app_session.dart';
import 'package:app/features/auth/application/bootstrap_service.dart';
import 'package:app/features/auth/data/auth_models.dart';
import 'package:app/features/auth/data/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  test('không có token thì đi tới trạng thái chưa đăng nhập', () async {
    final session = AppSessionController();
    final store = _MemoryTokenStore();
    final service = _service(
      config: publicConfigFixture(),
      session: session,
      store: store,
    );

    await service.start();

    expect(session.status, AppSessionStatus.unauthenticated);
    expect(session.config?.appName, 'Thu Chi');
  });

  test('token hợp lệ khôi phục người dùng hiện tại', () async {
    final session = AppSessionController();
    final store = _MemoryTokenStore('token');
    final user = userFixture();
    final service = _service(
      config: publicConfigFixture(),
      session: session,
      store: store,
      user: user,
    );

    await service.start();

    expect(session.status, AppSessionStatus.authenticated);
    expect(session.user, user);
    expect(store.cleared, isFalse);
  });

  test('bảo trì chặn trước bước đọc phiên đăng nhập', () async {
    final session = AppSessionController();
    final store = _MemoryTokenStore('token');
    final service = _service(
      config: publicConfigFixture(maintenance: true),
      session: session,
      store: store,
      authError: const ApiException(statusCode: 500, message: 'Không được gọi'),
    );

    await service.start();

    expect(session.status, AppSessionStatus.maintenance);
  });

  test('phiên bản thấp hơn minVersion bị buộc cập nhật', () async {
    final session = AppSessionController();
    final service = _service(
      config: publicConfigFixture(latestVersion: '2.1.0', minVersion: '2.0.0'),
      session: session,
      store: _MemoryTokenStore(),
    );

    await service.start();

    expect(session.status, AppSessionStatus.updateRequired);
    expect(session.requiredUpdate?.minVersion, '2.0.0');
  });

  test('401 xóa token và đưa người dùng về đăng nhập', () async {
    final session = AppSessionController();
    final store = _MemoryTokenStore('expired');
    final service = _service(
      config: publicConfigFixture(),
      session: session,
      store: store,
      authError: const ApiException(
        statusCode: 401,
        message: 'Phiên đăng nhập đã hết hạn',
      ),
    );

    await service.start();

    expect(store.cleared, isTrue);
    expect(session.status, AppSessionStatus.unauthenticated);
    expect(session.notice, 'Phiên đăng nhập đã hết hạn');
  });
}

BootstrapService _service({
  required PublicConfig config,
  required AppSessionController session,
  required _MemoryTokenStore store,
  AppUser? user,
  ApiException? authError,
}) => BootstrapService(
  _FakeConfigRepository(config),
  _FakeAuthRepository(user ?? userFixture(), authError),
  store,
  session,
  () async => '1.0.0',
  TargetPlatform.android,
);

class _FakeConfigRepository extends ConfigRepository {
  _FakeConfigRepository(this.value) : super(Dio());

  final PublicConfig value;

  @override
  Future<PublicConfig> fetch() async => value;
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository(this.value, this.error) : super(Dio());

  final AppUser value;
  final ApiException? error;

  @override
  Future<AppUser> me() async {
    if (error != null) throw error!;
    return value;
  }
}

class _MemoryTokenStore implements TokenStore {
  _MemoryTokenStore([this.token]);

  String? token;
  bool cleared = false;

  @override
  Future<void> clear() async {
    token = null;
    cleared = true;
  }

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String token) async => this.token = token;
}
