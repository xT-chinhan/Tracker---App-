import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_state_view.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../application/bootstrap_service.dart';
import '../../../core/widgets/trackerx_logo.dart';

class BootstrapScreen extends ConsumerStatefulWidget {
  const BootstrapScreen({super.key});

  @override
  ConsumerState<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends ConsumerState<BootstrapScreen> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_start);
  }

  Future<void> _start() async {
    if (mounted) setState(() => _error = null);
    try {
      await ref.read(bootstrapServiceProvider).start();
    } catch (error, stackTrace) {
      debugPrint('[Bootstrap] Error: $error\n$stackTrace');
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _error == null
            ? const _BootstrapLoading()
            : AppStateView(
                title: 'Chưa thể kết nối',
                message: 'Vui lòng kiểm tra kết nối mạng rồi thử lại.',
                actionLabel: 'Thử lại',
                onAction: _start,
              ),
      ),
    );
  }
}

class _BootstrapLoading extends StatelessWidget {
  const _BootstrapLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TrackerXLogo(size: 64),
          const SizedBox(height: 28),
          const AppSkeleton(width: 180, height: 14),
          const SizedBox(height: 10),
          const AppSkeleton(width: 124, height: 10),
        ],
      ),
    );
  }
}
