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
  meditate,
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
      case ScheduleType.meditate:
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
        return 'Đo đường huyết';
      case ScheduleType.blood_pressure:
        return 'Đo huyết áp';
      case ScheduleType.weight:
        return 'Đo cân nặng';
      case ScheduleType.emotion:
        return 'Nhập cảm xúc';
      case ScheduleType.food:
        return 'Cập nhật bữa ăn';
      case ScheduleType.exercise:
        return 'Vận động';
      case ScheduleType.hba1c:
        return 'Đo HbA1C';
      case ScheduleType.exercise_movement:
        return '';
      case ScheduleType.meditate:
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
      case ScheduleType.meditate:
        return -1;
      case ScheduleType.coaching:
        return -1;
      case ScheduleType.group:
        return -1;
      case ScheduleType.survey:
        return -1;
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
      case ScheduleType.meditate:
        return true;
      case ScheduleType.coaching:
        return false;
      case ScheduleType.group:
        return false;
      case ScheduleType.survey:
        return false;
    }
  }
}
