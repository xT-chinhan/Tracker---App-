import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatting/money_formatter.dart';
import '../../../core/formatting/vietnam_time.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_icon_helper.dart';
import '../../../core/widgets/app_progress.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/icon_bubble.dart';
import '../../../core/widgets/pressable.dart';
import '../../auth/application/app_session.dart';
import '../../notifications/application/notifications_service.dart';
import '../application/home_service.dart';
import '../data/home_models.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    final unreadCount = ref.watch(unreadCountProvider).value ?? 0;
    final publicConfig = ref.watch(appSessionProvider).config;
    final aiEnabled = publicConfig?.ai.enabled ?? false;
    final quickTemplatesEnabled = publicConfig?.features.quickTemplates ?? true;
    final transfersEnabled = publicConfig?.features.transfers ?? true;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: () =>
              ref.read(homeControllerProvider.notifier).load(refresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              context.spacing.screenPadding,
              12,
              context.spacing.screenPadding,
              120, // Bottom clearance for bottom nav bar
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top App Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'đ',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (aiEnabled) ...[
                          Pressable(
                            onTap: () => context.push('/ai'),
                            semanticLabel: 'Trợ lý AI',
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainer,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                LucideIcons.sparkles,
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Pressable(
                          onTap: () => context.push('/notifications'),
                          semanticLabel: 'Thông báo',
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainer,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  LucideIcons.bell,
                                  size: 20,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                if (unreadCount > 0)
                                  Positioned(
                                    top: -2,
                                    right: -2,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: context.appColors.danger,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Headline Date
                Text(
                  VietnamTime.headline(VietnamTime.now()),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),

                if (state.isLoading && state.balance == null)
                  _HomeSkeleton(transfersEnabled: transfersEnabled)
                else ...[
                  // Balance & Budget Card
                  _BalanceCard(
                    balance: state.balance,
                    budgets: state.budgets,
                    todaySummary: state.todaySummary,
                    monthSummary: state.monthSummary,
                    isHidden: state.isBalanceHidden,
                    onToggleVisibility: () => ref
                        .read(homeControllerProvider.notifier)
                        .toggleBalanceVisibility(),
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons: Ghi giao dịch & Chuyển tiền
                  Row(
                    children: [
                      Expanded(
                        flex: 145,
                        child: AppButton(
                          label: 'Ghi giao dịch',
                          icon: LucideIcons.plus,
                          onPressed: () => context.push('/transactions/new'),
                        ),
                      ),
                      if (transfersEnabled) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 100,
                          child: AppButton(
                            label: 'Chuyển tiền',
                            icon: LucideIcons.arrow_left_right,
                            style: AppButtonStyle.secondary,
                            onPressed: () => context.push('/transfers/new'),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Quick Templates Section
                  if (quickTemplatesEnabled &&
                      state.quickTemplates.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Nhập nhanh',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: state.quickTemplates.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final item = state.quickTemplates[index];
                          return _QuickTemplateChip(
                            item: item,
                            onTap: () => _handleUseTemplate(context, ref, item),
                          );
                        },
                      ),
                    ),
                  ],

                  // Recent Transactions Section
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Gần đây',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Pressable(
                        onTap: () => context.go('/history'),
                        child: Text(
                          'Xem tất cả',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (state.recentTransactions.isEmpty)
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                        vertical: 36,
                        horizontal: 16,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              LucideIcons.receipt_text,
                              size: 32,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Chưa có giao dịch gần đây',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (
                            var i = 0;
                            i < state.recentTransactions.length;
                            i++
                          ) ...[
                            if (i > 0) const Divider(height: 1, indent: 68),
                            _TransactionRow(
                              item: state.recentTransactions[i],
                              onTap: () => context.push(
                                '/transactions/${state.recentTransactions[i].id}',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleUseTemplate(
    BuildContext context,
    WidgetRef ref,
    QuickTemplateItem item,
  ) async {
    try {
      final title = await ref
          .read(homeControllerProvider.notifier)
          .useQuickTemplate(item.id);
      if (context.mounted && title != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã ghi: $title'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final message = e is ApiException
            ? e.message
            : 'Không thể sử dụng mẫu nhập nhanh';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: context.appColors.danger,
          ),
        );
      }
    }
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.budgets,
    required this.todaySummary,
    required this.monthSummary,
    required this.isHidden,
    required this.onToggleVisibility,
  });

  final StatsBalance? balance;
  final BudgetSummary? budgets;
  final StatsSummary? todaySummary;
  final StatsSummary? monthSummary;
  final bool isHidden;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final overall = budgets?.overall;
    final totalSpent = overall?.spent ?? monthSummary?.expense ?? 0;
    final totalLimit = overall?.limitAmount ?? 0;
    final percent = totalLimit > 0 ? (totalSpent / totalLimit) * 100 : 0.0;
    final progressStatus = overall != null
        ? switch (overall.status) {
            'warning' => ProgressStatus.warning,
            'exceeded' => ProgressStatus.exceeded,
            _ => ProgressStatus.ok,
          }
        : ProgressStatus.ok;

    final remaining = totalLimit - totalSpent;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Pressable(
                onTap: onToggleVisibility,
                semanticLabel: isHidden ? 'Hiện số dư' : 'Ẩn số dư',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tổng số dư · ${balance?.wallets.length ?? 0} ví',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      isHidden ? LucideIcons.eye_off : LucideIcons.eye,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              Pressable(
                onTap: () => context.push('/wallets'),
                semanticLabel: 'Xem danh sách ví',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ví',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      LucideIcons.chevron_right,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isHidden
                ? '••••••••'
                : MoneyFormatter.format(balance?.balance ?? 0),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontFeatures: MoneyFormatter.tabularFeatures,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          AppProgress(percent: percent, status: progressStatus, height: 6),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  children: [
                    const TextSpan(text: 'Ngân sách tháng đã dùng '),
                    TextSpan(
                      text: '${percent.round()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                totalLimit > 0
                    ? (remaining >= 0
                          ? 'còn ${MoneyFormatter.format(remaining)}'
                          : 'vượt ${MoneyFormatter.format(remaining.abs())}')
                    : 'Chưa đặt hạn mức',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontFeatures: MoneyFormatter.tabularFeatures,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hôm nay',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isHidden
                          ? '••••••••'
                          : MoneyFormatter.format(todaySummary?.expense ?? 0),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFeatures: MoneyFormatter.tabularFeatures,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 38,
                width: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tháng này',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isHidden
                          ? '••••••••'
                          : MoneyFormatter.format(monthSummary?.expense ?? 0),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFeatures: MoneyFormatter.tabularFeatures,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickTemplateChip extends StatelessWidget {
  const _QuickTemplateChip({required this.item, required this.onTap});

  final QuickTemplateItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: 'Nhập nhanh: ${item.label}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(context.radius.pill),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          boxShadow: context.shadows.card,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIconHelper.fromName(item.category?.icon),
              size: 15,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 6),
            Text(
              item.label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 4),
            Text(
              MoneyFormatter.compact(item.amount),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontFeatures: MoneyFormatter.tabularFeatures,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.item, required this.onTap});

  final TransactionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isExpense = item.type == 'EXPENSE';
    final sign = isExpense ? '−' : '+';
    final amountColor = isExpense
        ? context.appColors.expense
        : context.appColors.income;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconBubble(icon: AppIconHelper.fromName(item.category?.icon)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.category?.name ?? 'Khác'} · ${item.wallet?.name ?? 'Ví'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign${MoneyFormatter.format(item.amount)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFeatures: MoneyFormatter.tabularFeatures,
                    fontWeight: FontWeight.w600,
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  VietnamTime.timeOnly(item.occurredAt),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton({this.transfersEnabled = true});

  final bool transfersEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Balance Card Skeleton matching 23-dang-tai.png
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(
                width: 110,
                height: 14,
                borderRadius: BorderRadius.circular(7),
              ),
              const SizedBox(height: 12),
              AppSkeleton(
                width: double.infinity,
                height: 44,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFF0EFEC)),
              const SizedBox(height: 14),
              AppSkeleton(
                width: 170,
                height: 14,
                borderRadius: BorderRadius.circular(7),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  AppSkeleton(
                    width: 100,
                    height: 14,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  const SizedBox(width: 24),
                  AppSkeleton(
                    width: 110,
                    height: 14,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Action Buttons: Ghi giao dịch & Chuyển tiền matching 23-dang-tai.png
        Row(
          children: [
            Expanded(
              flex: 145,
              child: AppButton(
                label: 'Ghi giao dịch',
                icon: LucideIcons.plus,
                onPressed: () => context.push('/transactions/new'),
              ),
            ),
            if (transfersEnabled) ...[
              const SizedBox(width: 10),
              Expanded(
                flex: 100,
                child: AppButton(
                  label: 'Chuyển tiền',
                  icon: LucideIcons.arrow_left_right,
                  style: AppButtonStyle.secondary,
                  onPressed: () => context.push('/transfers/new'),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),

        // Thường dùng / Filter chips title skeleton
        AppSkeleton(
          width: 80,
          height: 14,
          borderRadius: BorderRadius.circular(7),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: AppSkeleton(
                width: double.infinity,
                height: 44,
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppSkeleton(
                width: double.infinity,
                height: 44,
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppSkeleton(
                width: double.infinity,
                height: 44,
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Gần đây title skeleton
        AppSkeleton(
          width: 70,
          height: 14,
          borderRadius: BorderRadius.circular(7),
        ),
        const SizedBox(height: 10),

        // Recent transactions card skeleton
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              _buildTransactionRowSkeleton(),
              const Divider(height: 20, indent: 56, color: Color(0xFFF0EFEC)),
              _buildTransactionRowSkeleton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionRowSkeleton() {
    return Row(
      children: [
        const AppSkeleton(width: 40, height: 40, shape: BoxShape.circle),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(
                width: 110,
                height: 14,
                borderRadius: BorderRadius.circular(7),
              ),
              const SizedBox(height: 6),
              AppSkeleton(
                width: 70,
                height: 12,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
        ),
        AppSkeleton(
          width: 60,
          height: 14,
          borderRadius: BorderRadius.circular(7),
        ),
      ],
    );
  }
}
