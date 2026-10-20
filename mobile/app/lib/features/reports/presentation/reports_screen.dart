import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/money_formatter.dart';
import '../../../core/formatting/vietnam_time.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../auth/application/app_session.dart';
import '../application/reports_service.dart';
import '../data/report_models.dart';
import 'widgets/donut_chart.dart';
import 'widgets/monthly_bar_chart.dart';
import 'widgets/trend_badge.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatMonthLabel(DateTime month) {
    final now = VietnamTime.now();
    if (month.year == now.year) {
      return 'Tháng ${month.month}';
    }
    return 'Tháng ${month.month}, ${month.year}';
  }

  int _calculateEndOfMonthForecast(int currentExpense, DateTime selectedMonth) {
    final now = VietnamTime.now();
    final isCurrentMonth =
        selectedMonth.year == now.year && selectedMonth.month == now.month;

    if (!isCurrentMonth) {
      // If month is in past or future, return current expense
      return currentExpense;
    }

    final daysInMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month + 1,
      0,
    ).day;
    final currentDay = now.day.clamp(1, daysInMonth);
    if (currentDay == 0 || currentExpense == 0) return currentExpense;
    return ((currentExpense / currentDay) * daysInMonth).round();
  }

  Future<void> _handleExportCsv() async {
    final notifier = ref.read(reportsProvider.notifier);
    final csv = await notifier.exportCsv();
    if (!mounted) return;

    if (csv == null) {
      final error = ref.read(reportsProvider).exportError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Xuất CSV thất bại'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Show success sheet with copy option
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radius.xl),
        ),
      ),
      builder: (sheetContext) {
        final lineCount = csv.split('\n').length - 1;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            context.spacing.screenPadding,
            24,
            context.spacing.screenPadding,
            32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: context.appColors.successContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.download,
                      color: context.appColors.income,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xuất file CSV thành công',
                          style: Theme.of(sheetContext).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '$lineCount dòng dữ liệu đã được xuất.',
                          style: Theme.of(sheetContext).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  sheetContext,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Sao chép nội dung CSV',
                icon: LucideIcons.copy,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: csv));
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã sao chép nội dung CSV vào bộ nhớ tạm!'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportsProvider);
    final notifier = ref.read(reportsProvider.notifier);
    final session = ref.watch(appSessionProvider);
    final colors = Theme.of(context).colorScheme;
    final csvExportEnabled = session.config?.features.csvExport ?? true;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: notifier.load,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Top Header with Title, Month Switcher & Download Icon
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.spacing.screenPadding,
                    16,
                    context.spacing.screenPadding,
                    12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Báo cáo',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.onSurface,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Month Switcher: < Tháng 9 >
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
                          if (csvExportEnabled) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: state.isExporting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(LucideIcons.download, size: 20),
                              onPressed: state.isExporting
                                  ? null
                                  : _handleExportCsv,
                              tooltip: 'Xuất CSV',
                              style: IconButton.styleFrom(
                                backgroundColor: colors.surfaceContainer,
                                shape: const CircleBorder(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Report Content
              state.report.when(
                loading: () => SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.screenPadding,
                      vertical: 12,
                    ),
                    child: Column(
                      children: [
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppSkeleton(width: 120, height: 16),
                              const SizedBox(height: 12),
                              const AppSkeleton(width: 200, height: 32),
                              const SizedBox(height: 16),
                              Row(
                                children: const [
                                  Expanded(
                                    child: AppSkeleton(
                                      width: double.infinity,
                                      height: 38,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: AppSkeleton(
                                      width: double.infinity,
                                      height: 38,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              AppSkeleton(width: 140, height: 20),
                              SizedBox(height: 16),
                              AppSkeleton(width: double.infinity, height: 132),
                            ],
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
                            'Không thể tải báo cáo',
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
                data: (report) => SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.spacing.screenPadding,
                      4,
                      context.spacing.screenPadding,
                      32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card 1: Chênh lệch thu chi (09-bao-cao.png)
                        _buildNetCard(context, report),
                        const SizedBox(height: 12),

                        // Card 2: Chi theo danh mục (09-bao-cao.png)
                        _buildCategoryCard(context, report),
                        const SizedBox(height: 12),

                        // Card 3: Thu chi 6 tháng (10-bao-cao-xu-huong.png)
                        _buildTrendCard(context, report, state),
                        const SizedBox(height: 12),

                        // Card 4: So với tháng trước (10-bao-cao-xu-huong.png)
                        _buildComparisonCard(context, report),
                        const SizedBox(height: 12),

                        // Card 5: Dự báo (10-bao-cao-xu-huong.png)
                        _buildForecastCard(context, report, state),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Chênh lệch thu chi Card
  Widget _buildNetCard(BuildContext context, ReportData report) {
    final colors = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chênh lệch thu chi',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            MoneyFormatter.format(report.net, signed: true),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 32,
              letterSpacing: -0.03 * 32,
              color: colors.onSurface,
              fontFeatures: MoneyFormatter.tabularFeatures,
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: colors.outlineVariant, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: context.appColors.income,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Thu nhập',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      MoneyFormatter.format(report.income),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.appColors.income,
                        fontFeatures: MoneyFormatter.tabularFeatures,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 38, color: colors.outlineVariant),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: context.appColors.expense,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Chi tiêu',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      MoneyFormatter.format(report.expense),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                        fontFeatures: MoneyFormatter.tabularFeatures,
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

  // 2. Chi theo danh mục Card
  Widget _buildCategoryCard(BuildContext context, ReportData report) {
    final colors = Theme.of(context).colorScheme;
    final vizColors = context.appColors.viz;
    // Mỗi nhóm một màu viz cố định: quá số màu thì gộp phần còn lại vào "Khác" (mockup 09)
    final categories = groupCategories(
      report.expenseByCategory,
      vizColors.length,
    );
    final topCategory = categories.isNotEmpty ? categories.first : null;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chi theo danh mục',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '${categories.length} nhóm',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              DonutChart(
                categories: categories,
                totalExpense: report.expense,
                size: 132,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng chi',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      MoneyFormatter.format(report.expense),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFeatures: MoneyFormatter.tabularFeatures,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Lớn nhất',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      topCategory != null
                          ? '${topCategory.category.name} · ${topCategory.percentage.toInt()}%'
                          : 'Chưa có',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (categories.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...List.generate(categories.length, (index) {
              final item = categories[index];
              final isLast = index == categories.length - 1;
              final segColor = vizColors[index % vizColors.length];

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: segColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.category.name,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          '${item.percentage.toInt()}%',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          MoneyFormatter.format(item.amount),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontFeatures: MoneyFormatter.tabularFeatures,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast) Divider(color: colors.outlineVariant, height: 1),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  // 3. Thu chi 6 tháng Card
  Widget _buildTrendCard(
    BuildContext context,
    ReportData report,
    ReportsState state,
  ) {
    final colors = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Thu chi 6 tháng',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: context.appColors.income,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Thu',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: context.appColors.expense,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Chi',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          MonthlyBarChart(
            history: report.history,
            currentMonth: state.monthString,
            height: 150,
          ),
          const SizedBox(height: 8),
          Text(
            'Tháng ${state.selectedMonth.month} tính đến hôm nay. Đơn vị: triệu đồng.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: context.appColors.faint),
          ),
        ],
      ),
    );
  }

  // 4. So với tháng trước Card
  Widget _buildComparisonCard(BuildContext context, ReportData report) {
    final comp = report.comparison;
    final prevMonthNum = comp.previousMonth.split('-').lastOrNull ?? '';

    final expenseDiff = comp.expense.difference;
    final expensePct = comp.expense.percentageChange ?? 0.0;
    // For expense: decreased is OK, increased is DANGER
    final expenseBadgeType = expenseDiff < 0
        ? TrendBadgeType.ok
        : (expenseDiff > 0 ? TrendBadgeType.danger : TrendBadgeType.neutral);

    final incomeDiff = comp.income.difference;
    final incomePct = comp.income.percentageChange ?? 0.0;
    // For income: increased is OK, decreased is NEUTRAL/DANGER
    final incomeBadgeType = incomeDiff > 0
        ? TrendBadgeType.ok
        : (incomeDiff < 0 ? TrendBadgeType.neutral : TrendBadgeType.neutral);

    final topCategoryComp = report.topCategoryComparison;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'So với tháng $prevMonthNum',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),

          // Row 1: Chi tiêu
          _buildComparisonRow(
            context,
            label: 'Chi tiêu',
            previousAmount: comp.expense.previous,
            currentAmount: comp.expense.current,
            pct: expensePct,
            isUp: expenseDiff > 0 ? true : (expenseDiff < 0 ? false : null),
            badgeType: expenseBadgeType,
          ),
          Divider(
            color: Theme.of(context).colorScheme.outlineVariant,
            height: 1,
          ),

          // Row 2: Thu nhập
          _buildComparisonRow(
            context,
            label: 'Thu nhập',
            previousAmount: comp.income.previous,
            currentAmount: comp.income.current,
            pct: incomePct,
            isUp: incomeDiff > 0 ? true : (incomeDiff < 0 ? false : null),
            badgeType: incomeBadgeType,
          ),

          // Row 3: Top category (if present)
          if (topCategoryComp != null) ...[
            Divider(
              color: Theme.of(context).colorScheme.outlineVariant,
              height: 1,
            ),
            _buildComparisonRow(
              context,
              label: topCategoryComp.categoryName ?? 'Danh mục lớn nhất',
              previousAmount: topCategoryComp.previous,
              currentAmount: topCategoryComp.current,
              pct: topCategoryComp.percentageChange ?? 0.0,
              isUp: topCategoryComp.difference > 0
                  ? true
                  : (topCategoryComp.difference < 0 ? false : null),
              badgeType: topCategoryComp.difference > 0
                  ? TrendBadgeType.danger
                  : TrendBadgeType.ok,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    BuildContext context, {
    required String label,
    required int previousAmount,
    required int currentAmount,
    required double pct,
    required bool? isUp,
    required TrendBadgeType badgeType,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${MoneyFormatter.format(previousAmount)} → ${MoneyFormatter.format(currentAmount)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontFeatures: MoneyFormatter.tabularFeatures,
                  ),
                ),
              ],
            ),
          ),
          TrendBadge(percentage: pct, isUp: isUp, type: badgeType),
        ],
      ),
    );
  }

  // 5. Dự báo Card
  Widget _buildForecastCard(
    BuildContext context,
    ReportData report,
    ReportsState state,
  ) {
    final colors = Theme.of(context).colorScheme;
    final forecastEndOfMonth = _calculateEndOfMonthForecast(
      report.expense,
      state.selectedMonth,
    );
    final nextMonthNum = report.forecast.month.split('-').lastOrNull ?? '';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dự báo',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cuối tháng ${state.selectedMonth.month}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '≈ ${MoneyFormatter.format(forecastEndOfMonth)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFeatures: MoneyFormatter.tabularFeatures,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dự kiến cả tháng',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.appColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 48, color: colors.outlineVariant),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tháng $nextMonthNum',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '≈ ${MoneyFormatter.format(report.forecast.expense.predicted)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFeatures: MoneyFormatter.tabularFeatures,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      report.forecast.expense.method == 'weighted_average'
                          ? 'TB có trọng số'
                          : 'TB các tháng gần nhất',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
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

/// Giữ `maxGroups - 1` nhóm lớn nhất, gộp phần còn lại thành "Khác" để không lặp màu biểu đồ.
List<CategoryReportItem> groupCategories(
  List<CategoryReportItem> items,
  int maxGroups,
) {
  if (maxGroups < 2 || items.length <= maxGroups) return items;
  final head = items.take(maxGroups - 1).toList();
  final rest = items.skip(maxGroups - 1);
  return [
    ...head,
    CategoryReportItem(
      category: const CategorySummaryItem(
        id: 'other',
        name: 'Khác',
        icon: 'ellipsis',
      ),
      amount: rest.fold(0, (sum, e) => sum + e.amount),
      count: rest.fold(0, (sum, e) => sum + e.count),
      percentage: rest.fold(0.0, (sum, e) => sum + e.percentage),
    ),
  ];
}
