import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_icon_helper.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../transactions/presentation/transaction_entry_screen.dart';
import '../application/categories_service.dart';
import '../data/category_models.dart';
import '../data/category_repository.dart';

class CategoryPickerSheet extends ConsumerStatefulWidget {
  const CategoryPickerSheet({
    required this.initialType,
    this.selectedCategoryId,
    required this.onSelect,
    super.key,
  });

  final TransactionType initialType;
  final String? selectedCategoryId;
  final ValueChanged<CategoryItem> onSelect;

  static Future<CategoryItem?> show(
    BuildContext context, {
    required TransactionType initialType,
    String? selectedCategoryId,
  }) {
    return showModalBottomSheet<CategoryItem>(
      // mở trên navigator gốc: không bị thanh menu dưới (shell) che
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CategoryPickerSheet(
        initialType: initialType,
        selectedCategoryId: selectedCategoryId,
        onSelect: (cat) => Navigator.of(ctx).pop(cat),
      ),
    );
  }

  @override
  ConsumerState<CategoryPickerSheet> createState() =>
      _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends ConsumerState<CategoryPickerSheet> {
  late TransactionType _type = widget.initialType;

  String get _apiType =>
      _type == TransactionType.expense ? 'EXPENSE' : 'INCOME';

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider(_apiType));
    final colors = Theme.of(context).colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radius.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: colors.outlineVariant.withAlpha(120),
                borderRadius: BorderRadius.circular(context.radius.pill),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.screenPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chọn danh mục',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showManageCategoriesDialog(context),
                    child: Text(
                      'Sửa',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _TypeSwitch(
              value: _type,
              onChanged: (newType) => setState(() => _type = newType),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: categoriesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: AppSkeleton(width: double.infinity, height: 200),
                ),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Không thể tải danh mục',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: colors.error),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'Thử lại',
                        style: AppButtonStyle.secondary,
                        onPressed: () =>
                            ref.invalidate(categoriesProvider(_apiType)),
                      ),
                    ],
                  ),
                ),
                data: (categories) => _buildCategoryGrid(context, categories),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(
    BuildContext context,
    List<CategoryItem> categories,
  ) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        context.spacing.screenPadding,
        8,
        context.spacing.screenPadding,
        24,
      ),
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: categories.length + 1, // +1 for "Thêm mới"
      itemBuilder: (context, index) {
        if (index == categories.length) {
          return _buildAddNewItem(context);
        }
        final item = categories[index];
        final isSelected = item.id == widget.selectedCategoryId;
        return _buildCategoryItem(context, item, isSelected);
      },
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    CategoryItem item,
    bool isSelected,
  ) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => widget.onSelect(item),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? const Color(0xFF111111)
                  : const Color(0xFFF3F2EE),
            ),
            alignment: Alignment.center,
            child: Icon(
              AppIconHelper.fromName(item.icon),
              size: 24,
              color: isSelected ? Colors.white : const Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF111111) : colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewItem(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => _showAddCategoryDialog(context),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            painter: _DashedCirclePainter(color: colors.outlineVariant),
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Icon(LucideIcons.plus, size: 24, color: Color(0xFF666666)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm mới',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final created = await showDialog<CategoryItem>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm danh mục mới'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Tên danh mục',
            hintText: 'Ví dụ: Đồ ăn vặt, Thể thao...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              try {
                final cat = await ref
                    .read(categoryRepositoryProvider)
                    .createCategory(
                      CreateCategoryDto(
                        name: name,
                        type: _apiType,
                        icon: 'shapes',
                      ),
                    );
                ref.invalidate(categoriesProvider(_apiType));
                if (ctx.mounted) Navigator.of(ctx).pop(cat);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(
                    ctx,
                  ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (created != null && mounted) {
      widget.onSelect(created);
    }
  }

  void _showManageCategoriesDialog(BuildContext context) {
    // Shows alert / dialog for category info
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bạn có thể thêm danh mục riêng qua nút "Thêm mới"'),
        duration: Duration(seconds: 2),
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
      margin: EdgeInsets.symmetric(horizontal: context.spacing.screenPadding),
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

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final radius = size.width / 2;
    const dashLength = 4.0;
    const totalDashes = 22;

    final center = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < totalDashes; i++) {
      final angle = (i * 2 * 3.14159) / totalDashes;
      final sweepAngle = (dashLength / (2 * 3.14159 * radius)) * (2 * 3.14159);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
