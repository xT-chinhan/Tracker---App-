import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/notifications/application/balance_undo.dart';
import 'package:app/features/notifications/data/notification_models.dart';
import 'package:app/features/notifications/data/notification_repository.dart';
import 'package:app/features/notifications/presentation/notifications_screen.dart';
import 'package:app/core/widgets/app_button.dart';
import 'package:app/features/home/data/home_repository.dart';
import 'package:app/features/transactions/data/transaction_repository.dart';
import '../../helpers/fixtures.dart';
import '../home/home_screen_test.dart' show FakeHomeRepository;

class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository({this.items = const <NotificationItem>[]});

  List<NotificationItem> items;
  var markReadCallCount = 0;
  var markReadAllCallCount = 0;
  final markReadAllCategories = <String?>[];

  @override
  Future<NotificationPage> list({
    int page = 1,
    int limit = 20,
    bool? unread,
    String? category,
  }) async {
    final filtered = category == null
        ? items
        : items.where((i) => i.group == category).toList();
    return NotificationPage(
      items: filtered,
      total: filtered.length,
      page: 1,
      limit: limit,
      totalPages: 1,
    );
  }

  @override
  Future<int> getUnreadCount() async {
    return items.where((i) => i.readAt == null).length;
  }

  @override
  Future<NotificationItem> markRead(String id) async {
    markReadCallCount++;
    return items.firstWhere((i) => i.id == id);
  }

  @override
  Future<UnreadSummary> getUnreadSummary() async {
    final unread = items.where((i) => i.readAt == null);
    return UnreadSummary(
      count: unread.length,
      byCategory: {
        for (final c in notificationCategories)
          c: unread.where((i) => i.group == c).length,
      },
    );
  }

  @override
  Future<int> markReadAll({String? category}) async {
    markReadAllCallCount++;
    markReadAllCategories.add(category);
    final now = DateTime.now();
    var n = 0;
    items = [
      for (final i in items)
        if (i.readAt == null && (category == null || i.group == category))
          (() {
            n++;
            return i.copyWith(readAt: now);
          })()
        else
          i,
    ];
    return n;
  }
}

class MemoryUndoneStore implements UndoneStore {
  Set<String> ids = {};
  @override
  Future<Set<String>> read() async => Set.of(ids);
  @override
  Future<void> write(Set<String> v) async => ids = Set.of(v);
}

void main() {
  group('chấm chưa đọc trên tab', () {
    const summary = UnreadSummary(
      count: 3,
      byCategory: {'balance': 2, 'budget': 1, 'system': 0},
    );

    test('Tất cả theo tổng, nhóm theo byCategory, thiếu nhóm = không chấm', () {
      expect(summary.hasUnread(null), isTrue);
      expect(summary.hasUnread('balance'), isTrue);
      expect(summary.hasUnread('budget'), isTrue);
      expect(summary.hasUnread('system'), isFalse);
      expect(summary.hasUnread('security'), isFalse);
      expect(const UnreadSummary().hasUnread(null), isFalse);
    });

    test('đánh dấu đã đọc một tab chỉ xóa chấm tab đó', () {
      final after = summary.cleared('balance');
      expect(after.hasUnread('balance'), isFalse);
      expect(after.hasUnread('budget'), isTrue);
      expect(after.count, 1);
      expect(summary.cleared(null).hasUnread(null), isFalse);
    });

    test('đọc một tin: giảm đúng nhóm', () {
      final after = summary.decremented('budget');
      expect(after.hasUnread('budget'), isFalse);
      expect(after.count, 2);
    });

    test('đọc từ JSON máy chủ', () {
      final s = UnreadSummary.fromJson({
        'count': 2,
        'byCategory': {'balance': 0, 'budget': 0, 'system': 0, 'security': 2},
      });
      expect(s.hasUnread('security'), isTrue);
      expect(s.hasUnread('balance'), isFalse);
    });
  });

  test('nhóm: dùng category, thiếu thì suy từ type', () {
    expect(notificationItemFixture(type: 'BUDGET_WARNING').group, 'budget');
    expect(notificationItemFixture(type: 'BALANCE_CHANGE').group, 'balance');
    expect(notificationItemFixture(type: 'SECURITY').group, 'security');
    expect(notificationItemFixture(type: 'RECURRING_PAUSED').group, 'system');
    expect(notificationItemFixture(type: 'BROADCAST').group, 'system');
    expect(
      notificationItemFixture(
        type: 'BROADCAST',
      ).copyWith(category: 'security').group,
      'security',
    );
  });

  testWidgets('NotificationsScreen hiển thị danh sách và đánh dấu đọc hết', (
    tester,
  ) async {
    final fakeRepo = FakeNotificationRepository(
      items: [
        notificationItemFixture(
          id: 'n-1',
          title: 'Ăn uống đã dùng 89% ngân sách',
          body: 'Đã chi 3.120.000đ / 3.500.000đ',
          type: 'BUDGET_WARNING',
          readAt: null, // Chưa đọc
        ),
        notificationItemFixture(
          id: 'n-2',
          title: 'Vượt ngân sách Mua sắm',
          body: 'Đã chi 1.380.000đ',
          type: 'BUDGET_EXCEEDED',
          readAt: null, // Chưa đọc
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(fakeRepo),
          undoneStoreProvider.overrideWithValue(MemoryUndoneStore()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const NotificationsScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

    // Kiểm tra tiêu đề và thông báo
    expect(find.text('Thông báo'), findsOneWidget);
    expect(find.text('Ăn uống đã dùng 89% ngân sách'), findsOneWidget);
    expect(find.text('Vượt ngân sách Mua sắm'), findsOneWidget);
    expect(find.text('Đánh dấu đã đọc'), findsOneWidget);
    for (final label in [
      'Tất cả',
      'Số dư',
      'Ngân sách',
      'Hệ thống',
      'Bảo mật',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('tab-dot-all')), findsOneWidget);
    expect(find.byKey(const ValueKey('tab-dot-budget')), findsOneWidget);
    expect(find.byKey(const ValueKey('tab-dot-balance')), findsNothing);

    await tester.tap(find.text('Đánh dấu đã đọc'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(fakeRepo.markReadAllCallCount, 1);
    expect(fakeRepo.markReadAllCategories, [null]);
    // Ẩn khi không còn tin chưa đọc
    expect(find.text('Đánh dấu đã đọc'), findsNothing);
    expect(find.byKey(const ValueKey('tab-dot-all')), findsNothing);
  });

  testWidgets(
    'tab Số dư: chỉ khoản tự ghi, Hoàn tác → xóa giao dịch → Đã hoàn tác',
    (tester) async {
      final fakeRepo = FakeNotificationRepository(
        items: [
          notificationItemFixture(id: 'b-1', type: 'BUDGET_WARNING'),
          NotificationItem(
            id: 'n-bal',
            type: 'BALANCE_CHANGE',
            category: 'balance',
            title: '−45.000đ · Cà phê',
            body:
                'Đã tự ghi vào ví MB Bank · Từ thông báo MB Bank. Sai thì chạm để hoàn tác.',
            data: const {
              'transactionId': 'tx-1',
              'walletId': 'w-1',
              'amount': 45000,
              'txType': 'EXPENSE',
              'auto': true,
            },
            createdAt: DateTime.now(),
          ),
        ],
      );
      final undoneStore = MemoryUndoneStore();
      final deleted = <String>[];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationRepositoryProvider.overrideWithValue(fakeRepo),
            undoneStoreProvider.overrideWithValue(undoneStore),
            transactionRepositoryProvider.overrideWithValue(
              _DeletingTxRepo(deleted),
            ),
            homeRepositoryProvider.overrideWithValue(FakeHomeRepository()),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const NotificationsScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.text('Số dư'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Ăn uống đã dùng 89% ngân sách'), findsNothing);
      expect(find.textContaining('Cà phê'), findsOneWidget);

      // Chạm để mở Hoàn tác · Xem giao dịch
      await tester.tap(find.textContaining('Cà phê'));
      await tester.pump();
      expect(find.text('Xem giao dịch'), findsOneWidget);
      await tester.tap(find.text('Hoàn tác'));
      await tester.pumpAndSettle();
      expect(find.text('Hoàn tác khoản tự ghi?'), findsOneWidget);
      await tester.tap(find.widgetWithText(AppButton, 'Hoàn tác'));
      await tester.pumpAndSettle();

      expect(deleted, ['tx-1']);
      expect(undoneStore.ids, {'tx-1'});
      expect(find.text('Đã hoàn tác'), findsOneWidget);
      expect(find.text('Xem giao dịch'), findsNothing);
    },
  );
}

class _DeletingTxRepo extends Fake implements TransactionRepository {
  _DeletingTxRepo(this.deleted);
  final List<String> deleted;

  @override
  Future<void> deleteTransaction(String id) async => deleted.add(id);
}
