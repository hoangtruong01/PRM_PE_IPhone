// lib/core/utils/date_utils.dart
import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  /// Format date as "dd MMM yyyy" e.g. "01 Aug 2026"
  static String formatDisplay(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Format date as "yyyy-MM-dd" for API
  static String formatApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format date range as "dd-dd MMM" e.g. "01-07 Aug"
  static String formatRange(DateTime start, DateTime end) {
    if (start.month == end.month && start.year == end.year) {
      return '${DateFormat('dd').format(start)}-${DateFormat('dd MMM').format(end)}';
    }
    return '${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM').format(end)}';
  }

  /// Calculate days between two dates
  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }
}
