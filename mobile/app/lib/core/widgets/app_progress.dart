import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

enum ProgressStatus { ok, warning, exceeded }

class AppProgress extends StatelessWidget {
  const AppProgress({
    required this.percent,
    this.status = ProgressStatus.ok,
    this.height = 6,
    super.key,
  });

  final double percent;
  final ProgressStatus status;
  final double height;

  @override
  Widget build(BuildContext context) {
    final fill = switch (status) {
      ProgressStatus.ok => Theme.of(context).colorScheme.primary,
      ProgressStatus.warning => context.appColors.warningBar,
      ProgressStatus.exceeded => context.appColors.dangerBar,
    };
    return Semantics(
      label: '${percent.round()} phần trăm',
      value: '${percent.round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.radius.pill),
        child: LinearProgressIndicator(
          value: (percent / 100).clamp(0, 1),
          minHeight: height,
          color: fill,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        ),
      ),
    );
  }
}
