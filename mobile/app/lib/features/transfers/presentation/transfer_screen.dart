import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/money_formatter.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/amount_keypad.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_icon_helper.dart';
import '../../wallets/application/wallets_service.dart';
import '../../wallets/data/wallet_models.dart';
import '../../wallets/presentation/wallet_picker_sheet.dart';
import '../application/transfer_service.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  late final TextEditingController _noteController;

  static const List<int> _quickAmounts = [100000, 200000, 500000, 1000000];

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transferProvider);
    final notifier = ref.read(transferProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    // Load wallets and auto-init source/target
    final walletsAsync = ref.watch(walletsProvider);
    walletsAsync.whenData((wallets) {
      if (state.fromWallet == null && wallets.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && state.fromWallet == null) {
            notifier.initWallets(wallets);
          }
        });
      }
    });

    final remainingBalance = state.fromWallet != null
        ? state.fromWallet!.balance - state.amount
        : 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Đóng',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(LucideIcons.x),
        ),
        title: const Text('Chuyển tiền giữa ví'),
        actions: const [SizedBox(width: 48)],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Top Card with From / To Wallets and Swap Button
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.screenPadding,
                      ),
                      child: AppCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              children: [
                                // Row Từ
                                _WalletSelectRow(
                                  label: 'Từ',
                                  wallet: state.fromWallet,
                                  onTap: () async {
                                    final picked = await WalletPickerSheet.show(
                                      context,
                                      selectedWalletId: state.fromWallet?.id,
                                    );
                                    if (picked != null) {
                                      notifier.setFromWallet(picked);
                                    }
                                  },
                                ),
                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                const SizedBox(height: 12),
                                // Row Đến
                                _WalletSelectRow(
                                  label: 'Đến',
                                  wallet: state.toWallet,
                                  onTap: () async {
                                    final picked = await WalletPickerSheet.show(
                                      context,
                                      selectedWalletId: state.toWallet?.id,
                                    );
                                    if (picked != null) {
                                      notifier.setToWallet(picked);
                                    }
                                  },
                                ),
                              ],
                            ),
                            // Swap button centered on divider
                            Positioned(
                              right: 48,
                              child: InkWell(
                                onTap: notifier.swapWallets,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: colors.outlineVariant.withAlpha(
                                        120,
                                      ),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x10111111),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    LucideIcons.arrow_up_down,
                                    size: 16,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                      state.fromWallet != null
                          ? 'Sau khi chuyển: ${state.fromWallet!.name} còn ${MoneyFormatter.format(remainingBalance)}'
                          : 'Chọn ví nguồn và ví đích',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: remainingBalance < 0
                            ? colors.error
                            : colors.onSurfaceVariant,
                        fontWeight: remainingBalance < 0
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Quick amount chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.screenPadding,
                      ),
                      child: Row(
                        children: _quickAmounts.map((amt) {
                          final isSelected = state.amount == amt;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => notifier.setAmount(amt),
                              borderRadius: BorderRadius.circular(
                                context.radius.pill,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF111111)
                                      : colors.surface,
                                  borderRadius: BorderRadius.circular(
                                    context.radius.pill,
                                  ),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF111111)
                                        : colors.outlineVariant.withAlpha(120),
                                  ),
                                ),
                                child: Text(
                                  MoneyFormatter.format(
                                    amt,
                                  ).replaceAll('đ', ''),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : colors.onSurface,
                                        fontFeatures:
                                            MoneyFormatter.tabularFeatures,
                                      ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Note Card
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.screenPadding,
                      ),
                      child: AppCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.square_pen,
                              size: 20,
                              color: colors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Ghi chú',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _noteController,
                                textAlign: TextAlign.right,
                                onChanged: notifier.setNote,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  hintText: 'Nạp ví MoMo',
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
                label: state.amount > 0
                    ? 'Chuyển ${MoneyFormatter.format(state.amount)}'
                    : 'Chuyển tiền',
                loading: state.isSaving,
                onPressed:
                    state.amount > 0 &&
                        state.fromWallet != null &&
                        state.toWallet != null &&
                        state.fromWallet!.id != state.toWallet!.id &&
                        state.fromWallet!.balance >= state.amount &&
                        !state.isSaving
                    ? () async {
                        final success = await notifier.submitTransfer();
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã chuyển tiền thành công'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          Navigator.of(context).pop();
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
}

class _WalletSelectRow extends StatelessWidget {
  const _WalletSelectRow({
    required this.label,
    required this.wallet,
    required this.onTap,
  });

  final String label;
  final WalletItem? wallet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF0EFEA),
              ),
              alignment: Alignment.center,
              child: Icon(
                AppIconHelper.fromName(wallet?.icon ?? 'wallet'),
                size: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    wallet?.name ?? 'Chọn ví',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (wallet != null) ...[
              Text(
                MoneyFormatter.format(wallet!.balance),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontFeatures: MoneyFormatter.tabularFeatures,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Icon(
              LucideIcons.chevron_down,
              size: 18,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
