import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';

enum DayInWeek {
  mon,
  tue,
  wed,
  thu,
  fri,
  sat,
  sun,
}

extension DayInWeekExtend on DayInWeek {
  String get title {
    switch (this) {
      case DayInWeek.mon:
        return R.string.day_in_week_monday.tr();
      case DayInWeek.tue:
        return R.string.day_in_week_tuesday.tr();
      case DayInWeek.wed:
        return R.string.day_in_week_wednesday.tr();
      case DayInWeek.thu:
        return R.string.day_in_week_thursday.tr();
      case DayInWeek.fri:
        return R.string.day_in_week_friday.tr();
      case DayInWeek.sat:
        return R.string.day_in_week_saturday.tr();
      case DayInWeek.sun:
        return R.string.day_in_week_sunday.tr();
    }
  }

  String get shortTitle {
    switch (this) {
      case DayInWeek.mon:
        return 'T2';
      case DayInWeek.tue:
        return 'T3';
      case DayInWeek.wed:
        return 'T4';
      case DayInWeek.thu:
        return 'T5';
      case DayInWeek.fri:
        return 'T6';
      case DayInWeek.sat:
        return 'T7';
      case DayInWeek.sun:
        return 'CN';
    }
  }

  int get index {
    switch (this) {
      case DayInWeek.sun:
        return 0;
      case DayInWeek.mon:
        return 1;
      case DayInWeek.tue:
        return 2;
      case DayInWeek.wed:
        return 3;
      case DayInWeek.thu:
        return 4;
      case DayInWeek.fri:
        return 5;
      case DayInWeek.sat:
        return 6;
    }
  }

  static DayInWeek getDayInWeekFromString(String text) {
    if (text == DayInWeek.mon.title) return DayInWeek.mon;
    if (text == DayInWeek.tue.title) return DayInWeek.tue;
    if (text == DayInWeek.wed.title) return DayInWeek.wed;
    if (text == DayInWeek.thu.title) return DayInWeek.thu;
    if (text == DayInWeek.fri.title) return DayInWeek.fri;
    if (text == DayInWeek.sat.title) return DayInWeek.sat;
    if (text == DayInWeek.sun.title) return DayInWeek.sun;
    return DayInWeek.mon;
  }

  static DayInWeek getDayInWeekFromIndex(int? index) {
    if (index == 1) return DayInWeek.mon;
    if (index == 2) return DayInWeek.tue;
    if (index == 3) return DayInWeek.wed;
    if (index == 4) return DayInWeek.thu;
    if (index == 5) return DayInWeek.fri;
    if (index == 6) return DayInWeek.sat;
    if (index == 7) return DayInWeek.sun;
    if (index == 0) return DayInWeek.sun;
    return DayInWeek.mon;
  }

  static List<DayInWeek> get dayInWeekList => [
        DayInWeek.mon,
        DayInWeek.tue,
        DayInWeek.wed,
        DayInWeek.thu,
        DayInWeek.fri,
        DayInWeek.sat,
        DayInWeek.sun,
      ];
}
