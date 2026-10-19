import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/bank_notifications/presentation/bank_disclosure_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'thông báo dữ liệu: nói rõ dữ liệu nào, giữ ở đâu, cần bấm đồng ý',
    (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async =>
                  result = await BankDisclosureSheet.show(context),
              child: const Text('mở'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('mở'));
      await tester.pumpAndSettle();
      expect(
        find.text('Cho phép Thu Chi đọc thông báo ngân hàng?'),
        findsOneWidget,
      );
      expect(find.textContaining('bị bỏ qua ngay'), findsOneWidget);
      expect(find.textContaining('chỉ nằm trên máy'), findsOneWidget);
      await tester.ensureVisible(find.text('Không, cảm ơn'));
      await tester.tap(find.text('Không, cảm ơn'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    },
  );
}
