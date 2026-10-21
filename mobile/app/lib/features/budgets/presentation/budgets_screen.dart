import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/money_formatter.dart';
import '../../../core/formatting/vietnam_time.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_icon_helper.dart';
import '../../../core/widgets/app_progress.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/icon_bubble.dart';
import '../../home/data/home_models.dart';
import '../application/budgets_service.dart';
import 'budget_form_sheet.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  String _formatMonthLabel(DateTime month) {
    final now = VietnamTime.now();
    if (month.year == now.year) {
      return 'Tháng ${month.month}';
    }
    return 'Tháng ${month.month}, ${month.year}';
  }

  int _calculateDaysLeft(DateTime selectedMonth) {
    final now = VietnamTime.now();
    final isCurrentMonth =
        selectedMonth.year == now.year && selectedMonth.month == now.month;
    if (!isCurrentMonth) {
      return 0;
    }
    final lastDay = DateTime(
      selectedMonth.year,
      selectedMonth.month + 1,
      0,
    ).day;
    return (lastDay - now.day).clamp(0, lastDay);
  }

  int _calculateDailySpendable(int remaining, int daysLeft) {
    if (remaining <= 0 || daysLeft <= 0) return 0;
    return (remaining / daysLeft).round();
  }

  void _openCreateBudgetSheet({
    BudgetItem? budget,
    BudgetOverall? overall,
    required Set<String> takenIds,
  }) {
    showModalBottomSheet<bool>(
      // mở trên navigator gốc: không bị thanh menu dưới (shell) che
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radius.xl),
        ),
      ),
      builder: (ctx) => BudgetFormSheet(
        existingBudget: budget,
        existingOverall: overall,
        takenCategoryIds: takenIds,
      ),
    );
  }

  Future<void> _handleCopyBudgets() async {
    final notifier = ref.read(budgetsProvider.notifier);
    try {
      final count = await notifier.copyFromPreviousMonth();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã sao chép $count ngân sách từ tháng trước!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể sao chép: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetsProvider);
    final notifier = ref.read(budgetsProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    final daysLeft = _calculateDaysLeft(state.selectedMonth);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: notifier.load,
          child: CustomScrollView(
            slivers: [
              // Top Appbar: < Cài đặt     +
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
                        tooltip: 'Tạo ngân sách',
                        onPressed: () {
                          final taken =
                              state.summary.value?.items
                                  .map((b) => b.categoryId)
                                  .toSet() ??
                              <String>{};
                          _openCreateBudgetSheet(takenIds: taken);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Title: Ngân sách     < Tháng 9 >
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.spacing.screenPadding,
                    4,
                    context.spacing.screenPadding,
                    16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Ngân sách',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.onSurface,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Month Selector Pill: < Tháng 9 >
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surfaceContainer,
                          borderRadius: BorderRadius.circular(
                            context.radius.pill,
                          ),
                          border: Border.all(color: colors.outline),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                LucideIcons.chevron_left,
                                size: 18,
                              ),
                              onPressed: notifier.previousMonth,
                              visualDensity: VisualDensity.compact,
                              splashRadius: 18,
                              tooltip: 'Tháng trước',
                            ),
                            Text(
                              _formatMonthLabel(state.selectedMonth),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colors.onSurface,
                                  ),
                            ),
                            IconButton(
                              icon: const Icon(
                                LucideIcons.chevron_right,
                                size: 18,
                              ),
                              onPressed: notifier.nextMonth,
                              visualDensity: VisualDensity.compact,
                              splashRadius: 18,
                              tooltip: 'Tháng sau',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Body
              state.summary.when(
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
                              SizedBox(height: 16),
                              AppSkeleton(width: double.infinity, height: 8),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        AppCard(
                          child: AppSkeleton(
                            width: double.infinity,
                            height: 180,
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
                            'Không thể tải ngân sách',
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
                data: (summary) {
                  final overall = summary.overall;
                  final totalLimit = overall != null
                      ? overall.limitAmount
                      : summary.totalLimit;
                  final totalSpent = overall != null
                      ? overall.spent
                      : summary.totalSpent;
                  final totalRemaining = overall != null
                      ? overall.remaining
                      : summary.totalRemaining;
                  final overallPercent = totalLimit > 0
                      ? ((totalSpent / totalLimit) * 100)
                            .clamp(0, 999)
                            .toDouble()
                      : 0.0;
                  final dailySpendable = _calculateDailySpendable(
                    totalRemaining,
                    daysLeft,
                  );

                  final takenIds = summary.items
                      .map((b) => b.categoryId)
                      .toSet();

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
                          // 1. Overall Budget Card (11-ngan-sach.png)
                          if (totalLimit > 0 || overall != null)
                            AppCard(
                              onTap: () {
                                _openCreateBudgetSheet(
                                  overall: overall,
                                  takenIds: takenIds,
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        daysLeft > 0
                                            ? 'Còn lại · $daysLeft ngày nữa hết tháng'
                                            : 'Còn lại trong tháng',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: colors.onSurfaceVariant,
                                            ),
                                      ),
                                      Text(
                                        '${overallPercent.toInt()}%',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: colors.onSurfaceVariant,
                                              fontFeatures: MoneyFormatter
                                                  .tabularFeatures,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    MoneyFormatter.format(totalRemaining),
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
                                  const SizedBox(height: 12),
                                  // Thick Progress Bar
                                  AppProgress(
                                    percent: overallPercent,
                                    height: 8,
                                    status: overallPercent >= 100
                                        ? ProgressStatus.exceeded
                                        : (overallPercent >= 80
                                              ? ProgressStatus.warning
                                              : ProgressStatus.ok),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Đã chi ${MoneyFormatter.format(totalSpent)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: colors.onSurfaceVariant,
                                              fontFeatures: MoneyFormatter
                                                  .tabularFeatures,
                                            ),
                                      ),
                                      Text(
                                        'Hạn mức ${MoneyFormatter.format(totalLimit)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: colors.onSurfaceVariant,
                                              fontFeatures: MoneyFormatter
                                                  .tabularFeatures,
                                            ),
                                      ),
                                    ],
                                  ),
                                  if (daysLeft > 0 && totalRemaining > 0) ...[
                                    const SizedBox(height: 8),
                                    RichText(
                                      text: TextSpan(
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: colors.onSurfaceVariant,
                                            ),
                                        children: [
                                          const TextSpan(
                                            text: 'Mỗi ngày còn chi được ',
                                          ),
                                          TextSpan(
                                            text: MoneyFormatter.format(
                                              dailySpendable,
                                            ),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: colors.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            )
                          else
                            AppCard(
                              child: Column(
                                children: [
                                  Icon(
                                    LucideIcons.target,
                                    size: 36,
                                    color: context.appColors.faint,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Chưa đặt ngân sách tổng',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Đặt ngân sách để kiểm soát chi tiêu tốt hơn.',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  AppButton(
                                    label: 'Đặt ngân sách tổng',
                                    onPressed: () {
                                      _openCreateBudgetSheet(
                                        overall: null,
                                        takenIds: takenIds,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 20),

                          // 2. Section Header: Theo danh mục      4 ngân sách
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Theo danh mục',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                '${summary.items.length} ngân sách',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: colors.onSurfaceVariant),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // 3. Category Budgets List Card (11-ngan-sach.png)
                          if (summary.items.isNotEmpty)
                            AppCard(
                              padding: EdgeInsets.zero,
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: summary.items.length,
                                separatorBuilder: (_, _) => Divider(
                                  color: colors.outlineVariant,
                                  height: 1,
                                  indent: 64,
                                ),
                                itemBuilder: (context, index) {
                                  final item = summary.items[index];
                                  return _buildBudgetItemRow(
                                    context,
                                    item,
                                    takenIds,
                                  );
                                },
                              ),
                            )
                          else
                            AppCard(
                              child: Column(
                                children: [
                                  const SizedBox(height: 12),
                                  Icon(
                                    LucideIcons.wallet,
                                    size: 40,
                                    color: context.appColors.faint,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Chưa có ngân sách theo danh mục',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Bạn có thể tạo mới hoặc sao chép nhanh từ tháng trước.',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppButton(
                                          label: 'Sao chép',
                                          icon: LucideIcons.copy,
                                          style: AppButtonStyle.secondary,
                                          onPressed: _handleCopyBudgets,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: AppButton(
                                          label: '+ Tạo mới',
                                          onPressed: () {
                                            _openCreateBudgetSheet(
                                              takenIds: takenIds,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
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

  Widget _buildBudgetItemRow(
    BuildContext context,
    BudgetItem item,
    Set<String> takenIds,
  ) {
    final colors = Theme.of(context).colorScheme;
    final cat = item.category;
    final isExceeded =
        item.status == 'exceeded' || item.spent > item.limitAmount;
    final isWarning = item.status == 'warning';

    // Subtitle text
    final subText = isExceeded
        ? 'Vượt ${MoneyFormatter.format(item.spent - item.limitAmount)}'
        : '${MoneyFormatter.format(item.spent)} / ${MoneyFormatter.format(item.limitAmount)}';

    return InkWell(
      onTap: () {
        _openCreateBudgetSheet(budget: item, takenIds: takenIds);
      },
      borderRadius: BorderRadius.circular(context.radius.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Row(
              children: [
                IconBubble(icon: AppIconHelper.fromName(cat?.icon)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat?.name ?? 'Danh mục',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isExceeded
                              ? context.appColors.danger
                              : colors.onSurfaceVariant,
                          fontWeight: isExceeded ? FontWeight.w600 : null,
                          fontFeatures: MoneyFormatter.tabularFeatures,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Badge or Percentage
                if (isExceeded)
                  Container(
                    height: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: context.appColors.dangerContainer,
                      borderRadius: BorderRadius.circular(context.radius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.circle_alert,
                          size: 13,
                          color: context.appColors.danger,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.percentage.toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.appColors.danger,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isWarning)
                  Container(
                    height: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: context.appColors.warningContainer,
                      borderRadius: BorderRadius.circular(context.radius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.triangle_alert,
                          size: 13,
                          color: context.appColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.percentage.toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.appColors.warning,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    '${item.percentage.toInt()}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      fontFeatures: MoneyFormatter.tabularFeatures,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // Progress Bar below row
            AppProgress(
              percent: item.percentage,
              height: 6,
              status: isExceeded
                  ? ProgressStatus.exceeded
                  : (isWarning ? ProgressStatus.warning : ProgressStatus.ok),
            ),
          ],
        ),
      ),
    );
  }
}
