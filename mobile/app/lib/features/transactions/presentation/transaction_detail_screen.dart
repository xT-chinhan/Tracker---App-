import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/money_formatter.dart';
import '../../../core/formatting/vietnam_time.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_icon_helper.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../history/application/history_service.dart';
import '../../home/application/home_service.dart';
import '../../home/data/home_models.dart';
import '../data/transaction_repository.dart';
import 'transaction_entry_screen.dart';

final transactionDetailProvider = FutureProvider.autoDispose
    .family<TransactionItem, String>((ref, id) async {
      final repo = ref.watch(transactionRepositoryProvider);
      return repo.getTransaction(id);
    });

class TransactionDetailScreen extends ConsumerStatefulWidget {
  const TransactionDetailScreen({required this.transactionId, super.key});

  final String transactionId;

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  bool _isDeleting = false;

  String _formatDateTime(DateTime dt) {
    final vn = VietnamTime.fromDateTime(dt);
    final timeStr =
        '${vn.hour.toString().padLeft(2, '0')}:${vn.minute.toString().padLeft(2, '0')}';
    final dateStr =
        '${vn.day.toString().padLeft(2, '0')}/${vn.month.toString().padLeft(2, '0')}/${vn.year}';

    const days = [
      '',
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    final dayStr = days[vn.weekday];

    return '$timeStr · $dayStr, $dateStr';
  }

  Future<void> _confirmDelete(BuildContext context, TransactionItem tx) async {
    final nav = Navigator.of(context);
    final scaffold = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: const Text(
          'Hành động này sẽ cập nhật lại số dư ví và không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      final repo = ref.read(transactionRepositoryProvider);
      await repo.deleteTransaction(tx.id);

      // Refresh home and history
      ref.read(homeControllerProvider.notifier).load(refresh: true);
      ref.read(historyProvider.notifier).load(resetPage: true);

      if (!mounted) return;
      scaffold.showSnackBar(const SnackBar(content: Text('Đã xóa giao dịch')));
      nav.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      scaffold.showSnackBar(
        const SnackBar(
          content: Text('Xóa giao dịch thất bại. Vui lòng thử lại.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(transactionDetailProvider(widget.transactionId));
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(LucideIcons.chevron_left, size: 20),
          label: const Text('Lịch sử'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 8),
            foregroundColor: colors.onSurface,
          ),
        ),
        actions: [
          txAsync.when(
            data: (tx) => TextButton(
              onPressed: () async {
                final updated = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (ctx) =>
                        TransactionEntryScreen(initialTransaction: tx),
                  ),
                );
                if (updated == true && mounted) {
                  ref.invalidate(
                    transactionDetailProvider(widget.transactionId),
                  );
                  ref.read(historyProvider.notifier).load(resetPage: true);
                }
              },
              child: Text(
                'Sửa',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: txAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Center(child: AppSkeleton(width: 64, height: 64)),
              SizedBox(height: 16),
              AppSkeleton(width: 140, height: 20),
              SizedBox(height: 12),
              AppSkeleton(width: 200, height: 36),
              SizedBox(height: 24),
              AppSkeleton(width: double.infinity, height: 200),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.circle_alert,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text('Không tìm thấy giao dịch hoặc đã bị xóa.'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Quay lại'),
                ),
              ],
            ),
          ),
        ),
        data: (tx) {
          final isExpense = tx.type == 'EXPENSE';

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.screenPadding,
                      vertical: 12,
                    ),
                    child: Column(
                      children: [
                        // Centered Header: Icon, Title, Amount
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFF0EFEA),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  AppIconHelper.fromName(tx.category?.icon),
                                  size: 28,
                                  color: const Color(0xFF111111),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                tx.title,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: colors.onSurfaceVariant),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isExpense
                                    ? '-${MoneyFormatter.format(tx.amount)}'
                                    : '+${MoneyFormatter.format(tx.amount)}',
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: isExpense
                                          ? colors.onSurface
                                          : const Color(0xFF1F8A4C),
                                      fontFeatures:
                                          MoneyFormatter.tabularFeatures,
                                    ),
                              ),
                              if (tx.recurring) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainer,
                                    borderRadius: BorderRadius.circular(
                                      context.radius.pill,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        LucideIcons.repeat,
                                        size: 14,
                                        color: colors.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'Tạo tự động · Định kỳ hằng tháng',
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: colors.onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Detail Card
                        AppCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Column(
                            children: [
                              _DetailRow(
                                label: 'Loại',
                                valueWidget: Text(
                                  isExpense ? 'Khoản chi' : 'Thu nhập',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Divider(height: 1),
                              _DetailRow(
                                label: 'Danh mục',
                                valueWidget: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFF0EFEA),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        AppIconHelper.fromName(
                                          tx.category?.icon,
                                        ),
                                        size: 14,
                                        color: const Color(0xFF111111),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        tx.category?.name ?? 'Chưa phân loại',
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              _DetailRow(
                                label: 'Ví',
                                valueWidget: Text(
                                  tx.wallet?.name ?? 'Ví',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Divider(height: 1),
                              _DetailRow(
                                label: 'Thời gian',
                                valueWidget: Text(
                                  _formatDateTime(tx.occurredAt),
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Divider(height: 1),
                              _DetailRow(
                                label: 'Ghi chú',
                                valueWidget: Text(
                                  tx.note != null && tx.note!.isNotEmpty
                                      ? tx.note!
                                      : tx.title,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Recurring rule note if recurring
                        if (tx.recurring) ...[
                          const SizedBox(height: 16),
                          AppCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFF0EFEA),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    LucideIcons.repeat,
                                    size: 18,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Ngày 1 hằng tháng',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: colors.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  LucideIcons.chevron_right,
                                  size: 18,
                                  color: colors.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              'Sửa giao dịch này không làm thay đổi quy tắc định kỳ.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colors.onSurfaceVariant.withAlpha(
                                      160,
                                    ),
                                  ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Bottom Delete Button
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.spacing.screenPadding,
                    8,
                    context.spacing.screenPadding,
                    16,
                  ),
                  child: InkWell(
                    onTap: _isDeleting
                        ? null
                        : () => _confirmDelete(context, tx),
                    borderRadius: BorderRadius.circular(context.radius.pill),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(
                          context.radius.pill,
                        ),
                        border: Border.all(
                          color: const Color(0xFFDC2626).withAlpha(100),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: _isDeleting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFDC2626),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  LucideIcons.trash,
                                  size: 18,
                                  color: Color(0xFFDC2626),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Xóa giao dịch',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFDC2626),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.valueWidget});

  final String label;
  final Widget valueWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(child: valueWidget),
        ],
      ),
    );
  }
}
