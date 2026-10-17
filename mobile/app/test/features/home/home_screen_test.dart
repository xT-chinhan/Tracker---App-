import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/auth/application/app_session.dart';
import 'package:app/features/home/data/home_models.dart';
import 'package:app/features/home/data/home_repository.dart';
import 'package:app/features/home/presentation/home_screen.dart';
import 'package:app/features/notifications/application/notifications_service.dart';
import '../../helpers/fixtures.dart';

class FakeHomeRepository implements HomeRepository {
  FakeHomeRepository({
    this.balance,
    this.todaySummary,
    this.monthSummary,
    this.budgets,
    this.recentTransactions = const <TransactionItem>[],
    this.quickTemplates = const <QuickTemplateItem>[],
  });

  final StatsBalance? balance;
  final StatsSummary? todaySummary;
  final StatsSummary? monthSummary;
  final BudgetSummary? budgets;
  final List<TransactionItem> recentTransactions;
  final List<QuickTemplateItem> quickTemplates;
  var useTemplateCallCount = 0;

  @override
  Future<StatsBalance> getBalance() async => balance ?? statsBalanceFixture();

  @override
  Future<StatsSummary> getSummary({
    String? month,
    String? from,
    String? to,
    String? walletId,
  }) async {
    if (from != null) {
      return todaySummary ?? statsSummaryFixture(expense: 120000);
    }
    return monthSummary ?? statsSummaryFixture(expense: 8680000);
  }

  @override
  Future<BudgetSummary> getBudgets(String month) async =>
      budgets ?? budgetSummaryFixture();

  @override
  Future<TransactionPage> getRecentTransactions({int limit = 5}) async =>
      TransactionPage(
        items: recentTransactions.isNotEmpty
            ? recentTransactions
            : [
                transactionItemFixture(
                  id: 'tx-1',
                  title: 'Cơm trưa văn phòng',
                  amount: 55000,
                ),
                transactionItemFixture(
                  id: 'tx-2',
                  title: 'Cà phê sáng',
                  amount: 45000,
                ),
              ],
        total: 2,
        page: 1,
        limit: 5,
        totalPages: 1,
      );

  @override
  Future<List<QuickTemplateItem>> getQuickTemplates() async =>
      quickTemplates.isNotEmpty
      ? quickTemplates
      : [
          quickTemplateItemFixture(id: 'qt-1', label: 'Cà phê', amount: 45000),
          quickTemplateItemFixture(
            id: 'qt-2',
            label: 'Cơm trưa',
            amount: 55000,
          ),
        ];

  @override
  Future<TransactionItem> useQuickTemplate(String id) async {
    useTemplateCallCount++;
    return transactionItemFixture(title: 'Cà phê sáng', amount: 45000);
  }
}

void main() {
  testWidgets(
    'HomeScreen hiển thị số dư, ngân sách, giao dịch và ẩn/hiện số dư',
    (tester) async {
      final session = AppSessionController();
      session.authenticate(
        value: userFixture(),
        publicConfig: publicConfigFixture(),
      );

      final fakeRepo = FakeHomeRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSessionProvider.overrideWith((ref) => session),
            homeRepositoryProvider.overrideWithValue(fakeRepo),
            unreadCountProvider.overrideWith(() => _FakeUnreadCountNotifier(2)),
          ],
          child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      // Kiểm tra số dư hiển thị
      expect(find.text('26.022.000đ'), findsOneWidget);
      expect(find.text('Tổng số dư · 2 ví'), findsOneWidget);

      // Kiểm tra chi hôm nay và tháng này
      expect(find.text('120.000đ'), findsOneWidget);
      expect(find.text('8.680.000đ'), findsOneWidget);

      // Kiểm tra ngân sách
      expect(find.textContaining('62%'), findsOneWidget);
      expect(find.text('còn 5.320.000đ'), findsOneWidget);

      // Kiểm tra giao dịch gần đây
      expect(find.text('Cơm trưa văn phòng'), findsOneWidget);
      expect(find.text('Cà phê sáng'), findsOneWidget);

      // Kiểm tra nút nhập nhanh
      expect(find.text('Cà phê'), findsOneWidget);
      expect(find.text('Cơm trưa'), findsOneWidget);

      // Nhấn nút ẩn số dư
      await tester.tap(find.byIcon(LucideIcons.eye));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Số dư và hôm nay/tháng này bị ẩn thành ••••••••
      expect(find.text('26.022.000đ'), findsNothing);
      expect(find.text('••••••••'), findsNWidgets(3));

      // Nhấn nút hiện lại số dư
      await tester.tap(find.byIcon(LucideIcons.eye_off));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('26.022.000đ'), findsOneWidget);
    },
  );

  testWidgets('HomeScreen chạm vào mẫu nhập nhanh kích hoạt ghi giao dịch', (
    tester,
  ) async {
    final session = AppSessionController();
    session.authenticate(
      value: userFixture(),
      publicConfig: publicConfigFixture(),
    );

    final fakeRepo = FakeHomeRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSessionProvider.overrideWith((ref) => session),
          homeRepositoryProvider.overrideWithValue(fakeRepo),
          unreadCountProvider.overrideWith(() => _FakeUnreadCountNotifier(0)),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

    // Tap vào mẫu Cà phê
    await tester.tap(find.text('Cà phê'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(fakeRepo.useTemplateCallCount, 1);
    expect(find.text('Đã ghi: Cà phê sáng'), findsOneWidget);
  });
}

class _FakeUnreadCountNotifier extends UnreadCountNotifier {
  _FakeUnreadCountNotifier(this.initialCount);
  final int initialCount;

  @override
  Future<int> build() async => initialCount;
}
