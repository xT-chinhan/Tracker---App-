import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/network_providers.dart';
import 'auth_models.dart';

class AuthRepository {
  const AuthRepository(this._dio);

  final Dio _dio;

  Future<AuthResult> login({required String email, required String password}) =>
      _auth('auth/login', <String, dynamic>{
        'email': email.trim(),
        'password': password,
      });

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) => _auth('auth/register', <String, dynamic>{
    'name': name.trim(),
    'email': email.trim(),
    'password': password,
  });

  Future<void> forgotPassword(String email) async {
    await _request(
      () => _dio.post<void>(
        'auth/forgot-password',
        data: <String, dynamic>{'email': email.trim()},
      ),
    );
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await _request(
      () => _dio.post<void>(
        'auth/reset-password',
        data: <String, dynamic>{
          'email': email.trim(),
          'otp': otp,
          'newPassword': newPassword,
        },
      ),
    );
  }

  Future<AppUser> me() async {
    final response = await _request(() => _dio.get<Map<String, dynamic>>('me'));
    return AppUser.fromJson(response.data!);
  }

  Future<void> logoutAll() async {
    await _request(() => _dio.post<void>('auth/logout-all'));
  }

  Future<AuthResult> _auth(String path, Map<String, dynamic> data) async {
    final response = await _request(
      () => _dio.post<Map<String, dynamic>>(path, data: data),
    );
    return AuthResult.fromJson(response.data!);
  }

  Future<Response<T>> _request<T>(Future<Response<T>> Function() run) async {
    try {
      return await run();
    } on DioException catch (error) {
      throw error.error is ApiException
          ? error.error! as ApiException
          : ApiException.fromDio(error);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(dioProvider)),
);
