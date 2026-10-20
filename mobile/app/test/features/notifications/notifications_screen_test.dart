import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/notifications/data/notification_models.dart';
import 'package:app/features/notifications/data/notification_repository.dart';
import 'package:app/features/notifications/presentation/notifications_screen.dart';
import '../../helpers/fixtures.dart';

class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository({this.items = const <NotificationItem>[]});

  List<NotificationItem> items;
  var markReadCallCount = 0;
  var markReadAllCallCount = 0;

  @override
  Future<NotificationPage> list({
    int page = 1,
    int limit = 20,
    bool? unread,
  }) async {
    return NotificationPage(
      items: items,
      total: items.length,
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
  Future<int> markReadAll() async {
    markReadAllCallCount++;
    return items.where((i) => i.readAt == null).length;
  }
}

void main() {
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
        overrides: [notificationRepositoryProvider.overrideWithValue(fakeRepo)],
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
    expect(find.text('Đọc hết'), findsOneWidget);

    // Chạm vào nút Đọc hết
    await tester.tap(find.text('Đọc hết'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(fakeRepo.markReadAllCallCount, 1);
    // Nút Đọc hết biến mất khi không còn tin chưa đọc
    expect(find.text('Đọc hết'), findsNothing);
  });
}
