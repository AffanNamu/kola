import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String short(DateTime dt) => DateFormat('MMM d, yyyy').format(dt);
  static String time(DateTime dt) => DateFormat('hh:mm a').format(dt);
  static String shortWithTime(DateTime dt) =>
      '${DateFormatter.short(dt)} • ${DateFormatter.time(dt)}';
}
