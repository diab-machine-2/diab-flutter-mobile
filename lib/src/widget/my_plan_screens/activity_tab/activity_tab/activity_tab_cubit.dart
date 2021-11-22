import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import '../../my_plan/my_plan.dart';
import 'activity_tab.dart';
import 'models/goal_type.dart';

class ActivityTabCubit extends Cubit<ActivityTabState> {
  ActivityTabCubit(this.repository, this.myPlanCubit)
      : super(const ActivityTabInitial());

  final AppRepository repository;
  final MyPlanCubit myPlanCubit;

  final List<GoalType> goalTypeList = [GoalType.day, GoalType.week];

  GoalType currentGoalType = GoalType.day;

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
}
