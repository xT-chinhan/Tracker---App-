import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatting/vietnam_time.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/pressable.dart';
import '../application/notifications_service.dart';
import '../data/notification_models.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _scrollController = ScrollController();

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
    final hasUnread = state.items.any((item) => item.readAt == null);

    final now = VietnamTime.now();
    final todayItems = <NotificationItem>[];
    final olderItems = <NotificationItem>[];

    for (final item in state.items) {
      final vn = VietnamTime.fromDateTime(item.createdAt);
      if (vn.year == now.year && vn.month == now.month && vn.day == now.day) {
        todayItems.add(item);
      } else {
        olderItems.add(item);
      }
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
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Trang chủ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: () => ref
                  .read(notificationsControllerProvider.notifier)
                  .markReadAll(),
              child: Text(
                'Đọc hết',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
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
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

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
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Không có thông báo mới',
                          style: Theme.of(context).textTheme.bodyLarge
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
              else ...[
                if (todayItems.isNotEmpty) ...[
                  _GroupHeader(title: 'Hôm nay'),
                  const SizedBox(height: 8),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < todayItems.length; i++) ...[
                          if (i > 0) const Divider(height: 1, indent: 68),
                          _NotificationRow(
                            item: todayItems[i],
                            onTap: () => _handleItemTap(context, todayItems[i]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                if (olderItems.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _GroupHeader(title: 'Trước đó'),
                  const SizedBox(height: 8),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < olderItems.length; i++) ...[
                          if (i > 0) const Divider(height: 1, indent: 68),
                          _NotificationRow(
                            item: olderItems[i],
                            onTap: () => _handleItemTap(context, olderItems[i]),
                          ),
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

  void _handleItemTap(BuildContext context, NotificationItem item) {
    ref.read(notificationsControllerProvider.notifier).markRead(item.id);
    if (item.type == 'BUDGET_WARNING' || item.type == 'BUDGET_EXCEEDED') {
      context.push('/budgets');
    }
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.item, required this.onTap});

  final NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = item.readAt == null;

    final (icon, iconColor, bgColor) = switch (item.type) {
      'BUDGET_WARNING' => (
        LucideIcons.triangle_alert,
        context.appColors.warning,
        context.appColors.warningContainer,
      ),
      'BUDGET_EXCEEDED' => (
        LucideIcons.circle_alert,
        context.appColors.danger,
        context.appColors.dangerContainer,
      ),
      'BROADCAST' => (
        LucideIcons.megaphone,
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.surfaceContainer,
      ),
      'RECURRING_PAUSED' => (
        LucideIcons.circle_pause,
        context.appColors.warning,
        context.appColors.warningContainer,
      ),
      _ => (
        LucideIcons.bell,
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.surfaceContainer,
      ),
    };

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
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
                    item.body,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    VietnamTime.relativeNotification(item.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
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
