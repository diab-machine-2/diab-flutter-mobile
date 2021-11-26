import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';

enum GoalFilterType {
  day,
  week,
}

extension GoalFilterTypeDetail on GoalFilterType {
  String get title {
    switch (this) {
      case GoalFilterType.day:
        return R.string.goal_of_day.tr();
      case GoalFilterType.week:
        return R.string.goal_of_week.tr();
    }
  }
}
