import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../home/data/home_models.dart';
import 'quick_template_models.dart';

final quickTemplateRepositoryProvider = Provider<QuickTemplateRepository>((
  ref,
) {
  return QuickTemplateRepository(ref.watch(dioProvider));
});

final quickTemplatesProvider = FutureProvider<List<QuickTemplateItem>>((ref) {
  return ref.watch(quickTemplateRepositoryProvider).getQuickTemplates();
});

class QuickTemplateRepository {
  QuickTemplateRepository(this._dio);

  final Dio _dio;

  Future<List<QuickTemplateItem>> getQuickTemplates() async {
    final response = await _dio.get<List<dynamic>>('quick-templates');
    final data = response.data ?? <dynamic>[];
    return data
        .map((e) => QuickTemplateItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<QuickTemplateItem> createQuickTemplate(
    CreateQuickTemplateDto dto,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'quick-templates',
      data: dto.toJson(),
    );
    return QuickTemplateItem.fromJson(response.data!);
  }

  Future<TransactionItem> useQuickTemplate(
    String id, {
    UseQuickTemplateDto? dto,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'quick-templates/$id/use',
      data: dto?.toJson() ?? <String, dynamic>{},
    );
    return TransactionItem.fromJson(response.data!);
  }

  Future<void> deleteQuickTemplate(String id) async {
    await _dio.delete<void>('quick-templates/$id');
  }
}
