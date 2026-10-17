import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/vietnam_time.dart';
import '../../home/data/home_models.dart';
import '../data/budget_repository.dart';

class BudgetsState {
  const BudgetsState({
    required this.selectedMonth,
    this.summary = const AsyncValue.loading(),
    this.isSubmitting = false,
  });

  final DateTime selectedMonth;
  final AsyncValue<BudgetSummary> summary;
  final bool isSubmitting;

  String get monthString =>
      '${selectedMonth.year}-${selectedMonth.month.toString().padLeft(2, '0')}';

  BudgetsState copyWith({
    DateTime? selectedMonth,
    AsyncValue<BudgetSummary>? summary,
    bool? isSubmitting,
  }) {
    return BudgetsState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      summary: summary ?? this.summary,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

final budgetsProvider = NotifierProvider<BudgetsNotifier, BudgetsState>(
  BudgetsNotifier.new,
);

class BudgetsNotifier extends Notifier<BudgetsState> {
  BudgetRepository get _repository => ref.read(budgetRepositoryProvider);

  @override
  BudgetsState build() {
    final now = VietnamTime.now();
    final initialState = BudgetsState(
      selectedMonth: DateTime(now.year, now.month),
    );
    Future.microtask(load);
    return initialState;
  }

  Future<void> load() async {
    state = state.copyWith(summary: const AsyncValue.loading());
    try {
      final summary = await _repository.getBudgets(state.monthString);
      state = state.copyWith(summary: AsyncValue.data(summary));
    } catch (e, st) {
      state = state.copyWith(summary: AsyncValue.error(e, st));
    }
  }

  void previousMonth() {
    final cur = state.selectedMonth;
    state = state.copyWith(selectedMonth: DateTime(cur.year, cur.month - 1));
    load();
  }

  void nextMonth() {
    final cur = state.selectedMonth;
    state = state.copyWith(selectedMonth: DateTime(cur.year, cur.month + 1));
    load();
  }

  Future<bool> createBudget({
    String? categoryId,
    required int limitAmount,
  }) async {
    state = state.copyWith(isSubmitting: true);
    try {
      await _repository.createBudget(
        month: state.monthString,
        limitAmount: limitAmount,
        categoryId: categoryId,
      );
      state = state.copyWith(isSubmitting: false);
      await load();
      return true;
    } catch (_) {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }

  Future<bool> updateBudget(String id, int limitAmount) async {
    state = state.copyWith(isSubmitting: true);
    try {
      await _repository.updateBudget(id, limitAmount);
      state = state.copyWith(isSubmitting: false);
      await load();
      return true;
    } catch (_) {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }

  Future<bool> deleteBudget(String id) async {
    state = state.copyWith(isSubmitting: true);
    try {
      await _repository.deleteBudget(id);
      state = state.copyWith(isSubmitting: false);
      await load();
      return true;
    } catch (_) {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }

  Future<int> copyFromPreviousMonth() async {
    final prev = DateTime(
      state.selectedMonth.year,
      state.selectedMonth.month - 1,
    );
    final prevMonthStr =
        '${prev.year}-${prev.month.toString().padLeft(2, '0')}';

    state = state.copyWith(isSubmitting: true);
    try {
      final count = await _repository.copyBudgets(
        fromMonth: prevMonthStr,
        toMonth: state.monthString,
      );
      state = state.copyWith(isSubmitting: false);
      await load();
      return count;
    } catch (_) {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }
}
