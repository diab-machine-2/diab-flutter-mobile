import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';

enum GoalRecordType {
  time,
  frequency,
}

extension GoalRecordTypeExtend on GoalRecordType {
  String get title {
    switch (this) {
      case GoalRecordType.time:
        return R.string.goal_record_type_time.tr();
      case GoalRecordType.frequency:
        return R.string.goal_record_type_frequency.tr();
    }
  }

  String get unit {
    switch (this) {
      case GoalRecordType.time:
        return R.string.minute.tr();
      case GoalRecordType.frequency:
        return R.string.single_time.tr();
    }
  }

  int get index {
    switch (this) {
      case GoalRecordType.time:
        return 0;
      case GoalRecordType.frequency:
        return 1;
    }
  }

  static GoalRecordType getGoalRecordTypeFromIndex(int index) {
    switch (index) {
      case 0:
        return GoalRecordType.time;
      case 1:
        return GoalRecordType.frequency;
    }
    return GoalRecordType.time;
  }
}
