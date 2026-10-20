import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/config/public_config.dart';
import 'package:app/core/network/api_exception.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/auth/application/app_session.dart';
import 'package:app/features/auth/data/auth_models.dart';
import 'package:app/features/auth/data/auth_repository.dart';
import 'package:app/features/phone/phone_verify.dart';
import '../../helpers/fixtures.dart';

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository() : super(Dio());

  @override
  Future<AppUser> me() async => userFixture().copyWith(email: 'minhanh.nguyen@gmail.com', phone: '0912345678', phoneVerifiedAt: DateTime.utc(2026, 10, 20));
}

class _FakePhoneRepository extends PhoneRepository {
  _FakePhoneRepository(this.statuses) : super(Dio());

  /// Trạng thái trả về lần lượt cho mỗi lần hỏi (hết danh sách thì giữ phần tử cuối).
  final List<PhoneStatus> statuses;
  int polls = 0;
  int starts = 0;
  ApiException? startError;

  Map<String, dynamic> _session() => {
        'verificationId': 'v-${++starts}',
        'phone': '0912345678',
        'code': '482910',
        'expiresAt': DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
        'smsLink': {'android': 'sms:0901234567?body=482910', 'ios': 'sms:0901234567&body=482910'},
      };

  @override
  Future<Map<String, dynamic>> startLink({required String phone, required String password}) async {
    if (startError != null) throw startError!;
    return _session();
  }

  @override
  Future<Map<String, dynamic>> startReset(String phone) async => _session();

  @override
  Future<PhoneStatus> linkStatus(String id) async => statuses[(polls++).clamp(0, statuses.length - 1)];

  @override
  Future<PhoneStatus> resetStatus(String id) async => statuses[(polls++).clamp(0, statuses.length - 1)];
}

Widget _app(_FakePhoneRepository repo, Widget home) {
  final session = AppSessionController()
    ..authenticate(
      value: userFixture().copyWith(email: 'minhanh.nguyen@gmail.com'),
      publicConfig: publicConfigFixture().copyWith(phoneOtp: const PhoneOtpPublicConfig(enabled: true, codeMinutes: 5)),
    );
  return ProviderScope(
    overrides: [
      phoneRepositoryProvider.overrideWithValue(repo),
      authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
      appSessionProvider.overrideWith((ref) => session),
    ],
    child: MaterialApp(theme: AppTheme.light, home: home),
  );
}

void main() {
  test('maskPhone chỉ giữ 4 số đầu và 3 số cuối', () {
    expect(maskPhone('0912345678'), '0912 ••• 678');
    expect(maskPhone('0912 345 678'), '0912 ••• 678');
  });

  test('smsDestination lấy số người nhận từ smsLink (Android và iOS)', () {
    expect(smsDestination('sms:0901234567?body=482910'), '0901234567');
    expect(smsDestination('sms:0901234567&body=482910'), '0901234567');
  });

  test('PublicConfig thiếu phoneOtp → tắt', () {
    final json = publicConfigFixture().toJson()..remove('phoneOtp');
    final config = PublicConfig.fromJson(_deep(json)! as Map<String, dynamic>);
    expect(config.phoneOtp.enabled, isFalse);
    expect(config.phoneOtp.codeMinutes, 5);
  });

  testWidgets('Gắn số: hiện nội dung xác nhận, không hiện số nào, xác nhận xong → Đã xác thực', (tester) async {
    final repo = _FakePhoneRepository([PhoneStatus.pending, PhoneStatus.verified]);
    await tester.pumpWidget(_app(repo, const PhoneNumberScreen()));

    expect(find.text('Gắn số điện thoại'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), '0912345678');
    await tester.enterText(find.byType(TextField).at(1), 'demo123');
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    expect(find.text('Gửi yêu cầu xác nhận'), findsWidgets);
    expect(find.text('Nội dung xác nhận'), findsOneWidget);
    for (final d in ['4', '8', '2', '9', '1', '0']) {
      expect(find.text(d), findsOneWidget);
    }
    expect(find.textContaining('0901'), findsNothing);
    expect(find.textContaining('0912'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Đã xác thực số điện thoại'), findsOneWidget);
    expect(find.textContaining('minhanh.nguyen@gmail.com'), findsOneWidget);

    await tester.tap(find.text('Xong'));
    await tester.pumpAndSettle();
    expect(find.text('Gắn số điện thoại'), findsNothing);
  });

  testWidgets('Số vừa bị tài khoản khác gắn (FAILED) → lỗi đỏ dưới ô số', (tester) async {
    final repo = _FakePhoneRepository([PhoneStatus.failed]);
    await tester.pumpWidget(_app(repo, const PhoneNumberScreen()));
    await tester.enterText(find.byType(TextField).at(0), '0912345678');
    await tester.enterText(find.byType(TextField).at(1), 'demo123');
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.textContaining('Số này đã được dùng cho tài khoản khác'), findsOneWidget);
  });

  testWidgets('409 PHONE_TAKEN khi xin mã → lỗi dưới ô số, không sang màn xác nhận', (tester) async {
    final repo = _FakePhoneRepository([PhoneStatus.pending])
      ..startError = const ApiException(statusCode: 409, code: 'PHONE_TAKEN', message: 'Số điện thoại đã được dùng cho tài khoản khác');
    await tester.pumpWidget(_app(repo, const PhoneNumberScreen()));
    await tester.enterText(find.byType(TextField).at(0), '0912345678');
    await tester.enterText(find.byType(TextField).at(1), 'demo123');
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Số này đã được dùng cho tài khoản khác'), findsOneWidget);
    expect(find.text('Nội dung xác nhận'), findsNothing);
  });

  testWidgets('Mã hết hạn → thẻ trung tính, Lấy mã mới xin phiên mới', (tester) async {
    final repo = _FakePhoneRepository([PhoneStatus.expired, PhoneStatus.pending]);
    await tester.pumpWidget(_app(repo, const PhoneNumberScreen()));
    await tester.enterText(find.byType(TextField).at(0), '0912345678');
    await tester.enterText(find.byType(TextField).at(1), 'demo123');
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Mã đã hết hạn'), findsOneWidget);
    expect(find.textContaining('5 phút'), findsOneWidget);

    await tester.tap(find.text('Lấy mã mới'));
    await tester.pumpAndSettle();
    expect(repo.starts, 2);
    expect(find.text('Nội dung xác nhận'), findsOneWidget);
  });
}

Object? _deep(Object? v) => switch (v) {
      Map() => {for (final e in v.entries) '${e.key}': _deep(e.value)},
      List() => v.map(_deep).toList(),
      _ when v != null && v is! num && v is! String && v is! bool => _deep((v as dynamic).toJson()),
      _ => v,
    };
