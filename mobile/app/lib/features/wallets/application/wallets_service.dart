import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/application/home_service.dart';
import '../data/wallet_models.dart';
import '../data/wallet_repository.dart';

final walletsResponseProvider = FutureProvider.autoDispose<WalletListResponse>((
  ref,
) async {
  final repo = ref.watch(walletRepositoryProvider);
  return repo.getWallets();
});

final walletsProvider = FutureProvider.autoDispose<List<WalletItem>>((
  ref,
) async {
  final response = await ref.watch(walletsResponseProvider.future);
  return response.items.where((w) => !w.isArchived).toList();
});

class WalletsState {
  const WalletsState({this.isSubmitting = false});

  final bool isSubmitting;

  WalletsState copyWith({bool? isSubmitting}) {
    return WalletsState(isSubmitting: isSubmitting ?? this.isSubmitting);
  }
}

final walletsActionProvider =
    NotifierProvider<WalletsActionNotifier, WalletsState>(
      WalletsActionNotifier.new,
    );

class WalletsActionNotifier extends Notifier<WalletsState> {
  WalletRepository get _repo => ref.read(walletRepositoryProvider);

  @override
  WalletsState build() => const WalletsState();

  Future<WalletItem> createWallet(CreateWalletDto dto) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final created = await _repo.createWallet(dto);
      _invalidateAll();
      return created;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<WalletItem> updateWallet(String id, UpdateWalletDto dto) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final updated = await _repo.updateWallet(id, dto);
      _invalidateAll();
      return updated;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<Map<String, dynamic>> deleteWallet(String id) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final result = await _repo.deleteWallet(id);
      _invalidateAll();
      return result;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<WalletItem> restoreWallet(String id) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final restored = await _repo.restoreWallet(id);
      _invalidateAll();
      return restored;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  void _invalidateAll() {
    ref.invalidate(walletsResponseProvider);
    ref.invalidate(walletsProvider);
    try {
      ref
          .read(homeControllerProvider.notifier)
          .load(refresh: true)
          .catchError((e) {});
    } catch (_) {}
  }
}
