import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/home/data/home_models.dart';
import 'package:app/features/home/data/home_repository.dart';
import 'package:app/features/transactions/data/transaction_repository.dart';
import 'package:app/features/transactions/presentation/transaction_detail_screen.dart';
import '../../helpers/fixtures.dart';

class FakeHomeRepository implements HomeRepository {
  @override
  Future<StatsBalance> getBalance() async => statsBalanceFixture();

  @override
  Future<StatsSummary> getSummary({
    String? month,
    String? from,
    String? to,
    String? walletId,
  }) async => statsSummaryFixture();

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
  FakeTransactionRepository({this.item}) : super(Dio());

  final TransactionItem? item;
  String? deletedId;

  @override
  Future<TransactionItem> getTransaction(String id) async {
    return item ??
        transactionItemFixture(
          id: id,
          title: 'Tiền nhà tháng 9',
          amount: 2500000,
          type: 'EXPENSE',
        );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    deletedId = id;
  }
}

void main() {
  Widget buildScreen({
    required String transactionId,
    FakeTransactionRepository? txRepo,
  }) {
    return ProviderScope(
      overrides: [
        homeRepositoryProvider.overrideWithValue(FakeHomeRepository()),
        transactionRepositoryProvider.overrideWithValue(
          txRepo ?? FakeTransactionRepository(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: TransactionDetailScreen(transactionId: transactionId),
      ),
    );
  }

  testWidgets(
    'TransactionDetailScreen hiển thị chi tiết giao dịch khớp mockup 08',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final tx = transactionItemFixture(
        id: 'tx-rent-1',
        title: 'Tiền nhà tháng 9',
        amount: 2500000,
        type: 'EXPENSE',
      ).copyWith(recurring: true);

      final fakeRepo = FakeTransactionRepository(item: tx);

      await tester.pumpWidget(
        buildScreen(transactionId: 'tx-rent-1', txRepo: fakeRepo),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tiền nhà tháng 9'), findsWidgets);
      expect(find.text('-2.500.000đ'), findsOneWidget);
      expect(find.text('Khoản chi'), findsOneWidget);
      expect(find.text('Ăn uống'), findsOneWidget);
      expect(find.text('Tiền mặt'), findsOneWidget);
      expect(find.text('Tạo tự động · Định kỳ hằng tháng'), findsOneWidget);
      expect(find.text('Xóa giao dịch'), findsOneWidget);
      expect(find.text('Sửa'), findsOneWidget);
    },
  );

  testWidgets('Xóa giao dịch hiển thị hộp thoại xác nhận và gọi API delete', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final fakeRepo = FakeTransactionRepository();

    await tester.pumpWidget(
      buildScreen(transactionId: 'tx-del-1', txRepo: fakeRepo),
    );
    await tester.pumpAndSettle();

    // Tap Xóa giao dịch button
    await tester.tap(find.text('Xóa giao dịch'));
    await tester.pumpAndSettle();

    // Dialog appears
    expect(find.text('Xóa giao dịch?'), findsOneWidget);
    expect(
      find.text(
        'Hành động này sẽ cập nhật lại số dư ví và không thể hoàn tác.',
      ),
      findsOneWidget,
    );

    // Tap confirm Xóa
    await tester.tap(find.text('Xóa'));
    await tester.pumpAndSettle();

    expect(fakeRepo.deletedId, 'tx-del-1');
  });
}
