import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/app_session.dart';
import '../config/app_environment.dart';
import '../storage/token_store.dart';
import 'api_client.dart';

final apiBaseUriProvider = Provider<Uri>(
  (ref) => AppEnvironment.requireApiUri(),
);

final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());

final dioProvider = Provider<Dio>((ref) {
  final client = ApiClient(
    baseUri: ref.watch(apiBaseUriProvider),
    tokenStore: ref.watch(tokenStoreProvider),
    onSessionExpired: (exception) async {
      ref.read(appSessionProvider).expire(exception.message);
    },
  );
  ref.onDispose(client.dio.close);
  return client.dio;
});
