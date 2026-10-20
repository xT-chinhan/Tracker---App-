import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_exception.dart';
import '../network/network_providers.dart';
import 'public_config.dart';

class ConfigRepository {
  const ConfigRepository(this._dio);

  final Dio _dio;

  Future<PublicConfig> fetch() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('config/public');
      return PublicConfig.fromJson(response.data!);
    } on DioException catch (error) {
      throw error.error is ApiException
          ? error.error! as ApiException
          : ApiException.fromDio(error);
    }
  }
}

final configRepositoryProvider = Provider<ConfigRepository>(
  (ref) => ConfigRepository(ref.watch(dioProvider)),
);
