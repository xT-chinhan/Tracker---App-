import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/formatting/money_formatter.dart';
import '../data/ai_models.dart';
import 'draft_item_edit_sheet.dart';
import '../../../core/formatting/vietnam_time.dart';

class TransactionDraftCard extends StatefulWidget {
  const TransactionDraftCard({
    required this.draft,
    required this.onConfirm,
    required this.onCancel,
    super.key,
  });

  final AiDraftItem draft;
  final Future<void> Function(Map<String, dynamic>? updatedPayload) onConfirm;
  final Future<void> Function() onCancel;

  @override
  State<TransactionDraftCard> createState() => _TransactionDraftCardState();
}

class _TransactionDraftCardState extends State<TransactionDraftCard> {
  late Map<String, dynamic> _payload;
  bool _isConfirming = false;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _payload = Map<String, dynamic>.from(widget.draft.payload ?? {});
  }

  @override
  void didUpdateWidget(covariant TransactionDraftCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.draft.payload != oldWidget.draft.payload) {
      _payload = Map<String, dynamic>.from(widget.draft.payload ?? {});
    }
  }

  List<Map<String, dynamic>> get _items {
    final raw = _payload['items'];
    if (raw is List) {
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  int get _totalAmount {
    int sum = 0;
    for (final it in _items) {
      final amt = (it['amount'] as num?)?.round() ?? 0;
      sum += amt;
    }
    return sum;
  }

  void _updateItem(int index, Map<String, dynamic> updatedItem) {
    final list = List<Map<String, dynamic>>.from(_items);
    list[index] = updatedItem;
    setState(() {
      _payload['items'] = list;
    });
  }

  void _removeItem(int index) {
    final list = List<Map<String, dynamic>>.from(_items);
    list.removeAt(index);
    setState(() {
      _payload['items'] = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isConfirmed =
        widget.draft.status == 'CONFIRMED' || widget.draft.status == 'EDITED';
    final isCancelled = widget.draft.status == 'CANCELLED';
    final items = _items;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAEAEA), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row: Badge status & Total amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isConfirmed) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7ED),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.check,
                        size: 14,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Đã lưu ${items.length} khoản',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (isCancelled) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F0EC),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Đã hủy',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF787774),
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F0EC),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.circle_dot,
                        size: 13,
                        color: Color(0xFF787774),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Nháp · chưa lưu',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF787774),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Text(
                '-${MoneyFormatter.format(_totalAmount)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111111),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Items list
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 16, color: Color(0xFFF0EFEC)),
            _buildItemRow(
              items[i],
              i,
              items.length,
              isEditable: !isConfirmed && !isCancelled,
            ),
          ],
          const SizedBox(height: 12),

          if (!isConfirmed && !isCancelled) ...[
            // Hint text
            const Row(
              children: [
                Icon(LucideIcons.info, size: 14, color: Color(0xFF787774)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Danh mục và ví đoán theo thói quen của bạn. Chạm một khoản để sửa.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF787774)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                TextButton(
                  onPressed: _isCancelling || _isConfirming
                      ? null
                      : () async {
                          setState(() => _isCancelling = true);
                          await widget.onCancel();
                          if (mounted) setState(() => _isCancelling = false);
                        },
                  child: _isCancelling
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Hủy',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF787774),
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    if (items.isNotEmpty) {
                      DraftItemEditSheet.show(
                        context,
                        item: items[0],
                        index: 0,
                        total: items.length,
                        onSave: (up) => _updateItem(0, up),
                        onRemove: () => _removeItem(0),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF111111),
                    side: const BorderSide(color: Color(0xFFEAEAEA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Sửa',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: _isConfirming || _isCancelling
                        ? null
                        : () async {
                            setState(() => _isConfirming = true);
                            await widget.onConfirm(_payload);
                            if (mounted) setState(() => _isConfirming = false);
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF111111),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: _isConfirming
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            items.length > 1
                                ? 'Xác nhận cả ${items.length}'
                                : 'Xác nhận',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ] else if (isConfirmed) ...[
            // Footer: Ghi lúc ... & Xem trong Lịch sử >
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.clock,
                      size: 14,
                      color: Color(0xFF787774),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ghi lúc ${DateFormat('HH:mm').format(VietnamTime.fromDateTime(widget.draft.resolvedAt ?? DateTime.now()))}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF787774),
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => context.push('/history'),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Xem trong Lịch sử',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                        ),
                      ),
                      Icon(LucideIcons.chevron_right, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemRow(
    Map<String, dynamic> item,
    int index,
    int total, {
    required bool isEditable,
  }) {
    final title = item['title'] as String? ?? 'Giao dịch';
    final amount = (item['amount'] as num?)?.round() ?? 0;
    final catName = item['categoryName'] as String?;
    final walletName = item['walletName'] as String?;
    final hasDup = item['possibleDuplicate'] != null;

    return InkWell(
      onTap: isEditable
          ? () {
              DraftItemEditSheet.show(
                context,
                item: item,
                index: index,
                total: total,
                onSave: (up) => _updateItem(index, up),
                onRemove: () => _removeItem(index),
              );
            }
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F2EE),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                LucideIcons.utensils,
                size: 18,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (catName != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F0EC),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            catName,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF787774),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (walletName != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F0EC),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            walletName,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF787774),
                            ),
                          ),
                        ),
                      ],
                      if (hasDup) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3CD),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Trùng lặp?',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '-${MoneyFormatter.format(amount)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111111),
              ),
            ),
            if (isEditable) ...[
              const SizedBox(width: 4),
              const Icon(
                LucideIcons.chevron_right,
                size: 16,
                color: Color(0xFFA9A8A3),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
