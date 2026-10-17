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
        'type': ?type,
        'categoryId': ?categoryId,
        'walletId': ?walletId,
        if (q != null && q.isNotEmpty) 'q': q,
      },
    );
    return TransactionPage.fromJson(response.data!);
  }
}
