import 'package:intl/intl.dart';

abstract final class AppDateFormat {
  static final _dateTime = DateFormat('dd/MM/yyyy HH:mm');

  static String dateTime(DateTime date) => _dateTime.format(date.toLocal());
}
