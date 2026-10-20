import 'package:app/core/formatting/money_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoneyFormatter', () {
    test('định dạng VND với dấu chấm và dấu trừ thật', () {
      expect(MoneyFormatter.format(26022000), '26.022.000đ');
      expect(MoneyFormatter.format(-45000), '−45.000đ');
      expect(MoneyFormatter.format(45000, signed: true), '+45.000đ');
    });

    test('đọc số tiền tiếng Việt', () {
      expect(MoneyFormatter.inWords(0), 'Không đồng');
      expect(MoneyFormatter.inWords(55000), 'năm mươi lăm nghìn đồng');
      expect(
        MoneyFormatter.inWords(1005000),
        'một triệu không trăm lẻ năm nghìn đồng',
      );
    });
  });
}
