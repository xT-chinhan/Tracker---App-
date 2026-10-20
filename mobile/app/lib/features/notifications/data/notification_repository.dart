import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import 'notification_models.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationRepository(dio);
});

class NotificationRepository {
  NotificationRepository(this._dio);

  final Dio _dio;

  Future<NotificationPage> list({
    int page = 1,
    int limit = 20,
    bool? unread,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      'unread': ?unread,
    };
    final response = await _dio.get<Map<String, dynamic>>(
      'notifications',
      queryParameters: query,
    );
    return NotificationPage.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get<Map<String, dynamic>>(
      'notifications/unread-count',
    );
    final data = response.data;
    if (data != null && data['count'] is num) {
      return (data['count'] as num).toInt();
    }
    return 0;
  }

  Future<NotificationItem> markRead(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'notifications/$id/read',
    );
    return NotificationItem.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }

  Future<int> markReadAll() async {
    final response = await _dio.post<Map<String, dynamic>>(
      'notifications/read-all',
    );
    final data = response.data;
    if (data != null && data['updated'] is num) {
      return (data['updated'] as num).toInt();
    }
    return 0;
  }
}
