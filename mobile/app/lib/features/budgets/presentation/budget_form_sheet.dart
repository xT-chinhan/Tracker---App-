import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_icon_helper.dart';
import '../../categories/application/categories_service.dart';
import '../../home/data/home_models.dart';
import '../application/budgets_service.dart';

class BudgetFormSheet extends ConsumerStatefulWidget {
  const BudgetFormSheet({
    super.key,
    this.existingBudget,
    this.existingOverall,
    this.takenCategoryIds = const <String>{},
  });

  final BudgetItem? existingBudget;
  final BudgetOverall? existingOverall;
  final Set<String> takenCategoryIds;

  @override
  ConsumerState<BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends ConsumerState<BudgetFormSheet> {
  final _amountController = TextEditingController();
  String? _selectedCategoryId;
  bool _isOverall = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.existingOverall != null) {
      _isOverall = true;
      _amountController.text = widget.existingOverall!.limitAmount.toString();
    } else if (widget.existingBudget != null) {
      _isOverall = false;
      _selectedCategoryId = widget.existingBudget!.categoryId;
      _amountController.text = widget.existingBudget!.limitAmount.toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final amount = int.tryParse(
      _amountController.text.replaceAll(RegExp(r'\D'), ''),
    );
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Vui lòng nhập hạn mức hợp lệ (> 0đ)');
      return;
    }

    if (!_isOverall && _selectedCategoryId == null) {
      setState(() => _errorMessage = 'Vui lòng chọn danh mục chi tiêu');
      return;
    }

    setState(() => _errorMessage = null);
    final notifier = ref.read(budgetsProvider.notifier);

    try {
      if (widget.existingOverall != null) {
        await notifier.updateBudget(widget.existingOverall!.id, amount);
      } else if (widget.existingBudget != null) {
        await notifier.updateBudget(widget.existingBudget!.id, amount);
      } else {
        await notifier.createBudget(
          categoryId: _isOverall ? null : _selectedCategoryId,
          limitAmount: amount,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    }
  }

  Future<void> _handleDelete() async {
    final id = widget.existingOverall?.id ?? widget.existingBudget?.id;
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa ngân sách'),
        content: const Text('Bạn có chắc chắn muốn xóa ngân sách này?'),
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
      final notifier = ref.read(budgetsProvider.notifier);
      await notifier.deleteBudget(id);
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isEditing =
        widget.existingBudget != null || widget.existingOverall != null;
    final categoriesAsync = ref.watch(categoriesProvider('EXPENSE'));

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.spacing.screenPadding,
        16,
        context.spacing.screenPadding,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? 'Sửa ngân sách' : 'Tạo ngân sách',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Scope selection (Overall vs Category) if creating new
          if (!isEditing) ...[
            Row(
              children: [
                Expanded(
                  child: FilterChip(
                    label: const Center(child: Text('Theo danh mục')),
                    selected: !_isOverall,
                    onSelected: (val) => setState(() => _isOverall = false),
                    showCheckmark: false,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilterChip(
                    label: const Center(child: Text('Ngân sách tổng')),
                    selected: _isOverall,
                    onSelected: (val) => setState(() {
                      _isOverall = true;
                      _selectedCategoryId = null;
                    }),
                    showCheckmark: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Category picker dropdown if category budget
          if (!_isOverall) ...[
            Text(
              'Danh mục chi tiêu',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            categoriesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text('Không thể tải danh mục'),
              data: (categories) {
                // Filter out categories already budgeted (unless it's the one we're editing)
                final available = categories.where((c) {
                  if (widget.existingBudget != null &&
                      c.id == widget.existingBudget!.categoryId) {
                    return true;
                  }
                  return !widget.takenCategoryIds.contains(c.id);
                }).toList();

                if (available.isEmpty) {
                  return const Text('Tất cả danh mục đã có ngân sách.');
                }

                return DropdownButtonFormField<String>(
                  initialValue: _selectedCategoryId,
                  hint: const Text('Chọn danh mục'),
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.radius.md),
                      borderSide: BorderSide(color: colors.outline),
                    ),
                  ),
                  items: available.map((c) {
                    return DropdownMenuItem<String>(
                      value: c.id,
                      child: Row(
                        children: [
                          Icon(
                            AppIconHelper.fromName(c.icon),
                            size: 18,
                            color: AppIconHelper.parseColor(c.color),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              c.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: isEditing
                      ? null
                      : (val) => setState(() => _selectedCategoryId = val),
                );
              },
            ),
            const SizedBox(height: 16),
          ],

          // Limit amount input
          Text(
            'Hạn mức (VNĐ)',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            autofocus: !isEditing,
            decoration: InputDecoration(
              hintText: 'Ví dụ: 3.500.000',
              suffixText: 'đ',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.radius.md),
                borderSide: BorderSide(color: colors.outline),
              ),
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: TextStyle(color: colors.error, fontSize: 13),
            ),
          ],

          const SizedBox(height: 24),
          AppButton(
            label: isEditing ? 'Lưu thay đổi' : 'Tạo ngân sách',
            onPressed: _handleSubmit,
          ),

          if (isEditing) ...[
            const SizedBox(height: 10),
            AppButton(
              label: 'Xóa ngân sách',
              icon: LucideIcons.trash,
              style: AppButtonStyle.danger,
              onPressed: _handleDelete,
            ),
          ],
        ],
      ),
    );
  }
}
