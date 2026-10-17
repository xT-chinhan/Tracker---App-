import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/widgets/pressable.dart';
import 'plus_action_menu_sheet.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _selectBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: AppBottomBar(
        currentIndex: navigationShell.currentIndex,
        onSelect: _selectBranch,
        onCreate: () => context.push('/transactions/new'),
        onCreateLongPress: () => PlusActionMenuSheet.show(context),
      ),
    );
  }
}

class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    required this.currentIndex,
    required this.onSelect,
    required this.onCreate,
    required this.onCreateLongPress,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onCreate;
  final VoidCallback onCreateLongPress;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final barHeight = 52 + bottom;
    return SizedBox(
      height: barHeight + 18,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned.fill(
            top: 18,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.97),
                border: Border(
                  top: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottom,
            height: 52,
            child: Row(
              children: [
                _item(context, 0, LucideIcons.house, 'Trang chủ'),
                _item(context, 1, LucideIcons.clock_fading, 'Lịch sử'),
                const Spacer(),
                _item(context, 2, LucideIcons.chart_no_axes_column, 'Báo cáo'),
                _item(context, 3, LucideIcons.settings, 'Cài đặt'),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: Pressable(
              onTap: onCreate,
              onLongPress: onCreateLongPress,
              semanticLabel: 'Ghi giao dịch. Nhấn giữ để mở menu nhanh',
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 5,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                  boxShadow: context.shadows.raised,
                ),
                child: Icon(
                  LucideIcons.plus,
                  size: 28,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, int index, IconData icon, String label) {
    final selected = currentIndex == index;
    final color = selected
        ? Theme.of(context).colorScheme.onSurface
        : const Color(0xFF9C9A94);
    return Expanded(
      child: InkResponse(
        onTap: () => onSelect(index),
        radius: 30,
        child: Semantics(
          selected: selected,
          label: label,
          child: SizedBox(
            height: 52,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 23, color: color),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontSize: 10.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
