import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/auth/application/app_session.dart';
import 'package:app/features/savings/data/saving_models.dart';
import 'package:app/features/savings/data/saving_repository.dart';
import 'package:app/features/savings/presentation/deposit_sheet.dart';
import 'package:app/features/savings/presentation/saving_detail_screen.dart';
import 'package:app/features/savings/presentation/savings_screen.dart';
import 'package:app/features/wallets/application/wallets_service.dart';
import 'package:app/features/wallets/data/wallet_models.dart';
import '../../helpers/fixtures.dart';

class FakeSavingRepository implements SavingRepository {
  List<SavingGoalItem>? goalsList;
  SavingGoalDetail? detail;
  int depositCalls = 0;
  int withdrawCalls = 0;

  @override
  Future<List<SavingGoalItem>> getGoals({String? status}) async {
    return goalsList ??
        [
          SavingGoalItem(
            id: 'g-1',
            name: 'Du lịch Nhật Bản',
            targetAmount: 30000000,
            savedAmount: 18000000,
            remaining: 12000000,
            startDate: DateTime(2026, 1, 1),
            targetDate: DateTime(2026, 12, 31),
            icon: 'plane',
            progress: 60.0,
            daysLeft: 75,
          ),
          SavingGoalItem(
            id: 'g-2',
            name: 'MacBook Pro M3',
            targetAmount: 45000000,
            savedAmount: 45000000,
            remaining: 0,
            startDate: DateTime(2026, 1, 1),
            targetDate: DateTime(2026, 11, 15),
            icon: 'laptop',
            progress: 100.0,
            daysLeft: 29,
          ),
        ];
  }

  @override
  Future<SavingGoalDetail> getGoal(String id) async {
    return detail ??
        SavingGoalDetail(
          id: id,
          name: 'Du lịch Nhật Bản',
          targetAmount: 30000000,
          savedAmount: 18000000,
          remaining: 12000000,
          startDate: DateTime(2026, 1, 1),
          targetDate: DateTime(2026, 12, 31),
          icon: 'plane',
          progress: 60.0,
          daysLeft: 75,
          entries: [
            SavingEntryItem(
              id: 'e-1',
              goalId: id,
              walletId: 'w-1',
              type: 'DEPOSIT',
              amount: 5000000,
              date: DateTime(2026, 9, 15),
              createdAt: DateTime(2026, 9, 15),
              wallet: const SavingWalletMeta(
                id: 'w-1',
                name: 'Vietcombank',
                type: 'BANK',
              ),
            ),
          ],
        );
  }

  @override
  Future<SavingGoalItem> createGoal(CreateGoalDto dto) async {
    throw UnimplementedError();
  }

  @override
  Future<SavingGoalItem> updateGoal(String id, UpdateGoalDto dto) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteGoal(String id) async {}

  @override
  Future<Map<String, dynamic>> deposit(String id, DepositDto dto) async {
    depositCalls++;
    return {'success': true};
  }

  @override
  Future<Map<String, dynamic>> withdraw(String id, WithdrawDto dto) async {
    withdrawCalls++;
    return {'success': true};
  }
}

void main() {
  Widget buildTestableSavingsScreen({required FakeSavingRepository repo}) {
    final session = AppSessionController();
    session.authenticate(
      value: userFixture(),
      publicConfig: publicConfigFixture(),
    );

    return ProviderScope(
      overrides: [
        savingRepositoryProvider.overrideWithValue(repo),
        appSessionProvider.overrideWith((ref) => session),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const SavingsScreen()),
    );
  }

  Widget buildTestableSavingDetailScreen({
    required FakeSavingRepository repo,
    required String goalId,
    List<WalletItem>? wallets,
  }) {
    final session = AppSessionController();
    session.authenticate(
      value: userFixture(),
      publicConfig: publicConfigFixture(),
    );

    return ProviderScope(
      overrides: [
        savingRepositoryProvider.overrideWithValue(repo),
        appSessionProvider.overrideWith((ref) => session),
        walletsProvider.overrideWith(
          (ref) => Future.value(
            wallets ??
                [
                  const WalletItem(
                    id: 'w-1',
                    name: 'Vietcombank',
                    type: 'BANK',
                    balance: 20000000,
                  ),
                ],
          ),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: SavingDetailScreen(goalId: goalId),
      ),
    );
  }

  testWidgets(
    'SavingsScreen hiển thị tổng đã tiết kiệm và danh sách mục tiêu',
    (tester) async {
      final repo = FakeSavingRepository();
      await tester.pumpWidget(buildTestableSavingsScreen(repo: repo));
      await tester.pumpAndSettle();

      // Tiêu đề & Tổng
      expect(find.text('Tiết kiệm'), findsOneWidget);
      expect(find.text('Đã tiết kiệm · 2 mục tiêu'), findsOneWidget);
      expect(find.text('63.000.000đ'), findsOneWidget);
      expect(find.text('trên tổng mục tiêu 75.000.000đ'), findsOneWidget);

      // Thẻ mục tiêu
      expect(find.text('Du lịch Nhật Bản'), findsOneWidget);
      expect(find.text('MacBook Pro M3'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    },
  );

  testWidgets('SavingsScreen hiển thị empty state khi chưa có mục tiêu', (
    tester,
  ) async {
    final repo = FakeSavingRepository()..goalsList = [];
    await tester.pumpWidget(buildTestableSavingsScreen(repo: repo));
    await tester.pumpAndSettle();

    expect(find.text('Chưa có mục tiêu tiết kiệm nào'), findsOneWidget);
    expect(find.text('+ Tạo mục tiêu đầu tiên'), findsOneWidget);
  });

  testWidgets(
    'SavingDetailScreen hiển thị chi tiết mục tiêu, tiến độ và lịch sử',
    (tester) async {
      final repo = FakeSavingRepository();
      await tester.pumpWidget(
        buildTestableSavingDetailScreen(repo: repo, goalId: 'g-1'),
      );
      await tester.pumpAndSettle();

      // Chi tiết tên & số tiền
      expect(find.text('Du lịch Nhật Bản'), findsOneWidget);
      expect(find.text('18.000.000đ'), findsOneWidget);
      expect(find.text('60% hoàn thành'), findsOneWidget);
      expect(find.text('còn 12.000.000đ'), findsOneWidget);

      // Nút hành động
      expect(find.text('Nạp tiền'), findsOneWidget);
      expect(find.text('Rút tiền'), findsOneWidget);

      // Lịch sử nạp rút
      expect(find.text('Lịch sử nạp rút'), findsOneWidget);
      expect(find.text('Nạp từ Vietcombank'), findsOneWidget);
      expect(find.text('+5.000.000đ'), findsOneWidget);
    },
  );

  testWidgets('DepositSheet cho phép chọn số tiền nhanh và nạp tiền', (
    tester,
  ) async {
    final repo = FakeSavingRepository();
    final goal = await repo.getGoal('g-1');

    final session = AppSessionController();
    session.authenticate(
      value: userFixture(),
      publicConfig: publicConfigFixture(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          savingRepositoryProvider.overrideWithValue(repo),
          appSessionProvider.overrideWith((ref) => session),
          walletsProvider.overrideWith(
            (ref) => Future.value([
              const WalletItem(
                id: 'w-1',
                name: 'Vietcombank',
                type: 'BANK',
                balance: 20000000,
              ),
            ]),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: DepositSheet(goal: goal)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nạp vào Du lịch Nhật Bản'), findsOneWidget);
    expect(find.text('Từ ví'), findsOneWidget);
    expect(find.text('Vietcombank'), findsOneWidget);

    // Bấm nút Nạp tiền
    await tester.tap(find.text('Nạp 1.000.000đ'));
    await tester.pumpAndSettle();

    expect(repo.depositCalls, 1);
  });
}
