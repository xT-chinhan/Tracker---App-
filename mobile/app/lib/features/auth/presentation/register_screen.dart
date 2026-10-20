import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_state_view.dart';
import '../application/app_session.dart';
import '../application/auth_flow_service.dart';
import 'auth_scaffold.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
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
          .register(
            name: _name.text,
            email: _email.text,
            password: _password.text,
          );
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appSessionProvider).config;
    if (config?.registrationEnabled == false) {
      return Scaffold(
        appBar: AppBar(title: const Text('Đăng ký')),
        body: AppStateView(
          title: 'Tạm ngưng nhận đăng ký',
          message:
              'Bạn có thể quay lại sau hoặc đăng nhập nếu đã có tài khoản.',
          actionLabel: 'Về đăng nhập',
          onAction: () => context.go('/login'),
        ),
      );
    }
    final minLength = config?.password.minLength ?? 6;
    return AuthScaffold(
      title: 'Tạo tài khoản',
      subtitle: 'Bắt đầu ghi chép tài chính của riêng bạn.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthField(
              controller: _name,
              label: 'Tên của bạn',
              hint: 'Nguyễn Minh Anh',
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  (value?.trim().isEmpty ?? true) ? 'Vui lòng nhập tên' : null,
            ),
            const SizedBox(height: 20),
            AuthField(
              controller: _email,
              label: 'Email',
              hint: 'ban@email.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: validateEmail,
            ),
            const SizedBox(height: 20),
            AuthField(
              controller: _password,
              label: 'Mật khẩu',
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 28),
            AppButton(
              label: 'Tạo tài khoản',
              onPressed: _submit,
              loading: _loading,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Đã có tài khoản? Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}
