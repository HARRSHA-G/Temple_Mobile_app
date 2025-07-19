import 'package:intl/intl.dart';

class DateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatMonth(int month) {
    return DateFormat.MMMM().format(DateTime(2024, month));
  }

  static DateTime getMonthStart(int month, int year) {
    return DateTime(year, month, 1);
  }

  static DateTime getMonthEnd(int month, int year) {
    return DateTime(year, month + 1, 0);
  }
}