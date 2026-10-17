import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/money_formatter.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_icon_helper.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../application/wallets_service.dart';
import '../data/wallet_models.dart';

class WalletPickerSheet extends ConsumerWidget {
  const WalletPickerSheet({
    this.selectedWalletId,
    required this.onSelect,
    super.key,
  });

  final String? selectedWalletId;
  final ValueChanged<WalletItem> onSelect;

  static Future<WalletItem?> show(
    BuildContext context, {
    String? selectedWalletId,
  }) {
    return showModalBottomSheet<WalletItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WalletPickerSheet(
        selectedWalletId: selectedWalletId,
        onSelect: (w) => Navigator.of(ctx).pop(w),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsProvider);
    final colors = Theme.of(context).colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radius.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.outlineVariant.withAlpha(120),
                  borderRadius: BorderRadius.circular(context.radius.pill),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.screenPadding,
              ),
              child: Text(
                'Chọn ví thanh toán',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: walletsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: AppSkeleton(width: double.infinity, height: 160),
                ),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Không thể tải danh sách ví',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: colors.error),
                    ),
                  ),
                ),
                data: (wallets) {
                  if (wallets.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text('Chưa có ví nào đang hoạt động'),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.fromLTRB(
                      context.spacing.screenPadding,
                      8,
                      context.spacing.screenPadding,
                      24,
                    ),
                    itemCount: wallets.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final wallet = wallets[index];
                      final isSelected = wallet.id == selectedWalletId;
                      return InkWell(
                        onTap: () => onSelect(wallet),
                        borderRadius: BorderRadius.circular(context.radius.lg),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.surfaceContainer
                                : const Color(0xFFFAF9F6),
                            borderRadius: BorderRadius.circular(
                              context.radius.lg,
                            ),
                            border: isSelected
                                ? Border.all(
                                    color: const Color(0xFF111111),
                                    width: 1.5,
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0EFEA),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  AppIconHelper.fromName(
                                    wallet.icon ?? 'wallet',
                                  ),
                                  size: 20,
                                  color: const Color(0xFF111111),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      wallet.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      MoneyFormatter.format(wallet.balance),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: colors.onSurfaceVariant,
                                            fontFeatures:
                                                MoneyFormatter.tabularFeatures,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  LucideIcons.check,
                                  size: 20,
                                  color: Color(0xFF111111),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
