import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/icon_bubble.dart';

/// Thông báo rõ ràng về dữ liệu (Google Play User Data policy · prominent disclosure):
/// hiện TRƯỚC khi xin quyền Truy cập thông báo, người dùng phải bấm đồng ý.
/// Câu chữ khớp mobile/GOOGLE-PLAY.md — sửa chỗ này thì sửa cả tài liệu và mục An toàn dữ liệu trên Play Console.
class BankDisclosureSheet extends StatelessWidget {
  const BankDisclosureSheet({this.privacyUrl, super.key});

  final String? privacyUrl;

  /// `true` = người dùng đồng ý.
  static Future<bool> show(BuildContext context, {String? privacyUrl}) async =>
      await showModalBottomSheet<bool>(
      // mở trên navigator gốc: không bị thanh menu dưới (shell) che
      useRootNavigator: true,
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => BankDisclosureSheet(privacyUrl: privacyUrl),
      ) ??
      false;

  static const points = <(IconData, String)>[
    (
      LucideIcons.bell_ring,
      'TrackerX đọc thông báo biến động số dư từ app ngân hàng và ví điện tử trên máy này để gợi ý ghi thu chi cho bạn.',
    ),
    (
      LucideIcons.eye_off,
      'Thông báo của app khác (tin nhắn, mạng xã hội, email…) bị bỏ qua ngay, không được lưu hay gửi đi.',
    ),
    (
      LucideIcons.smartphone,
      'Nội dung thông báo chỉ nằm trên máy. Chỉ khoản bạn bấm Xác nhận mới được lưu vào tài khoản TrackerX của bạn: số tiền, danh mục, ví, thời gian và mô tả.',
    ),
    (
      LucideIcons.toggle_left,
      'Tắt bất cứ lúc nào trong Cài đặt › Ghi từ thông báo ngân hàng, hoặc thu hồi quyền trong Cài đặt Android.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
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
          const IconBubble(icon: LucideIcons.bell_ring, size: 56),
          const SizedBox(height: 16),
          Text(
            'Cho phép TrackerX đọc thông báo ngân hàng?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          for (final (icon, text) in points) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(icon, size: 18, color: muted),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (privacyUrl != null && privacyUrl!.isNotEmpty)
            TextButton(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: () => launchUrl(
                Uri.parse(privacyUrl!),
                mode: LaunchMode.externalApplication,
              ),
              child: const Text('Xem chính sách quyền riêng tư'),
            ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Đồng ý và tiếp tục',
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Không, cảm ơn',
            style: AppButtonStyle.secondary,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
