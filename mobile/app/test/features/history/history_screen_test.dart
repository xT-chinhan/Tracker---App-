import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/categories/application/categories_service.dart';
import 'package:app/features/history/presentation/history_screen.dart';
import 'package:app/features/home/data/home_models.dart';
import 'package:app/features/home/data/home_repository.dart';
import 'package:app/features/transactions/data/transaction_repository.dart';
import 'package:app/features/wallets/application/wallets_service.dart';
import '../../helpers/fixtures.dart';

class FakeHomeRepository implements HomeRepository {
  FakeHomeRepository({this.summary});

  final StatsSummary? summary;

  @override
  Future<StatsBalance> getBalance() async => statsBalanceFixture();

  @override
  Future<StatsSummary> getSummary({
    String? month,
    String? from,
    String? to,
    String? walletId,
  }) async => summary ?? statsSummaryFixture(expense: 8680000);

  @override
  Future<BudgetSummary> getBudgets(String month) async =>
      budgetSummaryFixture();

  @override
  Future<TransactionPage> getRecentTransactions({int limit = 5}) async =>
      transactionPageFixture();

  @override
  Future<List<QuickTemplateItem>> getQuickTemplates() async => [];

  @override
  Future<TransactionItem> useQuickTemplate(String id) async =>
      transactionItemFixture();
}

class FakeTransactionRepository extends TransactionRepository {
  FakeTransactionRepository({this.pageData}) : super(Dio());

  final TransactionPage? pageData;

  @override
  Future<TransactionPage> getTransactions({
    int page = 1,
    int limit = 20,
    String? month,
    String? from,
    String? to,
    String? type,
    String? categoryId,
    String? walletId,
    String? q,
  }) async {
    return pageData ??
        transactionPageFixture(
          items: [
            transactionItemFixture(
              id: 'tx-1',
              title: 'Cơm trưa văn phòng',
              amount: 55000,
              type: 'EXPENSE',
            ),
            transactionItemFixture(
              id: 'tx-2',
              title: 'Cà phê sáng',
              amount: 45000,
              type: 'EXPENSE',
            ),
          ],
          total: 2,
        );
  }
}

void main() {
  Widget buildScreen({
    FakeHomeRepository? homeRepo,
    FakeTransactionRepository? txRepo,
  }) {
    return ProviderScope(
      overrides: [
        homeRepositoryProvider.overrideWithValue(
          homeRepo ?? FakeHomeRepository(),
        ),
        transactionRepositoryProvider.overrideWithValue(
          txRepo ?? FakeTransactionRepository(),
        ),
        categoriesProvider(null).overrideWith((ref) async => []),
        walletsProvider.overrideWith((ref) async => []),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const HistoryScreen()),
    );
  }

  testWidgets(
    'HistoryScreen hiển thị tiêu đề, bộ lọc loại và danh sách giao dịch',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Lịch sử'), findsOneWidget);
      expect(find.text('Tất cả'), findsOneWidget);
      expect(find.text('Khoản chi'), findsOneWidget);
      expect(find.text('Thu nhập'), findsOneWidget);

      expect(find.text('Cơm trưa văn phòng'), findsOneWidget);
      expect(find.text('Cà phê sáng'), findsOneWidget);
    },
  );

  testWidgets(
    'HistoryScreen hiển thị trạng thái trống khi không có giao dịch',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final emptyTxRepo = FakeTransactionRepository(
        pageData: transactionPageFixture(items: [], total: 0),
      );

      await tester.pumpWidget(buildScreen(txRepo: emptyTxRepo));
      await tester.pumpAndSettle();

      expect(find.text('Chưa có giao dịch nào'), findsOneWidget);
      expect(find.text('+ Ghi giao dịch đầu tiên'), findsOneWidget);
    },
  );
}
