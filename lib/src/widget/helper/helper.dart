import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/home/home_model.dart';

String convertToUTC(int timeStamp, String fotmat) {
  final date = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
  String formattedDate = DateFormat(fotmat).format(date);
  return formattedDate;
}

String convertToGMT0(int timeStamp, String fotmat) {
  final date = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
  String formattedDate = DateFormat(fotmat).format(date.toUtc());
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
  String formattedDate = DateFormat('dd/MMMM/yyyy, $format', 'vi_VN').format(date);
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
    return R.string.today.tr();
  } else if (now.day - 1 == date.day && now.month == date.month && now.year == date.year) {
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
    return R.string.today.tr();
  } else {
    return '${date.day} tháng ${date.month} năm ${date.year}';
  }
}

DateTime toDate(int timeStamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
  return DateTime(date.year, date.month, date.day);
}

int convertToGMT(int? timeStamp){
  if(timeStamp != null){
    var date = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    date = date.add(Duration(hours: 7));
    return date.millisecondsSinceEpoch ~/ 1000;
  } else {
    return 0;
  }
}

String getWeekDay(int timeStamp){
  final date = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
  var dateTime = DateTime(date.year, date.month, date.day);
  if(dateTime.weekday + 1 >= 2 && dateTime.weekday + 1 <=7){
    return "Thứ ${dateTime.weekday + 1}";
  } else if(dateTime.weekday + 1 == 8){
    return "Chủ Nhật";
  } else {
    return "";
  }
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

Color toColor(String? hex) {
  if (hex == null) {
    return R.color.mainColor;
  } else {
    if (hex.length == 7) {
      return Color(int.parse('0xff${hex.split('#').join()}'));
    } else {
      return R.color.mainColor;
    }
  }
}

Color getColorExercise(ExerciseIndexModel model) {
  if (model.targetExercise != 0) {
    double percent = model.facExercise! / model.targetExercise! * 100;
    percent = 10;
    if (percent > 0 && percent <= 10) {
      return toColor('#fdd6b4');
    } else if (percent > 10 && percent <= 25) {
      return toColor('#f78d1c');
    } else if (percent > 25 && percent <= 50) {
      return toColor('#ffacaf');
    } else if (percent > 50 && percent <= 75) {
      return toColor('#f24744');
    } else if (percent > 75 && percent <= 90) {
      return toColor('#d3eedf');
    } else if (percent > 90 && percent <= 100) {
      return toColor('#3bb479');
    } else {
      return R.color.transparent;
    }
  } else {
    return R.color.transparent;
  }
}

String roundNumberToInt(double number){
  final round = number.round();
  return round.toString();
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

String formatNumber(double? number) {
  return NumberFormat.decimalPattern().format(number);
}
