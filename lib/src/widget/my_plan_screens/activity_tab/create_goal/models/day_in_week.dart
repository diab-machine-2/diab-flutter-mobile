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
        return 'Thứ hai';
      case DayInWeek.tue:
        return 'Thứ ba';
      case DayInWeek.wed:
        return 'Thứ tư';
      case DayInWeek.thu:
        return 'Thứ năm';
      case DayInWeek.fri:
        return 'Thứ sáu';
      case DayInWeek.sat:
        return 'Thứ bảy';
      case DayInWeek.sun:
        return 'Chủ nhật';
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
      case DayInWeek.mon:
        return 0;
      case DayInWeek.tue:
        return 1;
      case DayInWeek.wed:
        return 2;
      case DayInWeek.thu:
        return 3;
      case DayInWeek.fri:
        return 4;
      case DayInWeek.sat:
        return 5;
      case DayInWeek.sun:
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
    if (index == DayInWeek.mon.index) return DayInWeek.mon;
    if (index == DayInWeek.tue.index) return DayInWeek.tue;
    if (index == DayInWeek.wed.index) return DayInWeek.wed;
    if (index == DayInWeek.thu.index) return DayInWeek.thu;
    if (index == DayInWeek.fri.index) return DayInWeek.fri;
    if (index == DayInWeek.sat.index) return DayInWeek.sat;
    if (index == DayInWeek.sun.index) return DayInWeek.sun;
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
