import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:medical/src/theme/app_theme.dart';

String convertToUTC(int timeStamp, String fotmat) {
  final date = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
  String formattedDate = DateFormat(fotmat).format(date);
  return formattedDate;
}

String convertToTicketDate(int timeStamp, String format) {
  final date = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
  String formattedDate = DateFormat('EEEE, $format', 'vi_VN').format(date);
  return formattedDate;
}

String convertToSectionTicketDate(int timeStamp, String format) {
  final date = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
  // String languageCode = Localizations.localeOf(context).languageCode;
  String formattedDate =
      DateFormat('dd/MMMM/yyyy, $format', 'vi_VN').format(date);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final aDate = DateTime(date.year, date.month, date.day);
  if (aDate == today) {
    return 'Hôm nay, ' + convertToUTC(timeStamp, 'dd/MM/yyyy');
  } else {
    return formattedDate;
  }
}

String getStringToday(int timeStamp) {
  final now = DateTime.now();
  final date = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
  if (now.day == date.day && now.month == date.month && now.year == date.year) {
    return 'Hôm nay';
  } else if (now.day - 1 == date.day &&
      now.month == date.month &&
      now.year == date.year) {
    return 'Hôm qua';
  } else {
    return '';
  }
}

String convertStringDate(String stringDate) {
  final date = DateFormat('dd/MM/yyyy').parse(stringDate);
  return '${date.day} tháng ${date.month} năm ${date.year}';
}

String convertCustomDate(int timeStamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
  final now = DateTime.now();
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return 'Hôm nay';
  } else {
    return '${date.day} tháng ${date.month} năm ${date.year}';
  }
}

DateTime toDate(int timeStamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
  return DateTime(date.year, date.month, date.day);
}

String toStringDate(DateTime date) {
  return '${date.day} tháng ${date.month} năm ${date.year}';
}

String toWeek(int timeStamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
  if (date.weekday == 7) {
    return 'CN';
  } else {
    return 'T' + (date.weekday + 1).toString();
  }
}

Color toColor(String hex) {
  if (hex == null) {
    return mainColor;
  } else {
    if (hex.length == 7) {
      return Color(int.parse('0xff${hex.split('#').join()}'));
    } else {
      return mainColor;
    }
  }
}

String roundNumber(double number) {
  final round = number.round();
  final result = round - number;
  if (result == 0) {
    return number.round().toString();
  } else {
    return number.toString().split('.').join(',');
  }
}

String roundNumber1(double number) {
  final round = number.round();
  final result = round - number;
  if (result == 0) {
    return number.round().toString();
  } else {
    return number.toString();
  }
}

double roundAsFixed(double number) {
  final data = number.toStringAsFixed(1);
  return double.parse(data);
}

String formatNumber(double number) {
  return NumberFormat.decimalPattern().format(number);
}
