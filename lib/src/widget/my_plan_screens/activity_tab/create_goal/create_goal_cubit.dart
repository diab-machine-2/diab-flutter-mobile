import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import '../activity_tab/models/schedule_type.dart';
import 'create_goal.dart';
import 'models/create_goal_status.dart';
import 'models/day_in_week.dart';
import 'models/goal_record_type.dart';
import 'models/repeat_type.dart';

class CreateGoalCubit extends Cubit<CreateGoalState> {
  CreateGoalCubit(this.repository) : super(const CreateGoalInitial());

  final AppRepository repository;

  CreateGoalStatus status = CreateGoalStatus.select_type;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  bool isRepeat = false;
  GoalRecordType goalRecordType = GoalRecordType.time;
  ScheduleType? type;
  RepeatType repeatType = RepeatType.day;
  List<DayInWeek> repeatDayList = [];

  void setupGoal({ScheduleType? selectedType}) {
    type = selectedType;
    status = CreateGoalStatus.setup;
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  void onTapNext() {
    if (status == CreateGoalStatus.setup) {
      status = CreateGoalStatus.complete;
      emit(const CreateGoalSuccess());
    } else if (status == CreateGoalStatus.complete) {
      emit(const CreateGoalCompleted());
    }
    emit(const CreateGoalInitial());
  }

  void onToggleRepeat() {
    isRepeat = !isRepeat;
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  void onChangeCalculateType(int newIndex) {
    goalRecordType = GoalRecordTypeExtend.getGoalRecordTypeFromIndex(newIndex);
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  void onChangeRepeatType(String selectedRepeatType) {
    repeatType = RepeatTypeExtend.getTypeFromString(selectedRepeatType);
    if (repeatType == RepeatType.day) {
      repeatDayList.clear();
    }
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  void onChangeRepeatDay(List<String> selectedDayList) {
    repeatDayList = selectedDayList
        .map((e) => DayInWeekExtend.getDayInWeekFromString(e))
        .toList();
    repeatDayList.sort((a, b) => a.index - b.index);
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }
}
