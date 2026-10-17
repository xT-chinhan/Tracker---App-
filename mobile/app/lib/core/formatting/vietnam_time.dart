import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

abstract final class VietnamTime {
  static tz.Location get location => tz.getLocation('Asia/Ho_Chi_Minh');

  static tz.TZDateTime now() => tz.TZDateTime.now(location);

  static tz.TZDateTime fromDateTime(DateTime value) =>
      tz.TZDateTime.from(value, location);

  static String dayMonth(DateTime value) =>
      DateFormat('dd/MM', 'vi_VN').format(fromDateTime(value));

  static String dateTime(DateTime value) =>
      DateFormat('dd/MM/yyyy · HH:mm', 'vi_VN').format(fromDateTime(value));

  static String monthKey(DateTime value) =>
      DateFormat('yyyy-MM', 'vi_VN').format(fromDateTime(value));
}
