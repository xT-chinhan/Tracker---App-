import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_skeleton.dart';

class FoundationScreen extends StatelessWidget {
  const FoundationScreen({
    required this.title,
    required this.description,
    super.key,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.spacing.screenPadding,
          24,
          context.spacing.screenPadding,
          100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            const AppSkeleton(width: double.infinity, height: 188),
            const SizedBox(height: 12),
            const AppSkeleton(width: double.infinity, height: 76),
            const SizedBox(height: 12),
            const AppSkeleton(width: double.infinity, height: 76),
          ],
        ),
      ),
    );
  }
}
