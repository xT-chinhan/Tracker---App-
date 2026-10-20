import 'package:app/core/widgets/trackerx_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'TrackerXLogo vẽ theo kích thước truyền vào, đổi màu theo theme',
    (tester) async {
      Future<TrackerXLogoPainter> pump(Brightness b, double size) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: b),
            home: Center(child: TrackerXLogo(size: size)),
          ),
        );
        await tester.pumpAndSettle(); // MaterialApp chuyển theme có animation
        expect(tester.getSize(find.byType(TrackerXLogo)), Size.square(size));
        final paint = tester.widget<CustomPaint>(
          find.descendant(
            of: find.byType(TrackerXLogo),
            matching: find.byType(CustomPaint),
          ),
        );
        return paint.painter! as TrackerXLogoPainter;
      }

      final light = await pump(Brightness.light, 56);
      expect(light.background, const Color(0xFF111111));
      expect(light.cell, const Color(0xFFFFFFFF));
      expect(find.bySemanticsLabel('TrackerX'), findsOneWidget);

      final dark = await pump(Brightness.dark, 32);
      expect(dark.background, const Color(0xFFF7F6F3));
      expect(dark.cell, const Color(0xFF111111));
    },
  );
}
