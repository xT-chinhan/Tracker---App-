import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/icon_bubble.dart';
import '../../auth/application/app_session.dart';
import '../../notifications/application/balance_undo.dart';
import '../application/bank_notifications_controller.dart';
import '../data/bank_notification_bridge.dart';
import '../data/mock_bank_samples.dart';
import 'auto_record_sheets.dart';
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

  Future<void> _toggleAuto(bool on) async {
    if (!on) return _c.setAutoRecord(false);
    final ok = await AutoRecordConsentSheet.show(context);
    if (ok) await _c.setAutoRecord(true);
  }

  Future<void> _pickThreshold() async {
    final v = await showThresholdPicker(
      context,
      ref.read(bankNotificationsProvider).threshold,
    );
    if (v != null) await _c.setThreshold(v);
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(bankNotificationsProvider);
    final undone = ref.watch(undoneTransactionsProvider);
    final autoToday = todayAutoRecorded(st.autoRecorded, undone).length;
    // Ngân hàng có khoản chờ nhưng chưa ghép ví
    final unmapped = <String>{
      for (final t in st.pending)
        if (!st.walletMap.containsKey(t.bank) && _c.walletFor(t) == null)
          t.bank,
    };
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
                'Chỉ Android · bản cài đầy đủ',
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
                  const SizedBox(height: 12),
                  _AutoRecordCard(
                    on: st.autoRecord,
                    threshold: st.threshold,
                    onToggle: st.loaded ? _toggleAuto : null,
                    onThreshold: _pickThreshold,
                  ),
                  const SizedBox(height: 12),
                  _LinksCard(
                    autoCount: autoToday,
                    pendingCount: st.pending.length,
                  ),
                  if (st.walletMap.isNotEmpty || unmapped.isNotEmpty) ...[
                    const SizedBox(height: 24),
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
                          for (final bank in unmapped)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const IconBubble(
                                icon: LucideIcons.landmark,
                                size: 36,
                              ),
                              title: Text(bank),
                              onTap: () =>
                                  context.push('/bank-notifications/pending'),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.warningContainer,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: colors.warningBar),
                                ),
                                child: Text(
                                  'Chọn ví',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colors.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
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
                      'Chỉ giữ thông báo của ngân hàng, ví điện tử; thông báo khác bị bỏ qua. Nội dung thông báo chỉ nằm trên máy. Chỉ khoản bạn Xác nhận, hoặc khoản app tự ghi khi bạn bật Tự động ghi vào sổ, mới được lưu vào tài khoản; khoản tự ghi hoàn tác được. Tắt tính năng sẽ xóa mọi dữ liệu chờ.',
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

class _AutoRecordCard extends StatelessWidget {
  const _AutoRecordCard({
    required this.on,
    required this.threshold,
    required this.onToggle,
    required this.onThreshold,
  });

  final bool on;
  final int threshold;
  final ValueChanged<bool>? onToggle;
  final VoidCallback onThreshold;

  static const _rules = <(IconData, String)>[
    (
      LucideIcons.wallet,
      'Chỉ ghi khi biết ví và danh mục. Còn lại vẫn chờ bạn xác nhận.',
    ),
    (
      LucideIcons.copy_check,
      'Cùng một khoản báo qua app ngân hàng và SMS chỉ ghi 1 lần.',
    ),
    (LucideIcons.clock, 'Ghi khi app đang chạy hoặc lần mở tiếp theo.'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBubble(icon: LucideIcons.notebook_pen),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tự động ghi vào sổ',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      on ? 'Đang bật trên máy này' : 'Đang tắt',
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              Switch(value: on, onChanged: onToggle),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          for (final (icon, text) in _rules) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(icon, size: 16, color: muted),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: muted,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          if (on) ...[
            const Divider(height: 1),
            InkWell(
              onTap: onThreshold,
              child: Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Khoản lớn chờ xác nhận',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      thresholdLabel(threshold),
                      style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      LucideIcons.chevron_right,
                      size: 18,
                      color: Color(0xFFA9A8A3),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LinksCard extends StatelessWidget {
  const _LinksCard({required this.autoCount, required this.pendingCount});
  final int autoCount;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget row(IconData icon, String label, Widget trailing) => InkWell(
      onTap: () => context.push('/bank-notifications/pending'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            IconBubble(icon: icon, size: 36),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing,
            const SizedBox(width: 8),
            const Icon(
              LucideIcons.chevron_right,
              size: 18,
              color: Color(0xFFA9A8A3),
            ),
          ],
        ),
      ),
    );
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          row(
            LucideIcons.list_checks,
            'Xem các khoản đã tự ghi',
            Text(
              '$autoCount',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Divider(height: 1, indent: 50),
          row(
            LucideIcons.inbox,
            'Chờ xác nhận',
            pendingCount > 0
                ? Container(
                    constraints: const BoxConstraints(minWidth: 22),
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$pendingCount',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.surface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : Text(
                    '0',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
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
