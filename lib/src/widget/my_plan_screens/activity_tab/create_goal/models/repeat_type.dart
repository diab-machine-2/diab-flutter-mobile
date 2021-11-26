enum RepeatType {
  day,
  week,
}

extension RepeatTypeExtend on RepeatType {
  String get title {
    switch (this) {
      case RepeatType.day:
        return 'Hàng ngày';
      case RepeatType.week:
        return 'Hàng tuần';
    }
  }

  static RepeatType getTypeFromString(String title) {
    if (title == 'Hàng tuần')
      return RepeatType.week;
    else
      return RepeatType.day;
  }
}
