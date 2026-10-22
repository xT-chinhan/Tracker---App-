import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/formatting/money_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/icon_bubble.dart';
import '../application/bank_mapping.dart';

/// Sheet đồng ý riêng khi bật Tự động ghi vào sổ (mockup 60-tb-05). `true` = Bật tự động ghi.
class AutoRecordConsentSheet extends StatelessWidget {
  const AutoRecordConsentSheet({super.key});

  static Future<bool> show(BuildContext context) async =>
      await showModalBottomSheet<bool>(
        useRootNavigator: true,
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => const AutoRecordConsentSheet(),
      ) ??
      false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final style = theme.textTheme.bodyMedium?.copyWith(height: 1.45);
    final points = <(IconData, InlineSpan)>[
      (
        LucideIcons.zap,
        const TextSpan(
          text:
              'Khoản biết rõ ví và danh mục được lưu ngay vào tài khoản, như khi bạn bấm Xác nhận.',
        ),
      ),
      (
        LucideIcons.bell,
        const TextSpan(
          children: [
            TextSpan(text: 'Mỗi khoản tự ghi có thông báo '),
            TextSpan(
              text: 'Biến động số dư',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: ' kèm nút Hoàn tác.'),
          ],
        ),
      ),
      (
        LucideIcons.inbox,
        const TextSpan(
          text: 'Khoản chưa rõ ví hoặc danh mục vẫn nằm trong Chờ xác nhận.',
        ),
      ),
      (
        LucideIcons.clock,
        const TextSpan(
          text:
              'App ghi khi đang chạy hoặc lần mở tiếp theo, không ghi khi app đã tắt hẳn.',
        ),
      ),
      (
        LucideIcons.toggle_left,
        const TextSpan(text: 'Chỉ trên máy này, tắt lúc nào cũng được.'),
      ),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const IconBubble(icon: LucideIcons.notebook_pen, size: 56),
          const SizedBox(height: 16),
          Text(
            'Bật tự động ghi vào sổ?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          for (final (icon, span) in points) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(icon, size: 18, color: muted),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text.rich(span, style: style)),
              ],
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),
          AppButton(
            label: 'Bật tự động ghi',
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Để sau',
            style: AppButtonStyle.secondary,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}

String thresholdLabel(int value) =>
    value <= 0 ? 'Tắt' : 'Từ ${MoneyFormatter.format(value)}';

/// Chọn ngưỡng "Khoản lớn chờ xác nhận".
Future<int?> showThresholdPicker(
  BuildContext context,
  int current,
) => showModalBottomSheet<int>(
  useRootNavigator: true,
  context: context,
  showDragHandle: true,
  builder: (context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Khoản lớn chờ xác nhận',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
            child: Text(
              'Khoản từ mức này trở lên không tự ghi, vẫn chờ bạn bấm Xác nhận.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          for (final v in autoRecordThresholds)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: Text(v <= 0 ? 'Tắt' : MoneyFormatter.format(v)),
              trailing: v == current
                  ? const Icon(LucideIcons.check, size: 18)
                  : null,
              onTap: () => Navigator.of(context).pop(v),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  },
);
