import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../categories/application/categories_service.dart';
import '../../../wallets/application/wallets_service.dart';
import '../../application/history_service.dart';

class HistoryFilterSheet extends ConsumerStatefulWidget {
  const HistoryFilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      // mở trên navigator gốc: không bị thanh menu dưới (shell) che
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const HistoryFilterSheet(),
    );
  }

  @override
  ConsumerState<HistoryFilterSheet> createState() => _HistoryFilterSheetState();
}

class _HistoryFilterSheetState extends ConsumerState<HistoryFilterSheet> {
  String? _selectedCategory;
  String? _selectedWallet;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(historyProvider).filter;
    _selectedCategory = filter.categoryId;
    _selectedWallet = filter.walletId;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final categoriesAsync = ref.watch(categoriesProvider(null));
    final walletsAsync = ref.watch(walletsProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bộ lọc giao dịch',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                        _selectedWallet = null;
                      });
                    },
                    child: Text(
                      'Đặt lại',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wallet Filter
                    Text(
                      'Ví',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    walletsAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (err, stack) =>
                          const Text('Không tải được danh sách ví'),
                      data: (wallets) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Tất cả ví'),
                            selected: _selectedWallet == null,
                            onSelected: (_) =>
                                setState(() => _selectedWallet = null),
                          ),
                          ...wallets.map(
                            (w) => ChoiceChip(
                              label: Text(w.name),
                              selected: _selectedWallet == w.id,
                              onSelected: (_) =>
                                  setState(() => _selectedWallet = w.id),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Category Filter
                    Text(
                      'Danh mục',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    categoriesAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (err, stack) =>
                          const Text('Không tải được danh mục'),
                      data: (categories) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Tất cả danh mục'),
                            selected: _selectedCategory == null,
                            onSelected: (_) =>
                                setState(() => _selectedCategory = null),
                          ),
                          ...categories.map(
                            (c) => ChoiceChip(
                              label: Text(c.name),
                              selected: _selectedCategory == c.id,
                              onSelected: (_) =>
                                  setState(() => _selectedCategory = c.id),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: AppButton(
                label: 'Áp dụng',
                onPressed: () {
                  final notifier = ref.read(historyProvider.notifier);
                  notifier.setCategoryFilter(_selectedCategory);
                  notifier.setWalletFilter(_selectedWallet);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
