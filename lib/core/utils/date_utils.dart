// lib/core/utils/date_utils.dart
import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  /// Định dạng ngày hiển thị dạng "dd MMM yyyy", ví dụ: "01 Aug 2026"
  static String formatDisplay(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Định dạng ngày gửi API dạng "yyyy-MM-dd"
  static String formatApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Định dạng khoảng ngày dạng "dd-dd MMM", ví dụ: "01-07 Aug"
  static String formatRange(DateTime start, DateTime end) {
    if (start.month == end.month && start.year == end.year) {
      return '${DateFormat('dd').format(start)}-${DateFormat('dd MMM').format(end)}';
    }
    return '${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM').format(end)}';
  }

  /// Tính số ngày giữa hai mốc thời gian
  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }
}
