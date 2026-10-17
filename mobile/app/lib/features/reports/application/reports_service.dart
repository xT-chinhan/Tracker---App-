import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/vietnam_time.dart';
import '../data/report_models.dart';
import '../data/report_repository.dart';

class ReportsState {
  const ReportsState({
    required this.selectedMonth,
    this.selectedWalletId,
    this.report = const AsyncValue.loading(),
    this.isExporting = false,
    this.exportError,
  });

  final DateTime selectedMonth;
  final String? selectedWalletId;
  final AsyncValue<ReportData> report;
  final bool isExporting;
  final String? exportError;

  String get monthString =>
      '${selectedMonth.year}-${selectedMonth.month.toString().padLeft(2, '0')}';

  ReportsState copyWith({
    DateTime? selectedMonth,
    String? selectedWalletId,
    bool clearWallet = false,
    AsyncValue<ReportData>? report,
    bool? isExporting,
    String? exportError,
    bool clearExportError = false,
  }) {
    return ReportsState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedWalletId: clearWallet
          ? null
          : (selectedWalletId ?? this.selectedWalletId),
      report: report ?? this.report,
      isExporting: isExporting ?? this.isExporting,
      exportError: clearExportError ? null : (exportError ?? this.exportError),
    );
  }
}

final reportsProvider = NotifierProvider<ReportsNotifier, ReportsState>(
  ReportsNotifier.new,
);

class ReportsNotifier extends Notifier<ReportsState> {
  ReportRepository get _repository => ref.read(reportRepositoryProvider);

  @override
  ReportsState build() {
    final now = VietnamTime.now();
    final initialState = ReportsState(
      selectedMonth: DateTime(now.year, now.month),
    );
    Future.microtask(load);
    return initialState;
  }

  Future<void> load() async {
    state = state.copyWith(report: const AsyncValue.loading());
    try {
      final monthStr = state.monthString;
      var report = await _repository.getReport(
        month: monthStr,
        walletId: state.selectedWalletId,
      );

      // If there are expense categories, enrich with top category comparison
      if (report.expenseByCategory.isNotEmpty) {
        final topCat = report.expenseByCategory.first;
        final prevMonthDate = DateTime(
          state.selectedMonth.year,
          state.selectedMonth.month - 1,
        );
        final prevMonthStr =
            '${prevMonthDate.year}-${prevMonthDate.month.toString().padLeft(2, '0')}';

        try {
          final prevCats = await _repository.getByCategory(
            month: prevMonthStr,
            walletId: state.selectedWalletId,
            type: 'EXPENSE',
          );
          final prevCat = prevCats
              .where((c) => c.category.id == topCat.category.id)
              .firstOrNull;
          final prevAmount = prevCat?.amount ?? 0;
          final curAmount = topCat.amount;
          final diff = curAmount - prevAmount;
          final pct = prevAmount > 0
              ? ((diff / prevAmount) * 1000).round() / 10
              : (curAmount > 0 ? 100.0 : 0.0);
          final trend = diff > 0
              ? 'increase'
              : (diff < 0 ? 'decrease' : 'stable');

          report = report.copyWith(
            topCategoryComparison: ComparisonMetric(
              current: curAmount,
              previous: prevAmount,
              difference: diff,
              percentageChange: pct,
              trend: trend,
              categoryName: topCat.category.name,
            ),
          );
        } catch (_) {
          // If previous category fetch fails, still show top category
          report = report.copyWith(
            topCategoryComparison: ComparisonMetric(
              current: topCat.amount,
              previous: 0,
              difference: topCat.amount,
              percentageChange: 100.0,
              trend: 'increase',
              categoryName: topCat.category.name,
            ),
          );
        }
      }

      state = state.copyWith(report: AsyncValue.data(report));
    } catch (e, st) {
      state = state.copyWith(report: AsyncValue.error(e, st));
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

  void selectWallet(String? walletId) {
    state = state.copyWith(
      selectedWalletId: walletId,
      clearWallet: walletId == null,
    );
    load();
  }

  Future<String?> exportCsv() async {
    state = state.copyWith(isExporting: true, clearExportError: true);
    try {
      final csv = await _repository.exportCsv(
        month: state.monthString,
        walletId: state.selectedWalletId,
      );
      state = state.copyWith(isExporting: false);
      return csv;
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        exportError: 'Không thể xuất file CSV: $e',
      );
      return null;
    }
  }
}
