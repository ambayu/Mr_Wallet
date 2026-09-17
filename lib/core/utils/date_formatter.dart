import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateFormat = DateFormat('d MMM yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('d MMM yyyy, HH:mm');

  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final diffDays = targetDay.difference(today).inDays;

    if (diffDays == 0) {
      return 'Hari ini, ${_timeFormat.format(dateTime)}';
    } else if (diffDays == -1) {
      return 'Kemarin, ${_timeFormat.format(dateTime)}';
    } else if (diffDays == 1) {
      return 'Besok, ${_timeFormat.format(dateTime)}';
    } else {
      return _dateTimeFormat.format(dateTime);
    }
  }
}
