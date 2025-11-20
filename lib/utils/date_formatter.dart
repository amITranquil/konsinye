import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('dd.MM.yyyy', 'tr_TR');
  static final DateFormat _dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm', 'tr_TR');

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }
}
