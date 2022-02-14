enum FilterType {
  week2,
  week4,
  week6,
  all,
}

extension FilterTypeExtends on FilterType {
  String get title {
    switch (this) {
      case FilterType.week2:
        return '2 tuần';
      case FilterType.week4:
        return '4 tuần';
      case FilterType.week6:
        return '6 tuần';
      case FilterType.all:
        return 'Từ đầu lộ trình';
    }
  }

  static FilterType? getTypeFromString(String text) {
    if (text == FilterType.week2.title) return FilterType.week2;
    if (text == FilterType.week4.title) return FilterType.week4;
    if (text == FilterType.week6.title) return FilterType.week6;
    if (text == FilterType.all.title) return FilterType.all;
    return null;
  }
}
