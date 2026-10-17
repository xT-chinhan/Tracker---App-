import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/formatting/money_formatter.dart';
import '../../../core/theme/app_tokens.dart';
import '../../auth/application/app_session.dart';
import '../../categories/application/categories_service.dart';
import '../../categories/presentation/category_picker_sheet.dart';
import '../../home/application/home_service.dart';
import '../../notifications/application/notifications_service.dart';
import '../../quick_templates/data/quick_template_repository.dart';
import '../../recurring/application/recurring_service.dart';
import '../../reports/data/report_repository.dart';
import '../../savings/application/savings_service.dart';
import '../../transactions/presentation/transaction_entry_screen.dart';
import '../../wallets/application/wallets_service.dart';
import 'change_password_sheet.dart';
import 'delete_account_sheet.dart';
import 'edit_profile_sheet.dart';
import 'logout_dialog.dart';

final appVersionProvider = FutureProvider<String>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    return '${info.version} (${info.buildNumber})';
  } catch (_) {
    return '1.0.0 (42)';
  }
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'TC';
    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'TC';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    // E.g. Nguyễn Minh Anh -> MA or NA
    if (parts.length >= 3) {
      return (parts[parts.length - 2][0] + parts.last[0]).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Future<void> _handleExportCsv(BuildContext context, WidgetRef ref) async {
    try {
      final repo = ref.read(reportRepositoryProvider);
      final csv = await repo.exportCsv();
      await Clipboard.setData(ClipboardData(text: csv));
      if (context.mounted) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text('Xuất CSV thành công'),
            content: const Text(
              'Dữ liệu giao dịch đã được tải về và sao chép vào bộ nhớ tạm của bạn.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể xuất dữ liệu CSV. Vui lòng thử lại.'),
          ),
        );
      }
    }
  }

  Future<void> _launchUrlSafe(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>();
    final session = ref.watch(appSessionProvider);
    final user = session.user;
    final config = session.config;
    final features = config?.features;

    // Data for counters / labels
    final walletsAsync = ref.watch(walletsResponseProvider);
    final homeState = ref.watch(homeControllerProvider);
    final savingsState = ref.watch(savingsProvider);
    final recurringState = ref.watch(recurringProvider);
    final categoriesAsync = ref.watch(categoriesProvider(null));
    final quickTemplatesAsync = ref.watch(quickTemplatesProvider);
    final unreadNotifsCount = ref.watch(unreadCountProvider).value ?? 0;
    final versionAsync = ref.watch(appVersionProvider);

    final totalBalanceStr = walletsAsync.maybeWhen(
      data: (d) => MoneyFormatter.format(d.totalBalance),
      orElse: () => '',
    );

    final budgetPercentage = homeState.budgets?.overall?.percentage;
    final budgetStr = budgetPercentage != null
        ? 'Đã dùng ${budgetPercentage.toInt()}%'
        : '';

    final savingsCount = savingsState.goals.value?.length ?? 0;
    final recurringCount =
        recurringState.activeRules.length + recurringState.pausedRules.length;
    final categoriesCount = categoriesAsync.value?.length ?? 0;
    final quickTemplatesCount = quickTemplatesAsync.value?.length ?? 0;
    final appVersion = versionAsync.value ?? '1.0.0 (42)';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Page title: Cài đặt
            Padding(
              padding: const EdgeInsets.only(bottom: 20, top: 4),
              child: Text(
                'Cài đặt',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),

            // Profile Card (mockup 20)
            InkWell(
              onTap: () => EditProfileSheet.show(context),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: Row(
                  children: [
                    // Avatar circle with initials
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E232A),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _getInitials(user?.name ?? 'NA'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Name and email
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Người dùng',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user?.email ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Trailing "Sửa >"
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Sửa',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          LucideIcons.chevron_right,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Section: Quản lý tiền
            _buildSectionHeader('Quản lý tiền'),
            _buildGroupCard(
              children: [
                _buildSettingRow(
                  icon: LucideIcons.wallet,
                  title: 'Ví',
                  trailingText: totalBalanceStr,
                  onTap: () => context.push('/wallets'),
                ),
                const _RowDivider(),
                _buildSettingRow(
                  icon: LucideIcons.target,
                  title: 'Ngân sách',
                  trailingText: budgetStr,
                  onTap: () => context.push('/budgets'),
                ),
                if (features?.savingGoals ?? true) ...[
                  const _RowDivider(),
                  _buildSettingRow(
                    icon: LucideIcons.piggy_bank,
                    title: 'Mục tiêu tiết kiệm',
                    trailingText: savingsCount > 0
                        ? '$savingsCount mục tiêu'
                        : '',
                    onTap: () => context.push('/savings'),
                  ),
                ],
                if (features?.recurring ?? true) ...[
                  const _RowDivider(),
                  _buildSettingRow(
                    icon: LucideIcons.repeat,
                    title: 'Giao dịch định kỳ',
                    trailingText: recurringCount > 0 ? '$recurringCount' : '',
                    onTap: () => context.push('/recurring'),
                  ),
                ],
              ],
            ),

            // Section: Nhập liệu
            _buildSectionHeader('Nhập liệu'),
            _buildGroupCard(
              children: [
                _buildSettingRow(
                  icon: LucideIcons.shapes,
                  title: 'Danh mục',
                  trailingText: categoriesCount > 0 ? '$categoriesCount' : '',
                  onTap: () => CategoryPickerSheet.show(
                    context,
                    initialType: TransactionType.expense,
                  ),
                ),
                if (features?.quickTemplates ?? true) ...[
                  const _RowDivider(),
                  _buildSettingRow(
                    icon: LucideIcons.zap,
                    title: 'Mẫu nhập nhanh',
                    trailingText: quickTemplatesCount > 0
                        ? '$quickTemplatesCount'
                        : '',
                    onTap: () => context.push('/transactions/new'),
                  ),
                ],
              ],
            ),

            // Section: Ứng dụng
            _buildSectionHeader('Ứng dụng'),
            _buildGroupCard(
              children: [
                _buildSettingRow(
                  icon: LucideIcons.bell,
                  title: 'Thông báo',
                  badgeCount: unreadNotifsCount,
                  onTap: () => context.push('/notifications'),
                ),
                if (features?.csvExport ?? true) ...[
                  const _RowDivider(),
                  _buildSettingRow(
                    icon: LucideIcons.download,
                    title: 'Xuất dữ liệu CSV',
                    onTap: () => _handleExportCsv(context, ref),
                  ),
                ],
                const _RowDivider(),
                _buildSettingRow(
                  icon: LucideIcons.lock,
                  title: 'Đổi mật khẩu',
                  onTap: () => ChangePasswordSheet.show(context),
                ),
              ],
            ),

            // Standalone Logout Card
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: _buildSettingRow(
                icon: LucideIcons.log_out,
                title: 'Đăng xuất',
                onTap: () => LogoutSheet.show(context),
              ),
            ),

            // Red Delete Account Button
            const SizedBox(height: 28),
            Center(
              child: TextButton(
                onPressed: () => DeleteAccountSheet.show(context),
                style: TextButton.styleFrom(
                  foregroundColor: colors?.danger ?? const Color(0xFFDC2626),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  'Xóa tài khoản',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors?.danger ?? const Color(0xFFDC2626),
                  ),
                ),
              ),
            ),

            // App Version text
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Thu Chi · phiên bản $appVersion',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFA9A8A3),
                  fontSize: 13,
                ),
              ),
            ),

            // Legal & Support Links (only if configured)
            if (config?.termsUrl != null ||
                config?.privacyUrl != null ||
                config?.supportEmail != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (config?.supportEmail != null &&
                      config!.supportEmail!.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () =>
                          _launchUrlSafe('mailto:${config.supportEmail}'),
                      child: Text(
                        'Hỗ trợ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFA9A8A3),
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                  if (config?.termsUrl != null &&
                      config!.termsUrl!.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '·',
                        style: TextStyle(color: Color(0xFFA9A8A3)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _launchUrlSafe(config.termsUrl!),
                      child: Text(
                        'Điều khoản',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFA9A8A3),
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                  if (config?.privacyUrl != null &&
                      config!.privacyUrl!.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '·',
                        style: TextStyle(color: Color(0xFFA9A8A3)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _launchUrlSafe(config.privacyUrl!),
                      child: Text(
                        'Quyền riêng tư',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFA9A8A3),
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF787774),
        ),
      ),
    );
  }

  Widget _buildGroupCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    String? trailingText,
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon bubble
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F0EC),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF3A3935)),
            ),
            const SizedBox(width: 14),
            // Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111111),
                ),
              ),
            ),
            // Trailing text if any
            if (trailingText != null && trailingText.isNotEmpty) ...[
              Text(
                trailingText,
                style: const TextStyle(fontSize: 14, color: Color(0xFF787774)),
              ),
              const SizedBox(width: 6),
            ],
            // Trailing badge if > 0
            if (badgeCount > 0) ...[
              Container(
                height: 22,
                constraints: const BoxConstraints(minWidth: 22),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            // Chevron right
            const Icon(
              LucideIcons.chevron_right,
              size: 18,
              color: Color(0xFFA9A8A3),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 68,
      color: Color(0xFFF0EFEC),
    );
  }
}
