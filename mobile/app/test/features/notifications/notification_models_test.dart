import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/notifications/data/notification_models.dart';

void main() {
  group('Notification Models', () {
    test('NotificationItem deserialization', () {
      final json = {
        'id': 'notif-1',
        'type': 'BUDGET_WARNING',
        'title': 'Ăn uống đã dùng 89% ngân sách',
        'body': 'Đã chi 3.120.000đ / 3.500.000đ',
        'createdAt': '2026-09-22T12:10:00.000Z',
      };

      final model = NotificationItem.fromJson(json);
      expect(model.id, 'notif-1');
      expect(model.type, 'BUDGET_WARNING');
      expect(model.title, 'Ăn uống đã dùng 89% ngân sách');
      expect(model.readAt, isNull);
    });

    test('NotificationPage deserialization', () {
      final json = {
        'items': [
          {
            'id': 'notif-1',
            'type': 'BROADCAST',
            'title': 'Mới: xuất báo cáo ra CSV',
            'body': 'Vào Báo cáo, chạm biểu tượng tải xuống.',
            'createdAt': '2026-09-20T10:00:00.000Z',
          },
        ],
        'total': 1,
        'page': 1,
        'limit': 20,
        'totalPages': 1,
      };

      final page = NotificationPage.fromJson(json);
      expect(page.total, 1);
      expect(page.items.length, 1);
      expect(page.items.first.title, 'Mới: xuất báo cáo ra CSV');
    });
  });
}
