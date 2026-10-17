import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../home/data/home_models.dart';
import 'transaction_models.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(dioProvider));
});

class TransactionRepository {
  TransactionRepository(this._dio);

  final Dio _dio;

  Future<TransactionItem> createTransaction(CreateTransactionDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'transactions',
      data: dto.toJson(),
    );
    return TransactionItem.fromJson(response.data!);
  }

  Future<TransactionItem> getTransaction(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('transactions/$id');
    return TransactionItem.fromJson(response.data!);
  }

  Future<TransactionPage> getTransactions({
    int page = 1,
    int limit = 20,
    String? month,
    String? from,
    String? to,
    String? type,
    String? categoryId,
    String? walletId,
    String? q,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'transactions',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (month != null && month.isNotEmpty) 'month': month,
        if (from != null && from.isNotEmpty) 'from': from,
        if (to != null && to.isNotEmpty) 'to': to,
        if (type != null && type.isNotEmpty) 'type': type,
        if (categoryId != null && categoryId.isNotEmpty)
          'categoryId': categoryId,
        if (walletId != null && walletId.isNotEmpty) 'walletId': walletId,
        if (q != null && q.isNotEmpty) 'q': q,
      },
    );
    return TransactionPage.fromJson(response.data!);
  }

  Future<TransactionItem> updateTransaction(
    String id,
    UpdateTransactionDto dto,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      'transactions/$id',
      data: dto.toJson(),
    );
    return TransactionItem.fromJson(response.data!);
  }

  Future<void> deleteTransaction(String id) async {
    await _dio.delete<void>('transactions/$id');
  }
}
