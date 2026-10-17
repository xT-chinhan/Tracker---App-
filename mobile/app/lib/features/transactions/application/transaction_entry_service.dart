import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/vietnam_time.dart';
import '../../categories/data/category_models.dart';
import '../../home/application/home_service.dart';
import '../../quick_templates/data/quick_template_models.dart';
import '../../quick_templates/data/quick_template_repository.dart';
import '../../wallets/data/wallet_models.dart';
import '../data/transaction_models.dart';
import '../data/transaction_repository.dart';
import '../presentation/transaction_entry_screen.dart';

class TransactionEntryState {
  const TransactionEntryState({
    required this.type,
    this.digits = '',
    this.selectedCategory,
    this.selectedWallet,
    required this.occurredAt,
    this.note = '',
    this.isSaving = false,
    this.isSavingTemplate = false,
    this.errorMessage,
  });

  final TransactionType type;
  final String digits;
  final CategoryItem? selectedCategory;
  final WalletItem? selectedWallet;
  final DateTime occurredAt;
  final String note;
  final bool isSaving;
  final bool isSavingTemplate;
  final String? errorMessage;

  int get amount => int.tryParse(digits) ?? 0;

  TransactionEntryState copyWith({
    TransactionType? type,
    String? digits,
    CategoryItem? selectedCategory,
    WalletItem? selectedWallet,
    DateTime? occurredAt,
    String? note,
    bool? isSaving,
    bool? isSavingTemplate,
    String? errorMessage,
    bool clearCategory = false,
  }) {
    return TransactionEntryState(
      type: type ?? this.type,
      digits: digits ?? this.digits,
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      selectedWallet: selectedWallet ?? this.selectedWallet,
      occurredAt: occurredAt ?? this.occurredAt,
      note: note ?? this.note,
      isSaving: isSaving ?? this.isSaving,
      isSavingTemplate: isSavingTemplate ?? this.isSavingTemplate,
      errorMessage: errorMessage,
    );
  }
}

final transactionEntryProvider =
    NotifierProvider<TransactionEntryNotifier, TransactionEntryState>(
      TransactionEntryNotifier.new,
    );

class TransactionEntryNotifier extends Notifier<TransactionEntryState> {
  @override
  TransactionEntryState build() {
    return TransactionEntryState(
      type: TransactionType.expense,
      occurredAt: VietnamTime.now(),
    );
  }

  void initType(TransactionType type) {
    state = TransactionEntryState(type: type, occurredAt: VietnamTime.now());
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

  void setType(TransactionType type) {
    if (state.type == type) return;
    state = state.copyWith(type: type, clearCategory: true, errorMessage: null);
  }

  void setCategory(CategoryItem category) {
    state = state.copyWith(selectedCategory: category, errorMessage: null);
  }

  void setWallet(WalletItem wallet) {
    state = state.copyWith(selectedWallet: wallet, errorMessage: null);
  }

  void setDate(DateTime date) {
    state = state.copyWith(occurredAt: date, errorMessage: null);
  }

  void setNote(String note) {
    state = state.copyWith(note: note, errorMessage: null);
  }

  Future<bool> submitTransaction() async {
    if (state.amount <= 0) {
      state = state.copyWith(errorMessage: 'Vui lòng nhập số tiền lớn hơn 0');
      return false;
    }
    if (state.selectedCategory == null) {
      state = state.copyWith(errorMessage: 'Vui lòng chọn danh mục');
      return false;
    }
    if (state.selectedWallet == null) {
      state = state.copyWith(errorMessage: 'Vui lòng chọn ví');
      return false;
    }

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final repo = ref.read(transactionRepositoryProvider);
      final category = state.selectedCategory!;
      final trimmedNote = state.note.trim();
      final title = trimmedNote.isNotEmpty ? trimmedNote : category.name;

      final dto = CreateTransactionDto(
        categoryId: category.id,
        walletId: state.selectedWallet!.id,
        amount: state.amount,
        title: title,
        note: trimmedNote.isNotEmpty ? trimmedNote : null,
        occurredAt: state.occurredAt.toUtc().toIso8601String(),
      );

      await repo.createTransaction(dto);
      // Refresh Home state so balances, budgets, recent transactions are updated immediately
      ref.read(homeControllerProvider.notifier).load(refresh: true);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Lưu giao dịch thất bại. Vui lòng thử lại.',
      );
      return false;
    }
  }

  Future<bool> saveAsTemplate(String templateLabel) async {
    final label = templateLabel.trim();
    if (label.isEmpty) {
      state = state.copyWith(errorMessage: 'Vui lòng nhập tên mẫu');
      return false;
    }
    if (state.amount <= 0) {
      state = state.copyWith(errorMessage: 'Vui lòng nhập số tiền mẫu');
      return false;
    }
    if (state.selectedCategory == null) {
      state = state.copyWith(errorMessage: 'Vui lòng chọn danh mục cho mẫu');
      return false;
    }
    if (state.selectedWallet == null) {
      state = state.copyWith(errorMessage: 'Vui lòng chọn ví cho mẫu');
      return false;
    }

    state = state.copyWith(isSavingTemplate: true, errorMessage: null);

    try {
      final repo = ref.read(quickTemplateRepositoryProvider);
      final category = state.selectedCategory!;
      final trimmedNote = state.note.trim();
      final title = trimmedNote.isNotEmpty ? trimmedNote : category.name;

      final dto = CreateQuickTemplateDto(
        label: label,
        title: title,
        amount: state.amount,
        categoryId: category.id,
        walletId: state.selectedWallet!.id,
        note: trimmedNote.isNotEmpty ? trimmedNote : null,
      );

      await repo.createQuickTemplate(dto);
      ref.read(homeControllerProvider.notifier).load(refresh: true);
      state = state.copyWith(isSavingTemplate: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSavingTemplate: false,
        errorMessage: 'Lưu mẫu thất bại. Vui lòng thử lại.',
      );
      return false;
    }
  }
}
