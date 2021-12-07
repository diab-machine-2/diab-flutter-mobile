enum FilterType {
  day14,
  day30,
  all,
}

extension FilterTypeExtends on FilterType {
  String get title {
    switch (this) {
      case FilterType.day14:
        return '14 ngày';
      case FilterType.day30:
        return '30 ngày';
      case FilterType.all:
        return 'Từ đầu lộ trình';
    }
  }

  static FilterType? getTypeFromString(String text) {
    if (text == FilterType.day14.title) return FilterType.day14;
    if (text == FilterType.day30.title) return FilterType.day30;
    if (text == FilterType.all.title) return FilterType.all;
    return null;
  }
}
