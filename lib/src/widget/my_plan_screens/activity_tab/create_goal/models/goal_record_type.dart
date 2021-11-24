enum GoalRecordType {
  time,
  frequency,
}

extension GoalRecordTypeExtend on GoalRecordType {
  String get title {
    switch (this) {
      case GoalRecordType.time:
        return 'Thời gian thực hiện';
      case GoalRecordType.frequency:
        return 'Số lần thực hiện';
    }
  }

  String get unit {
    switch (this) {
      case GoalRecordType.time:
        return 'phút';
      case GoalRecordType.frequency:
        return 'lần';
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
