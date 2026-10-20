import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/vietnam_time.dart';
import '../../../core/widgets/app_state_view.dart';
import '../application/app_session.dart';
import '../application/bootstrap_service.dart';

class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> {
  var _loading = false;

  Future<void> _retry() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await ref.read(bootstrapServiceProvider).start();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chưa thể kiểm tra trạng thái hệ thống.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maintenance = ref.watch(appSessionProvider).config?.maintenance;
    final end = maintenance?.endsAt;
    final endLabel = end == null
        ? ''
        : '\nDự kiến hoàn tất: ${VietnamTime.dateTime(end)}.';
    return Scaffold(
      body: SafeArea(
        child: AppStateView(
          icon: LucideIcons.construction,
          title: 'Hệ thống đang bảo trì',
          message:
              '${maintenance?.message ?? 'Chúng tôi đang nâng cấp để phục vụ bạn tốt hơn.'}$endLabel',
          actionLabel: _loading ? 'Đang kiểm tra…' : 'Kiểm tra lại',
          onAction: _loading ? null : _retry,
        ),
      ),
    );
  }
}
