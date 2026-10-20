import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import 'transfer_models.dart';

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return TransferRepository(ref.watch(dioProvider));
});

class TransferRepository {
  TransferRepository(this._dio);

  final Dio _dio;

  Future<TransferItem> createTransfer(CreateTransferDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'transfers',
      data: dto.toJson(),
    );
    return TransferItem.fromJson(response.data!);
  }

  Future<List<TransferItem>> getTransfers({
    int page = 1,
    int limit = 20,
    String? walletId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'transfers',
      queryParameters: {'page': page, 'limit': limit, 'walletId': ?walletId},
    );
    final items = response.data?['items'] as List<dynamic>? ?? <dynamic>[];
    return items
        .map((e) => TransferItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
