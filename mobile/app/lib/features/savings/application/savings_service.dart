import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/saving_models.dart';
import '../data/saving_repository.dart';

class SavingsState {
  const SavingsState({
    this.goals = const AsyncValue.loading(),
    this.totalSaved = 0,
    this.totalTarget = 0,
    this.isSubmitting = false,
  });

  final AsyncValue<List<SavingGoalItem>> goals;
  final int totalSaved;
  final int totalTarget;
  final bool isSubmitting;

  SavingsState copyWith({
    AsyncValue<List<SavingGoalItem>>? goals,
    int? totalSaved,
    int? totalTarget,
    bool? isSubmitting,
  }) {
    return SavingsState(
      goals: goals ?? this.goals,
      totalSaved: totalSaved ?? this.totalSaved,
      totalTarget: totalTarget ?? this.totalTarget,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

final savingsProvider = NotifierProvider<SavingsNotifier, SavingsState>(
  SavingsNotifier.new,
);

class SavingsNotifier extends Notifier<SavingsState> {
  SavingRepository get _repository => ref.read(savingRepositoryProvider);

  @override
  SavingsState build() {
    Future.microtask(load);
    return const SavingsState();
  }

  Future<void> load() async {
    state = state.copyWith(goals: const AsyncValue.loading());
    try {
      final goals = await _repository.getGoals();
      final totalSaved = goals.fold<int>(0, (s, g) => s + g.savedAmount);
      final totalTarget = goals.fold<int>(0, (s, g) => s + g.targetAmount);

      state = state.copyWith(
        goals: AsyncValue.data(goals),
        totalSaved: totalSaved,
        totalTarget: totalTarget,
      );
    } catch (e, st) {
      state = state.copyWith(goals: AsyncValue.error(e, st));
    }
  }

  Future<SavingGoalItem> createGoal(CreateGoalDto dto) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final created = await _repository.createGoal(dto);
      state = state.copyWith(isSubmitting: false);
      await load();
      return created;
    } catch (_) {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }

  Future<void> deleteGoal(String id) async {
    state = state.copyWith(isSubmitting: true);
    try {
      await _repository.deleteGoal(id);
      state = state.copyWith(isSubmitting: false);
      await load();
    } catch (_) {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }

  Future<void> deposit({
    required String goalId,
    required int amount,
    required String walletId,
    String? date,
  }) async {
    await _repository.deposit(
      goalId,
      DepositDto(amount: amount, walletId: walletId, date: date),
    );
    ref.invalidate(savingDetailProvider(goalId));
    await load();
  }

  Future<void> withdraw({
    required String goalId,
    required String walletId,
  }) async {
    await _repository.withdraw(goalId, WithdrawDto(walletId: walletId));
    ref.invalidate(savingDetailProvider(goalId));
    await load();
  }

  Future<void> updateGoal({
    required String goalId,
    required UpdateGoalDto dto,
  }) async {
    await _repository.updateGoal(goalId, dto);
    ref.invalidate(savingDetailProvider(goalId));
    await load();
  }
}

// Single Goal Detail Provider
final savingDetailProvider = FutureProvider.autoDispose
    .family<SavingGoalDetail, String>((ref, id) async {
      final repo = ref.watch(savingRepositoryProvider);
      return repo.getGoal(id);
    });
