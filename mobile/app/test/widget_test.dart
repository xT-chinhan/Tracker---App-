import 'package:app/app/app.dart';
import 'package:app/features/auth/application/app_session.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:app/features/home/data/home_repository.dart';
import 'package:app/features/notifications/data/notification_repository.dart';

import 'features/home/home_screen_test.dart';
import 'features/notifications/notifications_screen_test.dart';
import 'helpers/fixtures.dart';

void main() {
  setUpAll(tz.initializeTimeZones);

  Future<void> pumpAuthenticatedApp(WidgetTester tester) async {
    final session = AppSessionController()..authenticate(value: userFixture());
    addTearDown(session.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSessionProvider.overrideWithValue(session),
          homeRepositoryProvider.overrideWithValue(FakeHomeRepository()),
          notificationRepositoryProvider.overrideWithValue(
            FakeNotificationRepository(),
          ),
        ],
        child: const ThuChiApp(),
      ),
    );
    await tester.pump();
  }

  testWidgets('phiên chưa đăng nhập bị điều hướng tới màn đăng nhập', (
    tester,
  ) async {
    final session = AppSessionController()
      ..unauthenticate(publicConfig: publicConfigFixture());
    addTearDown(session.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appSessionProvider.overrideWithValue(session)],
        child: const ThuChiApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Chào mừng trở lại'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsWidgets);
    expect(find.text('Trang chủ'), findsNothing);
  });

  testWidgets('hiển thị khung điều hướng và mở màn ghi giao dịch', (
    tester,
  ) async {
    await pumpAuthenticatedApp(tester);

    expect(find.text('Trang chủ'), findsWidgets);
    expect(find.text('Lịch sử'), findsOneWidget);
    expect(find.text('Báo cáo'), findsOneWidget);
    expect(find.text('Cài đặt'), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.plus).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Ghi giao dịch'), findsWidgets);
    expect(find.text('Khoản chi'), findsWidgets);
    expect(find.text('0đ'), findsOneWidget);
  });

  testWidgets('keypad cập nhật số tiền và bật nút tiếp tục', (tester) async {
    await pumpAuthenticatedApp(tester);
    await tester.tap(find.byIcon(LucideIcons.plus).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('5'));
    await tester.tap(find.text('000'));
    await tester.pump();

    expect(find.text('5.000đ'), findsOneWidget);
    expect(find.text('Lưu khoản chi'), findsOneWidget);
  });
}
