import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/week_states_response.dart';
import 'package:medical/src/utils/const.dart';

import '../../my_plan/my_plan.dart';
import 'activity_tab.dart';
import 'models/goal_filter_type.dart';

class ActivityTabCubit extends Cubit<ActivityTabState> {
  ActivityTabCubit(this.repository, this.myPlanCubit)
      : super(const ActivityTabInitial());

  final AppRepository repository;
  final MyPlanCubit myPlanCubit;

  final List<GoalFilterType> goalTypeList = [
    GoalFilterType.day,
    GoalFilterType.week
  ];
  List<WeekStatesResponseData> weekStatesList = [];
  int mark = 0;
  int? currentWeekIndex;
  int currentDayIndex = 0;

  GoalFilterType currentGoalType = GoalFilterType.day;

  double progress = 0.4;

  int get currentGoalTypeIndex {
    final int index = goalTypeList.indexOf(currentGoalType);
    return index == -1 ? 0 : index;
  }

  void changeGoalType(int newIndex) {
    currentGoalType = goalTypeList[newIndex];
    emit(const GoalTypeChanged());
    emit(const ActivityTabInitial());
  }

  void goToLessonTab() {
    myPlanCubit.changePlanType(1);
  }

  void goToExerciseTab() {
    myPlanCubit.changePlanType(2);
  }

  Future<void> initData() async {
    await myPlanCubit.checkUserInfo();
    if (myPlanCubit.packageCode == Const.PRO &&
        myPlanCubit.currentStudyWeek != null) {
      weekStatesList.add(
        WeekStatesResponseData(
          week: 1,
          weekTitle: 'Tuần 1',
          state: 1,
        ),
      );
      // currentWeekIndex = myPlanCubit.currentStudyWeek! - 1;
    }
    emit(const ActivityTabSuccess());
    emit(const ActivityTabInitial());
  }
}
