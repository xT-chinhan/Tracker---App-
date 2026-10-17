import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatting/money_formatter.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/app_icon_helper.dart';
import '../../features/home/application/home_service.dart';

class PlusActionMenuSheet extends ConsumerWidget {
  const PlusActionMenuSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const PlusActionMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);
    final templates = homeState.quickTemplates;
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x18111111),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thu nhập
                  _ActionRow(
                    icon: LucideIcons.arrow_down_left,
                    iconBg: const Color(0xFFE8F7ED),
                    iconColor: context.appColors.income,
                    title: 'Thu nhập',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/transaction-entry?type=income');
                    },
                  ),
                  const Divider(height: 12),
                  // Chuyển tiền
                  _ActionRow(
                    icon: LucideIcons.arrow_left_right,
                    iconBg: const Color(0xFFF3F2EE),
                    iconColor: const Color(0xFF111111),
                    title: 'Chuyển tiền',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/transfer');
                    },
                  ),
                  if (templates.isNotEmpty) ...[
                    const Divider(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Mẫu nhập nhanh',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ...templates.map((tpl) {
                      return InkWell(
                        onTap: () async {
                          Navigator.of(context).pop();
                          final title = await ref
                              .read(homeControllerProvider.notifier)
                              .useQuickTemplate(tpl.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  title != null
                                      ? 'Đã ghi nhanh "${tpl.label}" (${MoneyFormatter.format(tpl.amount)})'
                                      : 'Ghi nhanh thất bại',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFF3F2EE),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  AppIconHelper.fromName(tpl.category?.icon),
                                  size: 18,
                                  color: const Color(0xFF111111),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  tpl.label,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                MoneyFormatter.format(tpl.amount),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: colors.onSurfaceVariant,
                                      fontFeatures:
                                          MoneyFormatter.tabularFeatures,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Close button that aligns with the center plus button
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(28),
              child: Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF111111),
                ),
                alignment: Alignment.center,
                child: const Icon(LucideIcons.x, size: 26, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
