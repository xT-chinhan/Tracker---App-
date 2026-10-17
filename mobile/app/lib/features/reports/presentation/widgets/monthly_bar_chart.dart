import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../data/report_models.dart';

class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({
    super.key,
    required this.history,
    required this.currentMonth,
    this.height = 150,
  });

  final List<MonthlyTrendItem> history;
  final String currentMonth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final incomeColor = context.appColors.income;
    final expenseColor = context.appColors.expense;
    final faintColor = context.appColors.faint;
    final gridColor = Theme.of(context).colorScheme.outlineVariant;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _MonthlyBarChartPainter(
          history: history,
          currentMonth: currentMonth,
          incomeColor: incomeColor,
          expenseColor: expenseColor,
          faintColor: faintColor,
          gridColor: gridColor,
          onSurface: onSurface,
        ),
      ),
    );
  }
}

class _MonthlyBarChartPainter extends CustomPainter {
  _MonthlyBarChartPainter({
    required this.history,
    required this.currentMonth,
    required this.incomeColor,
    required this.expenseColor,
    required this.faintColor,
    required this.gridColor,
    required this.onSurface,
  });

  final List<MonthlyTrendItem> history;
  final String currentMonth;
  final Color incomeColor;
  final Color expenseColor;
  final Color faintColor;
  final Color gridColor;
  final Color onSurface;

  String _formatTick(int value) {
    if (value == 0) return '0';
    final millions = value / 1000000;
    if (millions == millions.roundToDouble()) {
      return '${millions.toInt()} tr';
    }
    return '${millions.toStringAsFixed(1)} tr';
  }

  String _formatMonthLabel(String monthStr) {
    // monthStr is "YYYY-MM"
    final parts = monthStr.split('-');
    if (parts.length == 2) {
      final monthNum = int.tryParse(parts[1]) ?? 0;
      return 'T$monthNum';
    }
    return monthStr;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rightPadding = 42.0;
    final chartWidth = size.width - rightPadding;
    final baselineY = size.height - 24.0;
    final topY = 16.0;
    final availableHeight = baselineY - topY;

    // Find max value across all months for scaling
    int maxVal = 0;
    for (final item in history) {
      if (item.income > maxVal) maxVal = item.income;
      if (item.expense > maxVal) maxVal = item.expense;
    }

    // Default max to at least 20 million if data is smaller, or round up to nice unit
    int scaleMax;
    if (maxVal <= 0) {
      scaleMax = 20000000;
    } else if (maxVal <= 10000000) {
      scaleMax = 10000000;
    } else if (maxVal <= 20000000) {
      scaleMax = 20000000;
    } else {
      scaleMax = ((maxVal / 10000000).ceil()) * 10000000;
    }

    final tickValues = [0, (scaleMax / 2).round(), scaleMax];

    // Draw horizontal grid lines and tick labels
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    for (final tick in tickValues) {
      final ratio = tick / scaleMax;
      final y = baselineY - (ratio * availableHeight);

      // Grid line
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);

      // Tick text on the right
      final textSpan = TextSpan(
        text: _formatTick(tick),
        style: TextStyle(
          color: faintColor,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(chartWidth + 6, y - (textPainter.height / 2)),
      );
    }

    if (history.isEmpty) return;

    // Draw bars
    final count = history.length;
    final slotWidth = chartWidth / count;
    final barWidth = (slotWidth * 0.28).clamp(8.0, 14.0);
    final barGap = 3.0;

    final incomePaint = Paint()..color = incomeColor;
    final expensePaint = Paint()..color = expenseColor;

    for (int i = 0; i < count; i++) {
      final item = history[i];
      final isCurrent = item.month == currentMonth;
      final centerX = (i + 0.5) * slotWidth;

      // Income bar (left)
      final inRatio = (item.income / scaleMax).clamp(0.0, 1.0);
      final inBarHeight = (inRatio * availableHeight).clamp(0.0, availableHeight);
      final inLeft = centerX - barWidth - (barGap / 2);
      final inTop = baselineY - inBarHeight;
      if (inBarHeight > 0) {
        final inRRect = RRect.fromRectAndCorners(
          Rect.fromLTWH(inLeft, inTop, barWidth, inBarHeight),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        );
        canvas.drawRRect(inRRect, incomePaint);
      }

      // Expense bar (right)
      final exRatio = (item.expense / scaleMax).clamp(0.0, 1.0);
      final exBarHeight = (exRatio * availableHeight).clamp(0.0, availableHeight);
      final exLeft = centerX + (barGap / 2);
      final exTop = baselineY - exBarHeight;
      if (exBarHeight > 0) {
        final exRRect = RRect.fromRectAndCorners(
          Rect.fromLTWH(exLeft, exTop, barWidth, exBarHeight),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        );
        canvas.drawRRect(exRRect, expensePaint);
      }

      // Month label below baseline
      final labelSpan = TextSpan(
        text: _formatMonthLabel(item.month),
        style: TextStyle(
          color: isCurrent ? onSurface : faintColor,
          fontSize: 12,
          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
        ),
      );
      final labelPainter = TextPainter(
        text: labelSpan,
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(centerX - (labelPainter.width / 2), baselineY + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MonthlyBarChartPainter oldDelegate) {
    return oldDelegate.history != history ||
        oldDelegate.currentMonth != currentMonth;
  }
}
