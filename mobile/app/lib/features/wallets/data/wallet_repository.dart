import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import 'wallet_models.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.watch(dioProvider));
});

class WalletRepository {
  WalletRepository(this._dio);

  final Dio _dio;

  Future<WalletListResponse> getWallets() async {
    final response = await _dio.get<Map<String, dynamic>>('wallets');
    return WalletListResponse.fromJson(response.data!);
  }

  Future<WalletItem> getWallet(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('wallets/$id');
    return WalletItem.fromJson(response.data!);
  }

  Future<WalletItem> createWallet(CreateWalletDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'wallets',
      data: dto.toJson(),
    );
    return WalletItem.fromJson(response.data!);
  }

  Future<WalletItem> updateWallet(String id, UpdateWalletDto dto) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      'wallets/$id',
      data: dto.toJson(),
    );
    return WalletItem.fromJson(response.data!);
  }

  Future<Map<String, dynamic>> deleteWallet(String id) async {
    final response = await _dio.delete<Map<String, dynamic>>('wallets/$id');
    return response.data ?? {'archived': false};
  }

  Future<WalletItem> restoreWallet(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'wallets/$id/restore',
    );
    return WalletItem.fromJson(response.data!);
  }
}
