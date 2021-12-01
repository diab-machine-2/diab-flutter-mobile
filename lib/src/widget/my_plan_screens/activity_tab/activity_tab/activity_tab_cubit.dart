import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/model/response/week_states_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
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

  SmartGoalListReponse? smartGoalData;

  double progress = 0.4;

  int get currentGoalTypeIndex {
    final int index = goalTypeList.indexOf(currentGoalType);
    return index == -1 ? 0 : index;
  }

  int? get week => currentWeekIndex == null ? null : currentWeekIndex! + 1;

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

  void generateWeek() {
    weekStatesList = List.generate(
      9,
      (index) => WeekStatesResponseData(
        week: index + 1,
        weekTitle: 'Tuần ${index + 1}',
        state: 1,
      ),
    );
  }

  Future<void> initData() async {
    await myPlanCubit.checkUserInfo();
    if (myPlanCubit.packageCode == Const.PREMIUM &&
        myPlanCubit.currentStudyWeek != null) {
      generateWeek();
      currentWeekIndex = myPlanCubit.currentStudyWeek! - 1;
    }
    await getListSmartGoal();
    emit(ActivityTabWeekChanged(currentWeekIndex ?? 0));
  }

  Future<void> getListSmartGoal({bool isRefresh = false}) async {
    if (!isRefresh) {
      await Future.delayed(Duration.zero);
      emit(const ActivityTabLoading());
    }
    final ApiResult<SmartGoalListReponse> apiResult =
        await repository.getListSmartGoal(week: week);
    apiResult.when(success: (SmartGoalListReponse response) {
      smartGoalData = response;
      emit(const ActivityTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(ActivityTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const ActivityTabInitial());
  }
}
