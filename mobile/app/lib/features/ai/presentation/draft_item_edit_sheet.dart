import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/formatting/money_formatter.dart';
import '../../categories/presentation/category_picker_sheet.dart';
import '../../transactions/presentation/transaction_entry_screen.dart';
import '../../wallets/application/wallets_service.dart';

class DraftItemEditSheet extends ConsumerStatefulWidget {
  const DraftItemEditSheet({
    required this.item,
    required this.index,
    required this.total,
    required this.onSave,
    required this.onRemove,
    super.key,
  });

  final Map<String, dynamic> item;
  final int index;
  final int total;
  final ValueChanged<Map<String, dynamic>> onSave;
  final VoidCallback onRemove;

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> item,
    required int index,
    required int total,
    required ValueChanged<Map<String, dynamic>> onSave,
    required VoidCallback onRemove,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraftItemEditSheet(
        item: item,
        index: index,
        total: total,
        onSave: onSave,
        onRemove: onRemove,
      ),
    );
  }

  @override
  ConsumerState<DraftItemEditSheet> createState() => _DraftItemEditSheetState();
}

class _DraftItemEditSheetState extends ConsumerState<DraftItemEditSheet> {
  late String _title;
  late int _amount;
  late String _type; // EXPENSE or INCOME
  String? _categoryId;
  String? _categoryName;
  String? _walletId;
  String? _walletName;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _title = widget.item['title'] as String? ?? '';
    _amount = (widget.item['amount'] as num?)?.round() ?? 0;
    _type = widget.item['type'] as String? ?? 'EXPENSE';
    _categoryId = widget.item['categoryId'] as String?;
    _categoryName = widget.item['categoryName'] as String?;
    _walletId = widget.item['walletId'] as String?;
    _walletName = widget.item['walletName'] as String?;

    final dateStr = widget.item['date'] as String?;
    _date = dateStr != null
        ? DateTime.tryParse(dateStr) ?? DateTime.now()
        : DateTime.now();
  }

  void _handleSave() {
    final updated = Map<String, dynamic>.from(widget.item);
    updated['title'] = _title;
    updated['amount'] = _amount;
    updated['type'] = _type;
    updated['categoryId'] = _categoryId;
    updated['categoryName'] = _categoryName;
    updated['walletId'] = _walletId;
    updated['walletName'] = _walletName;
    updated['date'] = DateFormat('yyyy-MM-dd').format(_date);
    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  Future<void> _editTitle() async {
    final controller = TextEditingController(text: _title);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi tên khoản chi'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nhập tên'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Xong'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _title = result);
    }
  }

  Future<void> _editAmount() async {
    final controller = TextEditingController(text: _amount.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi số tiền'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(suffixText: 'đ'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final val = int.tryParse(controller.text.replaceAll('.', ''));
              Navigator.of(ctx).pop(val);
            },
            child: const Text('Xong'),
          ),
        ],
      ),
    );
    if (result != null && result > 0) {
      setState(() => _amount = result);
    }
  }

  Future<void> _selectCategory() async {
    final selected = await CategoryPickerSheet.show(
      context,
      initialType: _type == 'INCOME'
          ? TransactionType.income
          : TransactionType.expense,
      selectedCategoryId: _categoryId,
    );
    if (selected != null) {
      setState(() {
        _categoryId = selected.id;
        _categoryName = selected.name;
      });
    }
  }

  Future<void> _selectWallet() async {
    final walletsAsync = ref.read(walletsResponseProvider);
    final wallets = walletsAsync.value?.items ?? [];
    if (wallets.isEmpty) return;

    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Chọn ví',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            for (final w in wallets)
              ListTile(
                leading: const Icon(LucideIcons.wallet),
                title: Text(w.name),
                subtitle: Text(MoneyFormatter.format(w.balance)),
                selected: w.id == _walletId,
                onTap: () => Navigator.of(ctx).pop(w.id),
              ),
          ],
        ),
      ),
    );

    if (selected != null) {
      final w = wallets.firstWhere((x) => x.id == selected);
      setState(() {
        _walletId = w.id;
        _walletName = w.name;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Top bar: Khoản i/total & Xong
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Khoản ${widget.index + 1}/${widget.total}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _handleSave,
                  child: const Text(
                    'Xong',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111111),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Segment: Khoản chi / Thu nhập
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F0EC),
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _type = 'EXPENSE'),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _type == 'EXPENSE'
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: _type == 'EXPENSE'
                              ? const [
                                  BoxShadow(
                                    color: Color(0x0F000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Khoản chi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _type == 'EXPENSE'
                                ? const Color(0xFF111111)
                                : const Color(0xFF787774),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _type = 'INCOME'),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _type == 'INCOME'
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: _type == 'INCOME'
                              ? const [
                                  BoxShadow(
                                    color: Color(0x0F000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Thu nhập',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _type == 'INCOME'
                                ? const Color(0xFF111111)
                                : const Color(0xFF787774),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Big Amount with touch to edit
            InkWell(
              onTap: _editAmount,
              child: Column(
                children: [
                  Text(
                    MoneyFormatter.format(_amount),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${MoneyFormatter.inWords(_amount)} · chạm để sửa',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF787774),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Group Card: Tên, Danh mục, Ví, Ngày
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEAEAEA)),
              ),
              child: Column(
                children: [
                  _buildEditRow(
                    icon: LucideIcons.type,
                    label: 'Tên',
                    value: _title,
                    onTap: _editTitle,
                  ),
                  const Divider(
                    height: 1,
                    indent: 56,
                    color: Color(0xFFF0EFEC),
                  ),
                  _buildEditRow(
                    icon: LucideIcons.shapes,
                    label: 'Danh mục',
                    value: _categoryName ?? 'Chưa chọn',
                    onTap: _selectCategory,
                  ),
                  const Divider(
                    height: 1,
                    indent: 56,
                    color: Color(0xFFF0EFEC),
                  ),
                  _buildEditRow(
                    icon: LucideIcons.wallet,
                    label: 'Ví',
                    value: _walletName ?? 'Chưa chọn',
                    onTap: _selectWallet,
                  ),
                  const Divider(
                    height: 1,
                    indent: 56,
                    color: Color(0xFFF0EFEC),
                  ),
                  _buildEditRow(
                    icon: LucideIcons.calendar,
                    label: 'Ngày',
                    value: DateFormat('dd/MM/yyyy').format(_date),
                    onTap: _selectDate,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // AI Learning note box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFBFBF9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEAEAEA)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    LucideIcons.sparkles,
                    size: 16,
                    color: Color(0xFF787774),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Lần sau gặp “$_title”, trợ lý sẽ ưu tiên ví và danh mục bạn vừa chọn. Bạn xem và xóa điều đã học trong Cài đặt.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF787774),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Button: Lưu vào nháp
            FilledButton(
              onPressed: _handleSave,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF111111),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text(
                'Lưu vào nháp',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),

            // Button: Bỏ khoản này khỏi nháp
            Center(
              child: TextButton(
                onPressed: () {
                  widget.onRemove();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                ),
                child: const Text(
                  'Bỏ khoản này khỏi nháp',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF787774)),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(fontSize: 15, color: Color(0xFF787774)),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              LucideIcons.chevron_right,
              size: 16,
              color: Color(0xFFA9A8A3),
            ),
          ],
        ),
      ),
    );
  }
}
