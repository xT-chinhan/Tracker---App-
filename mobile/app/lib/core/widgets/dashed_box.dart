import 'dart:ui';

import 'package:flutter/material.dart';

/// Khung viền nét đứt bo góc: quy ước "nháp, chưa có hiệu lực" (mockup 30-ai-04).
class DashedBox extends StatelessWidget {
  const DashedBox({
    required this.child,
    this.radius = 18,
    this.color = const Color(0xFFD5D4CF),
    this.padding = const EdgeInsets.all(16),
    this.background = Colors.white,
    super.key,
  });

  final Widget child;
  final double radius;
  final Color color;
  final EdgeInsetsGeometry padding;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      // vẽ đè lên nền của child, nếu không nền trắng che mất viền
      foregroundPainter: _DashedRRectPainter(radius: radius, color: color),
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(radius),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.radius, required this.color});

  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ).deflate(0.6),
      );
    for (final PathMetric m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += 9) {
        canvas.drawPath(m.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.radius != radius || old.color != color;
}
