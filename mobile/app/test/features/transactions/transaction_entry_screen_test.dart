import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/categories/application/categories_service.dart';
import 'package:app/features/home/data/home_models.dart';
import 'package:app/features/home/data/home_repository.dart';
import 'package:app/features/transactions/data/transaction_models.dart';
import 'package:app/features/transactions/data/transaction_repository.dart';
import 'package:app/features/transactions/presentation/transaction_entry_screen.dart';
import 'package:app/features/wallets/application/wallets_service.dart';
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
  FakeTransactionRepository() : super(Dio());

  CreateTransactionDto? lastCreatedDto;

  @override
  Future<TransactionItem> createTransaction(CreateTransactionDto dto) async {
    lastCreatedDto = dto;
    return transactionItemFixture(
      id: 'tx-new-1',
      title: dto.title,
      amount: dto.amount,
      type: 'EXPENSE',
    );
  }
}

void main() {
  final testCategories = [
    categoryItemFixture(id: 'cat-1', name: 'Ăn uống', type: 'EXPENSE'),
    categoryItemFixture(id: 'cat-2', name: 'Di chuyển', type: 'EXPENSE'),
  ];
  final testIncomeCategories = [
    categoryItemFixture(id: 'cat-inc', name: 'Lương', type: 'INCOME'),
  ];
  final testWallets = [
    walletItemFixture(id: 'w-1', name: 'Tiền mặt', balance: 2000000),
    walletItemFixture(id: 'w-2', name: 'MB Bank', balance: 15000000),
  ];

  Widget buildScreen({
    FakeTransactionRepository? repo,
    TransactionType initialType = TransactionType.expense,
  }) {
    return ProviderScope(
      overrides: [
        homeRepositoryProvider.overrideWithValue(FakeHomeRepository()),
        if (repo != null) transactionRepositoryProvider.overrideWithValue(repo),
        categoriesProvider(
          'EXPENSE',
        ).overrideWith((ref) async => testCategories),
        categoriesProvider(
          'INCOME',
        ).overrideWith((ref) async => testIncomeCategories),
        walletsProvider.overrideWith((ref) async => testWallets),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: TransactionEntryScreen(initialType: initialType),
      ),
    );
  }

  testWidgets(
    'màn hình ghi giao dịch hiển thị keypad, chọn danh mục và chuyển đổi khoản chi/thu nhập',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Check switches
      expect(find.text('Khoản chi'), findsOneWidget);
      expect(find.text('Thu nhập'), findsOneWidget);
      expect(find.text('0đ'), findsOneWidget);
      expect(find.text('Lưu khoản chi'), findsOneWidget);

      // Switch to income
      await tester.tap(find.text('Thu nhập'));
      await tester.pumpAndSettle();

      expect(find.text('Lưu thu nhập'), findsOneWidget);
    },
  );

  testWidgets('nhập số tiền từ keypad và gửi tạo giao dịch thành công', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final fakeRepo = FakeTransactionRepository();
    await tester.pumpWidget(buildScreen(repo: fakeRepo));
    await tester.pumpAndSettle();

    // Tap digits: 5 0 000
    await tester.tap(find.text('5'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('0'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('000'));
    await tester.pumpAndSettle();

    expect(find.text('50.000đ'), findsOneWidget);

    // Tap Save button
    await tester.tap(find.text('Lưu khoản chi'));
    await tester.pumpAndSettle();

    expect(fakeRepo.lastCreatedDto, isNotNull);
    expect(fakeRepo.lastCreatedDto!.amount, 50000);
    expect(fakeRepo.lastCreatedDto!.categoryId, 'cat-1');
  });
}
