import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../theme/app_tokens.dart';
import 'app_button.dart';
import 'app_card.dart';

class AppStateView extends StatelessWidget {
  const AppStateView({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon = LucideIcons.inbox,
    super.key,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.spacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 128,
              height: 90,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 8,
                    left: 4,
                    right: 28,
                    child: Opacity(
                      opacity: 0.45,
                      child: AppCard(
                        padding: EdgeInsets.zero,
                        child: const SizedBox(height: 52),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 24,
                    right: 4,
                    child: AppCard(
                      padding: EdgeInsets.zero,
                      child: SizedBox(height: 58, child: Icon(icon, size: 24)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
