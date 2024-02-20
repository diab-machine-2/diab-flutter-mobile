import 'package:intl/intl.dart';
import 'package:medical/src/utils/app_log.dart';

class DateUtil {
  static bool? isAfter(int? dateTime1, int? dateTime2) {
    DateTime? date1;
    DateTime? date2;
    if (dateTime1 != null) {
      date1 = DateTime.fromMillisecondsSinceEpoch(dateTime1 * 1000);
      date1 = DateTime(date1.year, date1.month, date1.day);
    }
    if (dateTime2 != null) {
      date2 = DateTime.fromMillisecondsSinceEpoch(dateTime2 * 1000);
      date2 = DateTime(date2.year, date2.month, date2.day);
    }
    if (date1 != null && date2 != null) {
      return date1.isAfter(date2);
    } else {
      return null;
    }
  }

  static int getDayInMillis(DateTime dateTime) {
    int startDate = (dateTime.millisecondsSinceEpoch ~/ 1000).toInt();
    return startDate;
  }

  static int getCurrentDayInMillis() {
    DateTime dateTime0 = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);
    int startDate = (dateTime0.millisecondsSinceEpoch ~/ 1000).toInt();
    return startDate;
  }

  static int getCurrentNowInMillis() {
    int startDate = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toInt();
    return startDate;
  }

  static bool? isBefore(int? dateTime1, int? dateTime2) {
    DateTime? date1;
    DateTime? date2;
    if (dateTime1 != null) {
      date1 = DateTime.fromMillisecondsSinceEpoch(dateTime1 * 1000);
      date1 = DateTime(date1.year, date1.month, date1.day);
    }
    if (dateTime2 != null) {
      date2 = DateTime.fromMillisecondsSinceEpoch(dateTime2 * 1000);
      date2 = DateTime(date2.year, date2.month, date2.day);
    }
    if (date1 != null && date2 != null) {
      return date1.isBefore(date2);
    } else {
      return null;
    }
  }

  static bool isSameDay(int? dateTime1, int? dateTime2) {
    DateTime? date1;
    DateTime? date2;
    if (dateTime1 != null) {
      date1 = DateTime.fromMillisecondsSinceEpoch(dateTime1 * 1000);
      date1 = DateTime(date1.year, date1.month, date1.day);
    }
    if (dateTime2 != null) {
      date2 = DateTime.fromMillisecondsSinceEpoch(dateTime2 * 1000);
      date2 = DateTime(date2.year, date2.month, date2.day);
    }
    if (date1 != null && date2 != null) {
      return date1.year == date2.year &&
          date1.month == date2.month &&
          date1.day == date2.day;
    } else {
      return false;
    }
  }

  static bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static DateTime parseTimespanToDateTime(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return date;
  }

  static DateTime? parseStringToDate(String dateStr, String format) {
    DateTime? date;
    try {
      date = DateFormat(format).parse(dateStr);
    } on FormatException catch (e) {
      Console.log('parseStringToDate Error', e.toString());
    }
    return date;
  }

  static String parseDateToString(DateTime? dateTime, String format,
      {String? locale}) {
    String date = "";
    if (dateTime != null)
      try {
        date = DateFormat(format, locale).format(dateTime);
      } on FormatException catch (e) {
        Console.log('parseDateToString Error', e.toString());
      }
    return date;
  }

  static String? parseStringDateToString(
      String? dateSv, String fromFormat, String toFormat) {
    String? date = dateSv;
    if (dateSv != null)
      try {
        date =
            DateFormat(toFormat).format(DateFormat(fromFormat).parse(dateSv));
      } on FormatException catch (e) {
        Console.log('parseStringDateToString Error', e.toString());
      }
    return date;
  }

  static String? parseDateDefault(String? dateSv, String? toFormat) {
    String? date = dateSv;
    if (dateSv != null)
      try {
        date = DateFormat(toFormat).format(DateTime.parse(dateSv));
      } on FormatException catch (e) {
        Console.log('parseDateDefault Error', e.toString());
      }
    return date;
  }

  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  static int diffInDays(DateTime date1, DateTime date2) {
    return ((date1.difference(date2) -
                    Duration(hours: date1.hour) +
                    Duration(hours: date2.hour))
                .inHours /
            24)
        .round();
  }

  static String? convertDateTime(
    String? date, {
    bool isShowTime = false,
    bool isShowOnlyTime = false,
    bool toLocal = true,
    bool isTimeFromServer = true,
    String separate = '-',
  }) {
    if (date == null || date == '') return null;
    late DateFormat dateFormat;
    late DateTime dateConverted;
    if (isTimeFromServer) {
      dateConverted = DateTime.parse(date);
    } else {
      if (date.contains('-')) {
        dateFormat = DateFormat('dd-MM-yyyy');
      } else {
        dateFormat = DateFormat('dd/MM/yyyy');
      }
      dateConverted = dateFormat.parse(date);
    }

    Console.log('dateConverted', dateConverted);
    if (toLocal) dateConverted = dateConverted.toLocal();
    Console.log('dateConverted', dateConverted);

    return isShowOnlyTime
        ? DateFormat('HH:mm').format(dateConverted).toString()
        : isShowTime
            ? DateFormat('HH:mm $separate dd/MM/yyyy')
                .format(dateConverted)
                .toString()
            : DateFormat('dd/MM/yyyy').format(dateConverted).toString();
  }
}
