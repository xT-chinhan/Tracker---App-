import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/vietnam_time.dart';
import '../../home/data/home_models.dart';
import '../../home/data/home_repository.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/presentation/transaction_entry_screen.dart';

class TransactionDayGroup {
  const TransactionDayGroup({
    required this.date,
    required this.dateLabel,
    required this.totalNet,
    required this.items,
  });

  final DateTime date;
  final String dateLabel;
  final int totalNet;
  final List<TransactionItem> items;
}

class HistoryFilter {
  const HistoryFilter({
    required this.selectedMonth,
    this.type,
    this.categoryId,
    this.walletId,
    this.query = '',
  });

  final DateTime selectedMonth;
  final TransactionType? type;
  final String? categoryId;
  final String? walletId;
  final String query;

  String get monthString =>
      '${selectedMonth.year}-${selectedMonth.month.toString().padLeft(2, '0')}';

  String? get apiType => switch (type) {
    TransactionType.expense => 'EXPENSE',
    TransactionType.income => 'INCOME',
    null => null,
  };

  HistoryFilter copyWith({
    DateTime? selectedMonth,
    TransactionType? type,
    bool clearType = false,
    String? categoryId,
    bool clearCategory = false,
    String? walletId,
    bool clearWallet = false,
    String? query,
  }) {
    return HistoryFilter(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      type: clearType ? null : (type ?? this.type),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      walletId: clearWallet ? null : (walletId ?? this.walletId),
      query: query ?? this.query,
    );
  }
}

class HistoryState {
  const HistoryState({
    required this.filter,
    this.summary,
    this.transactions = const <TransactionItem>[],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.page = 1,
    this.totalPages = 1,
    this.total = 0,
    this.errorMessage,
  });

  final HistoryFilter filter;
  final StatsSummary? summary;
  final List<TransactionItem> transactions;
  final bool isLoading;
  final bool isLoadingMore;
  final int page;
  final int totalPages;
  final int total;
  final String? errorMessage;

  HistoryState copyWith({
    HistoryFilter? filter,
    StatsSummary? summary,
    List<TransactionItem>? transactions,
    bool? isLoading,
    bool? isLoadingMore,
    int? page,
    int? totalPages,
    int? total,
    String? errorMessage,
  }) {
    return HistoryState(
      filter: filter ?? this.filter,
      summary: summary ?? this.summary,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      errorMessage: errorMessage,
    );
  }

  List<TransactionDayGroup> get dayGroups {
    if (transactions.isEmpty) return const [];
    final Map<String, List<TransactionItem>> grouped = {};
    for (final tx in transactions) {
      final vnDate = VietnamTime.fromDateTime(tx.occurredAt);
      final key =
          '${vnDate.year}-${vnDate.month.toString().padLeft(2, '0')}-${vnDate.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    final now = VietnamTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));

    final groups = <TransactionDayGroup>[];
    grouped.forEach((key, items) {
      final firstVn = VietnamTime.fromDateTime(items.first.occurredAt);
      final dayDate = DateTime(firstVn.year, firstVn.month, firstVn.day);

      String label;
      if (dayDate == today) {
        label = 'Hôm nay';
      } else if (dayDate == yesterday) {
        label = 'Hôm qua';
      } else if (dayDate == twoDaysAgo) {
        label = '2 ngày trước';
      } else {
        label =
            '${dayDate.day.toString().padLeft(2, '0')}/${dayDate.month.toString().padLeft(2, '0')}/${dayDate.year}';
      }

      var dayNet = 0;
      for (final it in items) {
        if (it.type == 'INCOME') {
          dayNet += it.amount;
        } else {
          dayNet -= it.amount;
        }
      }

      groups.add(
        TransactionDayGroup(
          date: dayDate,
          dateLabel: label,
          totalNet: dayNet,
          items: items,
        ),
      );
    });

    return groups;
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, HistoryState>(
  HistoryNotifier.new,
);

class HistoryNotifier extends Notifier<HistoryState> {
  Timer? _debounceTimer;

  @override
  HistoryState build() {
    final now = VietnamTime.now();
    final filter = HistoryFilter(
      selectedMonth: DateTime(now.year, now.month, 1),
    );
    final state = HistoryState(filter: filter, isLoading: true);
    // Kick off initial load
    Future.microtask(() => load(resetPage: true));
    return state;
  }

  Future<void> load({bool resetPage = true}) async {
    final currentPage = resetPage ? 1 : state.page;
    state = state.copyWith(
      isLoading: resetPage,
      page: currentPage,
      errorMessage: null,
    );

    try {
      final txRepo = ref.read(transactionRepositoryProvider);
      final homeRepo = ref.read(homeRepositoryProvider);

      final filter = state.filter;
      final results = await Future.wait([
        homeRepo.getSummary(
          month: filter.monthString,
          walletId: filter.walletId,
        ),
        txRepo.getTransactions(
          page: currentPage,
          limit: 20,
          month: filter.monthString,
          type: filter.apiType,
          categoryId: filter.categoryId,
          walletId: filter.walletId,
          q: filter.query,
        ),
      ]);

      final summary = results[0] as StatsSummary;
      final pageData = results[1] as TransactionPage;

      state = state.copyWith(
        summary: summary,
        transactions: pageData.items,
        total: pageData.total,
        totalPages: pageData.totalPages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải lịch sử giao dịch. Vui lòng thử lại.',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.page >= state.totalPages) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final txRepo = ref.read(transactionRepositoryProvider);
      final filter = state.filter;
      final nextPage = state.page + 1;

      final pageData = await txRepo.getTransactions(
        page: nextPage,
        limit: 20,
        month: filter.monthString,
        type: filter.apiType,
        categoryId: filter.categoryId,
        walletId: filter.walletId,
        q: filter.query,
      );

      state = state.copyWith(
        transactions: [...state.transactions, ...pageData.items],
        page: nextPage,
        totalPages: pageData.totalPages,
        total: pageData.total,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void previousMonth() {
    final cur = state.filter.selectedMonth;
    final prev = DateTime(cur.year, cur.month - 1, 1);
    state = state.copyWith(filter: state.filter.copyWith(selectedMonth: prev));
    load(resetPage: true);
  }

  void nextMonth() {
    final cur = state.filter.selectedMonth;
    final next = DateTime(cur.year, cur.month + 1, 1);
    state = state.copyWith(filter: state.filter.copyWith(selectedMonth: next));
    load(resetPage: true);
  }

  void setMonth(DateTime month) {
    state = state.copyWith(
      filter: state.filter.copyWith(
        selectedMonth: DateTime(month.year, month.month, 1),
      ),
    );
    load(resetPage: true);
  }

  void setType(TransactionType? type) {
    if (state.filter.type == type) return;
    state = state.copyWith(
      filter: state.filter.copyWith(type: type, clearType: type == null),
    );
    load(resetPage: true);
  }

  void onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      state = state.copyWith(
        filter: state.filter.copyWith(query: query.trim()),
      );
      load(resetPage: true);
    });
  }

  void setCategoryFilter(String? categoryId) {
    state = state.copyWith(
      filter: state.filter.copyWith(
        categoryId: categoryId,
        clearCategory: categoryId == null,
      ),
    );
    load(resetPage: true);
  }

  void setWalletFilter(String? walletId) {
    state = state.copyWith(
      filter: state.filter.copyWith(
        walletId: walletId,
        clearWallet: walletId == null,
      ),
    );
    load(resetPage: true);
  }

  void clearExtraFilters() {
    state = state.copyWith(
      filter: state.filter.copyWith(clearCategory: true, clearWallet: true),
    );
    load(resetPage: true);
  }
}
