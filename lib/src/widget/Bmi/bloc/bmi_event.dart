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

class BmiGetWeightListEvent extends BmiEvent {
  const BmiGetWeightListEvent();
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

// 
