import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatting/vietnam_time.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/trackerx_logo.dart';
import '../../bank_notifications/data/bank_notification_bridge.dart';
import '../application/balance_undo.dart';
import '../application/notifications_service.dart';
import '../data/notification_models.dart';
import 'undo_confirm_sheet.dart';

/// Tab: `null` = Tất cả.
const notificationTabs = <(String?, String)>[
  (null, 'Tất cả'),
  ('balance', 'Số dư'),
  ('budget', 'Ngân sách'),
  ('system', 'Hệ thống'),
  ('security', 'Bảo mật'),
];

/// Thông tin rút từ thông báo Biến động số dư (tiêu đề "−45.000đ · Cà phê", thân "Đã tự ghi vào ví X · …").
class BalanceInfo {
  const BalanceInfo({
    required this.amountText,
    required this.name,
    required this.amount,
    required this.isIncome,
    this.walletName,
  });

  factory BalanceInfo.of(NotificationItem item) {
    final title = item.title;
    final i = title.indexOf(' · ');
    final amountText = i > 0 ? title.substring(0, i) : '';
    final name = i > 0 ? title.substring(i + 3) : title;
    final data = item.data ?? const {};
    final txType = data['txType'];
    final isIncome = txType is String
        ? txType == 'INCOME'
        : amountText.startsWith('+');
    final raw = data['amount'];
    final amount = raw is num
        ? raw.toInt().abs()
        : int.tryParse(amountText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final wallet = RegExp(
      r'vào ví (.+?)(?: · |\.\s|\.$)',
    ).firstMatch(item.body);
    return BalanceInfo(
      amountText: amountText,
      name: name,
      amount: amount,
      isIncome: isIncome,
      walletName: wallet?.group(1)?.trim(),
    );
  }

  final String amountText;
  final String name;
  final int amount;
  final bool isIncome;
  final String? walletName;
}

String dayGroupLabel(DateTime value) {
  final vn = VietnamTime.fromDateTime(value);
  final now = VietnamTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(vn.year, vn.month, vn.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Hôm nay';
  if (diff == 1) return 'Hôm qua';
  return now.year == vn.year
      ? VietnamTime.dayMonth(value)
      : '${VietnamTime.dayMonth(value)}/${vn.year}';
}

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _scrollController = ScrollController();
  String? _expanded;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationsControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsControllerProvider);
    final undone = ref.watch(undoneTransactionsProvider);
    final theme = Theme.of(context);

    // Nhóm theo ngày (giữ thứ tự mới → cũ)
    final groups = <String, List<NotificationItem>>{};
    for (final item in state.items) {
      groups.putIfAbsent(dayGroupLabel(item.createdAt), () => []).add(item);
    }

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 150,
        leading: Pressable(
          onTap: () => context.pop(),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.chevron_left,
                  size: 20,
                  color: theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Trang chủ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          if (state.canMarkAll)
            TextButton(
              onPressed: () => ref
                  .read(notificationsControllerProvider.notifier)
                  .markReadAll(),
              child: Text(
                'Đánh dấu đã đọc',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: () => ref
            .read(notificationsControllerProvider.notifier)
            .load(refresh: true),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            context.spacing.screenPadding,
            8,
            context.spacing.screenPadding,
            40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Thông báo',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              NotificationTabs(
                selected: state.tab,
                summary: state.summary,
                onSelect: (tab) {
                  setState(() => _expanded = null);
                  ref
                      .read(notificationsControllerProvider.notifier)
                      .selectTab(tab);
                },
              ),
              if (state.tab == 'balance') const _BalanceHint(),
              const SizedBox(height: 14),
              if (state.isLoading && state.items.isEmpty)
                const _NotificationsSkeleton()
              else if (state.items.isEmpty)
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    vertical: 48,
                    horizontal: 16,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          LucideIcons.bell_off,
                          size: 36,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.errorMessage ?? 'Không có thông báo',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                for (final (gi, entry) in groups.entries.indexed) ...[
                  if (gi > 0) const SizedBox(height: 24),
                  _GroupHeader(title: entry.key),
                  const SizedBox(height: 8),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < entry.value.length; i++) ...[
                          if (i > 0) const Divider(height: 1, indent: 68),
                          _row(entry.value[i], undone),
                        ],
                      ],
                    ),
                  ),
                ],
                if (state.isLoadingMore) ...[
                  const SizedBox(height: 16),
                  const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(NotificationItem item, Set<String> undone) {
    final txId = item.transactionId;
    final isUndone = txId != null && undone.contains(txId);
    final canAct = item.group == 'balance' && txId != null && !isUndone;
    return _NotificationRow(
      item: item,
      undone: isUndone,
      expanded: canAct && _expanded == item.id,
      onTap: () => _handleItemTap(item, canAct),
      onUndo: () => _undo(item),
      onView: () => context.push('/transactions/$txId'),
    );
  }

  void _handleItemTap(NotificationItem item, bool canAct) {
    ref.read(notificationsControllerProvider.notifier).markRead(item.id);
    if (canAct) {
      setState(() => _expanded = _expanded == item.id ? null : item.id);
      return;
    }
    if (item.type == 'BUDGET_WARNING' || item.type == 'BUDGET_EXCEEDED') {
      context.push('/budgets');
    }
  }

  Future<void> _undo(NotificationItem item) async {
    final txId = item.transactionId;
    if (txId == null) return;
    final info = BalanceInfo.of(item);
    final ok = await UndoConfirmSheet.show(
      context,
      amount: info.amount,
      isIncome: info.isIncome,
      content: info.name,
      walletName: info.walletName,
      when:
          '${VietnamTime.timeOnly(item.createdAt)} · ${VietnamTime.dayMonth(item.createdAt)}',
    );
    if (!ok || !mounted) return;
    final err = await ref.read(undoneTransactionsProvider.notifier).undo(txId);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    setState(() => _expanded = null);
    showUndoneSnack(
      context,
      title: info.name,
      amount: info.amount,
      isIncome: info.isIncome,
      walletName: info.walletName,
    );
  }
}

/// Menu 5 tab chữ dàn hết chiều ngang, không cuộn; chấm nhỏ = có tin chưa đọc.
class NotificationTabs extends StatelessWidget {
  const NotificationTabs({
    required this.selected,
    required this.summary,
    required this.onSelect,
    super.key,
  });

  final String? selected;
  final UnreadSummary summary;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = theme.colorScheme.onSurface;
    final grey = theme.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Dàn đều hết chiều ngang; máy hẹp quá thì thu nhỏ cả menu (không cuộn)
        LayoutBuilder(
          builder: (context, constraints) => FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final (i, (tab, label)) in notificationTabs.indexed) ...[
                    if (i > 0) const SizedBox(width: 8),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelect(tab),
                      child: Container(
                        padding: const EdgeInsets.only(top: 6, bottom: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 2,
                              color: tab == selected ? ink : Colors.transparent,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: tab == selected ? ink : grey,
                              ),
                            ),
                            if (summary.hasUnread(tab))
                              Container(
                                key: ValueKey('tab-dot-${tab ?? 'all'}'),
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.only(left: 2, top: 2),
                                decoration: BoxDecoration(
                                  color: ink,
                                  shape: BoxShape.circle,
                                ),
                              )
                            else
                              const SizedBox(width: 6),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Divider(height: 1, thickness: 1, color: theme.colorScheme.outline),
      ],
    );
  }
}

class _BalanceHint extends StatelessWidget {
  const _BalanceHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Khoản app tự ghi từ thông báo ngân hàng',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (bankNotificationsSupported)
            Pressable(
              onTap: () => context.push('/bank-notifications'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Cài đặt',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(LucideIcons.chevron_right, size: 14),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.item,
    required this.undone,
    required this.expanded,
    required this.onTap,
    required this.onUndo,
    required this.onView,
  });

  final NotificationItem item;
  final bool undone;
  final bool expanded;
  final VoidCallback onTap;
  final VoidCallback onUndo;
  final VoidCallback onView;

  Widget _bubble(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    if (item.type == 'BROADCAST') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: const TrackerXLogo(size: 40),
      );
    }
    final (icon, fg, bg) = switch (item.type) {
      'BUDGET_WARNING' => (
        LucideIcons.target,
        colors.warning,
        colors.warningContainer,
      ),
      'BUDGET_EXCEEDED' => (
        LucideIcons.target,
        colors.danger,
        colors.dangerContainer,
      ),
      'RECURRING_PAUSED' => (
        LucideIcons.circle_pause,
        const Color(0xFF3A3935),
        scheme.surfaceContainer,
      ),
      _ => (
        switch (item.group) {
          'balance' => LucideIcons.landmark,
          'security' => LucideIcons.shield_check,
          'budget' => LucideIcons.target,
          _ => LucideIcons.bell,
        },
        const Color(0xFF3A3935),
        scheme.surfaceContainer,
      ),
    };
    return Opacity(
      opacity: undone ? 0.5 : 1,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: fg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final muted = theme.colorScheme.onSurfaceVariant;
    final isUnread = item.readAt == null;
    final isBalance = item.group == 'balance';
    final info = isBalance ? BalanceInfo.of(item) : null;
    final titleStyle = theme.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: undone ? colors.faint : null,
    );

    final Widget title = info != null && info.amountText.isNotEmpty
        ? Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: info.amountText,
                  style: TextStyle(
                    color: undone
                        ? colors.faint
                        : info.isIncome
                        ? colors.income
                        : colors.expense,
                  ),
                ),
                TextSpan(text: ' · ${info.name}'),
              ],
            ),
            style: titleStyle,
          )
        : Text(item.title, style: titleStyle);

    final body = undone
        ? (info?.isIncome ?? false)
              ? 'Đã xóa khỏi ví ${info?.walletName ?? ''}, số dư đã trừ lại.'
              : 'Đã xóa khỏi ví ${info?.walletName ?? ''}, số dư đã cộng lại.'
        : item.body;
    final time = VietnamTime.timeOnly(item.createdAt);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bubble(context),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: title),
                      if (undone) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Đã hoàn tác',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ] else if (isUnread) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF111111),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: undone ? colors.faint : muted,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    undone ? time : '$time · ${categoryLabel(item.group)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.faint,
                      fontSize: 11,
                    ),
                  ),
                  if (expanded) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: onUndo,
                          icon: const Icon(LucideIcons.undo_2, size: 16),
                          label: const Text('Hoàn tác'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.onSurface,
                            side: BorderSide(color: theme.colorScheme.outline),
                            shape: const StadiumBorder(),
                            textStyle: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        FilledButton(
                          onPressed: onView,
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.surfaceContainer,
                            foregroundColor: theme.colorScheme.onSurface,
                            shape: const StadiumBorder(),
                            textStyle: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Xem giao dịch'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsSkeleton extends StatelessWidget {
  const _NotificationsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        AppSkeleton(width: 80, height: 16),
        SizedBox(height: 8),
        AppSkeleton(width: double.infinity, height: 140),
        SizedBox(height: 24),
        AppSkeleton(width: 80, height: 16),
        SizedBox(height: 8),
        AppSkeleton(width: double.infinity, height: 200),
      ],
    );
  }
}
