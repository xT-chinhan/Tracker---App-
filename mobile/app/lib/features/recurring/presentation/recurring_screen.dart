import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/formatting/money_formatter.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_icon_helper.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/icon_bubble.dart';
import '../application/recurring_service.dart';
import '../data/recurring_models.dart';
import 'recurring_form_sheet.dart';

class RecurringScreen extends ConsumerStatefulWidget {
  const RecurringScreen({super.key});

  @override
  ConsumerState<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends ConsumerState<RecurringScreen> {
  void _openRecurringFormSheet([RecurringRuleItem? rule]) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radius.xl),
        ),
      ),
      builder: (ctx) => RecurringFormSheet(existingRule: rule),
    );
  }

  String _formatScheduleSubtitle(RecurringRuleItem rule) {
    final freqText = switch (rule.frequency) {
      'DAILY' => 'Hằng ngày',
      'WEEKLY' => 'Hằng tuần',
      'MONTHLY' => 'Hằng tháng · ngày ${rule.anchorDay}',
      'YEARLY' => 'Hằng năm',
      _ => rule.frequency,
    };
    final walletName = rule.wallet?.name ?? 'Ví';
    return '$freqText · $walletName';
  }

  String _formatNextRun(DateTime nextRunAt) {
    final weekdayNames = [
      '',
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ nhật',
    ];
    final wd = weekdayNames[nextRunAt.weekday];
    final dateStr = DateFormat('dd/MM').format(nextRunAt);
    return 'Lần tới: $wd, $dateStr';
  }

  Future<void> _showRuleActions(RecurringRuleItem rule) async {
    final notifier = ref.read(recurringProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    await showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radius.xl),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                rule.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (rule.isActive)
                ListTile(
                  leading: const Icon(LucideIcons.pause),
                  title: const Text('Tạm dừng quy tắc này'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await notifier.pauseRule(rule.id);
                  },
                )
              else
                ListTile(
                  leading: const Icon(LucideIcons.play),
                  title: const Text('Tiếp tục chạy quy tắc'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    try {
                      await notifier.resumeRule(rule.id);
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Không thể tiếp tục: $e'),
                          backgroundColor: colors.error,
                        ),
                      );
                    }
                  },
                ),
              ListTile(
                leading: const Icon(LucideIcons.pencil),
                title: const Text('Sửa quy tắc'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _openRecurringFormSheet(rule);
                },
              ),
              ListTile(
                leading: Icon(LucideIcons.trash, color: colors.error),
                title: Text(
                  'Xóa quy tắc',
                  style: TextStyle(color: colors.error),
                ),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await notifier.deleteRule(rule.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final state = ref.watch(recurringProvider);
    final notifier = ref.read(recurringProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: notifier.load,
          child: CustomScrollView(
            slivers: [
              // Top Bar: < Cài đặt     +
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
                        tooltip: 'Thêm định kỳ mới',
                        onPressed: () => _openRecurringFormSheet(),
                      ),
                    ],
                  ),
                ),
              ),

              // Title: Định kỳ
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.spacing.screenPadding,
                    4,
                    context.spacing.screenPadding,
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Định kỳ',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tự động ghi vào ngày đến hạn.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Body
              state.rules.when(
                loading: () => SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.screenPadding,
                    ),
                    child: Column(
                      children: const [
                        AppCard(
                          child: AppSkeleton(
                            width: double.infinity,
                            height: 120,
                          ),
                        ),
                        SizedBox(height: 16),
                        AppCard(
                          child: AppSkeleton(
                            width: double.infinity,
                            height: 120,
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
                            'Không thể tải giao dịch định kỳ',
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
                data: (rules) {
                  final activeRules = rules.where((r) => r.isActive).toList();
                  final pausedRules = rules.where((r) => !r.isActive).toList();

                  if (rules.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing.screenPadding,
                        ),
                        child: AppCard(
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              Icon(
                                LucideIcons.calendar_clock,
                                size: 44,
                                color: context.appColors.faint,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Chưa có giao dịch định kỳ nào',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tạo quy tắc để tự động ghi các khoản thu chi lặp lại.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: colors.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 18),
                              AppButton(
                                label: '+ Thêm định kỳ đầu tiên',
                                onPressed: () => _openRecurringFormSheet(),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

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
                          // 1. Đang chạy · N
                          if (activeRules.isNotEmpty) ...[
                            Text(
                              'Đang chạy · ${activeRules.length}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 10),
                            AppCard(
                              padding: EdgeInsets.zero,
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: activeRules.length,
                                separatorBuilder: (_, _) => Divider(
                                  color: colors.outlineVariant,
                                  height: 1,
                                  indent: 64,
                                ),
                                itemBuilder: (context, index) {
                                  final rule = activeRules[index];
                                  return _buildRuleRow(context, rule);
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // 2. Tạm dừng · N
                          if (pausedRules.isNotEmpty) ...[
                            Text(
                              'Tạm dừng · ${pausedRules.length}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 10),
                            AppCard(
                              padding: EdgeInsets.zero,
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: pausedRules.length,
                                separatorBuilder: (_, _) => Divider(
                                  color: colors.outlineVariant,
                                  height: 1,
                                  indent: 64,
                                ),
                                itemBuilder: (context, index) {
                                  final rule = pausedRules[index];
                                  return _buildRuleRow(context, rule);
                                },
                              ),
                            ),
                          ],
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

  Widget _buildRuleRow(BuildContext context, RecurringRuleItem rule) {
    final colors = Theme.of(context).colorScheme;
    final isIncome = rule.category?.type == 'INCOME';
    final amountFormatted = isIncome
        ? '+${MoneyFormatter.format(rule.amount)}'
        : '−${MoneyFormatter.format(rule.amount)}';

    return InkWell(
      onTap: () => _showRuleActions(rule),
      borderRadius: BorderRadius.circular(context.radius.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconBubble(
              icon: rule.isActive
                  ? AppIconHelper.fromName(rule.category?.icon)
                  : LucideIcons.pause,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatScheduleSubtitle(rule),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (rule.isActive)
                    Text(
                      _formatNextRun(rule.nextRunAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: context.appColors.warningContainer,
                        borderRadius: BorderRadius.circular(
                          context.radius.pill,
                        ),
                      ),
                      child: Text(
                        'Đang tạm dừng',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.warning,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              amountFormatted,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: isIncome ? context.appColors.income : colors.onSurface,
                fontFeatures: MoneyFormatter.tabularFeatures,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
