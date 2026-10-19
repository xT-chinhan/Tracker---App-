import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatting/money_formatter.dart';
import '../../../core/formatting/vietnam_time.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_icon_helper.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../transactions/presentation/transaction_entry_screen.dart';
import '../application/history_service.dart';
import 'widgets/history_filter_sheet.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(historyProvider.notifier).loadMore();
    }
  }

  String _formatMonthLabel(DateTime month) {
    final now = VietnamTime.now();
    if (month.year == now.year) {
      return 'Tháng ${month.month}';
    }
    return 'Tháng ${month.month}, ${month.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);
    final notifier = ref.read(historyProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    final hasActiveExtraFilters =
        state.filter.categoryId != null || state.filter.walletId != null;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => notifier.load(resetPage: true),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Top Header with Title and Month Navigator
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
                      Text(
                        'Lịch sử',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colors.onSurface,
                            ),
                      ),
                      // Month Navigator Chip: < Tháng 9 >
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surfaceContainer,
                          borderRadius: BorderRadius.circular(
                            context.radius.pill,
                          ),
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
                              _formatMonthLabel(state.filter.selectedMonth),
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

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.screenPadding,
                  ),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(context.radius.pill),
                      border: Border.all(
                        color: colors.outlineVariant.withAlpha(120),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.search,
                          size: 18,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: notifier.onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Tìm người nhận, số tiền, ghi chú...',
                              hintStyle: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: colors.onSurfaceVariant.withAlpha(
                                      160,
                                    ),
                                  ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(LucideIcons.x, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              notifier.onSearchChanged('');
                            },
                            visualDensity: VisualDensity.compact,
                            splashRadius: 14,
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Filter Chips Row
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.screenPadding,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterTabChip(
                                label: 'Tất cả',
                                isSelected: state.filter.type == null,
                                onTap: () => notifier.setType(null),
                              ),
                              const SizedBox(width: 8),
                              _FilterTabChip(
                                label: 'Khoản chi',
                                isSelected:
                                    state.filter.type ==
                                    TransactionType.expense,
                                onTap: () =>
                                    notifier.setType(TransactionType.expense),
                              ),
                              const SizedBox(width: 8),
                              _FilterTabChip(
                                label: 'Thu nhập',
                                isSelected:
                                    state.filter.type == TransactionType.income,
                                onTap: () =>
                                    notifier.setType(TransactionType.income),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Filter Sheet Button
                      InkWell(
                        onTap: () => HistoryFilterSheet.show(context),
                        borderRadius: BorderRadius.circular(
                          context.radius.pill,
                        ),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasActiveExtraFilters
                                ? const Color(0xFF111111)
                                : colors.surface,
                            border: Border.all(
                              color: hasActiveExtraFilters
                                  ? const Color(0xFF111111)
                                  : colors.outlineVariant.withAlpha(120),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            LucideIcons.sliders_horizontal,
                            size: 16,
                            color: hasActiveExtraFilters
                                ? Colors.white
                                : colors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // Month Summary Row
              if (state.summary != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.screenPadding,
                    ),
                    child: Text.rich(
                      TextSpan(
                        text:
                            '${_formatMonthLabel(state.filter.selectedMonth)}: chi ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                        children: [
                          TextSpan(
                            text: MoneyFormatter.format(state.summary!.expense),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                              fontFeatures: MoneyFormatter.tabularFeatures,
                            ),
                          ),
                          const TextSpan(text: ' · thu '),
                          TextSpan(
                            text: MoneyFormatter.format(state.summary!.income),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F8A4C),
                              fontFeatures: MoneyFormatter.tabularFeatures,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Main content: Loading skeleton / Empty state / Grouped transactions
              if (state.isLoading)
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.screenPadding,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              const AppSkeleton(
                                width: 40,
                                height: 40,
                                shape: BoxShape.circle,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppSkeleton(
                                      width: 120,
                                      height: 14,
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    const SizedBox(height: 6),
                                    AppSkeleton(
                                      width: 80,
                                      height: 12,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ],
                                ),
                              ),
                              AppSkeleton(
                                width: 70,
                                height: 16,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ],
                          ),
                        ),
                      ),
                      childCount: 4,
                    ),
                  ),
                )
              else if (state.transactions.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 72,
                            decoration: BoxDecoration(
                              color: colors.surfaceContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              LucideIcons.receipt_text,
                              size: 36,
                              color: colors.onSurfaceVariant.withAlpha(160),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Chưa có giao dịch nào',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ghi khoản chi hoặc thu đầu tiên. Giao dịch sẽ hiện ở đây, nhóm theo từng ngày.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  height: 1.4,
                                ),
                          ),
                          const SizedBox(height: 24),
                          AppButton(
                            label: '+ Ghi giao dịch đầu tiên',
                            onPressed: () => context.push('/transactions/new'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.screenPadding,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final group = state.dayGroups[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Day Group Header: Date Label on left, Day Total on right
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 6,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    group.dateLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colors.onSurfaceVariant,
                                        ),
                                  ),
                                  Text(
                                    group.totalNet > 0
                                        ? '+${MoneyFormatter.format(group.totalNet)}'
                                        : MoneyFormatter.format(group.totalNet),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: group.totalNet > 0
                                              ? const Color(0xFF1F8A4C)
                                              : colors.onSurfaceVariant,
                                          fontFeatures:
                                              MoneyFormatter.tabularFeatures,
                                        ),
                                  ),
                                ],
                              ),
                            ),

                            // Card containing transactions of this day
                            AppCard(
                              padding: EdgeInsets.zero,
                              child: Column(
                                children: List.generate(group.items.length, (
                                  i,
                                ) {
                                  final tx = group.items[i];
                                  final isExpense = tx.type == 'EXPENSE';
                                  final vnTime = VietnamTime.fromDateTime(
                                    tx.occurredAt,
                                  );
                                  final timeStr =
                                      '${vnTime.hour.toString().padLeft(2, '0')}:${vnTime.minute.toString().padLeft(2, '0')}';

                                  return Column(
                                    children: [
                                      InkWell(
                                        onTap: () => context.push(
                                          '/transactions/${tx.id}',
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          context.radius.lg,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          child: Row(
                                            children: [
                                              // Category Icon Bubble
                                              Container(
                                                width: 38,
                                                height: 38,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(0xFFF0EFEA),
                                                ),
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  AppIconHelper.fromName(
                                                    tx.category?.icon,
                                                  ),
                                                  size: 18,
                                                  color: const Color(
                                                    0xFF111111,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              // Title & Subtitle
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      tx.title,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      '${tx.category?.name ?? 'Chưa phân loại'} · ${tx.wallet?.name ?? 'Ví'}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                              const SizedBox(width: 12),
                                              // Amount & Time
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    isExpense
                                                        ? '-${MoneyFormatter.format(tx.amount)}'
                                                        : '+${MoneyFormatter.format(tx.amount)}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: isExpense
                                                              ? colors.onSurface
                                                              : const Color(
                                                                  0xFF1F8A4C,
                                                                ),
                                                          fontFeatures:
                                                              MoneyFormatter
                                                                  .tabularFeatures,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    timeStr,
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
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (i < group.items.length - 1)
                                        const Divider(height: 1, indent: 66),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      );
                    }, childCount: state.dayGroups.length),
                  ),
                ),

              if (state.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterTabChip extends StatelessWidget {
  const _FilterTabChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.radius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF111111) : colors.surface,
          borderRadius: BorderRadius.circular(context.radius.pill),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF111111)
                : colors.outlineVariant.withAlpha(120),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : colors.onSurface,
          ),
        ),
      ),
    );
  }
}
