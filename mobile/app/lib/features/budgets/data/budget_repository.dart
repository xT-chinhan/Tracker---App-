import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../home/data/home_models.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(ref.watch(dioProvider));
});

class BudgetRepository {
  BudgetRepository(this._dio);

  final Dio _dio;

  Future<BudgetSummary> getBudgets(String month) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'budgets',
      queryParameters: {'month': month},
    );
    return BudgetSummary.fromJson(response.data!);
  }

  Future<BudgetItem> createBudget({
    required String month,
    required int limitAmount,
    String? categoryId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'budgets',
      data: {
        'month': month,
        'limitAmount': limitAmount,
        if (categoryId != null && categoryId.isNotEmpty)
          'categoryId': categoryId,
      },
    );
    return BudgetItem.fromJson(response.data!);
  }

  Future<BudgetItem> updateBudget(String id, int limitAmount) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      'budgets/$id',
      data: {'limitAmount': limitAmount},
    );
    return BudgetItem.fromJson(response.data!);
  }

  Future<void> deleteBudget(String id) async {
    await _dio.delete<void>('budgets/$id');
  }

  Future<int> copyBudgets({
    required String fromMonth,
    required String toMonth,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'budgets/copy',
      data: {'fromMonth': fromMonth, 'toMonth': toMonth},
    );
    return (response.data?['copied'] as num?)?.toInt() ?? 0;
  }
}
