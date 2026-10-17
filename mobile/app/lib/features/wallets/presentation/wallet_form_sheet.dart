import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/money_formatter.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../application/wallets_service.dart';
import '../data/wallet_models.dart';

class WalletFormSheet extends ConsumerStatefulWidget {
  const WalletFormSheet({super.key, this.existingWallet});

  final WalletItem? existingWallet;

  @override
  ConsumerState<WalletFormSheet> createState() => _WalletFormSheetState();
}

class _WalletFormSheetState extends ConsumerState<WalletFormSheet> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _selectedType = 'BANK';
  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingWallet != null) {
      final w = widget.existingWallet!;
      _nameController.text = w.name;
      _selectedType = w.type;
      _balanceController.text = w.initialBalance.toString();
    } else {
      _balanceController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  int get _parsedBalance {
    return int.tryParse(
          _balanceController.text.replaceAll(RegExp(r'\D'), ''),
        ) ??
        0;
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập tên ví');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    try {
      final notifier = ref.read(walletsActionProvider.notifier);
      if (widget.existingWallet != null) {
        await notifier.updateWallet(
          widget.existingWallet!.id,
          UpdateWalletDto(name: name, type: _selectedType),
        );
      } else {
        await notifier.createWallet(
          CreateWalletDto(
            name: name,
            type: _selectedType,
            initialBalance: _parsedBalance,
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

  Future<void> _handleDeleteOrArchive() async {
    final w = widget.existingWallet;
    if (w == null) return;

    if (w.balance > 0) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Không thể xóa ví'),
          content: Text(
            'Ví "${w.name}" còn số dư ${MoneyFormatter.format(w.balance)}. '
            'Vui lòng chuyển hết tiền sang ví khác trước khi xóa hoặc lưu trữ.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Đã hiểu'),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa / lưu trữ'),
        content: Text('Bạn có chắc chắn muốn xóa hoặc lưu trữ ví "${w.name}"?'),
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
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isSubmitting = true);
      try {
        final notifier = ref.read(walletsActionProvider.notifier);
        final res = await notifier.deleteWallet(w.id);
        if (mounted) {
          Navigator.of(context).pop(true);
          final isArchived = res['archived'] == true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArchived
                    ? 'Ví đã được chuyển vào lưu trữ.'
                    : 'Đã xóa ví thành công.',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) setState(() => _errorMessage = e.toString());
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleRestore() async {
    final w = widget.existingWallet;
    if (w == null) return;

    setState(() => _isSubmitting = true);
    try {
      final notifier = ref.read(walletsActionProvider.notifier);
      await notifier.restoreWallet(w.id);
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã khôi phục ví "${w.name}" thành công.')),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isEditing = widget.existingWallet != null;
    final isArchived = widget.existingWallet?.isArchived ?? false;

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
                isEditing ? 'Sửa thông tin ví' : 'Thêm ví mới',
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

          // Tên ví
          Text(
            'Tên ví',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            autofocus: !isEditing,
            decoration: InputDecoration(
              hintText: 'Ví dụ: MB Bank, Tiền mặt, MoMo...',
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
          const SizedBox(height: 16),

          // Loại ví: BANK / CASH / EWALLET
          Text(
            'Loại ví',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilterChip(
                  label: const Center(child: Text('Ngân hàng')),
                  selected: _selectedType == 'BANK',
                  onSelected: (_) => setState(() => _selectedType = 'BANK'),
                  showCheckmark: false,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilterChip(
                  label: const Center(child: Text('Tiền mặt')),
                  selected: _selectedType == 'CASH',
                  onSelected: (_) => setState(() => _selectedType = 'CASH'),
                  showCheckmark: false,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilterChip(
                  label: const Center(child: Text('Ví điện tử')),
                  selected: _selectedType == 'EWALLET',
                  onSelected: (_) => setState(() => _selectedType = 'EWALLET'),
                  showCheckmark: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Số dư ban đầu (chỉ khi tạo mới)
          if (!isEditing) ...[
            Text(
              'Số dư ban đầu (VNĐ)',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0',
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
            const SizedBox(height: 16),
          ],

          if (_errorMessage != null) ...[
            Text(
              _errorMessage!,
              style: TextStyle(color: colors.error, fontSize: 13),
            ),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 8),
          AppButton(
            label: isEditing ? 'Lưu thay đổi' : 'Tạo ví',
            loading: _isSubmitting,
            onPressed: _handleSubmit,
          ),

          if (isEditing) ...[
            const SizedBox(height: 10),
            if (isArchived)
              AppButton(
                label: 'Khôi phục ví',
                icon: LucideIcons.rotate_ccw,
                style: AppButtonStyle.secondary,
                loading: _isSubmitting,
                onPressed: _handleRestore,
              )
            else
              AppButton(
                label: 'Xóa hoặc lưu trữ ví',
                icon: LucideIcons.trash,
                style: AppButtonStyle.danger,
                loading: _isSubmitting,
                onPressed: _handleDeleteOrArchive,
              ),
          ],
        ],
      ),
    );
  }
}
