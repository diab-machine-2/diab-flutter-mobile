import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';

enum ScheduleType {
  blood_sugar,
  blood_pressure,
  weight,
  emotion,
  food,
  exercise,
  hba1c,
  exercise_movement,
  custom,
  coaching,
  group,
  survey,
}

extension ScheduleTypeExtend on ScheduleType {
  String get icon {
    switch (this) {
      case ScheduleType.blood_sugar:
        return R.drawable.ic_blood_sugar;
      case ScheduleType.blood_pressure:
        return R.drawable.ic_schedule_blood_pressure;
      case ScheduleType.weight:
        return R.drawable.ic_weight;
      case ScheduleType.emotion:
        return R.drawable.ic_schedule_emotion;
      case ScheduleType.food:
        return R.drawable.ic_schedule_food;
      case ScheduleType.exercise:
        return R.drawable.ic_exercise;
      case ScheduleType.hba1c:
        return R.drawable.ic_schedule_hba1c;
      case ScheduleType.exercise_movement:
        return R.drawable.ic_exercise;
      case ScheduleType.custom:
        return R.drawable.ic_schedule_custom;
      case ScheduleType.coaching:
        return R.drawable.ic_schedule_coaching;
      case ScheduleType.group:
        return R.drawable.ic_schedule_group;
      case ScheduleType.survey:
        return R.drawable.ic_schedule_survey;
    }
  }

  String get title {
    switch (this) {
      case ScheduleType.blood_sugar:
        return R.string.smart_goal_blood_sugar.tr();
      case ScheduleType.blood_pressure:
        return R.string.smart_goal_blood_sugar.tr();
      case ScheduleType.weight:
        return R.string.smart_goal_blood_sugar.tr();
      case ScheduleType.emotion:
        return R.string.smart_goal_blood_sugar.tr();
      case ScheduleType.food:
        return R.string.smart_goal_blood_sugar.tr();
      case ScheduleType.exercise:
        return R.string.smart_goal_blood_sugar.tr();
      case ScheduleType.hba1c:
        return R.string.smart_goal_blood_sugar.tr();
      case ScheduleType.exercise_movement:
        return '';
      case ScheduleType.custom:
        return '';
      case ScheduleType.coaching:
        return '';
      case ScheduleType.group:
        return '';
      case ScheduleType.survey:
        return '';
    }
  }

  int get setupTypeUIIndex {
    switch (this) {
      case ScheduleType.blood_sugar:
        return -1;
      case ScheduleType.blood_pressure:
        return 1;
      case ScheduleType.weight:
        return 1;
      case ScheduleType.emotion:
        return 1;
      case ScheduleType.food:
        return 1;
      case ScheduleType.exercise:
        return 2;
      case ScheduleType.hba1c:
        return 1;
      case ScheduleType.exercise_movement:
        return -1;
      case ScheduleType.custom:
        return -1;
      case ScheduleType.coaching:
        return -1;
      case ScheduleType.group:
        return -1;
      case ScheduleType.survey:
        return -1;
    }
  }

  int get typeIndex {
    switch (this) {
      case ScheduleType.blood_sugar:
        return 2;
      case ScheduleType.blood_pressure:
        return 1;
      case ScheduleType.weight:
        return 4;
      case ScheduleType.emotion:
        return 5;
      case ScheduleType.food:
        return 7;
      case ScheduleType.exercise:
        return 3;
      case ScheduleType.hba1c:
        return 6;
      case ScheduleType.exercise_movement:
        return 8;
      case ScheduleType.custom:
        return 0;
      case ScheduleType.coaching:
        return 9;
      case ScheduleType.group:
        return 10;
      case ScheduleType.survey:
        return 11;
    }
  }

  bool get editable {
    switch (this) {
      case ScheduleType.blood_sugar:
        return true;
      case ScheduleType.blood_pressure:
        return true;
      case ScheduleType.weight:
        return true;
      case ScheduleType.emotion:
        return true;
      case ScheduleType.food:
        return true;
      case ScheduleType.exercise:
        return true;
      case ScheduleType.hba1c:
        return true;
      case ScheduleType.exercise_movement:
        return false;
      case ScheduleType.custom:
        return true;
      case ScheduleType.coaching:
        return false;
      case ScheduleType.group:
        return false;
      case ScheduleType.survey:
        return false;
    }
  }

  static ScheduleType getTypeFromIndex(int? index) {
    if (index == ScheduleType.blood_pressure.typeIndex)
      return ScheduleType.blood_pressure;
    if (index == ScheduleType.blood_sugar.typeIndex)
      return ScheduleType.blood_sugar;
    if (index == ScheduleType.exercise.typeIndex) return ScheduleType.exercise;
    if (index == ScheduleType.weight.typeIndex) return ScheduleType.weight;
    if (index == ScheduleType.emotion.typeIndex) return ScheduleType.emotion;
    if (index == ScheduleType.hba1c.typeIndex) return ScheduleType.hba1c;
    if (index == ScheduleType.food.typeIndex) return ScheduleType.food;
    if (index == ScheduleType.exercise_movement.typeIndex)
      return ScheduleType.exercise_movement;
    if (index == ScheduleType.coaching.typeIndex) return ScheduleType.coaching;
    if (index == ScheduleType.group.typeIndex) return ScheduleType.group;
    if (index == ScheduleType.survey.typeIndex) return ScheduleType.survey;
    return ScheduleType.custom;
  }
}
