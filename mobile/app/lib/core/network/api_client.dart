import 'package:dio/dio.dart';

import '../storage/token_store.dart';
import 'api_exception.dart';

typedef SessionExpiredCallback = Future<void> Function(ApiException exception);

class ApiClient {
  ApiClient({
    required Uri baseUri,
    required this.tokenStore,
    this.onSessionExpired,
    Dio? dio,
  }) : dio = dio ?? Dio() {
    this.dio.options = BaseOptions(
      baseUrl: baseUri.toString(),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: const <String, Object>{'accept': 'application/json'},
    );
    this.dio.interceptors.add(
      InterceptorsWrapper(onRequest: _authorize, onError: _handleError),
    );
  }

  final Dio dio;
  final TokenStore tokenStore;
  final SessionExpiredCallback? onSessionExpired;
  Future<void>? _expirationInProgress;

  Future<void> _authorize(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStore.read();
    if (token != null && token.isNotEmpty) {
      options.headers['authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _handleError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final exception = ApiException.fromDio(error);
    if (exception.isUnauthorized || exception.isAccountLocked) {
      _expirationInProgress ??= _expire(exception);
      await _expirationInProgress;
      _expirationInProgress = null;
    }
    handler.reject(error.copyWith(error: exception));
  }

  Future<void> _expire(ApiException exception) async {
    await tokenStore.clear();
    await onSessionExpired?.call(exception);
  }
}
