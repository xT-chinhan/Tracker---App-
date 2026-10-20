import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../data/report_models.dart';

class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.categories,
    required this.totalExpense,
    this.size = 132,
  });

  final List<CategoryReportItem> categories;
  final int totalExpense;
  final double size;

  @override
  Widget build(BuildContext context) {
    final vizColors = context.appColors.viz;
    final faintColor = context.appColors.faint.withValues(alpha: 0.3);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutChartPainter(
          categories: categories,
          totalExpense: totalExpense,
          vizColors: vizColors,
          emptyColor: faintColor,
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({
    required this.categories,
    required this.totalExpense,
    required this.vizColors,
    required this.emptyColor,
  });

  final List<CategoryReportItem> categories;
  final int totalExpense;
  final List<Color> vizColors;
  final Color emptyColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.14;
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    if (totalExpense <= 0 || categories.isEmpty) {
      paint.color = emptyColor;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    // Start from top (-90 degrees)
    double startAngle = -math.pi / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    for (int i = 0; i < categories.length; i++) {
      final item = categories[i];
      final sweepAngle = (item.amount / totalExpense) * (2 * math.pi);
      if (sweepAngle <= 0) continue;

      paint.color = vizColors[i % vizColors.length];
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.totalExpense != totalExpense ||
        oldDelegate.categories != categories;
  }
}
