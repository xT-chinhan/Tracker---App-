import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import 'report_models.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(ref.watch(dioProvider));
});

class ReportRepository {
  ReportRepository(this._dio);

  final Dio _dio;

  Future<ReportData> getReport({
    String? month,
    String? walletId,
    int observationMonths = 6,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'stats/report',
      queryParameters: {
        if (month != null && month.isNotEmpty) 'month': month,
        if (walletId != null && walletId.isNotEmpty) 'walletId': walletId,
        'observationMonths': observationMonths,
      },
    );
    return ReportData.fromJson(response.data!);
  }

  Future<List<MonthlyTrendItem>> getTrend({
    String? month,
    String? walletId,
    int months = 6,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      'stats/trend',
      queryParameters: {
        if (month != null && month.isNotEmpty) 'month': month,
        if (walletId != null && walletId.isNotEmpty) 'walletId': walletId,
        'months': months,
      },
    );
    return response.data!
        .map((e) => MonthlyTrendItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CategoryReportItem>> getByCategory({
    String? month,
    String? walletId,
    String type = 'EXPENSE',
  }) async {
    final response = await _dio.get<List<dynamic>>(
      'stats/by-category',
      queryParameters: {
        if (month != null && month.isNotEmpty) 'month': month,
        if (walletId != null && walletId.isNotEmpty) 'walletId': walletId,
        'type': type,
      },
    );
    return response.data!
        .map((e) => CategoryReportItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> exportCsv({
    String? month,
    String? walletId,
  }) async {
    final response = await _dio.get<String>(
      'export/transactions.csv',
      queryParameters: {
        if (month != null && month.isNotEmpty) 'month': month,
        if (walletId != null && walletId.isNotEmpty) 'walletId': walletId,
      },
      options: Options(
        responseType: ResponseType.plain,
        headers: {'Accept': 'text/csv'},
      ),
    );
    return response.data ?? '';
  }
}
