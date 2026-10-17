import 'package:app/core/formatting/version_compare.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('so sánh phiên bản theo từng thành phần số', () {
    expect(VersionCompare.compare('1.10.0', '1.9.9'), greaterThan(0));
    expect(VersionCompare.compare('1.0', '1.0.0'), 0);
    expect(VersionCompare.compare('2.0.0+17', '2.0.0'), 0);
  });

  test('từ chối phiên bản không hợp lệ', () {
    expect(() => VersionCompare.compare('1.x', '1.0'), throwsFormatException);
  });
}
