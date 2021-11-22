import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';

enum GoalType {
  day,
  week,
}

extension GoalTypeDetail on GoalType {
  String get title {
    switch (this) {
      case GoalType.day:
        return R.string.goal_of_day.tr();
      case GoalType.week:
        return R.string.goal_of_week.tr();
    }
  }
}
