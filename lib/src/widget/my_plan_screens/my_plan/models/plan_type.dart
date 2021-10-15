import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';

enum PlanType {
  goal,
  lesson,
  activity,
}

extension PlanTypeDetail on PlanType {
  String get title {
    switch (this) {
      case PlanType.goal:
        return R.string.title_goal.tr();
      case PlanType.lesson:
        return R.string.title_lesson.tr();
      case PlanType.activity:
        return R.string.title_activity.tr();
    }
  }
}
