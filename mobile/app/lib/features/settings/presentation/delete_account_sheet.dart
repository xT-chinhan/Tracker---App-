import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_tokens.dart';
import '../../auth/application/auth_flow_service.dart';
import '../../reports/data/report_repository.dart';
import '../../savings/application/savings_service.dart';
import '../../wallets/application/wallets_service.dart';

class DeleteAccountSheet extends ConsumerStatefulWidget {
  const DeleteAccountSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DeleteAccountSheet(),
    );
  }

  @override
  ConsumerState<DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends ConsumerState<DeleteAccountSheet> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  bool _isExporting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleExportCsv() async {
    setState(() => _isExporting = true);
    try {
      final repo = ref.read(reportRepositoryProvider);
      final csv = await repo.exportCsv();
      await Clipboard.setData(ClipboardData(text: csv));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Đã xuất dữ liệu CSV thành công và sao chép vào bộ nhớ tạm.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể xuất dữ liệu CSV. Vui lòng thử lại.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _handleDelete() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập mật khẩu để xác nhận');
      return;
    }

    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authFlowServiceProvider).deleteAccount(password);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isSubmitting = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Không thể xóa tài khoản. Vui lòng kiểm tra lại mật khẩu.';
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>();
    final mediaQuery = MediaQuery.of(context);

    final walletsCount =
        ref.watch(walletsResponseProvider).value?.items.length ?? 4;
    final goalsCount = ref.watch(savingsProvider).goals.value?.length ?? 0;

    // Subtitle format matching mockup 21:
    // "4 ví, 312 giao dịch, ngân sách và 3 mục tiêu tiết kiệm sẽ bị xóa vĩnh viễn, không thể khôi phục."
    final subtitleText =
        '$walletsCount ví, toàn bộ giao dịch, ngân sách và ${goalsCount > 0 ? '$goalsCount mục tiêu' : 'mục tiêu'} tiết kiệm sẽ bị xóa vĩnh viễn, không thể khôi phục.';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: mediaQuery.viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
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
            const SizedBox(height: 20),

            // Red trash bubble
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors?.dangerContainer ?? const Color(0xFFFDE8E8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.trash,
                  size: 26,
                  color: colors?.danger ?? const Color(0xFFE03131),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Xóa tài khoản?',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              subtitleText,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6B7280),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),

            // Box "Muốn giữ lại dữ liệu? Xuất CSV"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.download,
                    size: 18,
                    color: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Muốn giữ lại dữ liệu?',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _isExporting ? null : _handleExportCsv,
                    child: Text(
                      _isExporting ? 'Đang xuất...' : 'Xuất CSV',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Error banner
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colors?.dangerContainer ?? const Color(0xFFFDEBEC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.circle_alert,
                      size: 16,
                      color: colors?.danger ?? const Color(0xFFB3261E),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors?.danger ?? const Color(0xFFB3261E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Label
            Text(
              'Nhập mật khẩu để xác nhận',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // Password Field
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(LucideIcons.lock, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? LucideIcons.eye_off : LucideIcons.eye,
                    size: 18,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Danger button: Xóa vĩnh viễn
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _isSubmitting || _passwordController.text.isEmpty
                    ? null
                    : _handleDelete,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  backgroundColor:
                      colors?.dangerContainer ?? const Color(0xFFFEE2E2),
                  foregroundColor: colors?.danger ?? const Color(0xFFDC2626),
                  disabledBackgroundColor: const Color(0xFFF3F4F6),
                  disabledForegroundColor: const Color(0xFF9CA3AF),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors?.danger ?? const Color(0xFFDC2626),
                        ),
                      )
                    : Text(
                        'Xóa vĩnh viễn',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _passwordController.text.isEmpty
                              ? const Color(0xFF9CA3AF)
                              : (colors?.danger ?? const Color(0xFFDC2626)),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),

            // Text button: Hủy
            SizedBox(
              height: 48,
              child: TextButton(
                onPressed: _isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  foregroundColor: theme.colorScheme.onSurface,
                ),
                child: const Text(
                  'Hủy',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
