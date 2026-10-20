import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/auth/application/app_session.dart';
import 'package:app/features/budgets/data/budget_repository.dart';
import 'package:app/features/budgets/presentation/budgets_screen.dart';
import 'package:app/features/home/data/home_models.dart';
import '../../helpers/fixtures.dart';

class FakeBudgetRepository implements BudgetRepository {
  BudgetSummary? summary;
  int getBudgetsCalls = 0;
  int copyCalls = 0;
  String? lastFetchedMonth;

  @override
  Future<BudgetSummary> getBudgets(String month) async {
    getBudgetsCalls++;
    lastFetchedMonth = month;
    return summary ??
        const BudgetSummary(
          month: '2026-09',
          thresholds: BudgetThresholds(
            warningPercent: 80,
            exceededPercent: 100,
          ),
          totalLimit: 5000000,
          totalSpent: 3500000,
          totalRemaining: 1500000,
          overall: BudgetOverall(
            id: 'overall-1',
            month: '2026-09',
            limitAmount: 5000000,
            spent: 3500000,
            remaining: 1500000,
            percentage: 70.0,
            status: 'ok',
          ),
          items: [
            BudgetItem(
              id: 'b-1',
              categoryId: 'cat-1',
              month: '2026-09',
              category: CategoryMeta(
                id: 'cat-1',
                name: 'Ăn uống',
                icon: 'utensils',
                color: '#2a78d6',
              ),
              limitAmount: 2000000,
              spent: 1500000,
              remaining: 500000,
              percentage: 75.0,
              status: 'ok',
            ),
            BudgetItem(
              id: 'b-2',
              categoryId: 'cat-2',
              month: '2026-09',
              category: CategoryMeta(
                id: 'cat-2',
                name: 'Mua sắm',
                icon: 'shopping-cart',
                color: '#1baf7a',
              ),
              limitAmount: 1000000,
              spent: 850000,
              remaining: 150000,
              percentage: 85.0,
              status: 'warning',
            ),
            BudgetItem(
              id: 'b-3',
              categoryId: 'cat-3',
              month: '2026-09',
              category: CategoryMeta(
                id: 'cat-3',
                name: 'Giải trí',
                icon: 'gamepad-2',
                color: '#eda100',
              ),
              limitAmount: 500000,
              spent: 600000,
              remaining: -100000,
              percentage: 120.0,
              status: 'exceeded',
            ),
          ],
        );
  }

  @override
  Future<BudgetItem> createBudget({
    required String month,
    required int limitAmount,
    String? categoryId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<BudgetItem> updateBudget(String id, int limitAmount) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteBudget(String id) async {}

  @override
  Future<int> copyBudgets({
    required String fromMonth,
    required String toMonth,
  }) async {
    copyCalls++;
    return 3;
  }
}

void main() {
  Widget buildTestableWidget({required FakeBudgetRepository repo}) {
    final session = AppSessionController();
    session.authenticate(
      value: userFixture(),
      publicConfig: publicConfigFixture(),
    );

    return ProviderScope(
      overrides: [
        budgetRepositoryProvider.overrideWithValue(repo),
        appSessionProvider.overrideWith((ref) => session),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const BudgetsScreen()),
    );
  }

  testWidgets('BudgetsScreen hiển thị ngân sách tổng, tiến độ và danh mục', (
    tester,
  ) async {
    final repo = FakeBudgetRepository();
    await tester.pumpWidget(buildTestableWidget(repo: repo));
    await tester.pumpAndSettle();

    // Tiêu đề
    expect(find.text('Ngân sách'), findsOneWidget);
    expect(find.textContaining('Còn lại'), findsOneWidget);
    expect(find.text('1.500.000đ'), findsOneWidget);
    expect(find.text('70%'), findsOneWidget);
    expect(find.text('Đã chi 3.500.000đ'), findsOneWidget);
    expect(find.text('Hạn mức 5.000.000đ'), findsOneWidget);

    // Section danh mục
    expect(find.text('Theo danh mục'), findsOneWidget);
    expect(find.text('3 ngân sách'), findsOneWidget);
    expect(find.text('Ăn uống'), findsOneWidget);
    expect(find.text('Mua sắm'), findsOneWidget);
    expect(find.text('Giải trí'), findsOneWidget);

    // Trạng thái cảnh báo và vượt hạn mức
    expect(find.text('85%'), findsOneWidget);
    expect(find.text('120%'), findsOneWidget);
    expect(find.text('Vượt 100.000đ'), findsOneWidget);
  });

  testWidgets('BudgetsScreen hỗ trợ chuyển tháng trước và tháng sau', (
    tester,
  ) async {
    final repo = FakeBudgetRepository();
    await tester.pumpWidget(buildTestableWidget(repo: repo));
    await tester.pumpAndSettle();

    expect(repo.getBudgetsCalls, 1);

    // Bấm icon tháng trước
    await tester.tap(find.byTooltip('Tháng trước'));
    await tester.pumpAndSettle();

    expect(repo.getBudgetsCalls, 2);

    // Bấm icon tháng sau
    await tester.tap(find.byTooltip('Tháng sau'));
    await tester.pumpAndSettle();

    expect(repo.getBudgetsCalls, 3);
  });

  testWidgets(
    'BudgetsScreen hiển thị empty state khi không có ngân sách danh mục và sao chép',
    (tester) async {
      final repo = FakeBudgetRepository()
        ..summary = const BudgetSummary(
          month: '2026-09',
          thresholds: BudgetThresholds(),
          totalLimit: 0,
          totalSpent: 0,
          totalRemaining: 0,
          items: [],
        );

      await tester.pumpWidget(buildTestableWidget(repo: repo));
      await tester.pumpAndSettle();

      expect(find.text('Chưa đặt ngân sách tổng'), findsOneWidget);
      expect(find.text('Chưa có ngân sách theo danh mục'), findsOneWidget);
      expect(find.text('Sao chép'), findsOneWidget);

      // Bấm sao chép
      await tester.tap(find.text('Sao chép'));
      await tester.pumpAndSettle();

      expect(repo.copyCalls, 1);
      expect(
        find.text('Đã sao chép 3 ngân sách từ tháng trước!'),
        findsOneWidget,
      );
    },
  );
}
