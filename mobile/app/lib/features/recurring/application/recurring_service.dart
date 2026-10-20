import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/recurring_models.dart';
import '../data/recurring_repository.dart';

class RecurringState {
  const RecurringState({
    this.rules = const AsyncValue.loading(),
    this.isSubmitting = false,
  });

  final AsyncValue<List<RecurringRuleItem>> rules;
  final bool isSubmitting;

  List<RecurringRuleItem> get activeRules =>
      rules.value?.where((r) => r.isActive).toList() ?? [];

  List<RecurringRuleItem> get pausedRules =>
      rules.value?.where((r) => !r.isActive).toList() ?? [];

  RecurringState copyWith({
    AsyncValue<List<RecurringRuleItem>>? rules,
    bool? isSubmitting,
  }) {
    return RecurringState(
      rules: rules ?? this.rules,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

final recurringProvider = NotifierProvider<RecurringNotifier, RecurringState>(
  RecurringNotifier.new,
);

class RecurringNotifier extends Notifier<RecurringState> {
  RecurringRepository get _repo => ref.read(recurringRepositoryProvider);

  @override
  RecurringState build() {
    Future.microtask(load);
    return const RecurringState();
  }

  Future<void> load() async {
    state = state.copyWith(rules: const AsyncValue.loading());
    try {
      final items = await _repo.getRules();
      state = state.copyWith(rules: AsyncValue.data(items));
    } catch (e, st) {
      state = state.copyWith(rules: AsyncValue.error(e, st));
    }
  }

  Future<RecurringRuleItem> createRule(CreateRecurringDto dto) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final created = await _repo.createRule(dto);
      await load();
      return created;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<RecurringRuleItem> updateRule(
    String id,
    UpdateRecurringDto dto,
  ) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final updated = await _repo.updateRule(id, dto);
      await load();
      return updated;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<void> deleteRule(String id) async {
    state = state.copyWith(isSubmitting: true);
    try {
      await _repo.deleteRule(id);
      await load();
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<void> pauseRule(String id) async {
    state = state.copyWith(isSubmitting: true);
    try {
      await _repo.pauseRule(id);
      await load();
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<void> resumeRule(String id) async {
    state = state.copyWith(isSubmitting: true);
    try {
      await _repo.resumeRule(id);
      await load();
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}
