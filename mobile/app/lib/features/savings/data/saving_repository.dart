import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import 'saving_models.dart';

final savingRepositoryProvider = Provider<SavingRepository>((ref) {
  return SavingRepository(ref.watch(dioProvider));
});

class SavingRepository {
  SavingRepository(this._dio);

  final Dio _dio;

  Future<List<SavingGoalItem>> getGoals({String? status}) async {
    final response = await _dio.get<List<dynamic>>(
      'saving-goals',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    return response.data!
        .map((e) => SavingGoalItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SavingGoalDetail> getGoal(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('saving-goals/$id');
    return SavingGoalDetail.fromJson(response.data!);
  }

  Future<SavingGoalItem> createGoal(CreateGoalDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'saving-goals',
      data: dto.toJson(),
    );
    return SavingGoalItem.fromJson(response.data!);
  }

  Future<SavingGoalItem> updateGoal(String id, UpdateGoalDto dto) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      'saving-goals/$id',
      data: dto.toJson(),
    );
    return SavingGoalItem.fromJson(response.data!);
  }

  Future<Map<String, dynamic>> deposit(String id, DepositDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'saving-goals/$id/deposit',
      data: dto.toJson(),
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> withdraw(String id, WithdrawDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'saving-goals/$id/withdraw',
      data: dto.toJson(),
    );
    return response.data!;
  }

  Future<void> deleteGoal(String id) async {
    await _dio.delete<void>('saving-goals/$id');
  }
}
