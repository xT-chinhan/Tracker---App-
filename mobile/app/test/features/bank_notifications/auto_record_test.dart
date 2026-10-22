import 'package:app/features/bank_notifications/application/bank_mapping.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

PendingBankTransaction _tx({
  String key = 'k1',
  String bank = 'MBBank',
  String pkg = 'com.mbmobile',
  int amount = 45000,
  String type = 'EXPENSE',
  DateTime? at,
}) => PendingBankTransaction(
  key: key,
  bank: bank,
  packageName: pkg,
  amount: amount,
  type: type,
  occurredAt: at ?? DateTime.utc(2026, 10, 22, 8, 12),
  title: 'Cà phê',
  categoryName: 'Ăn uống',
);

void main() {
  group('trùng app ngân hàng + SMS', () {
    final base = _tx();

    test('cùng số tiền, cùng loại, cách 3 phút → trùng', () {
      final sms = _tx(
        key: 'k2',
        pkg: 'com.google.android.apps.messaging',
        at: base.occurredAt.add(const Duration(minutes: 3)),
      );
      expect(isSameTx(base.shape, sms.shape), isTrue);
      expect(
        isDuplicateOfKnown(sms, pending: [base], autoRecorded: const []),
        isTrue,
      );
    });

    test('cách hơn 3 phút → hai khoản', () {
      final later = _tx(
        key: 'k2',
        at: base.occurredAt.add(const Duration(minutes: 3, seconds: 1)),
      );
      expect(isSameTx(base.shape, later.shape), isFalse);
    });

    test('khác số tiền hoặc khác loại → hai khoản', () {
      expect(
        isSameTx(base.shape, _tx(key: 'k2', amount: 45001).shape),
        isFalse,
      );
      expect(
        isSameTx(base.shape, _tx(key: 'k2', type: 'INCOME').shape),
        isFalse,
      );
    });

    test('trùng với khoản đã tự ghi', () {
      final auto = AutoRecordedTransaction.of(
        base,
        transactionId: 'tx-1',
        category: categoryItemFixture(),
        wallet: walletItemFixture(),
      );
      final sms = _tx(
        key: 'k2',
        at: base.occurredAt.subtract(const Duration(minutes: 2)),
      );
      expect(
        isDuplicateOfKnown(sms, pending: const [], autoRecorded: [auto]),
        isTrue,
      );
    });

    test('trùng với khoản đã xác nhận / bỏ qua trong 3 phút', () {
      final done = ProcessedBankTransaction.of(base);
      final sms = _tx(
        key: 'k2',
        at: base.occurredAt.add(const Duration(minutes: 1)),
      );
      expect(
        isDuplicateOfKnown(
          sms,
          pending: const [],
          autoRecorded: const [],
          processed: [done],
        ),
        isTrue,
      );
      final later = _tx(
        key: 'k3',
        at: base.occurredAt.add(const Duration(minutes: 4)),
      );
      expect(
        isDuplicateOfKnown(
          later,
          pending: const [],
          autoRecorded: const [],
          processed: [done],
        ),
        isFalse,
      );
      final back = ProcessedBankTransaction.fromJson('k1', done.toJson())!;
      expect(back.amount, base.amount);
      expect(back.occurredAt, base.occurredAt);
    });

    test('không tự so với chính nó', () {
      expect(
        isDuplicateOfKnown(base, pending: [base], autoRecorded: const []),
        isFalse,
      );
    });
  });

  group('điều kiện tự ghi', () {
    final cat = categoryItemFixture();
    final wallet = walletItemFixture();

    test('đủ ví, danh mục, dưới ngưỡng → tự ghi', () {
      expect(
        autoRecordBlock(
          _tx(),
          category: cat,
          wallet: wallet,
          threshold: 5000000,
        ),
        isNull,
      );
    });

    test('chưa có ví → chờ, nêu tên ngân hàng', () {
      expect(
        autoRecordBlock(
          _tx(bank: 'VPBank'),
          category: cat,
          wallet: null,
          threshold: 0,
        ),
        'Chưa chọn ví cho VPBank',
      );
    });

    test('chưa rõ danh mục → chờ', () {
      expect(
        autoRecordBlock(_tx(), category: null, wallet: wallet, threshold: 0),
        'Chưa rõ danh mục',
      );
    });

    test('khoản lớn từ ngưỡng trở lên → chờ; ngưỡng Tắt → tự ghi', () {
      final big = _tx(amount: 5000000);
      expect(
        autoRecordBlock(big, category: cat, wallet: wallet, threshold: 5000000),
        'Khoản lớn, chờ bạn xác nhận',
      );
      expect(
        autoRecordBlock(
          _tx(amount: 4999999),
          category: cat,
          wallet: wallet,
          threshold: 5000000,
        ),
        isNull,
      );
      expect(
        autoRecordBlock(big, category: cat, wallet: wallet, threshold: 0),
        isNull,
      );
    });
  });

  test('khoản tự ghi lưu / đọc lại đủ trường', () {
    final a = AutoRecordedTransaction.of(
      _tx(),
      transactionId: 'tx-9',
      category: categoryItemFixture(),
      wallet: walletItemFixture(),
    );
    final b = AutoRecordedTransaction.fromJson(a.toJson());
    expect(b.transactionId, 'tx-9');
    expect(b.amount, 45000);
    expect(b.type, 'EXPENSE');
    expect(b.occurredAt, a.occurredAt);
    expect(b.walletName, a.walletName);
  });
}
