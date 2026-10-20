import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/network_providers.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../auth/application/app_session.dart';
import '../auth/data/auth_repository.dart';
import '../auth/presentation/auth_scaffold.dart';

/*
 * Số điện thoại (mockup 50-sdt-*): người dùng tự gửi 1 tin chứa 6 số xác nhận từ SIM của mình tới máy cổng,
 * Thu Chi không nhắn tin. Luồng xác nhận KHÔNG hiện số điện thoại nào (kể cả số máy cổng, lấy từ smsLink chỉ để gửi).
 * Android (APK, không qua Google Play): app tự gửi bằng SmsManager (quyền SEND_SMS), máy 2 SIM thì hỏi SIM.
 * iOS / từ chối quyền / web: mở ứng dụng Tin nhắn soạn sẵn (smsLink).
 */

const _ink = Color(0xFF111111);
const _chipBg = Color(0xFFF3F2EE);
const _cardLine = Color(0xFFE6E5E0);
const _noteText = Color(0xFF55544F);

const _takenMessage = 'Số này đã được dùng cho tài khoản khác. Gỡ số ở tài khoản kia trước, hoặc dùng số khác.';

/// 0912345678 → "0912 ••• 678" (chỉ dùng ở dòng Cài đặt).
String maskPhone(String phone) {
  final d = phone.replaceAll(RegExp(r'\D'), '');
  if (d.length < 7) return phone;
  return '${d.substring(0, 4)} ••• ${d.substring(d.length - 3)}';
}

/// `sms:<số>?body=<mã>` (Android) / `sms:<số>&body=<mã>` (iOS) → số người nhận, chỉ để gửi, không hiển thị.
String smsDestination(String link) {
  final rest = link.startsWith('sms:') ? link.substring(4) : link;
  return Uri.decodeComponent(rest.split(RegExp(r'[?&]')).first);
}

bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
bool get _isIos => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

/* ============================== Dữ liệu ============================== */

/// Phiên xác nhận vừa xin: mã 6 số + link mở khung soạn tin. Trường `phone` của API cố ý không giữ.
class PhoneSession {
  const PhoneSession({required this.verificationId, required this.code, required this.deadline, required this.androidLink, required this.iosLink});

  final String verificationId;
  final String code;

  /// Hạn theo đồng hồ máy (giờ nhận + số phút cấu hình) để không lệch giờ với máy chủ.
  final DateTime deadline;
  final String androidLink;
  final String iosLink;

  factory PhoneSession.fromJson(Map<String, dynamic> json, {int? codeMinutes}) {
    final link = Map<String, dynamic>.from((json['smsLink'] as Map?) ?? const {});
    final expiresAt = DateTime.tryParse('${json['expiresAt']}');
    return PhoneSession(
      verificationId: json['verificationId'] as String,
      code: '${json['code']}',
      deadline: codeMinutes != null
          ? DateTime.now().add(Duration(minutes: codeMinutes))
          : (expiresAt?.toLocal() ?? DateTime.now().add(const Duration(minutes: 5))),
      androidLink: '${link['android'] ?? ''}',
      iosLink: '${link['ios'] ?? ''}',
    );
  }
}

enum PhoneStatus { pending, verified, expired, failed }

class PhoneRepository {
  const PhoneRepository(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> startLink({required String phone, required String password}) async =>
      (await _request(() => _dio.post<Map<String, dynamic>>('me/phone/verifications', data: {'phone': phone.trim(), 'password': password}))).data!;

  Future<PhoneStatus> linkStatus(String id) => _status('me/phone/verifications/$id');

  Future<void> removePhone(String password) => _request(() => _dio.delete<void>('me/phone', data: {'password': password}));

  Future<Map<String, dynamic>> startReset(String phone) async =>
      (await _request(() => _dio.post<Map<String, dynamic>>('auth/forgot-password/phone', data: {'phone': phone.trim()}))).data!;

  Future<PhoneStatus> resetStatus(String id) => _status('auth/forgot-password/phone/$id');

  Future<void> resetPassword({required String verificationId, required String newPassword}) =>
      _request(() => _dio.post<void>('auth/reset-password/phone', data: {'verificationId': verificationId, 'newPassword': newPassword}));

  Future<PhoneStatus> _status(String path) async {
    final res = await _request(() => _dio.get<Map<String, dynamic>>(path));
    return switch (res.data?['status']) {
      'VERIFIED' => PhoneStatus.verified,
      'EXPIRED' => PhoneStatus.expired,
      'FAILED' || 'USED' => PhoneStatus.failed,
      _ => PhoneStatus.pending,
    };
  }

  Future<Response<T>> _request<T>(Future<Response<T>> Function() run) async {
    try {
      return await run();
    } on DioException catch (error) {
      throw error.error is ApiException ? error.error! as ApiException : ApiException.fromDio(error);
    }
  }
}

final phoneRepositoryProvider = Provider<PhoneRepository>((ref) => PhoneRepository(ref.watch(dioProvider)));

/* ============================== Cầu nối Android (SmsChannel.kt) ============================== */

class SimInfo {
  const SimInfo({required this.subscriptionId, required this.slot, this.carrierName});
  final int subscriptionId;
  final int slot;
  final String? carrierName;

  /// "SIM 1 · Viettel": khe + tên nhà mạng, không có số.
  String get label => carrierName == null || carrierName!.isEmpty ? 'SIM $slot' : 'SIM $slot · $carrierName';
}

class SmsBridge {
  const SmsBridge();

  static const _methods = MethodChannel('vn.thuchi.app/sms/methods');

  Future<T?> _call<T>(String method, [Object? args]) async {
    try {
      return await _methods.invokeMethod<T>(method, args);
    } on PlatformException catch (e) {
      debugPrint('SmsBridge.$method: ${e.message}');
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<bool> hasPermission() async => await _call<bool>('hasPermission') ?? false;

  /// Hộp quyền hệ thống (SEND_SMS + READ_PHONE_STATE). true = được gửi SMS.
  Future<bool> requestPermission() async => await _call<bool>('requestPermission') ?? false;

  Future<List<SimInfo>> listSims() async {
    final raw = await _call<List<Object?>>('listSims') ?? const [];
    return [
      for (final e in raw.whereType<Map<Object?, Object?>>())
        SimInfo(subscriptionId: (e['subscriptionId'] as num).toInt(), slot: (e['slot'] as num?)?.toInt() ?? 1, carrierName: e['carrierName'] as String?),
    ];
  }

  /// [subscriptionId] null = SIM mặc định của máy.
  Future<bool> sendSms({int? subscriptionId, required String destination, required String body}) async =>
      await _call<bool>('sendSms', {'subscriptionId': subscriptionId, 'destination': destination, 'body': body}) ?? false;

  Future<void> openAppSettings() async => _call<bool>('openAppSettings');
}

/* ============================== Khung màn chung ============================== */

class _FlowScaffold extends StatelessWidget {
  const _FlowScaffold({required this.back, this.onBack, this.top, required this.title, this.subtitle, required this.children, this.bottom});
  final String? back;
  final VoidCallback? onBack;
  final Widget? top;
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final List<Widget>? bottom;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: back == null
          ? null
          : AppBar(
              leadingWidth: 160,
              leading: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  style: TextButton.styleFrom(padding: const EdgeInsets.only(left: 8, right: 12)),
                  icon: const Icon(LucideIcons.chevron_left, color: _ink),
                  label: Text(back!, maxLines: 1, softWrap: false, style: text.bodyLarge?.copyWith(color: _ink, fontSize: 16)),
                ),
              ),
            ),
      body: SafeArea(
        top: back == null,
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight - 28),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (top != null) ...[top!, const SizedBox(height: 22)],
                    Text(title, style: text.headlineLarge),
                    if (subtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(subtitle!, style: text.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w400)),
                    ],
                    const SizedBox(height: 24),
                    ...children,
                    if (bottom != null) ...[const Spacer(), const SizedBox(height: 24), ...bottom!],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.child});
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _chipBg, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 1), child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(width: 12),
          Expanded(child: DefaultTextStyle.merge(style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _noteText), child: child)),
        ],
      ),
    );
  }
}

class _IconDot extends StatelessWidget {
  const _IconDot({required this.icon, this.size = 44});
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: _chipBg),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.45, color: const Color(0xFF3A3935)),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final danger = context.appColors.danger;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 2), child: Icon(LucideIcons.circle_alert, size: 16, color: danger)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: danger))),
        ],
      ),
    );
  }
}

/* ============================== 02 · Nhập số (gắn số / quên mật khẩu) ============================== */

enum PhoneFlow { link, reset }

enum _Outcome { linked, taken }

class PhoneNumberScreen extends ConsumerStatefulWidget {
  const PhoneNumberScreen({this.flow = PhoneFlow.link, super.key});
  final PhoneFlow flow;

  /// Gắn số từ Cài đặt: phủ lên tab bar.
  static Future<void> open(BuildContext context, {PhoneFlow flow = PhoneFlow.link}) =>
      Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(builder: (_) => PhoneNumberScreen(flow: flow)));

  @override
  ConsumerState<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends ConsumerState<PhoneNumberScreen> {
  final _phone = TextEditingController();
  final _password = TextEditingController();
  var _loading = false;
  String? _phoneError;
  String? _error;

  bool get _link => widget.flow == PhoneFlow.link;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  int? get _codeMinutes => ref.read(appSessionProvider).config?.phoneOtp.codeMinutes;

  /// Xin phiên mới (dùng cả cho "Lấy mã mới" ở màn xác nhận).
  Future<PhoneSession> _start() async {
    final repo = ref.read(phoneRepositoryProvider);
    final json = _link ? await repo.startLink(phone: _phone.text, password: _password.text) : await repo.startReset(_phone.text);
    return PhoneSession.fromJson(json, codeMinutes: _codeMinutes);
  }

  Future<void> _submit() async {
    if (_loading) return;
    final phoneEmpty = _phone.text.trim().isEmpty;
    final passEmpty = _link && _password.text.isEmpty;
    if (phoneEmpty || passEmpty) {
      setState(() {
        _phoneError = phoneEmpty ? 'Vui lòng nhập số điện thoại' : null;
        _error = !phoneEmpty && passEmpty ? 'Vui lòng nhập mật khẩu hiện tại' : null;
      });
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _phoneError = null;
      _error = null;
    });
    try {
      final session = await _start();
      if (!mounted) return;
      setState(() => _loading = false);
      final outcome = await Navigator.of(context).push<_Outcome>(
        MaterialPageRoute(builder: (_) => PhoneConfirmScreen(flow: widget.flow, session: session, restart: _start)),
      );
      if (!mounted) return;
      if (outcome == _Outcome.linked) {
        Navigator.of(context).pop();
      } else if (outcome == _Outcome.taken) {
        setState(() => _phoneError = _takenMessage);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (e.code == 'PHONE_TAKEN') {
          _phoneError = _takenMessage;
        } else if (e.code == 'PHONE_ALREADY_LINKED' || (e.statusCode == 400 && e.message.startsWith('Số điện thoại'))) {
          _phoneError = e.message;
        } else {
          _error = e.message;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final text = Theme.of(context).textTheme;
    return _FlowScaffold(
      back: _link ? 'Cài đặt' : 'Quên mật khẩu',
      title: _link ? 'Gắn số điện thoại' : 'Qua số điện thoại',
      subtitle: _link ? 'Dùng để lấy lại mật khẩu khi quên. Mỗi tài khoản gắn một số.' : 'Nhập số điện thoại đã gắn với tài khoản của bạn.',
      bottom: [AppButton(label: 'Tiếp tục', onPressed: _submit, loading: _loading)],
      children: [
        Text('Số điện thoại', style: text.labelMedium?.copyWith(color: muted)),
        const SizedBox(height: 8),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          textInputAction: _link ? TextInputAction.next : TextInputAction.done,
          autofillHints: const [AutofillHints.telephoneNumber],
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ .\-]')), LengthLimitingTextInputFormatter(20)],
          style: text.bodyLarge?.copyWith(fontSize: 16, letterSpacing: 0.5),
          onChanged: (_) {
            if (_phoneError != null) setState(() => _phoneError = null);
          },
          onSubmitted: _link ? null : (_) => _submit(),
          decoration: InputDecoration(
            hintText: '0912 345 678',
            prefixIcon: Icon(LucideIcons.smartphone, size: 20, color: muted),
            enabledBorder: _phoneError == null ? null : _errorBorder(context),
            focusedBorder: _phoneError == null ? null : _errorBorder(context, 1.4),
          ),
        ),
        if (_phoneError != null) _InlineError(_phoneError!),
        if (_link) ...[
          const SizedBox(height: 20),
          AuthField(
            controller: _password,
            label: 'Mật khẩu hiện tại',
            icon: LucideIcons.lock_keyhole,
            obscureText: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => _submit(),
          ),
        ],
        if (_error != null) _InlineError(_error!),
        const SizedBox(height: 24),
        _Note(
          icon: LucideIcons.message_square,
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Bước sau, bạn '),
                const TextSpan(text: 'gửi yêu cầu xác nhận từ số của bạn', style: TextStyle(fontWeight: FontWeight.w700, color: _ink)),
                TextSpan(text: ' bằng 1 tin nhắn, phí như tin nhắn thường của nhà mạng.${_link ? ' Thu Chi không bao giờ nhắn tin hay gọi cho bạn.' : ''}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _errorBorder(BuildContext context, [double width = 1]) =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: context.appColors.dangerBar, width: width));
}

/* ============================== 03–06, 10–13 · Gửi yêu cầu xác nhận ============================== */

enum _Step { ready, waiting, expired, done }

class PhoneConfirmScreen extends ConsumerStatefulWidget {
  const PhoneConfirmScreen({required this.flow, required this.session, required this.restart, this.bridge = const SmsBridge(), super.key});
  final PhoneFlow flow;
  final PhoneSession session;

  /// Xin mã mới với cùng số (và mật khẩu khi gắn số).
  final Future<PhoneSession> Function() restart;
  final SmsBridge bridge;

  @override
  ConsumerState<PhoneConfirmScreen> createState() => _PhoneConfirmScreenState();
}

class _PhoneConfirmScreenState extends ConsumerState<PhoneConfirmScreen> with WidgetsBindingObserver {
  late PhoneSession _session = widget.session;
  _Step _step = _Step.ready;
  Timer? _tick;
  Timer? _poll;
  bool _polling = false;
  bool _sending = false;
  bool _restarting = false;
  String? _restartError;

  /// Android: đang hiện hộp quyền hệ thống (thẻ lý do của app phía trên, mockup 10).
  bool _asking = false;

  /// Android: người dùng từ chối quyền gửi SMS → mở Tin nhắn soạn sẵn (mockup 13).
  bool _denied = false;

  /// Đã tự gửi (Android) hay mở Tin nhắn; tên SIM đã gửi (mockup 12).
  bool _nativeSent = false;
  String? _sentFrom;
  DateTime? _sentAt;

  bool get _link => widget.flow == PhoneFlow.link;
  bool get _native => _isAndroid && !_denied;
  Duration get _left {
    final d = _session.deadline.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_left == Duration.zero && (_step == _Step.ready || _step == _Step.waiting)) {
        setState(() => _step = _Step.expired);
      } else {
        setState(() {});
      }
    });
    // máy chủ quyết khi nào xong: hỏi mỗi 2 giây cho tới khi xác nhận / hết hạn
    _poll = Timer.periodic(const Duration(seconds: 2), (_) => _check());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    _poll?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _check();
    // quay lại từ Cài đặt sau khi cấp quyền → về cách tự gửi
    if (_denied && _isAndroid) {
      widget.bridge.hasPermission().then((ok) {
        if (ok && mounted) setState(() => _denied = false);
      });
    }
  }

  Future<void> _check() async {
    if (_polling || _step == _Step.done || _step == _Step.expired) return;
    _polling = true;
    final id = _session.verificationId;
    try {
      final repo = ref.read(phoneRepositoryProvider);
      final status = _link ? await repo.linkStatus(id) : await repo.resetStatus(id);
      if (!mounted || id != _session.verificationId) return;
      switch (status) {
        case PhoneStatus.verified:
          await _verified();
        case PhoneStatus.expired:
          setState(() => _step = _Step.expired);
        case PhoneStatus.failed:
          // gắn số: số vừa bị tài khoản khác gắn (06b) · quên mật khẩu: phiên bị thay → như hết hạn
          if (_link) {
            Navigator.of(context).pop(_Outcome.taken);
          } else {
            setState(() => _step = _Step.expired);
          }
        case PhoneStatus.pending:
          break;
      }
    } catch (_) {
      // mất mạng tạm thời: lần hỏi sau thử lại
    } finally {
      _polling = false;
    }
  }

  Future<void> _verified() async {
    _poll?.cancel();
    if (_link) {
      setState(() => _step = _Step.done);
      try {
        final user = await ref.read(authRepositoryProvider).me();
        ref.read(appSessionProvider).updateUser(user);
      } catch (_) {}
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => PhoneResetPasswordScreen(verificationId: _session.verificationId)),
      );
    }
  }

  void _snack(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  /// "Gửi yêu cầu xác nhận" / "Gửi lại yêu cầu": Android tự gửi, còn lại mở Tin nhắn soạn sẵn.
  Future<void> _send() async {
    if (_sending) return;
    if (!_native) return _openComposer();
    final bridge = widget.bridge;
    if (!await bridge.hasPermission()) {
      setState(() => _asking = true);
      final ok = await bridge.requestPermission();
      if (!mounted) return;
      setState(() {
        _asking = false;
        if (!ok) _denied = true;
      });
      if (!ok) return;
    }
    final sims = await bridge.listSims();
    if (!mounted) return;
    SimInfo? sim = sims.length == 1 ? sims.first : null;
    if (sims.length >= 2) {
      sim = await SimPickerSheet.show(context, sims);
      if (sim == null || !mounted) return;
    }
    setState(() => _sending = true);
    final ok = await bridge.sendSms(subscriptionId: sim?.subscriptionId, destination: smsDestination(_session.androidLink), body: _session.code);
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (ok) {
        _step = _Step.waiting;
        _nativeSent = true;
        _sentFrom = sim?.label;
        _sentAt = DateTime.now();
      }
    });
    if (!ok) _snack('Chưa gửi được tin nhắn. Kiểm tra SIM còn tiền, có sóng rồi thử lại.');
    _check();
  }

  Future<void> _openComposer() async {
    final link = _isIos ? _session.iosLink : _session.androidLink;
    var ok = false;
    try {
      ok = await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!mounted) return;
    if (!ok) {
      _snack('Không mở được ứng dụng Tin nhắn trên máy này.');
      return;
    }
    setState(() {
      _step = _Step.waiting;
      _nativeSent = false;
      _sentAt = DateTime.now();
    });
  }

  Future<void> _newCode() async {
    if (_restarting) return;
    setState(() {
      _restarting = true;
      _restartError = null;
    });
    try {
      final next = await widget.restart();
      if (!mounted) return;
      setState(() {
        _session = next;
        _step = _Step.ready;
        _restarting = false;
        _nativeSent = false;
        _sentFrom = null;
        _sentAt = null;
      });
      _poll?.cancel();
      _poll = Timer.periodic(const Duration(seconds: 2), (_) => _check());
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.code == 'PHONE_TAKEN') {
        Navigator.of(context).pop(_Outcome.taken);
        return;
      }
      setState(() {
        _restarting = false;
        _restartError = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = switch (_step) {
      _Step.ready => _ready(),
      _Step.waiting => _waiting(),
      _Step.expired => _expired(),
      _Step.done => _done(),
    };
    return PopScope(
      canPop: _step != _Step.done,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step == _Step.done) Navigator.of(context).pop(_Outcome.linked);
      },
      child: Stack(
        children: [
          body,
          if (_asking) const Positioned.fill(child: _PermissionReason()),
        ],
      ),
    );
  }

  String _mmss(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  Widget _ready() {
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return _FlowScaffold(
      back: 'Quay lại',
      title: 'Gửi yêu cầu xác nhận',
      subtitle: _native
          ? 'Thu Chi gửi yêu cầu bằng 1 tin nhắn từ máy này. Bạn không cần mở ứng dụng Tin nhắn.'
          : 'Ứng dụng Tin nhắn sẽ mở với yêu cầu soạn sẵn. Bạn chỉ cần bấm Gửi từ chính số điện thoại vừa nhập.',
      bottom: [
        AppButton(
          label: _denied ? 'Mở Tin nhắn để gửi' : 'Gửi yêu cầu xác nhận',
          icon: _denied ? LucideIcons.message_square : LucideIcons.send,
          loading: _sending,
          onPressed: _send,
        ),
        const SizedBox(height: 10),
        if (_denied)
          TextButton(
            onPressed: widget.bridge.openAppSettings,
            style: TextButton.styleFrom(foregroundColor: muted),
            child: const Text('Cấp quyền trong Cài đặt'),
          )
        else
          Text('Phí 1 tin nhắn thường theo nhà mạng.', textAlign: TextAlign.center, style: text.bodyMedium?.copyWith(color: context.appColors.faint)),
      ],
      children: [
        Text('Nội dung xác nhận', style: text.labelMedium?.copyWith(color: muted)),
        const SizedBox(height: 10),
        _CodeBoxes(code: _session.code),
        const SizedBox(height: 14),
        Text.rich(
          TextSpan(
            text: 'Mã hết hạn sau ',
            children: [TextSpan(text: _mmss(_left), style: const TextStyle(fontWeight: FontWeight.w700, color: _ink))],
          ),
          textAlign: TextAlign.center,
          style: text.bodyMedium?.copyWith(color: muted),
        ),
        if (_denied) ...[
          const SizedBox(height: 22),
          const _Note(icon: LucideIcons.message_square_off, child: Text('Không có quyền gửi SMS. Mở ứng dụng Tin nhắn để gửi, yêu cầu đã soạn sẵn.')),
        ],
      ],
    );
  }

  Widget _waiting() {
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final appColors = context.appColors;
    final slow = _sentAt != null && DateTime.now().difference(_sentAt!) >= const Duration(minutes: 1);
    final at = _sentAt;
    return _FlowScaffold(
      back: 'Quay lại',
      title: 'Gửi yêu cầu xác nhận',
      bottom: [
        AppButton(label: 'Gửi lại yêu cầu', icon: LucideIcons.send, style: AppButtonStyle.secondary, loading: _sending, onPressed: _send),
        const SizedBox(height: 6),
        TextButton(onPressed: () => Navigator.of(context).pop(), style: TextButton.styleFrom(foregroundColor: muted), child: const Text('Đổi số khác')),
      ],
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _cardLine)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_nativeSent) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.circle_check, size: 20, color: appColors.income),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text('Đã gửi yêu cầu', style: text.titleMedium?.copyWith(color: appColors.income))),
                              if (at != null)
                                Text('${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}', style: text.bodyMedium?.copyWith(color: appColors.faint)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('Thu Chi tự gửi từ ${_sentFrom ?? 'máy này'}, không mở ứng dụng Tin nhắn.', style: text.bodyMedium?.copyWith(color: muted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1, color: Color(0xFFECEBE7))),
              ],
              Row(
                children: [
                  Icon(LucideIcons.message_square_more, size: 20, color: muted),
                  const SizedBox(width: 10),
                  _ShimmerText('Đang chờ xác nhận…', style: text.titleMedium?.copyWith(color: muted, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),
              const _IndeterminateBar(),
              const SizedBox(height: 12),
              Text(
                _nativeSent ? 'Thường mất vài giây. Màn này tự chuyển khi xác nhận xong.' : 'Thường mất vài giây sau khi bấm Gửi. Màn này tự chuyển khi xác nhận xong.',
                style: text.bodyMedium?.copyWith(color: muted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _cardLine)),
          child: Row(
            children: [
              SizedBox(width: 84, child: Text('Mã', style: text.bodyLarge?.copyWith(color: muted, fontWeight: FontWeight.w400))),
              Expanded(child: Text(_session.code, style: text.titleMedium?.copyWith(letterSpacing: 1.5, fontFeatures: const [FontFeature.tabularFigures()]))),
              Text('còn ${_mmss(_left)}', style: text.bodyMedium?.copyWith(color: muted, fontFeatures: const [FontFeature.tabularFigures()])),
            ],
          ),
        ),
        // quá 1 phút chưa xác nhận: gợi ý kiểm tra SIM (không kèm số nào)
        if (slow) ...[
          const SizedBox(height: 16),
          _Note(
            icon: LucideIcons.lightbulb,
            child: Text(
              _nativeSent
                  ? 'Quá 1 phút chưa xong? Kiểm tra SIM còn tiền, có sóng, rồi bấm Gửi lại yêu cầu.'
                  : 'Chưa gửi được? Kiểm tra SIM còn tiền, có sóng và gửi từ chính số điện thoại bạn vừa nhập, rồi bấm Gửi lại yêu cầu.',
            ),
          ),
        ],
      ],
    );
  }

  Widget _expired() {
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final minutes = ref.watch(appSessionProvider).config?.phoneOtp.codeMinutes ?? 5;
    return _FlowScaffold(
      back: 'Quay lại',
      title: 'Gửi yêu cầu xác nhận',
      subtitle: 'Mã cũ không dùng được nữa. Yêu cầu đã gửi bằng mã này sẽ không được tính.',
      bottom: [
        AppButton(label: 'Lấy mã mới', icon: LucideIcons.rotate_ccw, loading: _restarting, onPressed: _newCode),
        const SizedBox(height: 6),
        TextButton(onPressed: () => Navigator.of(context).pop(), style: TextButton.styleFrom(foregroundColor: muted), child: const Text('Đổi số khác')),
      ],
      children: [
        _CodeBoxes(code: _session.code, faded: true),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _cardLine), boxShadow: context.shadows.card),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _IconDot(icon: LucideIcons.timer_off),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mã đã hết hạn', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('Mỗi mã dùng được $minutes phút. Lấy mã mới rồi gửi lại yêu cầu.', style: text.bodyMedium?.copyWith(color: muted)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_restartError != null) ...[
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.only(top: 2), child: Icon(LucideIcons.hourglass, size: 16, color: context.appColors.faint)),
              const SizedBox(width: 10),
              Expanded(child: Text(_restartError!, style: text.bodyMedium?.copyWith(color: const Color(0xFF8A8984)))),
            ],
          ),
        ],
      ],
    );
  }

  Widget _done() {
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final appColors = context.appColors;
    final email = ref.watch(appSessionProvider).user?.email;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(color: appColors.successContainer, shape: BoxShape.circle),
                  child: Icon(LucideIcons.check, size: 32, color: appColors.income),
                ),
              ),
              const SizedBox(height: 24),
              Text('Đã xác thực số điện thoại', textAlign: TextAlign.center, style: text.titleLarge?.copyWith(fontSize: 22)),
              const SizedBox(height: 8),
              Text(
                'Từ nay bạn lấy lại mật khẩu được bằng số này, ngoài cách qua email.',
                textAlign: TextAlign.center,
                style: text.bodyLarge?.copyWith(color: muted, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 28),
              if (email != null)
                _Note(
                  icon: LucideIcons.mail_check,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'Chúng tôi đã gửi email xác nhận tới '),
                        TextSpan(text: email, style: const TextStyle(fontWeight: FontWeight.w700, color: _ink)),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
              const Spacer(flex: 3),
              AppButton(label: 'Xong', onPressed: () => Navigator.of(context).pop(_Outcome.linked)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CodeBoxes extends StatelessWidget {
  const _CodeBoxes({required this.code, this.faded = false});
  final String code;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final color = faded ? context.appColors.faint : _ink;
    return Semantics(
      label: 'Nội dung xác nhận ${code.split('').join(' ')}',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < code.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: faded ? const Color(0xFFF1F0EC) : _chipBg, borderRadius: BorderRadius.circular(14)),
                child: Text(code[i], style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Chữ trạng thái chạy sáng (tắt khi giảm chuyển động), giống "Đang đọc ảnh…".
class _ShimmerText extends StatefulWidget {
  const _ShimmerText(this.text, {this.style});
  final String text;
  final TextStyle? style;

  @override
  State<_ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<_ShimmerText> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = Text(widget.text, style: widget.style);
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) return label;
    return AnimatedBuilder(
      animation: _c,
      child: label,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment(-2 + _c.value * 4, 0),
          end: Alignment(-1 + _c.value * 4, 0),
          colors: const [Color(0xFF787774), Color(0xFFCFCDC7), Color(0xFF787774)],
        ).createShader(bounds),
        child: child,
      ),
    );
  }
}

/// Thanh chạy mảnh (không spinner); đứng yên khi giảm chuyển động.
class _IndeterminateBar extends StatelessWidget {
  const _IndeterminateBar();

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return LinearProgressIndicator(
      value: still ? 0.34 : null,
      minHeight: 4,
      borderRadius: BorderRadius.circular(2),
      color: context.appColors.faint,
      backgroundColor: const Color(0xFFF1F0EC),
    );
  }
}

/// Mockup 10: thẻ lý do của app, nằm phía trên hộp quyền hệ thống.
class _PermissionReason extends StatelessWidget {
  const _PermissionReason();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x52111111),
      child: SafeArea(
        child: Align(
          alignment: const Alignment(0, -0.62),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: context.shadows.raised),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.shield_check, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    const TextSpan(
                      children: [
                        TextSpan(text: 'Thu Chi chỉ gửi '),
                        TextSpan(text: '1 tin chứa 6 số xác nhận', style: TextStyle(fontWeight: FontWeight.w700, color: _ink)),
                        TextSpan(text: ', một lần, khi bạn bấm Gửi. Phí như tin nhắn thường của nhà mạng.'),
                      ],
                    ),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: _noteText, fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ============================== 11 · Gửi từ SIM nào? ============================== */

class SimPickerSheet extends StatefulWidget {
  const SimPickerSheet({required this.sims, super.key});
  final List<SimInfo> sims;

  static Future<SimInfo?> show(BuildContext context, List<SimInfo> sims) => showModalBottomSheet<SimInfo>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => SimPickerSheet(sims: sims),
      );

  @override
  State<SimPickerSheet> createState() => _SimPickerSheetState();
}

class _SimPickerSheetState extends State<SimPickerSheet> {
  late SimInfo _selected = widget.sims.first;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final faint = context.appColors.faint;
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 16 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFDAD9D4), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: Text('Gửi từ SIM nào?', style: text.titleLarge)),
              IconButton(tooltip: 'Đóng', onPressed: () => Navigator.of(context).pop(), icon: const Icon(LucideIcons.x)),
            ],
          ),
          Text('Chọn SIM của số điện thoại bạn vừa nhập.', style: text.bodyLarge?.copyWith(color: muted, fontWeight: FontWeight.w400)),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(border: Border.all(color: _cardLine), borderRadius: BorderRadius.circular(18)),
            child: Column(
              children: [
                for (var i = 0; i < widget.sims.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: 76, endIndent: 16, color: Color(0xFFECEBE7)),
                  InkWell(
                    onTap: () => setState(() => _selected = widget.sims[i]),
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const _IconDot(icon: LucideIcons.card_sim, size: 40),
                          const SizedBox(width: 16),
                          Expanded(child: Text(widget.sims[i].label, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w500))),
                          _Radio(selected: identical(_selected, widget.sims[i])),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(LucideIcons.info, size: 16, color: faint),
              const SizedBox(width: 10),
              Expanded(child: Text('Gửi từ SIM khác sẽ không được xác nhận.', style: text.bodyMedium?.copyWith(color: const Color(0xFF8A8984)))),
            ],
          ),
          const SizedBox(height: 18),
          AppButton(label: 'Gửi yêu cầu xác nhận', icon: LucideIcons.send, onPressed: () => Navigator.of(context).pop(_selected)),
          const SizedBox(height: 10),
          Text('Phí 1 tin nhắn thường theo nhà mạng.', textAlign: TextAlign.center, style: text.bodyMedium?.copyWith(color: faint)),
        ],
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: context.motion.fast,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? _ink : Colors.white,
        border: Border.all(color: selected ? _ink : const Color(0xFFD5D4CF), width: 1.4),
      ),
      alignment: Alignment.center,
      child: selected ? Container(width: 9, height: 9, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)) : null,
    );
  }
}

/* ============================== 07 · Quên mật khẩu: chọn cách ============================== */

class ForgotPasswordChoiceScreen extends StatelessWidget {
  const ForgotPasswordChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _FlowScaffold(
      back: 'Đăng nhập',
      onBack: () => context.canPop() ? context.pop() : context.go('/login'),
      title: 'Quên mật khẩu',
      subtitle: 'Chọn cách xác nhận để đặt lại mật khẩu.',
      children: [
        _ChoiceCard(
          icon: LucideIcons.mail,
          title: 'Qua email',
          subtitle: 'Nhận mã 6 số trong email',
          onTap: () => context.push('/forgot-password/email'),
        ),
        const SizedBox(height: 14),
        _ChoiceCard(
          icon: LucideIcons.smartphone,
          title: 'Qua số điện thoại',
          subtitle: 'Gửi yêu cầu xác nhận từ số đã gắn',
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PhoneNumberScreen(flow: PhoneFlow.reset))),
        ),
        const SizedBox(height: 22),
        const _Note(
          icon: LucideIcons.info,
          child: Text('Cách qua số điện thoại chỉ dùng được nếu bạn đã gắn số trong Cài đặt > Tài khoản. Thu Chi không gửi tin nhắn, bạn gửi yêu cầu xác nhận từ số của bạn.'),
        ),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: _cardLine)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _IconDot(icon: icon),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.titleMedium),
                    const SizedBox(height: 2),
                    Text(subtitle, style: text.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(LucideIcons.chevron_right, size: 20, color: context.appColors.faint),
            ],
          ),
        ),
      ),
    );
  }
}

/* ============================== 08 · Đặt mật khẩu mới (sau khi xác nhận số) ============================== */

class PhoneResetPasswordScreen extends ConsumerStatefulWidget {
  const PhoneResetPasswordScreen({required this.verificationId, super.key});
  final String verificationId;

  @override
  ConsumerState<PhoneResetPasswordScreen> createState() => _PhoneResetPasswordScreenState();
}

class _PhoneResetPasswordScreenState extends ConsumerState<PhoneResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  var _loading = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(phoneRepositoryProvider).resetPassword(verificationId: widget.verificationId, newPassword: _password.text);
      if (!mounted) return;
      ref.read(appSessionProvider).showNotice('Đặt lại mật khẩu thành công. Bạn có thể đăng nhập.');
      context.go('/login');
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final text = Theme.of(context).textTheme;
    final minLength = ref.watch(appSessionProvider).config?.password.minLength ?? 6;
    return _FlowScaffold(
      back: 'Đăng nhập',
      onBack: () => context.go('/login'),
      top: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: appColors.successContainer, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(LucideIcons.circle_check, size: 20, color: appColors.income),
            const SizedBox(width: 12),
            Text('Đã xác nhận số điện thoại', style: text.bodyLarge?.copyWith(color: const Color(0xFF2F5B3A), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      title: 'Đặt mật khẩu mới',
      subtitle: 'Cho tài khoản đã gắn số điện thoại này.',
      bottom: [AppButton(label: 'Đặt mật khẩu mới', onPressed: _submit, loading: _loading)],
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthField(
                controller: _password,
                label: 'Mật khẩu mới',
                icon: LucideIcons.lock_keyhole,
                obscureText: true,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: (v) => (v?.length ?? 0) < minLength ? 'Mật khẩu phải có ít nhất $minLength ký tự' : null,
              ),
              const SizedBox(height: 8),
              Text('Ít nhất $minLength ký tự.', style: text.bodyMedium?.copyWith(color: appColors.faint)),
              const SizedBox(height: 16),
              AuthField(
                controller: _confirm,
                label: 'Nhập lại mật khẩu mới',
                hint: 'Nhập lại để chắc chắn',
                icon: LucideIcons.lock_keyhole,
                obscureText: true,
                textInputAction: TextInputAction.done,
                validator: (v) => v != _password.text ? 'Mật khẩu nhập lại chưa khớp' : null,
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        if (_error != null) _InlineError(_error!),
        const SizedBox(height: 24),
        const _Note(icon: LucideIcons.mail, child: Text('Sau khi đặt lại, chúng tôi gửi email báo tới email của tài khoản.')),
      ],
    );
  }
}

/* ============================== 09 · Gỡ số điện thoại ============================== */

class RemovePhoneSheet extends ConsumerStatefulWidget {
  const RemovePhoneSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const RemovePhoneSheet(),
      );

  @override
  ConsumerState<RemovePhoneSheet> createState() => _RemovePhoneSheetState();
}

class _RemovePhoneSheetState extends ConsumerState<RemovePhoneSheet> {
  final _password = TextEditingController();
  var _loading = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _remove() async {
    if (_loading || _password.text.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(phoneRepositoryProvider).removePhone(_password.text);
      final session = ref.read(appSessionProvider);
      final user = session.user;
      if (user != null) session.updateUser(user.copyWith(phone: null, phoneVerifiedAt: null));
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(const SnackBar(content: Text('Đã gỡ số điện thoại')));
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final appColors = context.appColors;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).viewInsets.bottom + 16 + MediaQuery.of(context).padding.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(width: 36, height: 5, decoration: BoxDecoration(color: const Color(0xFFDAD8D2), borderRadius: BorderRadius.circular(999)))),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: appColors.dangerContainer, shape: BoxShape.circle),
                child: Icon(LucideIcons.phone_off, size: 26, color: appColors.danger),
              ),
            ),
            const SizedBox(height: 16),
            Text('Gỡ số điện thoại?', textAlign: TextAlign.center, style: text.titleLarge?.copyWith(fontSize: 22)),
            const SizedBox(height: 10),
            Text(
              'Bạn sẽ không lấy lại mật khẩu bằng số này được nữa. Cách qua email vẫn dùng bình thường.',
              textAlign: TextAlign.center,
              style: text.bodyLarge?.copyWith(color: muted, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 22),
            Text('Nhập mật khẩu để xác nhận', style: text.labelMedium?.copyWith(color: muted)),
            const SizedBox(height: 8),
            TextField(
              controller: _password,
              obscureText: true,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() => _error = null),
              onSubmitted: (_) => _remove(),
              decoration: InputDecoration(prefixIcon: Icon(LucideIcons.lock_keyhole, size: 20, color: muted)),
            ),
            if (_error != null)
              _InlineError(_error!)
            else
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Chúng tôi sẽ gửi email báo đã gỡ số.', style: text.bodyMedium?.copyWith(color: appColors.faint)),
              ),
            const SizedBox(height: 22),
            AppButton(label: 'Gỡ số', style: AppButtonStyle.danger, loading: _loading, onPressed: _password.text.isEmpty ? null : _remove),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: TextButton(
                onPressed: _loading ? null : () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(foregroundColor: _ink),
                child: const Text('Hủy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
