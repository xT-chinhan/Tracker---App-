import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/formatting/money_formatter.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/icon_bubble.dart';
import '../../transfers/data/transfer_models.dart';
import '../../transfers/data/transfer_repository.dart';
import '../application/wallets_service.dart';
import '../data/wallet_models.dart';
import 'wallet_form_sheet.dart';
import '../../../core/formatting/vietnam_time.dart';

final recentTransfersProvider = FutureProvider.autoDispose<List<TransferItem>>((
  ref,
) async {
  final repo = ref.watch(transferRepositoryProvider);
  try {
    return await repo.getTransfers(limit: 5);
  } catch (_) {
    return [];
  }
});

class WalletsScreen extends ConsumerStatefulWidget {
  const WalletsScreen({super.key});

  @override
  ConsumerState<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends ConsumerState<WalletsScreen> {
  void _openWalletFormSheet([WalletItem? wallet]) {
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
      builder: (ctx) => WalletFormSheet(existingWallet: wallet),
    );
  }

  IconData _iconForWalletType(String type) {
    return switch (type) {
      'BANK' => LucideIcons.landmark,
      'EWALLET' => LucideIcons.smartphone,
      _ => LucideIcons.banknote,
    };
  }

  String _labelForWalletType(String type) {
    return switch (type) {
      'BANK' => 'Ngân hàng',
      'EWALLET' => 'Ví điện tử',
      _ => 'Tiền mặt',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final walletsAsync = ref.watch(walletsResponseProvider);
    final transfersAsync = ref.watch(recentTransfersProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(walletsResponseProvider);
            ref.invalidate(recentTransfersProvider);
          },
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
                        tooltip: 'Thêm ví mới',
                        onPressed: () => _openWalletFormSheet(),
                      ),
                    ],
                  ),
                ),
              ),

              // Title: Ví
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.spacing.screenPadding,
                    4,
                    context.spacing.screenPadding,
                    16,
                  ),
                  child: Text(
                    'Ví',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ),

              // Content Body
              walletsAsync.when(
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
                              AppSkeleton(width: 140, height: 16),
                              SizedBox(height: 12),
                              AppSkeleton(width: 220, height: 36),
                              SizedBox(height: 14),
                              AppSkeleton(width: double.infinity, height: 8),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        AppCard(
                          child: AppSkeleton(
                            width: double.infinity,
                            height: 200,
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
                            'Không thể tải danh sách ví',
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
                          AppButton(
                            label: 'Thử lại',
                            onPressed: () =>
                                ref.invalidate(walletsResponseProvider),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                data: (res) {
                  final activeWallets = res.items
                      .where((w) => !w.isArchived)
                      .toList();
                  final archivedWallets = res.items
                      .where((w) => w.isArchived)
                      .toList();

                  // Find wallet with largest balance
                  WalletItem? largestWallet;
                  for (final w in activeWallets) {
                    if (largestWallet == null ||
                        w.balance > largestWallet.balance) {
                      largestWallet = w;
                    }
                  }

                  final largestPercent =
                      (res.totalBalance > 0 && largestWallet != null)
                      ? ((largestWallet.balance / res.totalBalance) * 100)
                            .round()
                      : 0;

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
                          // 1. Total Balance Card (15-vi.png)
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tổng số dư · ${activeWallets.length} ví',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  MoneyFormatter.format(res.totalBalance),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 34,
                                        letterSpacing: -0.03 * 34,
                                        color: colors.onSurface,
                                        fontFeatures:
                                            MoneyFormatter.tabularFeatures,
                                      ),
                                ),
                                const SizedBox(height: 14),

                                // Segmented distribution progress bar
                                if (res.totalBalance > 0 &&
                                    activeWallets.isNotEmpty) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      context.radius.pill,
                                    ),
                                    child: SizedBox(
                                      height: 8,
                                      child: Row(
                                        children: activeWallets.map((w) {
                                          final share =
                                              (w.balance / res.totalBalance)
                                                  .clamp(0.0, 1.0);
                                          final isLargest =
                                              w.id == largestWallet?.id;
                                          return Expanded(
                                            flex: (share * 100).round().clamp(
                                              1,
                                              100,
                                            ),
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 1.5,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isLargest
                                                    ? colors.primary
                                                    : colors
                                                          .surfaceContainerHighest,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '$largestPercent% nằm ở ${largestWallet?.name ?? ''}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 2. Wallets List Card (15-vi.png)
                          if (activeWallets.isNotEmpty)
                            AppCard(
                              padding: EdgeInsets.zero,
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: activeWallets.length,
                                separatorBuilder: (_, _) => Divider(
                                  color: colors.outlineVariant,
                                  height: 1,
                                  indent: 64,
                                ),
                                itemBuilder: (context, index) {
                                  final wallet = activeWallets[index];
                                  return InkWell(
                                    onTap: () => _openWalletFormSheet(wallet),
                                    borderRadius: BorderRadius.circular(
                                      context.radius.lg,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      child: Row(
                                        children: [
                                          IconBubble(
                                            icon: _iconForWalletType(
                                              wallet.type,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  wallet.name,
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
                                                  _labelForWalletType(
                                                    wallet.type,
                                                  ),
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
                                            MoneyFormatter.format(
                                              wallet.balance,
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontFeatures: MoneyFormatter
                                                      .tabularFeatures,
                                                ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(
                                            LucideIcons.chevron_right,
                                            size: 16,
                                            color: colors.onSurfaceVariant,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            AppCard(
                              child: Column(
                                children: [
                                  Icon(
                                    LucideIcons.wallet,
                                    size: 40,
                                    color: context.appColors.faint,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('Chưa có ví nào.'),
                                  const SizedBox(height: 12),
                                  AppButton(
                                    label: '+ Thêm ví đầu tiên',
                                    onPressed: () => _openWalletFormSheet(),
                                  ),
                                ],
                              ),
                            ),

                          // Collapsible Archived Wallets Section if any
                          if (archivedWallets.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            ExpansionTile(
                              title: Text(
                                'Ví đã lưu trữ (${archivedWallets.length})',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(color: colors.onSurfaceVariant),
                              ),
                              children: archivedWallets.map((wallet) {
                                return ListTile(
                                  leading: IconBubble(
                                    icon: _iconForWalletType(wallet.type),
                                  ),
                                  title: Text(
                                    wallet.name,
                                    style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  subtitle: Text(
                                    _labelForWalletType(wallet.type),
                                  ),
                                  trailing: const Icon(
                                    LucideIcons.chevron_right,
                                    size: 16,
                                  ),
                                  onTap: () => _openWalletFormSheet(wallet),
                                );
                              }).toList(),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // 3. Transfer Button (15-vi.png)
                          AppButton(
                            label: 'Chuyển tiền giữa ví',
                            icon: LucideIcons.arrow_left_right,
                            onPressed: () => context.push('/transfers'),
                          ),

                          const SizedBox(height: 24),

                          // 4. Recent Transfers Section (15-vi.png)
                          Text(
                            'Chuyển gần đây',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),

                          transfersAsync.when(
                            loading: () => const AppCard(
                              child: AppSkeleton(
                                width: double.infinity,
                                height: 60,
                              ),
                            ),
                            error: (_, _) => const SizedBox.shrink(),
                            data: (transfers) {
                              if (transfers.isEmpty) {
                                return AppCard(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      'Chưa có giao dịch chuyển tiền nào.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: colors.onSurfaceVariant,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }

                              return AppCard(
                                padding: EdgeInsets.zero,
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: transfers.length,
                                  separatorBuilder: (_, _) => Divider(
                                    color: colors.outlineVariant,
                                    height: 1,
                                    indent: 64,
                                  ),
                                  itemBuilder: (context, index) {
                                    final tx = transfers[index];
                                    final dateStr = DateFormat('dd/MM').format(
                                      VietnamTime.fromDateTime(tx.occurredAt),
                                    );
                                    final noteStr = tx.note?.isNotEmpty == true
                                        ? ' · ${tx.note}'
                                        : '';

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      child: Row(
                                        children: [
                                          const IconBubble(
                                            icon: LucideIcons.arrow_left_right,
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${tx.fromWallet?.name ?? 'Ví'} → ${tx.toWallet?.name ?? 'Ví'}',
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
                                                  '$dateStr$noteStr',
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
                                            MoneyFormatter.format(tx.amount),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontFeatures: MoneyFormatter
                                                      .tabularFeatures,
                                                ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
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
}
