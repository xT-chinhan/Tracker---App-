import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/home/data/home_models.dart';
import 'package:app/features/home/data/home_repository.dart';
import 'package:app/features/transfers/data/transfer_models.dart';
import 'package:app/features/transfers/data/transfer_repository.dart';
import 'package:app/features/transfers/presentation/transfer_screen.dart';
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

class FakeTransferRepository extends TransferRepository {
  FakeTransferRepository() : super(Dio());

  CreateTransferDto? lastCreatedDto;

  @override
  Future<TransferItem> createTransfer(CreateTransferDto dto) async {
    lastCreatedDto = dto;
    return TransferItem(
      id: 'tr-1',
      fromWalletId: dto.fromWalletId,
      toWalletId: dto.toWalletId,
      amount: dto.amount,
      occurredAt: DateTime.now(),
    );
  }
}

void main() {
  final testWallets = [
    walletItemFixture(id: 'w-1', name: 'Tiền mặt', balance: 2000000),
    walletItemFixture(id: 'w-2', name: 'MB Bank', balance: 10000000),
  ];

  Widget buildScreen({FakeTransferRepository? repo}) {
    return ProviderScope(
      overrides: [
        homeRepositoryProvider.overrideWithValue(FakeHomeRepository()),
        if (repo != null) transferRepositoryProvider.overrideWithValue(repo),
        walletsProvider.overrideWith((ref) async => testWallets),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const TransferScreen()),
    );
  }

  testWidgets(
    'màn hình chuyển tiền hiển thị ví nguồn, ví đích và nút hoán đổi ví',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Chuyển tiền giữa ví'), findsOneWidget);
      expect(find.text('Tiền mặt'), findsOneWidget);
      expect(find.text('MB Bank'), findsOneWidget);

      // Tap swap button
      await tester.tap(find.byIcon(LucideIcons.arrow_up_down));
      await tester.pumpAndSettle();

      // Verify wallets are swapped: From is now MB Bank, To is Tiền mặt
      expect(find.text('Tiền mặt'), findsOneWidget);
      expect(find.text('MB Bank'), findsOneWidget);
    },
  );

  testWidgets('chọn chip số tiền nhanh và gửi chuyển tiền thành công', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final fakeRepo = FakeTransferRepository();
    await tester.pumpWidget(buildScreen(repo: fakeRepo));
    await tester.pumpAndSettle();

    // Tap quick chip 500.000
    await tester.tap(find.text('500.000'));
    await tester.pumpAndSettle();

    expect(find.text('500.000đ'), findsWidgets);
    expect(find.text('Chuyển 500.000đ'), findsOneWidget);

    // Tap submit button
    await tester.tap(find.text('Chuyển 500.000đ'));
    await tester.pumpAndSettle();

    expect(fakeRepo.lastCreatedDto, isNotNull);
    expect(fakeRepo.lastCreatedDto!.amount, 500000);
    expect(fakeRepo.lastCreatedDto!.fromWalletId, 'w-1');
    expect(fakeRepo.lastCreatedDto!.toWalletId, 'w-2');
  });
}
