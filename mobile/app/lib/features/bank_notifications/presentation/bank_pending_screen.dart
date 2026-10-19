import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatting/money_formatter.dart';
import '../../../core/formatting/vietnam_time.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_icon_helper.dart';
import '../../../core/widgets/dashed_box.dart';
import '../../../core/widgets/icon_bubble.dart';
import '../../categories/data/category_models.dart';
import '../../wallets/data/wallet_models.dart';
import '../application/bank_mapping.dart';
import '../application/bank_notifications_controller.dart';

/// Giao dịch phát hiện từ thông báo ngân hàng, chờ xác nhận (viền nét đứt = chưa lưu).
class BankPendingScreen extends ConsumerStatefulWidget {
  const BankPendingScreen({super.key});

  @override
  ConsumerState<BankPendingScreen> createState() => _BankPendingScreenState();
}

class _BankPendingScreenState extends ConsumerState<BankPendingScreen> {
  // Lựa chọn người dùng sửa trên từng thẻ (khóa = PendingBankTransaction.key)
  final _category = <String, CategoryItem>{};
  final _wallet = <String, WalletItem>{};

  BankNotificationsController get _c =>
      ref.read(bankNotificationsProvider.notifier);

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _c.sync();
      await _c.loadReferences();
    });
  }

  CategoryItem? _cat(PendingBankTransaction t) =>
      _category[t.key] ?? _c.categoryFor(t);
  WalletItem? _wal(PendingBankTransaction t) =>
      _wallet[t.key] ?? _c.walletFor(t);

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _confirm(PendingBankTransaction t) async {
    final c = _cat(t), w = _wal(t);
    if (w == null) return _pickWallet(t, thenConfirm: true);
    if (c == null) return _snack('Chưa có danh mục phù hợp, chọn danh mục.');
    final err = await _c.confirm(t, category: c, wallet: w);
    if (!mounted) return;
    _snack(err ?? 'Đã ghi ${MoneyFormatter.format(t.amount)} vào ${w.name}');
  }

  Future<void> _confirmAll() async {
    // Ghi nhớ ví người dùng vừa chọn trên thẻ để confirmAll dùng được
    for (final e in _wallet.entries) {
      final t = ref
          .read(bankNotificationsProvider)
          .pending
          .where((p) => p.key == e.key)
          .firstOrNull;
      if (t != null) await _c.rememberWallet(t.bank, e.value.id);
    }
    final err = await _c.confirmAll();
    if (mounted) _snack(err ?? 'Đã ghi các giao dịch đã chọn đủ ví');
  }

  Future<void> _pickWallet(
    PendingBankTransaction t, {
    bool thenConfirm = false,
  }) async {
    final wallets = ref
        .read(bankNotificationsProvider)
        .wallets
        .where((w) => !w.isArchived)
        .toList();
    final picked = await showModalBottomSheet<WalletItem>(
      context: context,
      showDragHandle: true,
      builder: (_) => _PickerSheet(
        title: 'Ghi vào ví nào?',
        subtitle: 'Thu Chi nhớ lựa chọn này cho ${t.bank}.',
        children: [
          for (final w in wallets)
            ListTile(
              leading: IconBubble(
                icon: AppIconHelper.fromName(w.icon),
                size: 36,
              ),
              title: Text(w.name),
              trailing: Text(MoneyFormatter.format(w.balance)),
              onTap: () => Navigator.of(context).pop(w),
            ),
        ],
      ),
    );
    if (picked == null) return;
    setState(() => _wallet[t.key] = picked);
    await _c.rememberWallet(t.bank, picked.id);
    if (thenConfirm) await _confirm(t);
  }

  Future<void> _pickCategory(PendingBankTransaction t) async {
    final cats = ref
        .read(bankNotificationsProvider)
        .categories
        .where((c) => !c.isArchived && c.type == t.type)
        .toList();
    final picked = await showModalBottomSheet<CategoryItem>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _PickerSheet(
        title: t.isIncome ? 'Danh mục thu' : 'Danh mục chi',
        children: [
          for (final c in cats)
            ListTile(
              leading: IconBubble(
                icon: AppIconHelper.fromName(c.icon),
                size: 36,
              ),
              title: Text(c.name),
              onTap: () => Navigator.of(context).pop(c),
            ),
        ],
      ),
    );
    if (picked != null) setState(() => _category[t.key] = picked);
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(bankNotificationsProvider);
    final theme = Theme.of(context);
    final pad = context.spacing.screenPadding;
    final readyCount = st.pending
        .where((t) => _cat(t) != null && _wal(t) != null)
        .length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _c.sync();
                  await _c.loadReferences();
                },
                child: ListView(
                  padding: EdgeInsets.fromLTRB(pad, 4, pad, 24),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(LucideIcons.chevron_left, size: 20),
                        label: const Text('Quay lại'),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.onSurface,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    Text(
                      'Chờ xác nhận',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Từ thông báo ngân hàng · chưa lưu cho tới khi bạn xác nhận',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (st.error != null) ...[
                      Text(
                        st.error!,
                        style: TextStyle(color: context.appColors.danger),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (st.pending.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 48),
                        child: Column(
                          children: [
                            const IconBubble(icon: LucideIcons.inbox, size: 56),
                            const SizedBox(height: 16),
                            Text(
                              'Chưa có giao dịch nào chờ xác nhận',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Khi ngân hàng hoặc ví báo biến động số dư, khoản đó sẽ hiện ở đây.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      for (final t in st.pending) ...[
                        _PendingCard(
                          t: t,
                          category: _cat(t),
                          wallet: _wal(t),
                          busy: st.busy,
                          onCategory: () => _pickCategory(t),
                          onWallet: () => _pickWallet(t),
                          onConfirm: () => _confirm(t),
                          onSkip: () => _c.skip(t),
                        ),
                        const SizedBox(height: 12),
                      ],
                  ],
                ),
              ),
            ),
            if (st.pending.length > 1)
              Padding(
                padding: EdgeInsets.fromLTRB(pad, 8, pad, 16),
                child: AppButton(
                  label: 'Xác nhận $readyCount khoản đã đủ ví',
                  loading: st.busy,
                  onPressed: readyCount == 0 ? null : _confirmAll,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({
    required this.t,
    required this.category,
    required this.wallet,
    required this.busy,
    required this.onCategory,
    required this.onWallet,
    required this.onConfirm,
    required this.onSkip,
  });

  final PendingBankTransaction t;
  final CategoryItem? category;
  final WalletItem? wallet;
  final bool busy;
  final VoidCallback onCategory;
  final VoidCallback onWallet;
  final VoidCallback onConfirm;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final muted = theme.colorScheme.onSurfaceVariant;
    return DashedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${t.bank} · ${VietnamTime.dateTime(t.occurredAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Chưa lưu',
                  style: theme.textTheme.labelSmall?.copyWith(color: muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            MoneyFormatter.format(
              t.isIncome ? t.amount : -t.amount,
              signed: true,
            ),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: t.isIncome ? colors.income : colors.expense,
              fontFeatures: MoneyFormatter.tabularFeatures,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            t.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(
                icon: AppIconHelper.fromName(category?.icon),
                label: category?.name ?? 'Chọn danh mục',
                onTap: onCategory,
              ),
              _Chip(
                icon: LucideIcons.wallet,
                label: wallet?.name ?? 'Chọn ví',
                warn: wallet == null,
                onTap: onWallet,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Bỏ qua',
                  style: AppButtonStyle.secondary,
                  onPressed: busy ? null : onSkip,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: 'Xác nhận',
                  onPressed: busy ? null : onConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.warn = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: warn ? colors.warningContainer : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: warn ? colors.warningBar : theme.colorScheme.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: warn ? colors.warning : null),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: warn ? colors.warning : null,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              LucideIcons.chevron_down,
              size: 14,
              color: warn ? colors.warning : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerSheet extends StatelessWidget {
  const _PickerSheet({
    required this.title,
    required this.children,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}
