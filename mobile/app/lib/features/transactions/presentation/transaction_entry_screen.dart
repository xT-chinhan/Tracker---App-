import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/money_formatter.dart';
import '../../../core/formatting/vietnam_time.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/amount_keypad.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_icon_helper.dart';
import '../../categories/application/categories_service.dart';
import '../../categories/presentation/category_picker_sheet.dart';
import '../../home/data/home_models.dart';
import '../../wallets/application/wallets_service.dart';
import '../../wallets/presentation/wallet_picker_sheet.dart';
import '../application/transaction_entry_service.dart';

enum TransactionType { expense, income }

class TransactionEntryScreen extends ConsumerStatefulWidget {
  const TransactionEntryScreen({
    this.initialType = TransactionType.expense,
    this.initialTransaction,
    super.key,
  });

  final TransactionType initialType;
  final TransactionItem? initialTransaction;

  @override
  ConsumerState<TransactionEntryScreen> createState() =>
      _TransactionEntryScreenState();
}

class _TransactionEntryScreenState
    extends ConsumerState<TransactionEntryScreen> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (widget.initialTransaction != null) {
          final tx = widget.initialTransaction!;
          _noteController.text =
              tx.note ?? (tx.title != tx.category?.name ? tx.title : '');
          ref.read(transactionEntryProvider.notifier).initFromTransaction(tx);
        } else {
          ref
              .read(transactionEntryProvider.notifier)
              .initType(widget.initialType);
        }
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _formatDateLabel(DateTime date) {
    final now = VietnamTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Hôm nay, ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Hôm qua, ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionEntryProvider);
    final notifier = ref.read(transactionEntryProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    // Auto-select first category and wallet when loaded if not yet set
    final apiType = state.type == TransactionType.expense
        ? 'EXPENSE'
        : 'INCOME';
    final categoriesAsync = ref.watch(categoriesProvider(apiType));
    final walletsAsync = ref.watch(walletsProvider);

    categoriesAsync.whenData((categories) {
      if (state.selectedCategory == null && categories.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && state.selectedCategory == null) {
            notifier.setCategory(categories.first);
          }
        });
      }
    });

    walletsAsync.whenData((wallets) {
      if (state.selectedWallet == null && wallets.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && state.selectedWallet == null) {
            notifier.setWallet(wallets.first);
          }
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Đóng',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(LucideIcons.x),
        ),
        title: Text(
          widget.initialTransaction != null ? 'Sửa giao dịch' : 'Ghi giao dịch',
        ),
        actions: [
          IconButton(
            tooltip: 'Lưu làm mẫu',
            icon: const Icon(LucideIcons.bookmark_plus),
            onPressed: () => _showSaveTemplateDialog(notifier, state),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.screenPadding,
                        vertical: 4,
                      ),
                      child: _TypeSwitch(
                        value: state.type,
                        onChanged: (newType) => notifier.setType(newType),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      MoneyFormatter.format(state.amount),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontFeatures: MoneyFormatter.tabularFeatures,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.amount > 0
                          ? MoneyFormatter.inWords(state.amount)
                          : 'Chạm bàn phím để nhập số tiền',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Form Card
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.screenPadding,
                      ),
                      child: AppCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Column(
                          children: [
                            // Row 1: Danh mục
                            _FormRow(
                              icon: LucideIcons.shapes,
                              label: 'Danh mục',
                              trailing: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (state.selectedCategory != null) ...[
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFF0EFEA),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        AppIconHelper.fromName(
                                          state.selectedCategory?.icon,
                                        ),
                                        size: 16,
                                        color: const Color(0xFF111111),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        state.selectedCategory!.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ] else
                                    Flexible(
                                      child: Text(
                                        'Chọn danh mục',
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: colors.onSurfaceVariant,
                                            ),
                                      ),
                                    ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    LucideIcons.chevron_right,
                                    size: 18,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ],
                              ),
                              onTap: () async {
                                final selected = await CategoryPickerSheet.show(
                                  context,
                                  initialType: state.type,
                                  selectedCategoryId:
                                      state.selectedCategory?.id,
                                );
                                if (selected != null) {
                                  notifier.setCategory(selected);
                                }
                              },
                            ),
                            const Divider(height: 1, indent: 36),
                            // Row 2: Ví
                            _FormRow(
                              icon: LucideIcons.wallet,
                              label: 'Ví',
                              trailing: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: Text(
                                      state.selectedWallet?.name ?? 'Chọn ví',
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    LucideIcons.chevron_right,
                                    size: 18,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ],
                              ),
                              onTap: () async {
                                final selected = await WalletPickerSheet.show(
                                  context,
                                  selectedWalletId: state.selectedWallet?.id,
                                );
                                if (selected != null) {
                                  notifier.setWallet(selected);
                                }
                              },
                            ),
                            const Divider(height: 1, indent: 36),
                            // Row 3: Ngày
                            _FormRow(
                              icon: LucideIcons.calendar,
                              label: 'Ngày',
                              trailing: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: Text(
                                      _formatDateLabel(state.occurredAt),
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    LucideIcons.chevron_right,
                                    size: 18,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ],
                              ),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: state.occurredAt,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  notifier.setDate(picked);
                                }
                              },
                            ),
                            const Divider(height: 1, indent: 36),
                            // Row 4: Ghi chú
                            _FormRow(
                              icon: LucideIcons.square_pen,
                              label: 'Ghi chú',
                              trailing: TextField(
                                controller: _noteController,
                                textAlign: TextAlign.right,
                                onChanged: notifier.setNote,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  hintText:
                                      state.type == TransactionType.expense
                                      ? 'Cơm trưa văn phòng'
                                      : 'Tiền lương tháng',
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: colors.onSurfaceVariant
                                            .withAlpha(120),
                                      ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing.screenPadding,
                        ),
                        child: Text(
                          state.errorMessage!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colors.error,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            AmountKeypad(
              onDigit: notifier.appendDigit,
              onDelete: notifier.deleteDigit,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.spacing.screenPadding,
                0,
                context.spacing.screenPadding,
                16,
              ),
              child: AppButton(
                label: widget.initialTransaction != null
                    ? 'Lưu thay đổi'
                    : (state.type == TransactionType.expense
                          ? 'Lưu khoản chi'
                          : 'Lưu thu nhập'),
                loading: state.isSaving,
                onPressed:
                    state.amount > 0 &&
                        state.selectedCategory != null &&
                        state.selectedWallet != null &&
                        !state.isSaving
                    ? () async {
                        final success = await notifier.submitTransaction(
                          updateTransactionId: widget.initialTransaction?.id,
                        );
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                widget.initialTransaction != null
                                    ? 'Đã cập nhật giao dịch'
                                    : (state.type == TransactionType.expense
                                          ? 'Đã ghi khoản chi thành công'
                                          : 'Đã ghi thu nhập thành công'),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          Navigator.of(context).pop(true);
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSaveTemplateDialog(
    TransactionEntryNotifier notifier,
    TransactionEntryState state,
  ) async {
    final templateLabelController = TextEditingController(
      text: state.selectedCategory?.name ?? '',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lưu làm mẫu nhập nhanh'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập nhãn ngắn để hiển thị trên nút mẫu (ví dụ: Cà phê, Cơm trưa, Grab...):',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: templateLabelController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Tên mẫu',
                hintText: 'Cà phê',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final label = templateLabelController.text.trim();
              if (label.isEmpty) return;
              final ok = await notifier.saveAsTemplate(label);
              if (ctx.mounted) Navigator.of(ctx).pop(ok);
            },
            child: const Text('Lưu mẫu'),
          ),
        ],
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu mẫu nhập nhanh thành công'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

class _FormRow extends StatelessWidget {
  const _FormRow({
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 12),
            Expanded(child: trailing),
          ],
        ),
      ),
    );
  }
}

class _TypeSwitch extends StatelessWidget {
  const _TypeSwitch({required this.value, required this.onChanged});

  final TransactionType value;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(context.radius.pill),
      ),
      child: Row(
        children: [
          Expanded(child: _item(context, TransactionType.expense, 'Khoản chi')),
          Expanded(child: _item(context, TransactionType.income, 'Thu nhập')),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, TransactionType type, String label) {
    final selected = value == type;
    return InkWell(
      onTap: () => onChanged(type),
      borderRadius: BorderRadius.circular(context.radius.pill),
      child: AnimatedContainer(
        duration: context.motion.fast,
        curve: AppMotion.easeOut,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.surface
              : Colors.transparent,
          borderRadius: BorderRadius.circular(context.radius.pill),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x14111111),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
