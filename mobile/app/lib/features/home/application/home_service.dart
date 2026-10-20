import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/vietnam_time.dart';
import '../../notifications/application/notifications_service.dart';
import '../data/home_models.dart';
import '../data/home_repository.dart';

class HomeState {
  const HomeState({
    this.balance,
    this.todaySummary,
    this.monthSummary,
    this.budgets,
    this.recentTransactions = const <TransactionItem>[],
    this.quickTemplates = const <QuickTemplateItem>[],
    this.isBalanceHidden = false,
    this.isLoading = false,
    this.isSubmittingQuickTemplate = false,
    this.errorMessage,
  });

  final StatsBalance? balance;
  final StatsSummary? todaySummary;
  final StatsSummary? monthSummary;
  final BudgetSummary? budgets;
  final List<TransactionItem> recentTransactions;
  final List<QuickTemplateItem> quickTemplates;
  final bool isBalanceHidden;
  final bool isLoading;
  final bool isSubmittingQuickTemplate;
  final String? errorMessage;

  HomeState copyWith({
    StatsBalance? balance,
    StatsSummary? todaySummary,
    StatsSummary? monthSummary,
    BudgetSummary? budgets,
    List<TransactionItem>? recentTransactions,
    List<QuickTemplateItem>? quickTemplates,
    bool? isBalanceHidden,
    bool? isLoading,
    bool? isSubmittingQuickTemplate,
    String? errorMessage,
  }) => HomeState(
    balance: balance ?? this.balance,
    todaySummary: todaySummary ?? this.todaySummary,
    monthSummary: monthSummary ?? this.monthSummary,
    budgets: budgets ?? this.budgets,
    recentTransactions: recentTransactions ?? this.recentTransactions,
    quickTemplates: quickTemplates ?? this.quickTemplates,
    isBalanceHidden: isBalanceHidden ?? this.isBalanceHidden,
    isLoading: isLoading ?? this.isLoading,
    isSubmittingQuickTemplate:
        isSubmittingQuickTemplate ?? this.isSubmittingQuickTemplate,
    errorMessage: errorMessage,
  );
}

final homeControllerProvider = NotifierProvider<HomeController, HomeState>(
  HomeController.new,
);

class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() {
    load();
    return const HomeState(isLoading: true);
  }

  void toggleBalanceVisibility() {
    state = state.copyWith(isBalanceHidden: !state.isBalanceHidden);
  }

  Future<T?> _safe<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (_) {
      return null;
    }
  }

  Future<void> load({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    final repo = ref.read(homeRepositoryProvider);
    final now = VietnamTime.now();
    final todayStr =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowStr =
        '${tomorrow.year.toString().padLeft(4, '0')}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
    final monthStr = VietnamTime.monthKey(now);

    try {
      final balance = await _safe(() => repo.getBalance());
      final todaySummary = await _safe(
        () => repo.getSummary(from: todayStr, to: tomorrowStr),
      );
      final monthSummary = await _safe(() => repo.getSummary(month: monthStr));
      final budgets = await _safe(() => repo.getBudgets(monthStr));
      final recentTx = await _safe(() => repo.getRecentTransactions(limit: 5));
      final quickTemplates =
          await _safe(() => repo.getQuickTemplates()) ??
          const <QuickTemplateItem>[];

      state = state.copyWith(
        balance: balance,
        todaySummary: todaySummary,
        monthSummary: monthSummary,
        budgets: budgets,
        recentTransactions: recentTx?.items ?? state.recentTransactions,
        quickTemplates: quickTemplates,
        isLoading: false,
        errorMessage: null,
      );

      // Also trigger unread count refresh in background
      ref.read(unreadCountProvider.notifier).refresh().ignore();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải dữ liệu trang chủ. Vui lòng thử lại.',
      );
    }
  }

  Future<String?> useQuickTemplate(String id) async {
    state = state.copyWith(isSubmittingQuickTemplate: true);
    final repo = ref.read(homeRepositoryProvider);
    try {
      final tx = await repo.useQuickTemplate(id);
      await load(refresh: false);
      state = state.copyWith(isSubmittingQuickTemplate: false);
      return tx.title;
    } catch (e) {
      state = state.copyWith(isSubmittingQuickTemplate: false);
      rethrow;
    }
  }
}
