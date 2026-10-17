import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/wallet_models.dart';
import '../data/wallet_repository.dart';

final walletsProvider = FutureProvider.autoDispose<List<WalletItem>>((
  ref,
) async {
  final repo = ref.watch(walletRepositoryProvider);
  final response = await repo.getWallets();
  return response.items.where((w) => !w.isArchived).toList();
});
