import 'dart:math' as math;
import 'dart:ui';

import 'package:intl/intl.dart';

abstract final class MoneyFormatter {
  static final NumberFormat _digits = NumberFormat.decimalPattern('vi_VN');

  static String format(int amount, {bool signed = false}) {
    final absolute = _digits.format(amount.abs());
    if (amount < 0) return '−$absolute\u0111';
    if (signed && amount > 0) return '+$absolute\u0111';
    return '$absolute\u0111';
  }

  static String compact(int amount) {
    if (amount.abs() < 1000) return format(amount);
    final sign = amount < 0 ? '−' : '';
    final value = amount.abs();
    if (value % 1000 == 0 && value < 1000000) {
      return '$sign${value ~/ 1000}k';
    }
    return format(amount);
  }

  static const tabularFeatures = <FontFeature>[FontFeature.tabularFigures()];

  static String inWords(int value) {
    if (value == 0) return 'Không đồng';
    if (value < 0) return 'Âm ${inWords(value.abs()).toLowerCase()}';
    return '${_group(value).trim()} đồng'.replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _group(int value) {
    const units = <String>['', ' nghìn', ' triệu', ' tỷ'];
    final chunks = <String>[];
    var remaining = value;
    var index = 0;
    while (remaining > 0 && index < units.length) {
      final part = remaining % 1000;
      if (part > 0) {
        final forceHundreds = index > 0 && remaining >= 1000;
        chunks.add('${_underThousand(part, forceHundreds)}${units[index]}');
      }
      remaining ~/= 1000;
      index++;
    }
    if (remaining > 0) {
      final billions = value ~/ math.pow(10, 9).toInt();
      return '${_group(billions)} tỷ ${_group(value % math.pow(10, 9).toInt())}';
    }
    return chunks.reversed.join(' ');
  }

  static String _underThousand(int value, bool forceHundreds) {
    const digit = <String>[
      'không',
      'một',
      'hai',
      'ba',
      'bốn',
      'năm',
      'sáu',
      'bảy',
      'tám',
      'chín',
    ];
    final words = <String>[];
    final hundreds = value ~/ 100;
    final tens = (value ~/ 10) % 10;
    final ones = value % 10;
    if (hundreds > 0 || forceHundreds) {
      words.add('${digit[hundreds]} trăm');
    }
    if (tens > 1) {
      words.add('${digit[tens]} mươi');
    } else if (tens == 1) {
      words.add('mười');
    } else if (ones > 0 && (hundreds > 0 || forceHundreds)) {
      words.add('lẻ');
    }
    if (ones > 0) {
      if (ones == 1 && tens > 1) {
        words.add('mốt');
      } else if (ones == 5 && tens > 0) {
        words.add('lăm');
      } else {
        words.add(digit[ones]);
      }
    }
    return words.join(' ');
  }
}
