enum CreateGoalStatus {
  select_type,
  setup,
  complete,
}

extension CreateGoalStatusExtend on CreateGoalStatus {
  int get index {
    switch (this) {
      case CreateGoalStatus.select_type:
        return 0;
      case CreateGoalStatus.setup:
        return 1;
      case CreateGoalStatus.complete:
        return 2;
    }
  }
}
