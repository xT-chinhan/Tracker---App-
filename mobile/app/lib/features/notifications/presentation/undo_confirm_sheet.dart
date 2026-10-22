import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatting/money_formatter.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/icon_bubble.dart';

/// Sheet "Hoàn tác khoản tự ghi?" (mockup 60-tb-03). `true` = người dùng chọn Hoàn tác.
class UndoConfirmSheet extends StatelessWidget {
  const UndoConfirmSheet({
    required this.amount,
    required this.isIncome,
    required this.content,
    required this.walletName,
    required this.when,
    super.key,
  });

  final int amount;
  final bool isIncome;
  final String content;
  final String? walletName;
  final String when;

  static Future<bool> show(
    BuildContext context, {
    required int amount,
    required bool isIncome,
    required String content,
    required String? walletName,
    required String when,
  }) async =>
      await showModalBottomSheet<bool>(
        useRootNavigator: true,
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => UndoConfirmSheet(
          amount: amount,
          isIncome: isIncome,
          content: content,
          walletName: walletName,
          when: when,
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final wallet = walletName ?? 'ví';
    final money = MoneyFormatter.format(amount);
    final rows = <(String, String)>[
      (
        'Số tiền',
        MoneyFormatter.format(isIncome ? amount : -amount, signed: true),
      ),
      ('Nội dung', content),
      if (walletName != null) ('Ví', walletName!),
      ('Lúc', when),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const IconBubble(icon: LucideIcons.undo_2, size: 56),
          const SizedBox(height: 16),
          Text(
            'Hoàn tác khoản tự ghi?',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Giao dịch sẽ bị xóa, số dư ví trở lại như cũ.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: muted),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Text(
                          rows[i].$1,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: muted,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            rows[i].$2,
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontFeatures: MoneyFormatter.tabularFeatures,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isIncome
                ? 'Sau khi hoàn tác, $wallet trừ lại $money.'
                : 'Sau khi hoàn tác, $wallet cộng lại $money.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: context.appColors.faint,
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Hoàn tác',
            style: AppButtonStyle.danger,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text(
              'Giữ lại',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Toast sau khi hoàn tác (mockup 60-tb-03b).
void showUndoneSnack(
  BuildContext context, {
  required String title,
  required int amount,
  required bool isIncome,
  required String? walletName,
}) {
  final theme = Theme.of(context);
  final money = MoneyFormatter.format(amount);
  final wallet = walletName == null ? 'ví' : 'ví $walletName';
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.maybeOf(context);
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.appColors.successContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.check,
              size: 16,
              color: context.appColors.income,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Đã hoàn tác: $title',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  isIncome
                      ? '$money đã trừ khỏi $wallet.'
                      : '$money đã trả lại $wallet.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      action: router == null
          ? null
          : SnackBarAction(
              label: 'Xem ví',
              textColor: theme.colorScheme.onSurface,
              onPressed: () => router.push('/wallets'),
            ),
    ),
  );
}
