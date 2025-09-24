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
}

class BmiGetWeightLessonsEvent extends BmiEvent {
  const BmiGetWeightLessonsEvent();
}

// statistical

class BmiGetWeightStatisticalEvent extends BmiEvent {
  const BmiGetWeightStatisticalEvent();
}

class BmiGetBmiStatisticalEvent extends BmiEvent {
  const BmiGetBmiStatisticalEvent();
}

class BmiGetWaistStatisticalEvent extends BmiEvent {
  const BmiGetWaistStatisticalEvent();
}

// weight index

class BmiGetWeightRecordsEvent extends BmiEvent {
  const BmiGetWeightRecordsEvent();
}
// others

class BmiGetAIAnalysicEvent extends BmiEvent {
  const BmiGetAIAnalysicEvent();
}

class BmiGetAIIndexAnalysicEvent extends BmiEvent {
  const BmiGetAIIndexAnalysicEvent();
}
