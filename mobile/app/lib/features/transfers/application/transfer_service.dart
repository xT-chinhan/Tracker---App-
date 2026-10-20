import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/vietnam_time.dart';
import '../../home/application/home_service.dart';
import '../../wallets/application/wallets_service.dart';
import '../../wallets/data/wallet_models.dart';
import '../data/transfer_models.dart';
import '../data/transfer_repository.dart';

class TransferState {
  const TransferState({
    this.fromWallet,
    this.toWallet,
    this.digits = '',
    this.note = '',
    required this.occurredAt,
    this.isSaving = false,
    this.errorMessage,
  });

  final WalletItem? fromWallet;
  final WalletItem? toWallet;
  final String digits;
  final String note;
  final DateTime occurredAt;
  final bool isSaving;
  final String? errorMessage;

  int get amount => int.tryParse(digits) ?? 0;

  TransferState copyWith({
    WalletItem? fromWallet,
    WalletItem? toWallet,
    String? digits,
    String? note,
    DateTime? occurredAt,
    bool? isSaving,
    String? errorMessage,
  }) {
    return TransferState(
      fromWallet: fromWallet ?? this.fromWallet,
      toWallet: toWallet ?? this.toWallet,
      digits: digits ?? this.digits,
      note: note ?? this.note,
      occurredAt: occurredAt ?? this.occurredAt,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

final transferProvider = NotifierProvider<TransferNotifier, TransferState>(
  TransferNotifier.new,
);

class TransferNotifier extends Notifier<TransferState> {
  @override
  TransferState build() {
    return TransferState(occurredAt: VietnamTime.now());
  }

  void initWallets(List<WalletItem> wallets) {
    if (wallets.isEmpty) return;
    if (state.fromWallet != null && state.toWallet != null) return;
    final from = state.fromWallet ?? wallets.first;
    final to =
        state.toWallet ?? (wallets.length > 1 ? wallets[1] : wallets.first);
    state = state.copyWith(fromWallet: from, toWallet: to);
  }

  void setFromWallet(WalletItem wallet) {
    state = state.copyWith(fromWallet: wallet, errorMessage: null);
  }

  void setToWallet(WalletItem wallet) {
    state = state.copyWith(toWallet: wallet, errorMessage: null);
  }

  void swapWallets() {
    final temp = state.fromWallet;
    state = state.copyWith(
      fromWallet: state.toWallet,
      toWallet: temp,
      errorMessage: null,
    );
  }

  void appendDigit(String value) {
    if (state.digits.length >= 14) return;
    final candidate = '${state.digits}$value'.replaceFirst(RegExp(r'^0+'), '');
    state = state.copyWith(
      digits: candidate.substring(0, candidate.length.clamp(0, 14)),
      errorMessage: null,
    );
  }

  void deleteDigit() {
    if (state.digits.isEmpty) return;
    state = state.copyWith(
      digits: state.digits.substring(0, state.digits.length - 1),
      errorMessage: null,
    );
  }

  void setAmount(int amount) {
    state = state.copyWith(digits: amount.toString(), errorMessage: null);
  }

  void setNote(String note) {
    state = state.copyWith(note: note, errorMessage: null);
  }

  Future<bool> submitTransfer() async {
    if (state.fromWallet == null || state.toWallet == null) {
      state = state.copyWith(errorMessage: 'Vui lòng chọn ví nguồn và ví đích');
      return false;
    }
    if (state.fromWallet!.id == state.toWallet!.id) {
      state = state.copyWith(
        errorMessage: 'Ví nguồn và ví đích phải khác nhau',
      );
      return false;
    }
    if (state.amount <= 0) {
      state = state.copyWith(errorMessage: 'Vui lòng nhập số tiền chuyển');
      return false;
    }
    if (state.fromWallet!.balance < state.amount) {
      state = state.copyWith(
        errorMessage: 'Số dư ví "${state.fromWallet!.name}" không đủ để chuyển',
      );
      return false;
    }

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final repo = ref.read(transferRepositoryProvider);
      final dto = CreateTransferDto(
        fromWalletId: state.fromWallet!.id,
        toWalletId: state.toWallet!.id,
        amount: state.amount,
        note: state.note.trim().isNotEmpty ? state.note.trim() : null,
        occurredAt: state.occurredAt.toUtc().toIso8601String(),
      );

      await repo.createTransfer(dto);
      // Refresh Home and Wallets
      ref.read(homeControllerProvider.notifier).load(refresh: true);
      ref.invalidate(walletsProvider);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Chuyển tiền thất bại. Vui lòng thử lại.',
      );
      return false;
    }
  }
}
