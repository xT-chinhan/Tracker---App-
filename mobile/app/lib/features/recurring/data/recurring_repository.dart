import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import 'recurring_models.dart';

final recurringRepositoryProvider = Provider<RecurringRepository>((ref) {
  return RecurringRepository(ref.watch(dioProvider));
});

class RecurringRepository {
  RecurringRepository(this._dio);

  final Dio _dio;

  Future<List<RecurringRuleItem>> getRules() async {
    final response = await _dio.get<List<dynamic>>('recurring');
    return response.data!
        .map((e) => RecurringRuleItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RecurringRuleItem> getRule(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('recurring/$id');
    return RecurringRuleItem.fromJson(response.data!);
  }

  Future<RecurringRuleItem> createRule(CreateRecurringDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'recurring',
      data: dto.toJson(),
    );
    return RecurringRuleItem.fromJson(response.data!);
  }

  Future<RecurringRuleItem> updateRule(
    String id,
    UpdateRecurringDto dto,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      'recurring/$id',
      data: dto.toJson(),
    );
    return RecurringRuleItem.fromJson(response.data!);
  }

  Future<void> deleteRule(String id) async {
    await _dio.delete<void>('recurring/$id');
  }

  Future<RecurringRuleItem> pauseRule(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'recurring/$id/pause',
    );
    return RecurringRuleItem.fromJson(response.data!);
  }

  Future<RecurringRuleItem> resumeRule(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'recurring/$id/resume',
    );
    return RecurringRuleItem.fromJson(response.data!);
  }

  Future<RecurringPreviewResponse> preview(String id, {int count = 5}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'recurring/$id/preview',
      queryParameters: {'count': count},
    );
    return RecurringPreviewResponse.fromJson(response.data!);
  }
}
