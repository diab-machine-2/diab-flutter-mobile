import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';

enum ScheduleType {
  blood_sugar,
  blood_pressure,
  weight,
  emotion,
  food,
  exercise,
  exercise_movement,
  custom,
  book_1_1,
  book_1_n,
  survey,
  lesson,
  io_evaluate,
  update_profile,
  output_assessment
}

extension ScheduleTypeExtend on ScheduleType {
  String get icon {
    switch (this) {
      case ScheduleType.blood_sugar:
        return R.drawable.ic_schedule_blood_sugar;
      case ScheduleType.blood_pressure:
        return R.drawable.ic_schedule_blood_pressure;
      case ScheduleType.weight:
        return R.drawable.ic_schedule_weight;
      case ScheduleType.emotion:
        return R.drawable.ic_schedule_emotion;
      case ScheduleType.food:
        return R.drawable.ic_schedule_food;
      case ScheduleType.exercise:
        return R.drawable.ic_schedule_exercise;
      case ScheduleType.exercise_movement:
        return R.drawable.ic_schedule_exercise_lesson;
      case ScheduleType.custom:
        return R.drawable.ic_schedule_custom;
      case ScheduleType.book_1_1:
        return R.drawable.ic_schedule_book_1_1;
      case ScheduleType.book_1_n:
        return R.drawable.ic_schedule_book_1_n;
      case ScheduleType.survey:
        return R.drawable.ic_schedule_survey;
      case ScheduleType.lesson:
        return R.drawable.ic_schedule_exercise;
      case ScheduleType.io_evaluate:
        return R.drawable.ic_schedule_book_1_1;
      case ScheduleType.update_profile:
        return R.drawable.ic_schedule_update_profile;
        case ScheduleType.output_assessment:
        return R.drawable.ic_schedule_book_1_1;
    }
  }

  String get title {
    switch (this) {
      case ScheduleType.blood_sugar:
        return R.string.smart_goal_blood_sugar.tr();
      case ScheduleType.blood_pressure:
        return R.string.smart_goal_blood_pressure.tr();
      case ScheduleType.weight:
        return R.string.smart_goal_weight.tr();
      case ScheduleType.emotion:
        return R.string.smart_goal_emotion.tr();
      case ScheduleType.food:
        return R.string.smart_goal_food.tr();
      case ScheduleType.exercise:
        return R.string.smart_goal_exercise.tr();
      case ScheduleType.exercise_movement:
        return R.string.smart_goal_exercise_lesson.tr();
      case ScheduleType.custom:
        return '';
      case ScheduleType.book_1_1:
        return R.string.coaching_11.tr();
      case ScheduleType.book_1_n:
        return R.string.coaching_1n.tr();
      case ScheduleType.survey:
        return R.string.survey.tr();
      case ScheduleType.lesson:
        return R.string.smart_goal_lesson.tr();
      case ScheduleType.io_evaluate:
        return R.string.input_evaluate;
      case ScheduleType.update_profile:
        return R.string.update_profile_type.tr();
      case ScheduleType.output_assessment:
        return R.string.output_evaluate.tr();
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
      case ScheduleType.exercise_movement:
        return -1;
      case ScheduleType.custom:
        return -1;
      case ScheduleType.book_1_1:
        return -1;
      case ScheduleType.book_1_n:
        return -1;
      case ScheduleType.survey:
        return -1;
      case ScheduleType.lesson:
        return -1;
      case ScheduleType.io_evaluate:
        return -1;
      case ScheduleType.update_profile:
        return -1;
      case ScheduleType.output_assessment:
        return -1;
    }
  }

  int get typeIndex {
    switch (this) {
      case ScheduleType.custom:
        return 0;
      case ScheduleType.blood_pressure:
        return 1;
      case ScheduleType.blood_sugar:
        return 2;
      case ScheduleType.exercise:
        return 3;
      case ScheduleType.weight:
        return 4;
      case ScheduleType.emotion:
        return 5;
      case ScheduleType.food:
        return 6;
      case ScheduleType.exercise_movement:
        return 7;
      case ScheduleType.book_1_1:
        return 8;
      case ScheduleType.book_1_n:
        return 9;
      case ScheduleType.io_evaluate:
        return 10;
      case ScheduleType.lesson:
        return 11;
      case ScheduleType.survey:
        return 12;
      case ScheduleType.update_profile:
        return 13;
      case ScheduleType.output_assessment:
        return 14;
    }
  }

  bool get removeAble {
    switch (this) {
      case ScheduleType.custom:
        return true;
      case ScheduleType.blood_pressure:
        return true;
      case ScheduleType.blood_sugar:
        return true;
      case ScheduleType.exercise:
        return true;
      case ScheduleType.weight:
        return true;
      case ScheduleType.emotion:
        return true;
      case ScheduleType.food:
        return true;
      case ScheduleType.exercise_movement:
        return false;
      case ScheduleType.book_1_1:
        return false;
      case ScheduleType.book_1_n:
        return true;
      case ScheduleType.io_evaluate:
        return false;
      case ScheduleType.lesson:
        return false;
      case ScheduleType.survey:
        return false;
      case ScheduleType.update_profile:
        return false;
      case ScheduleType.output_assessment:
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
    if (index == ScheduleType.food.typeIndex) return ScheduleType.food;
    if (index == ScheduleType.exercise_movement.typeIndex)
      return ScheduleType.exercise_movement;
    if (index == ScheduleType.book_1_1.typeIndex) return ScheduleType.book_1_1;
    if (index == ScheduleType.book_1_n.typeIndex) return ScheduleType.book_1_n;
    if (index == ScheduleType.survey.typeIndex) return ScheduleType.survey;
    if (index == ScheduleType.lesson.typeIndex) return ScheduleType.lesson;
    if (index == ScheduleType.io_evaluate.typeIndex) return ScheduleType.io_evaluate;
    if (index == ScheduleType.output_assessment.typeIndex) return ScheduleType.output_assessment;
    return ScheduleType.custom;
  }
}
