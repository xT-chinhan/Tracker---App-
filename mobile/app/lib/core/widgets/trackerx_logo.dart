import 'package:flutter/material.dart';

/// Logo TrackerX (hướng C "Lưới ô"): ô vuông bo 22%, lưới 3×3 ô bo góc —
/// 5 ô sáng tạo chữ T, 2 ô góc dưới màu xám. Hình học theo
/// design/brand/trackerx/c-grid/icon.svg (viewBox 120).
/// Nền sáng: nền đen, ô trắng. Nền tối: nền trắng ngà, ô đen (icon-dark.svg).
class TrackerXLogo extends StatelessWidget {
  const TrackerXLogo({this.size = 56, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: 'TrackerX',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: TrackerXLogoPainter(
            background: dark
                ? const Color(0xFFF7F6F3)
                : const Color(0xFF111111),
            cell: dark ? const Color(0xFF111111) : const Color(0xFFFFFFFF),
            accent: dark ? const Color(0xFFB9B7B0) : const Color(0xFF5E5D59),
          ),
        ),
      ),
    );
  }
}

class TrackerXLogoPainter extends CustomPainter {
  const TrackerXLogoPainter({
    required this.background,
    required this.cell,
    required this.accent,
  });

  final Color background;
  final Color cell;
  final Color accent;

  static const _cells = <(double, double, bool)>[
    (23, 23, false),
    (49, 23, false),
    (75, 23, false),
    (49, 49, false),
    (49, 75, false),
    (23, 75, true),
    (75, 75, true),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.shortestSide / 120;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & Size.square(120 * u),
        Radius.circular(26.4 * u),
      ),
      Paint()..color = background,
    );
    final cellPaint = Paint()..color = cell;
    final accentPaint = Paint()..color = accent;
    for (final (x, y, isAccent) in _cells) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x * u, y * u, 22 * u, 22 * u),
          Radius.circular(5 * u),
        ),
        isAccent ? accentPaint : cellPaint,
      );
    }
  }

  @override
  bool shouldRepaint(TrackerXLogoPainter old) =>
      old.background != background || old.cell != cell || old.accent != accent;
}
