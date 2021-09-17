import 'package:intl/intl.dart';

import 'logger.dart';

class DateUtil {
  static DateTime parseStringToDate(String dateStr, String format) {
    DateTime date;
    if (dateStr != null)
      try {
        date = DateFormat(format).parse(dateStr);
      } on FormatException catch (e) {
        logger.e(e.toString());
      }
    return date;
  }

  static String parseDateToString(DateTime dateTime, String format) {
    String date = "";
    if (dateTime != null)
      try {
        date = DateFormat(format).format(dateTime);
      } on FormatException catch (e) {
        logger.e(e.toString());
      }
    return date;
  }

  static String parseStringDateToString(
      String dateSv, String fromFormat, String toFormat) {
    String date = dateSv;
    if (dateSv != null)
      try {
        date = DateFormat(toFormat, "en_US")
            .format(DateFormat(fromFormat).parse(dateSv));
      } on FormatException catch (e) {
        logger.d(e.toString());
      }
    return date;
  }

  static String parseDateDefault(String dateSv, String toFormat) {
    String date = dateSv;
    if (dateSv != null)
      try {
        date = DateFormat(toFormat).format(DateTime.parse(dateSv));
      } on FormatException catch (e) {
        logger.d(e.toString());
      }
    return date;
  }
}
