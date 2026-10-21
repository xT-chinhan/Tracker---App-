import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/icon_bubble.dart';
import '../../auth/application/app_session.dart';
import '../application/bank_notifications_controller.dart';
import '../data/bank_notification_bridge.dart';
import '../data/mock_bank_samples.dart';
import 'bank_disclosure_sheet.dart';

/// Cài đặt › Ghi từ thông báo ngân hàng (chỉ Android).
class BankSettingsScreen extends ConsumerStatefulWidget {
  const BankSettingsScreen({super.key});

  @override
  ConsumerState<BankSettingsScreen> createState() => _BankSettingsScreenState();
}

class _BankSettingsScreenState extends ConsumerState<BankSettingsScreen>
    with WidgetsBindingObserver {
  BankNotificationsController get _c =>
      ref.read(bankNotificationsProvider.notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() async {
      await _c.sync();
      await _c.loadReferences();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Quay lại từ Cài đặt Android: đọc lại trạng thái quyền
  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) _c.sync();
  }

  Future<void> _toggle(bool on) async {
    if (!on) return _c.setEnabled(false);
    final st = ref.read(bankNotificationsProvider);
    if (!st.consent) {
      final ok = await BankDisclosureSheet.show(
        context,
        privacyUrl: ref.read(appSessionProvider).config?.privacyUrl,
      );
      if (!ok) return;
      await _c.giveConsent();
    }
    await _c.setEnabled(true);
    if (!ref.read(bankNotificationsProvider).permissionGranted) {
      await _c.openPermissionSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(bankNotificationsProvider);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final adminOn =
        ref.watch(appSessionProvider).config?.features.bankNotifications ??
        false;
    final available = bankNotificationsSupported && adminOn;
    final pad = context.spacing.screenPadding;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _c.sync();
            await _c.loadReferences();
          },
          child: ListView(
            padding: EdgeInsets.fromLTRB(pad, 4, pad, 32),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(LucideIcons.chevron_left, size: 20),
                  label: const Text('Cài đặt'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              Text(
                'Ghi từ thông báo ngân hàng',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Chỉ Android · mọi khoản đều chờ bạn xác nhận',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              if (!available)
                _Note(
                  icon: LucideIcons.info,
                  text: bankNotificationsSupported
                      ? 'Tính năng đang tạm tắt. Bạn vẫn ghi giao dịch thủ công bình thường.'
                      : !kBankNotificationsBuilt
                      ? 'Bản cài này không kèm tính năng ghi từ thông báo ngân hàng. Cần dùng thì cài bản đầy đủ của TrackerX.'
                      : 'Chỉ có trên Android. iOS không cho ứng dụng đọc thông báo của ứng dụng khác.',
                )
              else ...[
                AppCard(
                  child: Row(
                    children: [
                      const IconBubble(icon: LucideIcons.bell_ring),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bật tính năng',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              st.active
                                  ? 'Đang đọc thông báo ngân hàng, ví'
                                  : st.enabled
                                  ? 'Chưa cấp quyền Truy cập thông báo'
                                  : 'Đang tắt',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: st.enabled && !st.active
                                    ? colors.warning
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: st.enabled,
                        onChanged: st.loaded ? _toggle : null,
                      ),
                    ],
                  ),
                ),
                if (st.enabled) ...[
                  const SizedBox(height: 16),
                  _PendingRow(count: st.pending.length),
                  const SizedBox(height: 24),
                  _SectionTitle('Cấp quyền'),
                  _Step(
                    index: 1,
                    title: 'Bật quyền Truy cập thông báo',
                    body:
                        'Trong trang mở ra, chọn TrackerX và bật công tắc. Android sẽ hỏi lại, chọn Cho phép.',
                    done: st.permissionGranted,
                    action: st.permissionGranted ? null : 'Mở cài đặt',
                    onAction: _c.openPermissionSettings,
                  ),
                  _Step(
                    index: 2,
                    title: 'Nếu công tắc bị mờ (Android 13 trở lên)',
                    body:
                        'Mở Thông tin ứng dụng › chạm ⋮ góc trên › Cho phép cài đặt bị hạn chế, rồi làm lại bước 1. Thường gặp khi cài ứng dụng ngoài CH Play.',
                    done: st.permissionGranted,
                    action: st.permissionGranted
                        ? null
                        : 'Mở thông tin ứng dụng',
                    onAction: _c.openAppDetails,
                  ),
                  _Step(
                    index: 3,
                    title: 'Giữ chạy nền (khuyên dùng)',
                    body:
                        'Một số máy (Xiaomi, Oppo, Vivo, Samsung) tắt ứng dụng chạy nền để tiết kiệm pin. Chọn TrackerX › Không tối ưu hóa; với Xiaomi / Oppo bật thêm Tự khởi chạy.',
                    done: st.batteryUnrestricted,
                    action: st.batteryUnrestricted ? null : 'Mở cài đặt pin',
                    onAction: _c.openBatterySettings,
                  ),
                  if (st.walletMap.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SectionTitle('Ngân hàng đã ghép ví'),
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Column(
                        children: [
                          for (final e in st.walletMap.entries)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const IconBubble(
                                icon: LucideIcons.landmark,
                                size: 36,
                              ),
                              title: Text(e.key),
                              trailing: Text(
                                st.wallets
                                        .where((w) => w.id == e.value)
                                        .map((w) => w.name)
                                        .firstOrNull ??
                                    '—',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (kBankDemo) ...[
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Thử với thông báo mẫu',
                      icon: LucideIcons.flask_conical,
                      style: AppButtonStyle.secondary,
                      onPressed: () {
                        for (final n in MockBankSamples.bankSamples) {
                          _c.injectDemo(n);
                        }
                      },
                    ),
                  ],
                ],
                const SizedBox(height: 24),
                _SectionTitle('Dữ liệu của bạn'),
                const _Note(
                  icon: LucideIcons.shield_check,
                  text:
                      'Chỉ giữ thông báo của ngân hàng, ví điện tử; thông báo khác bị bỏ qua. Nội dung thông báo chỉ nằm trên máy. Chỉ khoản bạn Xác nhận mới được lưu vào tài khoản. Tắt tính năng sẽ xóa mọi dữ liệu chờ.',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

class _PendingRow extends StatelessWidget {
  const _PendingRow({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: () => context.push('/bank-notifications/pending'),
      child: Row(
        children: [
          const IconBubble(icon: LucideIcons.inbox),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              count > 0
                  ? '$count giao dịch chờ xác nhận'
                  : 'Chưa có giao dịch chờ xác nhận',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(
            LucideIcons.chevron_right,
            size: 18,
            color: Color(0xFFA9A8A3),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.index,
    required this.title,
    required this.body,
    required this.done,
    this.action,
    this.onAction,
  });

  final int index;
  final String title;
  final String body;
  final bool done;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: done
                        ? colors.successContainer
                        : theme.colorScheme.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: done
                      ? Icon(LucideIcons.check, size: 15, color: colors.income)
                      : Text(
                          '$index',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 12),
              AppButton(
                label: action!,
                style: AppButtonStyle.secondary,
                expand: false,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
