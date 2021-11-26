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
      case DayInWeek.sun:
        return 7;
    }
  }

  static DayInWeek getDayInWeekFromString(String text) {
    switch (text) {
      case 'Thứ hai':
        return DayInWeek.mon;
      case 'Thứ ba':
        return DayInWeek.tue;
      case 'Thứ tư':
        return DayInWeek.wed;
      case 'Thứ năm':
        return DayInWeek.thu;
      case 'Thứ sáu':
        return DayInWeek.fri;
      case 'Thứ bảy':
        return DayInWeek.sat;
      case 'Chủ nhật':
        return DayInWeek.sun;
    }
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
