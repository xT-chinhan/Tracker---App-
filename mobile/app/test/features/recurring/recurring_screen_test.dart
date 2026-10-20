import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/auth/application/app_session.dart';
import 'package:app/features/recurring/data/recurring_models.dart';
import 'package:app/features/recurring/data/recurring_repository.dart';
import 'package:app/features/recurring/presentation/recurring_screen.dart';
import '../../helpers/fixtures.dart';

class FakeRecurringRepository implements RecurringRepository {
  List<RecurringRuleItem>? rulesList;
  int pauseCalls = 0;
  int resumeCalls = 0;
  int deleteCalls = 0;

  @override
  Future<List<RecurringRuleItem>> getRules() async {
    return rulesList ??
        [
          RecurringRuleItem(
            id: 'r-1',
            userId: 'u-1',
            walletId: 'w-1',
            categoryId: 'cat-1',
            amount: 22000000,
            title: 'Lương công ty',
            frequency: 'MONTHLY',
            anchorDay: 5,
            interval: 1,
            startDate: DateTime(2026, 1, 5),
            nextRunAt: DateTime(2026, 10, 5),
            isActive: true,
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            wallet: const RecurringWalletMeta(
              id: 'w-1',
              name: 'MB Bank',
              type: 'BANK',
            ),
            category: const RecurringCategoryMeta(
              id: 'cat-1',
              name: 'Tiền lương',
              type: 'INCOME',
              icon: 'banknote',
            ),
          ),
          RecurringRuleItem(
            id: 'r-2',
            userId: 'u-1',
            walletId: 'w-1',
            categoryId: 'cat-2',
            amount: 2500000,
            title: 'Tiền nhà',
            frequency: 'MONTHLY',
            anchorDay: 1,
            interval: 1,
            startDate: DateTime(2026, 1, 1),
            nextRunAt: DateTime(2026, 10, 1),
            isActive: true,
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            wallet: const RecurringWalletMeta(
              id: 'w-1',
              name: 'MB Bank',
              type: 'BANK',
            ),
            category: const RecurringCategoryMeta(
              id: 'cat-2',
              name: 'Nhà ở',
              type: 'EXPENSE',
              icon: 'house',
            ),
          ),
          RecurringRuleItem(
            id: 'r-3',
            userId: 'u-1',
            walletId: 'w-3',
            categoryId: 'cat-3',
            amount: 500000,
            title: 'Đi chợ cuối tuần',
            frequency: 'WEEKLY',
            anchorDay: 7,
            interval: 1,
            startDate: DateTime(2026, 1, 4),
            nextRunAt: DateTime(2026, 9, 27),
            isActive: true,
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            wallet: const RecurringWalletMeta(
              id: 'w-3',
              name: 'Tiền mặt',
              type: 'CASH',
            ),
            category: const RecurringCategoryMeta(
              id: 'cat-3',
              name: 'Đi chợ',
              type: 'EXPENSE',
              icon: 'shopping-cart',
            ),
          ),
          RecurringRuleItem(
            id: 'r-4',
            userId: 'u-1',
            walletId: 'w-4',
            categoryId: 'cat-4',
            amount: 59000,
            title: 'Spotify Premium',
            frequency: 'MONTHLY',
            anchorDay: 15,
            interval: 1,
            startDate: DateTime(2026, 1, 15),
            nextRunAt: DateTime(2026, 10, 15),
            isActive: false,
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            wallet: const RecurringWalletMeta(
              id: 'w-4',
              name: 'MoMo',
              type: 'EWALLET',
            ),
            category: const RecurringCategoryMeta(
              id: 'cat-4',
              name: 'Giải trí',
              type: 'EXPENSE',
              icon: 'music',
            ),
          ),
        ];
  }

  @override
  Future<RecurringRuleItem> getRule(String id) async {
    final list = await getRules();
    return list.firstWhere((r) => r.id == id);
  }

  @override
  Future<RecurringRuleItem> createRule(CreateRecurringDto dto) async {
    throw UnimplementedError();
  }

  @override
  Future<RecurringRuleItem> updateRule(
    String id,
    UpdateRecurringDto dto,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteRule(String id) async {
    deleteCalls++;
  }

  @override
  Future<RecurringRuleItem> pauseRule(String id) async {
    pauseCalls++;
    final r = await getRule(id);
    return r.copyWith(isActive: false);
  }

  @override
  Future<RecurringRuleItem> resumeRule(String id) async {
    resumeCalls++;
    final r = await getRule(id);
    return r.copyWith(isActive: true);
  }

  @override
  Future<RecurringPreviewResponse> preview(String id, {int count = 5}) async {
    return RecurringPreviewResponse(
      ruleId: id,
      isActive: true,
      items: [
        RecurringPreviewItem(
          scheduledFor: DateTime(2026, 10, 5),
          date: '2026-10-05',
        ),
      ],
    );
  }
}

void main() {
  Widget buildTestableWidget({required FakeRecurringRepository repo}) {
    final session = AppSessionController();
    session.authenticate(
      value: userFixture(),
      publicConfig: publicConfigFixture(),
    );

    return ProviderScope(
      overrides: [
        recurringRepositoryProvider.overrideWithValue(repo),
        appSessionProvider.overrideWith((ref) => session),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const RecurringScreen()),
    );
  }

  testWidgets(
    'RecurringScreen hiển thị danh sách quy tắc đang chạy và tạm dừng khớp mockup 17',
    (tester) async {
      final repo = FakeRecurringRepository();
      await tester.pumpWidget(buildTestableWidget(repo: repo));
      await tester.pumpAndSettle();

      // Tiêu đề & Subtitle
      expect(find.text('Định kỳ'), findsOneWidget);
      expect(find.text('Tự động ghi vào ngày đến hạn.'), findsOneWidget);

      // Section Đang chạy
      expect(find.text('Đang chạy · 3'), findsOneWidget);
      expect(find.text('Lương công ty'), findsOneWidget);
      expect(find.text('+22.000.000đ'), findsOneWidget);
      expect(find.text('Hằng tháng · ngày 5 · MB Bank'), findsOneWidget);

      expect(find.text('Tiền nhà'), findsOneWidget);
      expect(find.text('−2.500.000đ'), findsOneWidget);

      expect(find.text('Đi chợ cuối tuần'), findsOneWidget);
      expect(find.text('−500.000đ'), findsOneWidget);

      // Section Tạm dừng
      expect(find.text('Tạm dừng · 1'), findsOneWidget);
      expect(find.text('Spotify Premium'), findsOneWidget);
      expect(find.text('−59.000đ'), findsOneWidget);
      expect(find.text('Đang tạm dừng'), findsOneWidget);
    },
  );

  testWidgets('RecurringScreen hiển thị empty state khi không có quy tắc', (
    tester,
  ) async {
    final repo = FakeRecurringRepository()..rulesList = [];
    await tester.pumpWidget(buildTestableWidget(repo: repo));
    await tester.pumpAndSettle();

    expect(find.text('Chưa có giao dịch định kỳ nào'), findsOneWidget);
    expect(find.text('+ Thêm định kỳ đầu tiên'), findsOneWidget);
  });

  testWidgets(
    'RecurringScreen cho phép mở menu hành động tạm dừng hoặc tiếp tục',
    (tester) async {
      final repo = FakeRecurringRepository();
      await tester.pumpWidget(buildTestableWidget(repo: repo));
      await tester.pumpAndSettle();

      // Bấm vào quy tắc đang chạy Lương công ty
      await tester.tap(find.text('Lương công ty'));
      await tester.pumpAndSettle();

      // Menu hiện lên
      expect(find.text('Tạm dừng quy tắc này'), findsOneWidget);
      expect(find.text('Sửa quy tắc'), findsOneWidget);
      expect(find.text('Xóa quy tắc'), findsOneWidget);

      // Bấm tạm dừng
      await tester.tap(find.text('Tạm dừng quy tắc này'));
      await tester.pumpAndSettle();

      expect(repo.pauseCalls, 1);
    },
  );
}
