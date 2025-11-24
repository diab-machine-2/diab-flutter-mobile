abstract class BmiEvent {
  const BmiEvent();
}

class BmiInstructionFetchingEvent extends BmiEvent {
  const BmiInstructionFetchingEvent();
}

class BmiDataChangeEvent extends BmiEvent {
  final String event;
  final dynamic data;

  const BmiDataChangeEvent(this.event, [this.data]);

  static const String selectedPointChanged = "selected_point_changed";
  static const String heightChanged = "height_changed";
  static const String weightGoalChanged = "weight_goal_changed";
  static const String hasDataChanged = "has_data_changed";
}

class BmiGetWeightThresholdEvent extends BmiEvent {
  const BmiGetWeightThresholdEvent();
}

class BmiGetWeightLessonsEvent extends BmiEvent {
  const BmiGetWeightLessonsEvent();
}

// statistical

class BmiGetWeightStatisticalEvent extends BmiEvent {
  const BmiGetWeightStatisticalEvent();
}

class BmiGetBmiStatisticalEvent extends BmiEvent {
  // final DateTime time;

  const BmiGetBmiStatisticalEvent();
}

class BmiGetWaistStatisticalEvent extends BmiEvent {
  const BmiGetWaistStatisticalEvent();
}

class BmiCheckStatisticalDataExistedEvent extends BmiEvent {
  const BmiCheckStatisticalDataExistedEvent();
}

// weight index

class BmiGetWeightRecordsEvent extends BmiEvent {
  final int? page;
  
  const BmiGetWeightRecordsEvent({this.page});
}
// others

class BmiGetAIAnalysicEvent extends BmiEvent {
  const BmiGetAIAnalysicEvent();
}

class BmiGetAIIndexAnalysicEvent extends BmiEvent {
  final String recordId;

  const BmiGetAIIndexAnalysicEvent(this.recordId);
}


class BmiUpdateWeightGoalEvent extends BmiEvent {
  final double weightGoal;

  const BmiUpdateWeightGoalEvent(this.weightGoal);
}