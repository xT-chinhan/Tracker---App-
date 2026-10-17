import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/auth/application/app_session.dart';
import 'package:app/features/home/data/home_models.dart';
import 'package:app/features/home/data/home_repository.dart';
import 'package:app/features/transfers/data/transfer_models.dart';
import 'package:app/features/transfers/data/transfer_repository.dart';
import 'package:app/features/wallets/data/wallet_models.dart';
import 'package:app/features/wallets/data/wallet_repository.dart';
import 'package:app/features/wallets/presentation/wallet_form_sheet.dart';
import 'package:app/features/wallets/presentation/wallets_screen.dart';
import '../../helpers/fixtures.dart';

class FakeWalletRepository implements WalletRepository {
  WalletListResponse? response;
  int createCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;

  @override
  Future<WalletListResponse> getWallets() async {
    return response ??
        const WalletListResponse(
          totalBalance: 26022000,
          items: [
            WalletItem(
              id: 'w-1',
              name: 'MB Bank',
              type: 'BANK',
              balance: 18672000,
            ),
            WalletItem(
              id: 'w-2',
              name: 'Techcombank',
              type: 'BANK',
              balance: 4000000,
            ),
            WalletItem(
              id: 'w-3',
              name: 'Tiền mặt',
              type: 'CASH',
              balance: 1850000,
            ),
            WalletItem(
              id: 'w-4',
              name: 'MoMo',
              type: 'EWALLET',
              balance: 1500000,
            ),
          ],
        );
  }

  @override
  Future<WalletItem> getWallet(String id) async {
    final list = await getWallets();
    return list.items.firstWhere((w) => w.id == id);
  }

  @override
  Future<WalletItem> createWallet(CreateWalletDto dto) async {
    createCalls++;
    return WalletItem(
      id: 'new-id',
      name: dto.name,
      type: dto.type,
      balance: dto.initialBalance ?? 0,
    );
  }

  @override
  Future<WalletItem> updateWallet(String id, UpdateWalletDto dto) async {
    updateCalls++;
    final existing = await getWallet(id);
    return existing.copyWith(
      name: dto.name ?? existing.name,
      type: dto.type ?? existing.type,
    );
  }

  @override
  Future<Map<String, dynamic>> deleteWallet(String id) async {
    deleteCalls++;
    return {'archived': false};
  }

  @override
  Future<WalletItem> restoreWallet(String id) async {
    final existing = await getWallet(id);
    return existing.copyWith(isArchived: false);
  }
}

class FakeTransferRepository implements TransferRepository {
  List<TransferItem>? transfers;

  @override
  Future<List<TransferItem>> getTransfers({
    int page = 1,
    int limit = 20,
    String? walletId,
  }) async {
    return transfers ??
        [
          TransferItem(
            id: 't-1',
            fromWalletId: 'w-1',
            toWalletId: 'w-4',
            amount: 500000,
            occurredAt: DateTime(2026, 9, 18),
            note: 'Nạp ví',
            fromWallet: const WalletMeta(
              id: 'w-1',
              name: 'MB Bank',
              type: 'BANK',
            ),
            toWallet: const WalletMeta(
              id: 'w-4',
              name: 'MoMo',
              type: 'EWALLET',
            ),
          ),
        ];
  }

  @override
  Future<TransferItem> createTransfer(CreateTransferDto dto) async {
    throw UnimplementedError();
  }
}

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

void main() {
  Widget buildTestableWidget({
    required FakeWalletRepository walletRepo,
    required FakeTransferRepository transferRepo,
  }) {
    final session = AppSessionController();
    session.authenticate(
      value: userFixture(),
      publicConfig: publicConfigFixture(),
    );

    return ProviderScope(
      overrides: [
        walletRepositoryProvider.overrideWithValue(walletRepo),
        transferRepositoryProvider.overrideWithValue(transferRepo),
        homeRepositoryProvider.overrideWithValue(FakeHomeRepository()),
        appSessionProvider.overrideWith((ref) => session),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const WalletsScreen()),
    );
  }

  testWidgets(
    'WalletsScreen hiển thị tổng số dư, danh sách ví và chuyển gần đây khớp mockup 15',
    (tester) async {
      final walletRepo = FakeWalletRepository();
      final transferRepo = FakeTransferRepository();

      await tester.pumpWidget(
        buildTestableWidget(walletRepo: walletRepo, transferRepo: transferRepo),
      );
      await tester.pumpAndSettle();

      // Tiêu đề & Tổng số dư
      expect(find.text('Ví'), findsOneWidget);
      expect(find.text('Tổng số dư · 4 ví'), findsOneWidget);
      expect(find.text('26.022.000đ'), findsOneWidget);
      expect(find.text('72% nằm ở MB Bank'), findsOneWidget);

      // Danh sách ví
      expect(find.text('MB Bank'), findsAtLeastNWidgets(1));
      expect(find.text('18.672.000đ'), findsOneWidget);
      expect(find.text('Techcombank'), findsOneWidget);
      expect(find.text('4.000.000đ'), findsOneWidget);
      expect(find.text('Tiền mặt'), findsAtLeastNWidgets(1));
      expect(find.text('1.850.000đ'), findsOneWidget);
      expect(find.text('MoMo'), findsAtLeastNWidgets(1));
      expect(find.text('1.500.000đ'), findsOneWidget);

      // Nút Chuyển tiền giữa ví
      expect(find.text('Chuyển tiền giữa ví'), findsOneWidget);

      // Chuyển gần đây
      expect(find.text('Chuyển gần đây'), findsOneWidget);
      expect(find.text('MB Bank → MoMo'), findsOneWidget);
      expect(find.text('18/09 · Nạp ví'), findsOneWidget);
      expect(find.text('500.000đ'), findsOneWidget);
    },
  );

  testWidgets('WalletsScreen hiển thị empty state khi không có ví', (
    tester,
  ) async {
    final walletRepo = FakeWalletRepository()
      ..response = const WalletListResponse(totalBalance: 0, items: []);
    final transferRepo = FakeTransferRepository()..transfers = [];

    await tester.pumpWidget(
      buildTestableWidget(walletRepo: walletRepo, transferRepo: transferRepo),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chưa có ví nào.'), findsOneWidget);
    expect(find.text('+ Thêm ví đầu tiên'), findsOneWidget);
  });

  testWidgets('WalletFormSheet cho phép thêm ví mới', (tester) async {
    final walletRepo = FakeWalletRepository();
    final session = AppSessionController();
    session.authenticate(
      value: userFixture(),
      publicConfig: publicConfigFixture(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          walletRepositoryProvider.overrideWithValue(walletRepo),
          homeRepositoryProvider.overrideWithValue(FakeHomeRepository()),
          appSessionProvider.overrideWith((ref) => session),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: WalletFormSheet()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Thêm ví mới'), findsOneWidget);
    expect(find.text('Tên ví'), findsOneWidget);
    expect(find.text('Loại ví'), findsOneWidget);
    expect(find.text('Số dư ban đầu (VNĐ)'), findsOneWidget);

    // Nhập tên ví
    await tester.enterText(find.byType(TextField).first, 'Ví phụ');
    await tester.pumpAndSettle();

    // Bấm nút Tạo ví
    await tester.tap(find.text('Tạo ví'));
    await tester.pumpAndSettle();

    expect(walletRepo.createCalls, 1);
  });
}
