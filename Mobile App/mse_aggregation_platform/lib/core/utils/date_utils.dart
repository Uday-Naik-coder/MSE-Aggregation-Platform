import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final _dateFormat     = DateFormat('dd MMM yyyy');
  static final _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

  static String formatDate(DateTime? dt) =>
      dt == null ? '-' : _dateFormat.format(dt.toLocal());

  static String formatDateTime(DateTime? dt) =>
      dt == null ? '-' : _dateTimeFormat.format(dt.toLocal());

  static String timeRemaining(DateTime deadline) {
    final diff = deadline.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inDays > 0) return '${diff.inDays}d remaining';
    if (diff.inHours > 0) return '${diff.inHours}h remaining';
    return '${diff.inMinutes}m remaining';
  }

  static bool isExpired(DateTime deadline) => DateTime.now().isAfter(deadline);
}
