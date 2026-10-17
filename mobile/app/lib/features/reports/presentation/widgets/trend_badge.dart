import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_tokens.dart';

enum TrendBadgeType { ok, danger, neutral }

class TrendBadge extends StatelessWidget {
  const TrendBadge({
    super.key,
    required this.percentage,
    required this.isUp,
    required this.type,
  });

  final double percentage;
  final bool? isUp;
  final TrendBadgeType type;

  @override
  Widget build(BuildContext context) {
    final colors = switch (type) {
      TrendBadgeType.ok => (
        bg: context.appColors.successContainer,
        fg: context.appColors.income,
      ),
      TrendBadgeType.danger => (
        bg: context.appColors.dangerContainer,
        fg: context.appColors.danger,
      ),
      TrendBadgeType.neutral => (
        bg: Theme.of(context).colorScheme.surfaceContainer,
        fg: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    };

    final icon = isUp == true
        ? LucideIcons.arrow_up_right
        : (isUp == false ? LucideIcons.arrow_down_right : LucideIcons.minus);

    final pctStr = percentage.abs().toStringAsFixed(
      percentage.abs() % 1 == 0 ? 0 : 1,
    );

    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(context.radius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colors.fg),
          const SizedBox(width: 2),
          Text(
            '$pctStr%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.fg,
            ),
          ),
        ],
      ),
    );
  }
}
