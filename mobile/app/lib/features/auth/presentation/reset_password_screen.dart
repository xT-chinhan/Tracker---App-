import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/widgets/app_button.dart';
import '../application/app_session.dart';
import '../application/auth_flow_service.dart';
import 'auth_scaffold.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({required this.email, super.key});

  final String email;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otp = TextEditingController();
  final _password = TextEditingController();
  Timer? _timer;
  var _remaining = 0;
  var _loading = false;
  var _resending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startCountdown(
      ref.read(appSessionProvider).config?.otp.resendSeconds ?? 60,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otp.dispose();
    _password.dispose();
    super.dispose();
  }

  void _startCountdown(int seconds) {
    _timer?.cancel();
    _remaining = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remaining <= 1) {
        timer.cancel();
        setState(() => _remaining = 0);
      } else {
        setState(() => _remaining--);
      }
    });
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authFlowServiceProvider)
          .resetPassword(
            email: widget.email,
            otp: _otp.text,
            newPassword: _password.text,
          );
      if (!mounted) return;
      ref
          .read(appSessionProvider)
          .showNotice('Đặt lại mật khẩu thành công. Bạn có thể đăng nhập.');
      context.go('/login');
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (_resending || _remaining > 0) return;
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      await ref.read(authFlowServiceProvider).forgotPassword(widget.email);
      if (!mounted) return;
      _startCountdown(
        ref.read(appSessionProvider).config?.otp.resendSeconds ?? 60,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nếu email hợp lệ, mã OTP mới đã được gửi.'),
        ),
      );
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final minLength =
        ref.watch(appSessionProvider).config?.password.minLength ?? 6;
    return AuthScaffold(
      title: 'Nhập mã xác thực',
      subtitle:
          'Mã OTP đã được gửi tới ${widget.email}. Mã chỉ có hiệu lực trong thời gian giới hạn.',
      showMark: false,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthField(
              controller: _otp,
              label: 'Mã OTP',
              hint: '000000',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) => (value?.length ?? 0) != 6
                  ? 'Mã OTP phải gồm đúng 6 số'
                  : null,
            ),
            const SizedBox(height: 20),
            AuthField(
              controller: _password,
              label: 'Mật khẩu mới',
              hint: 'Ít nhất $minLength ký tự',
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: (value) => (value?.length ?? 0) < minLength
                  ? 'Mật khẩu phải có ít nhất $minLength ký tự'
                  : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 28),
            AppButton(
              label: 'Đặt lại mật khẩu',
              onPressed: _submit,
              loading: _loading,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _remaining == 0 && !_resending ? _resend : null,
              child: Text(
                _remaining > 0
                    ? 'Gửi lại mã sau ${_remaining}s'
                    : _resending
                    ? 'Đang gửi lại…'
                    : 'Gửi lại mã OTP',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
