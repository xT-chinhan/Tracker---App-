import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import 'home_models.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return HomeRepository(dio);
});

class HomeRepository {
  HomeRepository(this._dio);

  final Dio _dio;

  Future<StatsBalance> getBalance() async {
    final response = await _dio.get<Map<String, dynamic>>('stats/balance');
    return StatsBalance.fromJson(response.data ?? const <String, dynamic>{});
  }

  Future<StatsSummary> getSummary({
    String? month,
    String? from,
    String? to,
    String? walletId,
  }) async {
    final query = <String, dynamic>{
      'month': ?month,
      'from': ?from,
      'to': ?to,
      'walletId': ?walletId,
    };
    final response = await _dio.get<Map<String, dynamic>>(
      'stats/summary',
      queryParameters: query,
    );
    return StatsSummary.fromJson(response.data ?? const <String, dynamic>{});
  }

  Future<BudgetSummary> getBudgets(String month) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'budgets',
      queryParameters: <String, dynamic>{'month': month},
    );
    return BudgetSummary.fromJson(response.data ?? const <String, dynamic>{});
  }

  Future<TransactionPage> getRecentTransactions({int limit = 5}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'transactions',
      queryParameters: <String, dynamic>{'limit': limit},
    );
    return TransactionPage.fromJson(response.data ?? const <String, dynamic>{});
  }

  Future<List<QuickTemplateItem>> getQuickTemplates() async {
    final response = await _dio.get<dynamic>('quick-templates');
    final raw = response.data;
    if (raw is List) {
      return raw
          .map((e) => QuickTemplateItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const <QuickTemplateItem>[];
  }

  Future<TransactionItem> useQuickTemplate(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'quick-templates/$id/use',
    );
    return TransactionItem.fromJson(response.data ?? const <String, dynamic>{});
  }
}
