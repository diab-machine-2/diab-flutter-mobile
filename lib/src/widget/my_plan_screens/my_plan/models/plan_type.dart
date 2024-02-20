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
        return R.string.title_activity;
      case PlanType.lesson:
        return R.string.title_lesson;
      case PlanType.activity:
        return R.string.title_exercise;
    }
  }
  int get planTypeIndex {
    switch (this) {
      case PlanType.goal:
        return 0;
      case PlanType.lesson:
        return 1;
      case PlanType.activity:
        return 2;
    }
  }
}
