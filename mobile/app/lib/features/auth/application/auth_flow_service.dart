import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/storage/token_store.dart';
import '../data/auth_repository.dart';
import 'app_session.dart';

class AuthFlowService {
  const AuthFlowService(this._repository, this._tokenStore, this._session);

  final AuthRepository _repository;
  final TokenStore _tokenStore;
  final AppSessionController _session;

  Future<void> login({required String email, required String password}) async {
    final result = await _repository.login(email: email, password: password);
    await _tokenStore.write(result.accessToken);
    _session.authenticate(value: result.user);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await _repository.register(
      name: name,
      email: email,
      password: password,
    );
    await _tokenStore.write(result.accessToken);
    _session.authenticate(value: result.user);
  }

  Future<void> forgotPassword(String email) =>
      _repository.forgotPassword(email);

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) => _repository.resetPassword(
    email: email,
    otp: otp,
    newPassword: newPassword,
  );

  Future<void> logoutAll() async {
    await _repository.logoutAll();
    await _tokenStore.clear();
    _session.unauthenticate(publicConfig: _session.config);
  }
}

final authFlowServiceProvider = Provider<AuthFlowService>((ref) {
  return AuthFlowService(
    ref.watch(authRepositoryProvider),
    ref.watch(tokenStoreProvider),
    ref.watch(appSessionProvider),
  );
});
