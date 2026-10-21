import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/money_formatter.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/icon_bubble.dart';
import '../../wallets/application/wallets_service.dart';
import '../application/savings_service.dart';
import '../data/saving_models.dart';

class DepositSheet extends ConsumerStatefulWidget {
  const DepositSheet({super.key, required this.goal});

  final SavingGoalDetail goal;

  @override
  ConsumerState<DepositSheet> createState() => _DepositSheetState();
}

class _DepositSheetState extends ConsumerState<DepositSheet> {
  final _amountController = TextEditingController();
  String? _selectedWalletId;
  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final defaultAmount = widget.goal.remaining > 0
        ? (widget.goal.remaining >= 1000000 ? 1000000 : widget.goal.remaining)
        : 500000;
    _amountController.text = defaultAmount.toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int get _parsedAmount {
    return int.tryParse(_amountController.text.replaceAll(RegExp(r'\D'), '')) ??
        0;
  }

  void _setAmount(int amount) {
    setState(() {
      _amountController.text = amount.toString();
      _errorMessage = null;
    });
  }

  Future<void> _handleSubmit() async {
    final amount = _parsedAmount;
    if (amount <= 0) {
      setState(() => _errorMessage = 'Vui lòng nhập số tiền nạp hợp lệ');
      return;
    }

    if (_selectedWalletId == null) {
      setState(() => _errorMessage = 'Vui lòng chọn ví trích tiền');
      return;
    }

    final wallets = ref.read(walletsProvider).value ?? [];
    final wallet = wallets.where((w) => w.id == _selectedWalletId).firstOrNull;
    if (wallet != null && wallet.balance < amount) {
      setState(
        () => _errorMessage =
            'Số dư ví "${wallet.name}" không đủ (còn ${MoneyFormatter.format(wallet.balance)})',
      );
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    try {
      final notifier = ref.read(savingsProvider.notifier);
      await notifier.deposit(
        goalId: widget.goal.id,
        amount: amount,
        walletId: _selectedWalletId!,
      );
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã nạp ${MoneyFormatter.format(amount)} vào ${widget.goal.name}!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final walletsAsync = ref.watch(walletsProvider);
    final currentAmount = _parsedAmount;

    final quickAmounts = <int>{500000, 1000000};
    if (widget.goal.remaining > 0) {
      quickAmounts.add(widget.goal.remaining);
    }
    final sortedQuick = quickAmounts.toList()..sort();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.spacing.screenPadding,
        14,
        context.spacing.screenPadding,
        MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).viewPadding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Grabber
          Center(
            child: Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFDAD8D2),
                borderRadius: BorderRadius.circular(context.radius.pill),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Nạp vào ${widget.goal.name}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Amount Box (14-nap-tien-muc-tieu.png)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(context.radius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Số tiền',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 34,
                    letterSpacing: -0.03 * 34,
                    color: colors.onSurface,
                    fontFeatures: MoneyFormatter.tabularFeatures,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    suffixText: 'đ',
                    suffixStyle: Theme.of(context).textTheme.displaySmall
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 34,
                          color: colors.onSurface,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Quick Chips (500.000 · 1.000.000 · 1.800.000)
          Wrap(
            spacing: 8,
            children: sortedQuick.map((amt) {
              final isSelected = currentAmount == amt;
              return ChoiceChip(
                label: Text(MoneyFormatter.compact(amt).replaceAll('đ', '')),
                selected: isSelected,
                onSelected: (_) => _setAmount(amt),
                selectedColor: colors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? colors.onPrimary : colors.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.radius.pill),
                  side: BorderSide(
                    color: isSelected ? colors.primary : colors.outline,
                  ),
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Label: Từ ví
          Text(
            'Từ ví',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 6),

          // Wallets List
          walletsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const Text('Không thể tải danh sách ví'),
            data: (wallets) {
              if (wallets.isEmpty) {
                return const Text('Bạn chưa có ví nào.');
              }
              if (_selectedWalletId == null && wallets.isNotEmpty) {
                _selectedWalletId = wallets.first.id;
              }

              return Column(
                children: wallets.map((wallet) {
                  final isSelected = _selectedWalletId == wallet.id;
                  final previewBalance = (wallet.balance - currentAmount)
                      .clamp(0, double.infinity)
                      .toInt();

                  final subtitle = isSelected
                      ? '${MoneyFormatter.format(wallet.balance)} → ${MoneyFormatter.format(previewBalance)}'
                      : MoneyFormatter.format(wallet.balance);

                  return InkWell(
                    onTap: () => setState(() => _selectedWalletId = wallet.id),
                    borderRadius: BorderRadius.circular(context.radius.md),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          IconBubble(
                            icon: wallet.type == 'BANK'
                                ? LucideIcons.landmark
                                : (wallet.type == 'EWALLET'
                                      ? LucideIcons.smartphone
                                      : LucideIcons.banknote),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  wallet.name,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colors.onSurfaceVariant,
                                        fontFeatures:
                                            MoneyFormatter.tabularFeatures,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? colors.primary
                                    : colors.outline,
                                width: 2,
                              ),
                              color: isSelected ? colors.primary : null,
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: colors.onPrimary,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
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
            label: 'Nạp ${MoneyFormatter.format(currentAmount)}',
            loading: _isSubmitting,
            onPressed: _handleSubmit,
          ),
        ],
      ),
    );
  }
}
