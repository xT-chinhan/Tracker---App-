import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/formatting/money_formatter.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/amount_keypad.dart';
import '../../../core/widgets/app_button.dart';

enum TransactionType { expense, income }

class TransactionEntryScreen extends StatefulWidget {
  const TransactionEntryScreen({required this.initialType, super.key});

  final TransactionType initialType;

  @override
  State<TransactionEntryScreen> createState() => _TransactionEntryScreenState();
}

class _TransactionEntryScreenState extends State<TransactionEntryScreen> {
  late TransactionType _type = widget.initialType;
  var _digits = '';

  int get _amount => int.tryParse(_digits) ?? 0;

  void _append(String value) {
    if (_digits.length >= 14) return;
    final candidate = '$_digits$value'.replaceFirst(RegExp(r'^0+'), '');
    setState(
      () => _digits = candidate.substring(0, candidate.length.clamp(0, 14)),
    );
  }

  void _delete() {
    if (_digits.isEmpty) return;
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Đóng',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(LucideIcons.x),
        ),
        title: const Text('Ghi giao dịch'),
        actions: const [SizedBox(width: 48)],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            context.spacing.screenPadding,
            8,
            context.spacing.screenPadding,
            12,
          ),
          child: Column(
            children: [
              _TypeSwitch(
                value: _type,
                onChanged: (value) => setState(() => _type = value),
              ),
              const Spacer(),
              Text(
                MoneyFormatter.format(_amount),
                maxLines: 1,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontFeatures: MoneyFormatter.tabularFeatures,
                  color: _type == TransactionType.income
                      ? context.appColors.income
                      : colors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                MoneyFormatter.inWords(_amount),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              AmountKeypad(onDigit: _append, onDelete: _delete),
              const SizedBox(height: 8),
              AppButton(
                label: _type == TransactionType.expense
                    ? 'Tiếp tục ghi khoản chi'
                    : 'Tiếp tục ghi thu nhập',
                onPressed: _amount > 0 ? () {} : null,
              ),
            ],
          ),
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
      height: 76,
      alignment: Alignment.center,
      child: Container(
        height: 40,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(context.radius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _item(context, TransactionType.expense, 'Khoản chi'),
            _item(context, TransactionType.income, 'Thu nhập'),
          ],
        ),
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
        width: 108,
        height: 34,
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
                    offset: Offset(0, 1),
                    blurRadius: 3,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
