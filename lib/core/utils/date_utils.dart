import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class NubarDateUtils {
  NubarDateUtils._();

  static String timeAgo(DateTime dateTime) {
    return timeago.format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat.yMMMd().format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat.yMMMd().add_jm().format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime);
  }
}
