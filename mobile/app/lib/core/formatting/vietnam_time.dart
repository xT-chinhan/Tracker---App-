import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

abstract final class VietnamTime {
  static tz.Location get location {
    try {
      return tz.getLocation('Asia/Ho_Chi_Minh');
    } catch (_) {
      tz_data.initializeTimeZones();
      return tz.getLocation('Asia/Ho_Chi_Minh');
    }
  }

  static tz.TZDateTime now() => tz.TZDateTime.now(location);

  static tz.TZDateTime fromDateTime(DateTime value) =>
      tz.TZDateTime.from(value, location);

  static String dayMonth(DateTime value) {
    final vn = fromDateTime(value);
    return '${vn.day.toString().padLeft(2, '0')}/${vn.month.toString().padLeft(2, '0')}';
  }

  static String dateTime(DateTime value) {
    final vn = fromDateTime(value);
    return '${vn.day.toString().padLeft(2, '0')}/${vn.month.toString().padLeft(2, '0')}/${vn.year} · ${vn.hour.toString().padLeft(2, '0')}:${vn.minute.toString().padLeft(2, '0')}';
  }

  static String monthKey(DateTime value) {
    final vn = fromDateTime(value);
    return '${vn.year}-${vn.month.toString().padLeft(2, '0')}';
  }

  static String headline(DateTime value) {
    final vn = fromDateTime(value);
    final dow = switch (vn.weekday) {
      1 => 'Thứ Hai',
      2 => 'Thứ Ba',
      3 => 'Thứ Tư',
      4 => 'Thứ Năm',
      5 => 'Thứ Sáu',
      6 => 'Thứ Bảy',
      7 => 'Chủ Nhật',
      _ => '',
    };
    return '$dow, ${vn.day} tháng ${vn.month}';
  }

  static String timeOnly(DateTime value) {
    final vn = fromDateTime(value);
    return '${vn.hour.toString().padLeft(2, '0')}:${vn.minute.toString().padLeft(2, '0')}';
  }

  static String relativeNotification(DateTime value) {
    final vn = fromDateTime(value);
    final current = now();
    final today = tz.TZDateTime(
      location,
      current.year,
      current.month,
      current.day,
    );
    final targetDay = tz.TZDateTime(location, vn.year, vn.month, vn.day);
    final diffDays = today.difference(targetDay).inDays;

    if (diffDays == 0) {
      return timeOnly(value);
    } else if (diffDays == 1) {
      return 'Hôm qua, ${timeOnly(value)}';
    } else {
      return dayMonth(value);
    }
  }
}
