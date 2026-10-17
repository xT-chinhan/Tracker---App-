import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/app_state_view.dart';
import '../application/app_session.dart';
import '../application/bootstrap_service.dart';

class UpdateRequiredScreen extends ConsumerWidget {
  const UpdateRequiredScreen({super.key});

  Future<void> _openStore(BuildContext context, String? rawUrl) async {
    final uri = rawUrl == null ? null : Uri.tryParse(rawUrl);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa thể mở cửa hàng ứng dụng.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    final platform = session.requiredUpdate;
    final notes = session.config?.mobile.releaseNotes;
    final detail = notes == null || notes.trim().isEmpty
        ? 'Phiên bản hiện tại không còn được hỗ trợ. Hãy cập nhật để tiếp tục sử dụng.'
        : 'Phiên bản hiện tại không còn được hỗ trợ.\n\n$notes';
    return Scaffold(
      body: SafeArea(
        child: AppStateView(
          icon: LucideIcons.download,
          title: 'Cần cập nhật ứng dụng',
          message: detail,
          actionLabel: 'Cập nhật ngay',
          onAction: () => _openStore(context, platform?.storeUrl),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: TextButton(
          onPressed: () async {
            try {
              await ref.read(bootstrapServiceProvider).start();
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chưa thể kiểm tra phiên bản mới.'),
                  ),
                );
              }
            }
          },
          child: const Text('Tôi đã cập nhật — kiểm tra lại'),
        ),
      ),
    );
  }
}
