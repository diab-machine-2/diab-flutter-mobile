enum ScheduleState {
  in_completed,
  completed,
  in_progress,
  future,
  hidden
}
extension ScheduleTypeExtend on ScheduleState {
int get stateIndex {
    switch (this) {
      case ScheduleState.in_completed:
        return 0;
      case ScheduleState.completed:
        return 1;
      case ScheduleState.in_progress:
        return 2;
      case ScheduleState.future:
        return 3;
      case ScheduleState.hidden:
        return 4;
    }
  }
}