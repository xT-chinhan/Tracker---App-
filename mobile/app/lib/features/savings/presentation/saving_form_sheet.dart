import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../application/savings_service.dart';
import '../data/saving_models.dart';
import '../../../core/formatting/vietnam_time.dart';

class SavingFormSheet extends ConsumerStatefulWidget {
  const SavingFormSheet({super.key, this.existingGoal});

  final SavingGoalDetail? existingGoal;

  @override
  ConsumerState<SavingFormSheet> createState() => _SavingFormSheetState();
}

class _SavingFormSheetState extends ConsumerState<SavingFormSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 90));
  String _selectedIcon = 'plane';
  String? _errorMessage;
  bool _isSubmitting = false;

  static const _availableIcons = [
    ('plane', LucideIcons.plane, 'Du lịch'),
    ('laptop', LucideIcons.laptop, 'Công nghệ'),
    ('shield-check', LucideIcons.shield_check, 'Khẩn cấp'),
    ('car', LucideIcons.car, 'Xe cộ'),
    ('house', LucideIcons.house, 'Nhà cửa'),
    ('heart', LucideIcons.heart, 'Sức khỏe'),
    ('gift', LucideIcons.gift, 'Quà tặng'),
    ('graduation-cap', LucideIcons.graduation_cap, 'Giáo dục'),
    ('piggy-bank', LucideIcons.piggy_bank, 'Tiết kiệm'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingGoal != null) {
      final g = widget.existingGoal!;
      _nameController.text = g.name;
      _amountController.text = g.targetAmount.toString();
      _targetDate = VietnamTime.fromDateTime(g.targetDate);
      if (g.icon != null) _selectedIcon = g.icon!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập tên mục tiêu');
      return;
    }

    final amount = int.tryParse(
      _amountController.text.replaceAll(RegExp(r'\D'), ''),
    );
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Vui lòng nhập số tiền mục tiêu hợp lệ');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_targetDate);
      final notifier = ref.read(savingsProvider.notifier);
      if (widget.existingGoal != null) {
        await notifier.updateGoal(
          goalId: widget.existingGoal!.id,
          dto: UpdateGoalDto(
            name: name,
            targetAmount: amount,
            targetDate: dateStr,
            icon: _selectedIcon,
          ),
        );
      } else {
        await notifier.createGoal(
          CreateGoalDto(
            name: name,
            targetAmount: amount,
            targetDate: dateStr,
            icon: _selectedIcon,
          ),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _handleDelete() async {
    final g = widget.existingGoal;
    if (g == null) return;

    if (g.savedAmount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng rút hết tiền trước khi xóa mục tiêu này!'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa mục tiêu'),
        content: Text('Bạn có chắc chắn muốn xóa mục tiêu "${g.name}"?'),
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
      final notifier = ref.read(savingsProvider.notifier);
      await notifier.deleteGoal(g.id);
      if (mounted) {
        Navigator.of(context).pop('deleted');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isEditing = widget.existingGoal != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.spacing.screenPadding,
        16,
        context.spacing.screenPadding,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Sửa mục tiêu' : 'Tạo mục tiêu tiết kiệm',
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

            // Goal Name
            Text(
              'Tên mục tiêu',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Ví dụ: Du lịch Đà Lạt, Mua laptop...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.radius.md),
                  borderSide: BorderSide(color: colors.outline),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Target Amount
            Text(
              'Số tiền mục tiêu (VNĐ)',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Ví dụ: 6.000.000',
                suffixText: 'đ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.radius.md),
                  borderSide: BorderSide(color: colors.outline),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Target Date
            Text(
              'Hạn hoàn thành',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _selectTargetDate,
              borderRadius: BorderRadius.circular(context.radius.md),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.radius.md),
                  border: Border.all(color: colors.outline),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.calendar,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_targetDate),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(LucideIcons.chevron_down, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Icon Picker
            Text(
              'Biểu tượng',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: _availableIcons.map((item) {
                final isSelected = _selectedIcon == item.$1;
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = item.$1),
                  borderRadius: BorderRadius.circular(context.radius.pill),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.primary
                          : colors.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.$2,
                      size: 20,
                      color: isSelected ? colors.onPrimary : colors.onSurface,
                    ),
                  ),
                );
              }).toList(),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(color: colors.error, fontSize: 13),
              ),
            ],

            const SizedBox(height: 24),
            AppButton(
              label: isEditing ? 'Lưu thay đổi' : 'Tạo mục tiêu',
              loading: _isSubmitting,
              onPressed: _handleSubmit,
            ),

            if (isEditing) ...[
              const SizedBox(height: 10),
              AppButton(
                label: 'Xóa mục tiêu',
                icon: LucideIcons.trash,
                style: AppButtonStyle.danger,
                onPressed: _handleDelete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
