import 'package:app/app/app.dart';
import 'package:app/app/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  setUpAll(tz.initializeTimeZones);
  setUp(() => appRouter.go('/home'));

  testWidgets('hiển thị khung điều hướng và mở màn ghi giao dịch', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: ThuChiApp()));
    await tester.pump();

    expect(find.text('Trang chủ'), findsWidgets);
    expect(find.text('Lịch sử'), findsOneWidget);
    expect(find.text('Báo cáo'), findsOneWidget);
    expect(find.text('Cài đặt'), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.plus));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Ghi giao dịch'), findsOneWidget);
    expect(find.text('Khoản chi'), findsOneWidget);
    expect(find.text('0đ'), findsOneWidget);
  });

  testWidgets('keypad cập nhật số tiền và bật nút tiếp tục', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ThuChiApp()));
    await tester.pump();
    await tester.tap(find.byIcon(LucideIcons.plus));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('5'));
    await tester.tap(find.text('000'));
    await tester.pump();

    expect(find.text('5.000đ'), findsOneWidget);
    expect(find.text('Tiếp tục ghi khoản chi'), findsOneWidget);
  });
}
