import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/formatting/money_formatter.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_icon_helper.dart';
import '../../../core/widgets/app_progress.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/icon_bubble.dart';
import '../application/savings_service.dart';
import '../data/saving_models.dart';
import 'saving_form_sheet.dart';
import '../../../core/formatting/vietnam_time.dart';

class SavingsScreen extends ConsumerStatefulWidget {
  const SavingsScreen({super.key});

  @override
  ConsumerState<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends ConsumerState<SavingsScreen> {
  void _openCreateGoalSheet() {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radius.xl),
        ),
      ),
      builder: (ctx) => const SavingFormSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(savingsProvider);
    final notifier = ref.read(savingsProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: notifier.load,
          child: CustomScrollView(
            slivers: [
              // Top App Bar: < Cài đặt      +
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
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                        icon: const Icon(LucideIcons.chevron_left, size: 20),
                        label: const Text('Cài đặt'),
                        style: TextButton.styleFrom(
                          foregroundColor: colors.onSurface,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.plus, size: 22),
                        tooltip: 'Tạo mục tiêu',
                        onPressed: _openCreateGoalSheet,
                      ),
                    ],
                  ),
                ),
              ),

              // Title: Tiết kiệm
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.spacing.screenPadding,
                    4,
                    context.spacing.screenPadding,
                    16,
                  ),
                  child: Text(
                    'Tiết kiệm',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ),

              // Content Body
              state.goals.when(
                loading: () => SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.screenPadding,
                    ),
                    child: Column(
                      children: const [
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppSkeleton(width: 160, height: 16),
                              SizedBox(height: 12),
                              AppSkeleton(width: 220, height: 32),
                              SizedBox(height: 8),
                              AppSkeleton(width: 180, height: 14),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        AppCard(
                          child: AppSkeleton(
                            width: double.infinity,
                            height: 100,
                          ),
                        ),
                        SizedBox(height: 12),
                        AppCard(
                          child: AppSkeleton(
                            width: double.infinity,
                            height: 100,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                error: (err, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(context.spacing.screenPadding),
                    child: AppCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.circle_alert,
                            size: 40,
                            color: colors.error,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Không thể tải mục tiêu tiết kiệm',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            err.toString(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          AppButton(label: 'Thử lại', onPressed: notifier.load),
                        ],
                      ),
                    ),
                  ),
                ),
                data: (goals) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        context.spacing.screenPadding,
                        0,
                        context.spacing.screenPadding,
                        32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Total Savings Summary Card (12-tiet-kiem.png)
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Đã tiết kiệm · ${goals.length} mục tiêu',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  MoneyFormatter.format(state.totalSaved),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 32,
                                        letterSpacing: -0.03 * 32,
                                        color: colors.onSurface,
                                        fontFeatures:
                                            MoneyFormatter.tabularFeatures,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'trên tổng mục tiêu ${MoneyFormatter.format(state.totalTarget)}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colors.onSurfaceVariant,
                                        fontFeatures:
                                            MoneyFormatter.tabularFeatures,
                                      ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 2. Individual Goal Cards (12-tiet-kiem.png)
                          if (goals.isNotEmpty)
                            ...goals.map(
                              (goal) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildGoalCard(context, goal),
                              ),
                            )
                          else
                            AppCard(
                              child: Column(
                                children: [
                                  const SizedBox(height: 16),
                                  Icon(
                                    LucideIcons.piggy_bank,
                                    size: 44,
                                    color: context.appColors.faint,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Chưa có mục tiêu tiết kiệm nào',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Tạo mục tiêu để theo dõi và hoàn thành kế hoạch tích lũy.',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 18),
                                  AppButton(
                                    label: '+ Tạo mục tiêu đầu tiên',
                                    onPressed: _openCreateGoalSheet,
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, SavingGoalItem goal) {
    final colors = Theme.of(context).colorScheme;
    final dateStr = DateFormat(
      'dd/MM/yyyy',
    ).format(VietnamTime.fromDateTime(goal.targetDate));

    final subtitle = goal.daysLeft > 0
        ? 'Hạn $dateStr · còn ${goal.daysLeft} ngày'
        : 'Hạn $dateStr';

    return AppCard(
      onTap: () => context.push('/savings/${goal.id}'),
      child: Column(
        children: [
          Row(
            children: [
              IconBubble(icon: AppIconHelper.fromName(goal.icon)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${goal.progress.toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFeatures: MoneyFormatter.tabularFeatures,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppProgress(percent: goal.progress, height: 6),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                MoneyFormatter.format(goal.savedAmount),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: MoneyFormatter.tabularFeatures,
                ),
              ),
              Text(
                '/ ${MoneyFormatter.format(goal.targetAmount)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontFeatures: MoneyFormatter.tabularFeatures,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
