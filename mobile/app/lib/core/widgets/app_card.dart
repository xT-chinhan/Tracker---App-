import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class AppCard extends StatelessWidget {
  const AppCard({required this.child, this.padding, this.onTap, super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(context.radius.lg),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        boxShadow: context.shadows.card,
      ),
      child: child,
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.radius.lg),
      child: content,
    );
  }
}
