import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_flow_service.dart';

class LogoutSheet extends ConsumerStatefulWidget {
  const LogoutSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      // mở trên navigator gốc: không bị thanh menu dưới (shell) che
      useRootNavigator: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const LogoutSheet(),
    );
  }

  @override
  ConsumerState<LogoutSheet> createState() => _LogoutSheetState();
}

class _LogoutSheetState extends ConsumerState<LogoutSheet> {
  bool _isLoading = false;

  Future<void> _logoutSingle() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authFlowServiceProvider).logout();
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logoutAll() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authFlowServiceProvider).logoutAll();
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 32),
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
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Title
          Text(
            'Đăng xuất',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn muốn đăng xuất khỏi thiết bị này hay tất cả thiết bị đã đăng nhập?',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Option 1: Đăng xuất thiết bị này
          SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _logoutSingle,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                side: BorderSide(color: theme.colorScheme.outline),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.smartphone, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Đăng xuất thiết bị này',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Option 2: Đăng xuất mọi thiết bị
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _isLoading ? null : _logoutAll,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                backgroundColor: theme.colorScheme.primary,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.log_out, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Đăng xuất mọi thiết bị',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Option 3: Hủy
          SizedBox(
            height: 48,
            child: TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                foregroundColor: theme.colorScheme.onSurface,
              ),
              child: const Text(
                'Hủy',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
