import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';

enum RepeatType {
  day,
  week,
}

extension RepeatTypeExtend on RepeatType {
  String get title {
    switch (this) {
      case RepeatType.day:
        return R.string.every_day.tr();
      case RepeatType.week:
        return R.string.every_week.tr();
    }
  }

  static RepeatType getTypeFromString(String title) {
    if (title == RepeatType.week.title.tr())
      return RepeatType.week;
    else
      return RepeatType.day;
  }

  static RepeatType getTypeFromNumber(int? index) {
    if (index == 1)
      return RepeatType.week;
    else
      return RepeatType.day;
  }
}
