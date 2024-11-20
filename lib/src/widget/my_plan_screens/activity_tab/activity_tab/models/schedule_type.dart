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
  output_assessment,

  // New Recommend
  lesson_recommend,
  blood_sugar_recommend, // Glucose
  hba1c_recommend,
  schedule_glucose_recommend,
  food_menu,
  goal_setting_recommend,
  schedule_recommend,
  blood_pressure_recommend,
  height_recommend,
  weight_recommend,
  exercise_recommend,
  food_recommend,
  update_profile_recommend,
  peripheral_recommend,
  completed,
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
        return R.drawable.ic_schedule_bool_1_1;
      case ScheduleType.survey:
        return R.drawable.ic_schedule_survey;
      case ScheduleType.lesson:
        return R.drawable.ic_schedule_lesson;
      case ScheduleType.io_evaluate:
        return R.drawable.ic_schedule_io_evaluate;
      case ScheduleType.update_profile:
        return R.drawable.ic_schedule_update_profile;
      case ScheduleType.output_assessment:
        return R.drawable.ic_schedule_io_evaluate;

      // New Recommend
      case ScheduleType.lesson_recommend:
        return R.drawable.ic_schedule_lesson;
      case ScheduleType.blood_sugar_recommend:
        return R.drawable.ic_schedule_blood_sugar;
      case ScheduleType.hba1c_recommend:
        return R.drawable.ic_schedule_hb1ac;
      case ScheduleType.schedule_glucose_recommend:
        return R.drawable.ic_schedule_blood_sugar;
      case ScheduleType.food_menu:
        return R.drawable.ic_schedule_food;
      case ScheduleType.goal_setting_recommend:
        return R.drawable.ic_schedule_custom;
      case ScheduleType.schedule_recommend:
        return R.drawable.ic_reminder;
      case ScheduleType.blood_pressure_recommend:
        return R.drawable.ic_home_measurement_blood;
      case ScheduleType.height_recommend:
        return R.drawable.ic_home_target;
      case ScheduleType.weight_recommend:
        return R.drawable.ic_home_measurement_weight;
      case ScheduleType.exercise_recommend:
        return R.drawable.ic_home_measurement_exercise;
      case ScheduleType.food_recommend:
        return R.drawable.ic_home_measurement_nutrition;
      case ScheduleType.update_profile_recommend:
        return R.drawable.ic_schedule_update_profile;
      case ScheduleType.peripheral_recommend:
        return R.drawable.ic_home_peripheral;
      case ScheduleType.completed:
        return R.drawable.ic_home_target;
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

      // New Recommend : NOT USE
      case ScheduleType.lesson_recommend:
      case ScheduleType.blood_sugar_recommend:
      case ScheduleType.hba1c_recommend:
      case ScheduleType.schedule_glucose_recommend:
      case ScheduleType.food_menu:
      case ScheduleType.goal_setting_recommend:
      case ScheduleType.schedule_recommend:
      case ScheduleType.blood_pressure_recommend:
      case ScheduleType.height_recommend:
      case ScheduleType.weight_recommend:
      case ScheduleType.exercise_recommend:
      case ScheduleType.food_recommend:
      case ScheduleType.update_profile_recommend:
      case ScheduleType.peripheral_recommend:
      case ScheduleType.completed:
        return "";
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

      default:
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
      // New Recommend
      case ScheduleType.lesson_recommend:
        return 15;
      case ScheduleType.blood_sugar_recommend:
        return 16;
      case ScheduleType.hba1c_recommend:
        return 17;
      case ScheduleType.schedule_glucose_recommend:
        return 18;
      case ScheduleType.food_menu:
        return 19;
      case ScheduleType.goal_setting_recommend:
        return 20;
      case ScheduleType.schedule_recommend:
        return 21;
      case ScheduleType.blood_pressure_recommend:
        return 22;
      case ScheduleType.height_recommend:
        return 23;
      case ScheduleType.weight_recommend:
        return 24;
      case ScheduleType.exercise_recommend:
        return 25;
      case ScheduleType.food_recommend:
        return 26;
      case ScheduleType.update_profile_recommend:
        return 27;
      case ScheduleType.peripheral_recommend:
        return 28;
      case ScheduleType.completed:
        return 29;
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
        return true;
      case ScheduleType.update_profile:
        return false;
      case ScheduleType.output_assessment:
        return false;
      default:
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
    if (index == ScheduleType.update_profile.typeIndex)
      return ScheduleType.update_profile;
    if (index == ScheduleType.exercise_movement.typeIndex)
      return ScheduleType.exercise_movement;
    if (index == ScheduleType.book_1_1.typeIndex) return ScheduleType.book_1_1;
    if (index == ScheduleType.book_1_n.typeIndex) return ScheduleType.book_1_n;
    if (index == ScheduleType.survey.typeIndex) return ScheduleType.survey;
    if (index == ScheduleType.lesson.typeIndex) return ScheduleType.lesson;
    if (index == ScheduleType.io_evaluate.typeIndex)
      return ScheduleType.io_evaluate;
    if (index == ScheduleType.output_assessment.typeIndex)
      return ScheduleType.output_assessment;

    // NEW recommend target
    if (index == ScheduleType.lesson_recommend.typeIndex)
      return ScheduleType.lesson_recommend;
    if (index == ScheduleType.blood_sugar_recommend.typeIndex)
      return ScheduleType.blood_sugar_recommend;
    if (index == ScheduleType.hba1c_recommend.typeIndex)
      return ScheduleType.hba1c_recommend;
    if (index == ScheduleType.schedule_glucose_recommend.typeIndex)
      return ScheduleType.schedule_glucose_recommend;
    if (index == ScheduleType.food_menu.typeIndex)
      return ScheduleType.food_menu;
    if (index == ScheduleType.goal_setting_recommend.typeIndex)
      return ScheduleType.goal_setting_recommend;
    if (index == ScheduleType.schedule_recommend.typeIndex)
      return ScheduleType.schedule_recommend;
    if (index == ScheduleType.blood_pressure_recommend.typeIndex)
      return ScheduleType.blood_pressure_recommend;
    if (index == ScheduleType.height_recommend.typeIndex)
      return ScheduleType.height_recommend;
    if (index == ScheduleType.weight_recommend.typeIndex)
      return ScheduleType.weight_recommend;
    if (index == ScheduleType.exercise_recommend.typeIndex)
      return ScheduleType.exercise_recommend;
    if (index == ScheduleType.food_recommend.typeIndex)
      return ScheduleType.food_recommend;
    if (index == ScheduleType.update_profile_recommend.typeIndex)
      return ScheduleType.update_profile_recommend;
    if (index == ScheduleType.peripheral_recommend.typeIndex)
      return ScheduleType.peripheral_recommend;
    if (index == ScheduleType.completed.typeIndex)
      return ScheduleType.completed;

    return ScheduleType.custom;
  }
}
