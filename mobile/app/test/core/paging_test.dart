import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/network/paging.dart';
import 'package:app/features/home/data/home_models.dart';
import 'package:app/features/notifications/data/notification_models.dart';

void main() {
  // Dạng JSON thật của backend: không có `totalPages`
  test('TransactionPage đọc được trang không có totalPages', () {
    final page = TransactionPage.fromJson({
      'items': <dynamic>[],
      'total': 1061,
      'page': 1,
      'limit': 20,
    });
    expect(page.totalPages, 54);
  });

  test('NotificationPage đọc được trang không có totalPages', () {
    final page = NotificationPage.fromJson({
      'items': <dynamic>[],
      'total': 0,
      'page': 1,
      'limit': 20,
    });
    expect(page.totalPages, 1);
  });

  test('giữ nguyên totalPages nếu API có trả', () {
    expect(
      withTotalPages({'total': 5, 'limit': 2, 'totalPages': 9})['totalPages'],
      9,
    );
  });
}
