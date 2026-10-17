import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/history/application/history_service.dart';
import 'package:app/features/transactions/presentation/transaction_entry_screen.dart';
import '../../helpers/fixtures.dart';

void main() {
  group('HistoryState dayGroups and filtering', () {
    test('nhóm giao dịch theo ngày và tính tổng net từng ngày', () {
      final now = DateTime.now();
      final todayTx1 = transactionItemFixture(
        id: 'tx-1',
        title: 'Cơm trưa',
        amount: 55000,
        type: 'EXPENSE',
      ).copyWith(occurredAt: now);

      final todayTx2 = transactionItemFixture(
        id: 'tx-2',
        title: 'Cà phê sáng',
        amount: 45000,
        type: 'EXPENSE',
      ).copyWith(occurredAt: now);

      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayTx = transactionItemFixture(
        id: 'tx-3',
        title: 'Lương dự án',
        amount: 2000000,
        type: 'INCOME',
      ).copyWith(occurredAt: yesterday);

      final state = HistoryState(
        filter: HistoryFilter(selectedMonth: DateTime(now.year, now.month, 1)),
        transactions: [todayTx1, todayTx2, yesterdayTx],
      );

      final groups = state.dayGroups;
      expect(groups.length, 2);

      // First group is today
      expect(groups[0].dateLabel, 'Hôm nay');
      expect(groups[0].items.length, 2);
      expect(groups[0].totalNet, -100000);

      // Second group is yesterday
      expect(groups[1].dateLabel, 'Hôm qua');
      expect(groups[1].items.length, 1);
      expect(groups[1].totalNet, 2000000);
    });

    test('HistoryFilter sinh monthString và apiType chính xác', () {
      final filter = HistoryFilter(selectedMonth: DateTime(2026, 9, 1));
      expect(filter.monthString, '2026-09');
      expect(filter.apiType, isNull);

      final filterExpense = filter.copyWith(type: TransactionType.expense);
      expect(filterExpense.apiType, 'EXPENSE');

      final filterIncome = filter.copyWith(type: TransactionType.income);
      expect(filterIncome.apiType, 'INCOME');
    });
  });
}
