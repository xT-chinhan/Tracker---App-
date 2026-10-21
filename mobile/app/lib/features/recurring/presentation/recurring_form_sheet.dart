import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_icon_helper.dart';
import '../../categories/data/category_models.dart';
import '../../categories/presentation/category_picker_sheet.dart';
import '../../transactions/presentation/transaction_entry_screen.dart';
import '../../wallets/application/wallets_service.dart';
import '../../wallets/data/wallet_models.dart';
import '../../wallets/presentation/wallet_picker_sheet.dart';
import '../application/recurring_service.dart';
import '../data/recurring_models.dart';

class RecurringFormSheet extends ConsumerStatefulWidget {
  const RecurringFormSheet({super.key, this.existingRule});

  final RecurringRuleItem? existingRule;

  @override
  ConsumerState<RecurringFormSheet> createState() => _RecurringFormSheetState();
}

class _RecurringFormSheetState extends ConsumerState<RecurringFormSheet> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  String _transactionType = 'EXPENSE';
  CategoryItem? _selectedCategory;
  WalletItem? _selectedWallet;

  String _frequency = 'WEEKLY';
  int _interval = 1;
  int _selectedWeekday = 7; // 1 = T2, ..., 7 = CN

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isSubmitting = false;
  String? _errorMessage;

  static const _daysOfWeek = [
    (1, 'T2'),
    (2, 'T3'),
    (3, 'T4'),
    (4, 'T5'),
    (5, 'T6'),
    (6, 'T7'),
    (7, 'CN'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingRule != null) {
      final r = widget.existingRule!;
      _titleController.text = r.title;
      _amountController.text = r.amount.toString();
      _noteController.text = r.note ?? '';
      _frequency = r.frequency;
      _interval = r.interval;
      _startDate = r.startDate;
      _endDate = r.endDate;
      _selectedWeekday = r.startDate.weekday;

      if (r.category != null) {
        _transactionType = r.category!.type;
        _selectedCategory = CategoryItem(
          id: r.category!.id,
          name: r.category!.name,
          type: r.category!.type,
          icon: r.category!.icon,
          color: r.category!.color,
        );
      }

      if (r.wallet != null) {
        _selectedWallet = WalletItem(
          id: r.wallet!.id,
          name: r.wallet!.name,
          type: r.wallet!.type,
        );
      }
    } else {
      _amountController.text = '500000';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int get _parsedAmount {
    return int.tryParse(_amountController.text.replaceAll(RegExp(r'\D'), '')) ??
        0;
  }

  Future<void> _openCategoryPicker() async {
    final cat = await CategoryPickerSheet.show(
      context,
      initialType: _transactionType == 'EXPENSE'
          ? TransactionType.expense
          : TransactionType.income,
      selectedCategoryId: _selectedCategory?.id,
    );
    if (cat != null && mounted) {
      setState(() {
        _selectedCategory = cat;
        _transactionType = cat.type;
      });
    }
  }

  Future<void> _openWalletPicker() async {
    final wallet = await WalletPickerSheet.show(
      context,
      selectedWalletId: _selectedWallet?.id,
    );
    if (wallet != null && mounted) {
      setState(() => _selectedWallet = wallet);
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 365)),
      firstDate: _startDate,
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  String _formatPreviewSubtitle() {
    final formatter = DateFormat('dd/MM');
    final nextStr = formatter.format(_startDate);
    return 'Lần tới: $nextStr, sau đó tiếp tục định kỳ';
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập tên định kỳ');
      return;
    }

    final amount = _parsedAmount;
    if (amount <= 0) {
      setState(() => _errorMessage = 'Vui lòng nhập số tiền hợp lệ');
      return;
    }

    if (_selectedCategory == null) {
      setState(() => _errorMessage = 'Vui lòng chọn danh mục');
      return;
    }

    if (_selectedWallet == null) {
      // Pick default wallet if any
      final wallets = ref.read(walletsProvider).value ?? [];
      if (wallets.isNotEmpty) {
        _selectedWallet = wallets.first;
      } else {
        setState(() => _errorMessage = 'Vui lòng chọn ví');
        return;
      }
    }

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    try {
      final notifier = ref.read(recurringProvider.notifier);
      final startDateStr = _startDate.toIso8601String();
      final endDateStr = _endDate?.toIso8601String();

      if (widget.existingRule != null) {
        await notifier.updateRule(
          widget.existingRule!.id,
          UpdateRecurringDto(
            title: title,
            amount: amount,
            categoryId: _selectedCategory!.id,
            walletId: _selectedWallet!.id,
            frequency: _frequency,
            interval: _interval,
            startDate: startDateStr,
            endDate: endDateStr,
            note: _noteController.text.trim(),
          ),
        );
      } else {
        await notifier.createRule(
          CreateRecurringDto(
            title: title,
            amount: amount,
            categoryId: _selectedCategory!.id,
            walletId: _selectedWallet!.id,
            frequency: _frequency,
            interval: _interval,
            startDate: startDateStr,
            endDate: endDateStr,
            note: _noteController.text.trim(),
          ),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleDelete() async {
    final r = widget.existingRule;
    if (r == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa quy tắc'),
        content: Text(
          'Bạn có chắc chắn muốn xóa quy tắc định kỳ "${r.title}"? '
          'Các giao dịch đã phát sinh trước đây sẽ vẫn được giữ lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isSubmitting = true);
      try {
        final notifier = ref.read(recurringProvider.notifier);
        await notifier.deleteRule(r.id);
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa quy tắc định kỳ thành công.')),
          );
        }
      } catch (e) {
        if (mounted) setState(() => _errorMessage = e.toString());
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isEditing = widget.existingRule != null;
    final walletsAsync = ref.watch(walletsProvider);

    // Default wallet if unselected
    walletsAsync.whenData((wallets) {
      if (_selectedWallet == null && wallets.isNotEmpty) {
        _selectedWallet = wallets.first;
      }
    });

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.spacing.screenPadding,
        14,
        context.spacing.screenPadding,
        MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).viewPadding.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar: X      Định kỳ mới
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  visualDensity: VisualDensity.compact,
                ),
                Text(
                  isEditing ? 'Sửa quy tắc' : 'Định kỳ mới',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 40), // Balance space
              ],
            ),
            const SizedBox(height: 12),

            // Segmented Type: Khoản chi | Thu nhập
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(context.radius.pill),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _transactionType = 'EXPENSE'),
                      borderRadius: BorderRadius.circular(context.radius.pill),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _transactionType == 'EXPENSE'
                              ? colors.surface
                              : null,
                          borderRadius: BorderRadius.circular(
                            context.radius.pill,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Khoản chi',
                          style: TextStyle(
                            fontWeight: _transactionType == 'EXPENSE'
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _transactionType = 'INCOME'),
                      borderRadius: BorderRadius.circular(context.radius.pill),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _transactionType == 'INCOME'
                              ? colors.surface
                              : null,
                          borderRadius: BorderRadius.circular(
                            context.radius.pill,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Thu nhập',
                          style: TextStyle(
                            fontWeight: _transactionType == 'INCOME'
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Card 1: Số tiền, Tên, Danh mục, Ví (18-tao-dinh-ky.png)
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Số tiền
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Số tiền',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                        SizedBox(
                          width: 160,
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.end,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              suffixText: 'đ',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: colors.outlineVariant, height: 1),

                  // Tên
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tên',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _titleController,
                            textAlign: TextAlign.end,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              hintText: 'Ví dụ: Đi chợ, Tiền nhà',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: colors.outlineVariant, height: 1),

                  // Danh mục
                  InkWell(
                    onTap: _openCategoryPicker,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Danh mục',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                          Row(
                            children: [
                              if (_selectedCategory != null) ...[
                                Icon(
                                  AppIconHelper.fromName(
                                    _selectedCategory!.icon,
                                  ),
                                  size: 16,
                                  color: AppIconHelper.parseColor(
                                    _selectedCategory!.color,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _selectedCategory!.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ] else
                                const Text('Chọn danh mục >'),
                              const SizedBox(width: 4),
                              Icon(
                                LucideIcons.chevron_right,
                                size: 16,
                                color: colors.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(color: colors.outlineVariant, height: 1),

                  // Ví
                  InkWell(
                    onTap: _openWalletPicker,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ví',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                          Row(
                            children: [
                              Text(
                                _selectedWallet?.name ?? 'Chọn ví',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                LucideIcons.chevron_right,
                                size: 16,
                                color: colors.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tần suất
            Text(
              'Tần suất',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilterChip(
                    label: const Center(child: Text('Hằng ngày')),
                    selected: _frequency == 'DAILY',
                    onSelected: (_) => setState(() => _frequency = 'DAILY'),
                    showCheckmark: false,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: FilterChip(
                    label: const Center(child: Text('Hằng tuần')),
                    selected: _frequency == 'WEEKLY',
                    onSelected: (_) => setState(() => _frequency = 'WEEKLY'),
                    showCheckmark: false,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: FilterChip(
                    label: const Center(child: Text('Hằng tháng')),
                    selected: _frequency == 'MONTHLY',
                    onSelected: (_) => setState(() => _frequency = 'MONTHLY'),
                    showCheckmark: false,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: FilterChip(
                    label: const Center(child: Text('Hằng năm')),
                    selected: _frequency == 'YEARLY',
                    onSelected: (_) => setState(() => _frequency = 'YEARLY'),
                    showCheckmark: false,
                  ),
                ),
              ],
            ),

            // Lặp vào (khi WEEKLY)
            if (_frequency == 'WEEKLY') ...[
              const SizedBox(height: 14),
              Text(
                'Lặp vào',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _daysOfWeek.map((d) {
                  final isSelected = _selectedWeekday == d.$1;
                  return InkWell(
                    onTap: () => setState(() => _selectedWeekday = d.$1),
                    borderRadius: BorderRadius.circular(context.radius.pill),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary
                            : colors.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        d.$2,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? colors.onPrimary
                              : colors.onSurface,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 16),

            // Card 2: Bắt đầu, Kết thúc (18-tao-dinh-ky.png)
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  InkWell(
                    onTap: _selectStartDate,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bắt đầu',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                          Row(
                            children: [
                              Text(
                                DateFormat('dd/MM/yyyy').format(_startDate),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                LucideIcons.chevron_right,
                                size: 16,
                                color: colors.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(color: colors.outlineVariant, height: 1),
                  InkWell(
                    onTap: () async {
                      if (_endDate != null) {
                        setState(() => _endDate = null);
                      } else {
                        await _selectEndDate();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kết thúc',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                          Row(
                            children: [
                              Text(
                                _endDate != null
                                    ? DateFormat('dd/MM/yyyy').format(_endDate!)
                                    : 'Không giới hạn',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                LucideIcons.chevron_right,
                                size: 16,
                                color: colors.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Text(
              _formatPreviewSubtitle(),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: TextStyle(color: colors.error, fontSize: 13),
              ),
            ],

            const SizedBox(height: 20),
            AppButton(
              label: isEditing ? 'Lưu thay đổi' : 'Lưu quy tắc',
              loading: _isSubmitting,
              onPressed: _handleSubmit,
            ),

            if (isEditing) ...[
              const SizedBox(height: 10),
              AppButton(
                label: 'Xóa quy tắc',
                icon: LucideIcons.trash,
                style: AppButtonStyle.danger,
                loading: _isSubmitting,
                onPressed: _handleDelete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
