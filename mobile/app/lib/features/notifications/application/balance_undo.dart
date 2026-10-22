import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../history/application/history_service.dart';
import '../../home/application/home_service.dart';
import '../../transactions/data/transaction_repository.dart';

/// Id các giao dịch tự ghi đã hoàn tác (lưu trên máy) để thông báo hiện "Đã hoàn tác".
abstract interface class UndoneStore {
  Future<Set<String>> read();
  Future<void> write(Set<String> ids);
}

class SecureUndoneStore implements UndoneStore {
  SecureUndoneStore({FlutterSecureStorage? storage})
    : _s = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _s;
  static const _key = 'notifications.undone';

  @override
  Future<Set<String>> read() async {
    try {
      final raw = await _s.read(key: _key);
      if (raw == null || raw.isEmpty) return {};
      final list = jsonDecode(raw);
      return list is List ? list.map((e) => '$e').toSet() : {};
    } catch (_) {
      return {};
    }
  }

  @override
  Future<void> write(Set<String> ids) async {
    try {
      // giữ 300 id gần nhất
      final list = ids.toList();
      final keep = list.length > 300 ? list.sublist(list.length - 300) : list;
      await _s.write(key: _key, value: jsonEncode(keep));
    } catch (_) {}
  }
}

final undoneStoreProvider = Provider<UndoneStore>((ref) => SecureUndoneStore());

final undoneTransactionsProvider =
    NotifierProvider<UndoneTransactionsController, Set<String>>(
      UndoneTransactionsController.new,
    );

class UndoneTransactionsController extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    _load();
    return const {};
  }

  Future<void> _load() async {
    final ids = await ref.read(undoneStoreProvider).read();
    if (ids.isNotEmpty) state = {...state, ...ids};
  }

  Future<void> add(String id) async {
    state = {...state, id};
    await ref.read(undoneStoreProvider).write(state);
  }

  /// Hoàn tác khoản tự ghi = xóa giao dịch. 404 = đã xóa trước đó, coi như xong.
  /// Trả về thông báo lỗi hoặc null.
  Future<String?> undo(String transactionId) async {
    try {
      await ref
          .read(transactionRepositoryProvider)
          .deleteTransaction(transactionId);
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) {
        return 'Không hoàn tác được. Vui lòng thử lại.';
      }
    } catch (_) {
      return 'Không hoàn tác được. Vui lòng thử lại.';
    }
    await add(transactionId);
    ref.read(homeControllerProvider.notifier).load(refresh: true);
    ref.invalidate(historyProvider);
    return null;
  }
}
