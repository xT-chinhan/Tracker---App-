import 'package:app/features/bank_notifications/application/bank_mapping.dart';
import 'package:app/features/bank_notifications/data/bank_notification_parser.dart';
import 'package:app/features/bank_notifications/data/mock_bank_samples.dart';
import 'package:app/features/bank_notifications/data/raw_notification.dart';
import 'package:app/features/categories/data/category_models.dart';
import 'package:app/features/wallets/data/wallet_models.dart';
import 'package:flutter_test/flutter_test.dart';

const _cats = [
  CategoryItem(id: 'luong', name: 'Lương', type: 'INCOME'),
  CategoryItem(id: 'thukhac', name: 'Thu khác', type: 'INCOME'),
  CategoryItem(id: 'anuong', name: 'Ăn uống', type: 'EXPENSE'),
  CategoryItem(id: 'hoadon', name: 'Hóa đơn', type: 'EXPENSE'),
  CategoryItem(id: 'chikhac', name: 'Chi khác', type: 'EXPENSE'),
];
const _wallets = [
  WalletItem(id: 'mb', name: 'MB Bank', type: 'BANK'),
  WalletItem(id: 'momo', name: 'MoMo', type: 'EWALLET'),
  WalletItem(id: 'cash', name: 'Tiền mặt', type: 'CASH'),
];

PendingBankTransaction _pending(RawNotification raw) {
  final parsed = BankNotificationParser.parse(raw);
  expect(parsed, isNotNull, reason: raw.text);
  return toPending(parsed!, packageName: raw.packageName)!;
}

void main() {
  test(
    'thông báo tiền vào → khoản THU, tiền ra → khoản CHI, số tiền nguyên đồng',
    () {
      final income = _pending(MockBankSamples.vietcombankCredit);
      expect(income.type, 'INCOME');
      expect(income.amount, 200000);
      final expense = _pending(MockBankSamples.vietcombankDebit);
      expect(expense.type, 'EXPENSE');
      expect(expense.amount, 50000);
    },
  );

  test(
    'lương → danh mục Lương; danh mục module không có ở Thu Chi → Thu khác / Chi khác',
    () {
      final salary = _pending(MockBankSamples.mbbankCredit);
      expect(pickCategory(_cats, salary)?.id, 'luong');
      final t = PendingBankTransaction(
        key: 'k',
        bank: 'X',
        packageName: 'x',
        amount: 1,
        type: 'EXPENSE',
        occurredAt: DateTime.utc(2026),
        title: 't',
        categoryName: 'Giáo dục',
      );
      expect(pickCategory(_cats, t)?.id, 'chikhac');
    },
  );

  test(
    'ví: khớp tên ngân hàng ("MBBank" ↔ "MB Bank"), ví đã ghép được ưu tiên, không khớp → hỏi',
    () {
      final mb = _pending(MockBankSamples.mbbankDebit);
      expect(pickWallet(_wallets, mb, const {})?.id, 'mb');
      expect(pickWallet(_wallets, mb, {mb.bank: 'cash'})?.id, 'cash');
      final vcb = _pending(MockBankSamples.vietcombankDebit);
      expect(pickWallet(_wallets, vcb, const {}), isNull);
    },
  );

  test('chống trùng: cùng gói, số tiền, phút → cùng khóa', () {
    expect(
      dedupeKey('com.VCB', 50000, 60000 * 10 + 5),
      dedupeKey('com.vcb', 50000, 60000 * 10 + 59000),
    );
    expect(
      dedupeKey('com.vcb', 50000, 0),
      isNot(dedupeKey('com.vcb', 50001, 0)),
    );
  });

  test('thông báo không phải ngân hàng (Facebook) không thành giao dịch', () {
    final parsed = BankNotificationParser.parse(
      MockBankSamples.facebookNotification,
    );
    final item = parsed == null
        ? null
        : toPending(parsed, packageName: 'com.facebook.katana');
    expect(item, isNull);
  });

  test('lưu / đọc lại JSON không mất dữ liệu', () {
    final t = _pending(MockBankSamples.momoPayment);
    final back = PendingBankTransaction.fromJson(t.toJson());
    expect(back.key, t.key);
    expect(back.amount, t.amount);
    expect(back.occurredAt, t.occurredAt);
  });
}
