import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/formatting/money_formatter.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_icon_helper.dart';
import '../../../core/widgets/app_progress.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/icon_bubble.dart';
import '../../wallets/application/wallets_service.dart';
import '../application/savings_service.dart';
import '../data/saving_models.dart';
import 'deposit_sheet.dart';
import 'saving_form_sheet.dart';

class SavingDetailScreen extends ConsumerStatefulWidget {
  const SavingDetailScreen({super.key, required this.goalId});

  final String goalId;

  @override
  ConsumerState<SavingDetailScreen> createState() => _SavingDetailScreenState();
}

class _SavingDetailScreenState extends ConsumerState<SavingDetailScreen> {
  void _openDepositSheet(SavingGoalDetail goal) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radius.xl),
        ),
      ),
      builder: (ctx) => DepositSheet(goal: goal),
    );
  }

  void _openEditSheet(SavingGoalDetail goal) {
    showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radius.xl),
        ),
      ),
      builder: (ctx) => SavingFormSheet(existingGoal: goal),
    ).then((result) {
      if (result == 'deleted' && mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _handleWithdraw(SavingGoalDetail goal) async {
    if (goal.savedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mục tiêu này chưa có tiền để rút!')),
      );
      return;
    }

    final wallets = ref.read(walletsProvider).value ?? [];
    if (wallets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy ví khả dụng để nhận tiền rút!'),
        ),
      );
      return;
    }

    String selectedWalletId = wallets.first.id;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Rút tiền tiết kiệm'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Số tiền rút: ${MoneyFormatter.format(goal.savedAmount)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text('Chọn ví nhận tiền:'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: selectedWalletId,
                isExpanded: true,
                items: wallets.map((w) {
                  return DropdownMenuItem(
                    value: w.id,
                    child: Text(
                      '${w.name} (${MoneyFormatter.format(w.balance)})',
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => selectedWalletId = val);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Xác nhận rút'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final notifier = ref.read(savingsProvider.notifier);
        await notifier.withdraw(goalId: goal.id, walletId: selectedWalletId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Đã rút toàn bộ ${MoneyFormatter.format(goal.savedAmount)} về ví!',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi rút tiền: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(savingDetailProvider(widget.goalId));
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: detailAsync.when(
          loading: () =>
              const Center(child: AppSkeleton(width: 200, height: 200)),
          error: (err, _) => Padding(
            padding: EdgeInsets.all(context.spacing.screenPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.circle_alert, size: 48, color: colors.error),
                const SizedBox(height: 16),
                Text(
                  'Không thể tải chi tiết mục tiêu',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Quay lại',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          data: (goal) {
            final monthsLeft = (goal.daysLeft / 30).ceil().clamp(1, 120);
            final monthlyRequired = (goal.remaining / monthsLeft).round();
            final targetDateStr = DateFormat(
              'dd/MM/yyyy',
            ).format(goal.targetDate);

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(savingDetailProvider(widget.goalId));
              },
              child: CustomScrollView(
                slivers: [
                  // App Bar: < Tiết kiệm      [edit icon]
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.screenPadding - 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              LucideIcons.chevron_left,
                              size: 20,
                            ),
                            label: const Text('Tiết kiệm'),
                            style: TextButton.styleFrom(
                              foregroundColor: colors.onSurface,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.pencil, size: 20),
                            tooltip: 'Sửa mục tiêu',
                            onPressed: () => _openEditSheet(goal),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Centered Header (13-chi-tiet-muc-tieu.png)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        context.spacing.screenPadding,
                        8,
                        context.spacing.screenPadding,
                        24,
                      ),
                      child: Column(
                        children: [
                          IconBubble(
                            icon: AppIconHelper.fromName(goal.icon),
                            size: 56,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            goal.name,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            MoneyFormatter.format(goal.savedAmount),
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 40,
                                  letterSpacing: -0.03 * 40,
                                  color: colors.onSurface,
                                  fontFeatures: MoneyFormatter.tabularFeatures,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'trên ${MoneyFormatter.format(goal.targetAmount)} · hạn $targetDateStr',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontFeatures: MoneyFormatter.tabularFeatures,
                                ),
                          ),

                          const SizedBox(height: 20),

                          // Progress Card (13-chi-tiet-muc-tieu.png)
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${goal.progress.toInt()}% hoàn thành',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      'còn ${MoneyFormatter.format(goal.remaining)}',
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
                                const SizedBox(height: 10),
                                AppProgress(percent: goal.progress, height: 8),
                                if (goal.remaining > 0 &&
                                    goal.daysLeft > 0) ...[
                                  const SizedBox(height: 12),
                                  RichText(
                                    text: TextSpan(
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: colors.onSurfaceVariant,
                                          ),
                                      children: [
                                        const TextSpan(text: 'Nạp khoảng '),
                                        TextSpan(
                                          text:
                                              '${MoneyFormatter.format(monthlyRequired)}/tháng',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: colors.onSurface,
                                          ),
                                        ),
                                        const TextSpan(text: ' để kịp hạn.'),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Action Buttons: + Nạp tiền  |  Rút tiền
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  label: 'Nạp tiền',
                                  icon: LucideIcons.plus,
                                  onPressed: () => _openDepositSheet(goal),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: AppButton(
                                  label: 'Rút tiền',
                                  icon: LucideIcons.hand_coins,
                                  style: AppButtonStyle.secondary,
                                  onPressed: () => _handleWithdraw(goal),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Section Header: Lịch sử nạp rút
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Lịch sử nạp rút',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Entries Card List (13-chi-tiet-muc-tieu.png)
                          if (goal.entries.isNotEmpty)
                            AppCard(
                              padding: EdgeInsets.zero,
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: goal.entries.length,
                                separatorBuilder: (_, _) => Divider(
                                  color: colors.outlineVariant,
                                  height: 1,
                                  indent: 64,
                                ),
                                itemBuilder: (context, index) {
                                  final entry = goal.entries[index];
                                  final isDeposit = entry.type == 'DEPOSIT';
                                  final walletType = entry.wallet?.type;

                                  final walletIcon = walletType == 'BANK'
                                      ? LucideIcons.landmark
                                      : (walletType == 'EWALLET'
                                            ? LucideIcons.smartphone
                                            : LucideIcons.banknote);

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    child: Row(
                                      children: [
                                        IconBubble(icon: walletIcon),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                isDeposit
                                                    ? 'Nạp từ ${entry.wallet?.name ?? 'Ví'}'
                                                    : 'Rút về ${entry.wallet?.name ?? 'Ví'}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                DateFormat(
                                                  'dd/MM/yyyy',
                                                ).format(entry.date),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: colors
                                                          .onSurfaceVariant,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          isDeposit
                                              ? '+${MoneyFormatter.format(entry.amount)}'
                                              : '−${MoneyFormatter.format(entry.amount)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: isDeposit
                                                    ? colors.onSurface
                                                    : colors.onSurfaceVariant,
                                                fontFeatures: MoneyFormatter
                                                    .tabularFeatures,
                                              ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            AppCard(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  'Chưa có giao dịch nạp hoặc rút tiền nào.',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
