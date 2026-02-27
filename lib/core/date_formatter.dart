import 'package:intl/intl.dart';

class DateFormatter {
  static final _dateFormat = DateFormat('MMM dd, yyyy');
  static final _fullDateFormat = DateFormat('EEEE, MMM dd, yyyy');

  static String format(DateTime date) => _dateFormat.format(date);
  static String formatFull(DateTime date) => _fullDateFormat.format(date);

  static bool isOverdue(DateTime dueDate) {
    final now = DateTime.now();
    return dueDate.isBefore(DateTime(now.year, now.month, now.day));
  }

  static bool isDueToday(DateTime dueDate) {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  static bool isDueSoon(DateTime dueDate) {
    final now = DateTime.now();
    final diff = dueDate.difference(now).inDays;
    return diff >= 0 && diff <= 2;
  }

  static String relativeLabel(DateTime dueDate) {
    if (isDueToday(dueDate)) return 'Due Today';
    if (isOverdue(dueDate)) return 'Overdue';
    if (isDueSoon(dueDate)) return 'Due Soon';
    return 'Due ${format(dueDate)}';
  }
}