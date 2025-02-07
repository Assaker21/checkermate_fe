import 'package:intl/intl.dart';

class DateFormatUtils {
  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }
}
