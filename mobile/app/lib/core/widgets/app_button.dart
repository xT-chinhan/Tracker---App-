import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import 'pressable.dart';

enum AppButtonStyle { primary, secondary, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = AppButtonStyle.primary,
    this.loading = false,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonStyle style;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final colors = Theme.of(context).colorScheme;
    final appColors = context.appColors;
    final background = switch (style) {
      AppButtonStyle.primary when enabled => colors.primary,
      AppButtonStyle.primary => colors.surfaceContainerHigh,
      AppButtonStyle.secondary => colors.surface,
      AppButtonStyle.danger => appColors.dangerContainer,
    };
    final foreground = switch (style) {
      AppButtonStyle.primary when enabled => colors.onPrimary,
      AppButtonStyle.primary => appColors.faint,
      AppButtonStyle.secondary => colors.onSurface,
      AppButtonStyle.danger => appColors.danger,
    };

    final button = Pressable(
      onTap: enabled ? onPressed : null,
      semanticLabel: label,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(context.radius.pill),
          border: style == AppButtonStyle.secondary
              ? Border.all(color: colors.outline)
              : null,
        ),
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: context.motion.fast,
          child: loading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  width: 22,
                  height: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List<Widget>.generate(
                      3,
                      (_) => DecoratedBox(
                        decoration: BoxDecoration(
                          color: foreground,
                          shape: BoxShape.circle,
                        ),
                        child: const SizedBox(width: 4, height: 4),
                      ),
                    ),
                  ),
                )
              : Row(
                  key: const ValueKey('label'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: foreground),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: foreground),
                    ),
                  ],
                ),
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
