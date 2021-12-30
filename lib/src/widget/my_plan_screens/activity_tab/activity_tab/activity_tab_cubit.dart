import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/complete_smart_goal_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/delete_smart_goal_reponse.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/model/response/smart_goal_statistic_response.dart';
import 'package:medical/src/model/response/week_states_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/extention.dart';
import 'package:medical/src/widgets/day_in_week_widget.dart';

import '../../my_plan/my_plan.dart';
import 'activity_tab.dart';
import 'models/goal_filter_type.dart';
import 'models/message_state.dart';

class ActivityTabCubit extends Cubit<ActivityTabState> {
  ActivityTabCubit(this.repository, this.myPlanCubit)
      : super(const ActivityTabInitial());

  final AppRepository repository;
  final MyPlanCubit myPlanCubit;

  final List<GoalFilterType> goalTypeList = [
    GoalFilterType.day,
    GoalFilterType.week
  ];

  SmartGoalStatisticResponseData? statistic;

  int mark = 0;
  int? currentWeekIndex;
  int currentDayIndex = 0;

  GoalFilterType currentGoalType = GoalFilterType.day;

  List<SmartGoalList?> smartGoalDayList = [];
  List<SmartGoalList?> smartGoalWeekList = [];

  List<WeekStatesResponseData?> get weekStatesList => statistic?.weeks ?? [];
  List<DayStatesResponseData?> get dayStatesList =>
      statistic?.daysInCurrentWeek ?? [];

  int get currentGoalTypeIndex {
    final int index = goalTypeList.indexOf(currentGoalType);
    return index == -1 ? 0 : index;
  }

  int? get currentWeek =>
      currentWeekIndex == null ? null : currentWeekIndex! + 1;

  int? get currentDay => dayStatesList.isEmpty ? 0 : dayStatesList[currentDayIndex]?.day;

  MessageState get messageState => currentGoalType == GoalFilterType.day
      ? myPlanCubit.dayMessageState
      : myPlanCubit.weekMessageState;

  List<DayInWeekData> get dayInWeekList => statistic?.dayInWeekList ?? [];

  void goToLessonTab() {
    myPlanCubit.changePlanType(1);
  }

  void goToExerciseTab() {
    myPlanCubit.changePlanType(2);
  }

  Future<void> onSelectWeek(int newWeekIndex,
      {bool hideLoadingAfterDone = false}) async {
    currentWeekIndex = newWeekIndex;
    await getSmartGoalStatistics(hideLoadingAfterDone: hideLoadingAfterDone);
    refreshData();
    // if (weekStatesList.isNotEmpty) getListSmartGoal();
  }

  void onSelectDay(int newDayIndex) {
    currentDayIndex = newDayIndex;
    getListSmartGoal();
  }

  void checkMessageDay() {
    if (!messageState.dateTime.isSameDayWith(DateTime.now())) {
      messageState.dateTime = DateTime.now();
      messageState.showed50Message = false;
      messageState.showed90Message = false;
    }
  }

  Future<void> initData() async {
    await myPlanCubit.checkUserInfo();
    if (myPlanCubit.isHasRoadmapUser) {
      currentWeekIndex = myPlanCubit.currentStudyWeek! - 1;
    } else {
      currentWeekIndex = 0;
    }
    await getSmartGoalStatistics(hideLoadingAfterDone: false);
    await refreshData();
    Timer(const Duration(milliseconds: 100), () {
      emit(ActivityTabWeekChanged(currentWeekIndex ?? 0));
    });
    emit(const ActivityTabProgressChanged());
  }

  Future<void> refreshData({bool isRefresh = false}) async {
    await getListSmartGoal(isRefresh: isRefresh);
  }

  Future<void> getListSmartGoal({bool isRefresh = false}) async {
    if (!isRefresh) {
      await Future.delayed(Duration.zero);
      emit(const ActivityTabLoading());
    }
    final ApiResult<SmartGoalListReponse> apiResult =
        await repository.getListSmartGoal(day: currentDay, week: currentWeek);
    apiResult.when(success: (SmartGoalListReponse response) {
      smartGoalDayList = response.data?.daily ?? [];
      smartGoalWeekList = response.data?.weekly ?? [];
      checkMessageDay();
      emit(const ActivityTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(ActivityTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const ActivityTabInitial());
  }

  Future<void> getSmartGoalStatistics(
      {bool hideLoadingAfterDone = true}) async {
    await Future.delayed(Duration.zero);
    emit(const ActivityTabLoading());
    final ApiResult<SmartGoalStatisticResponse> apiResult =
        await repository.getSmartGoalStatistics(week: currentWeek);
    apiResult.when(success: (SmartGoalStatisticResponse response) {
      statistic = response.data;
      currentDayIndex = response.initDayIndex;
      mark = response.getCompletedMarkIndex(
          currentWeek: currentWeek,
          userCurrentWeek:
              weekStatesList.isNotEmpty ? myPlanCubit.currentStudyWeek : 0);
      if (hideLoadingAfterDone) emit(const ActivityTabSuccess());
      emit(const ActivityTabProgressChanged());
    }, failure: (NetworkExceptions error) {
      emit(ActivityTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
    if (hideLoadingAfterDone) emit(const ActivityTabInitial());
  }

  Future<void> completeSmartGoal(String? smartGoalId) async {
    if (smartGoalId == null) return;
    emit(const ActivityTabLoading());
    final CompleteSmartGoalRequest request =
        CompleteSmartGoalRequest(id: smartGoalId);
    final ApiResult<CommonResponse> apiResult =
        await repository.completeSmartGoal(request);
    apiResult.when(success: (CommonResponse response) {
      refreshData();
      emit(const ActivityTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(ActivityTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const ActivityTabInitial());
  }

  Future<void> deleteSmartGoal(String? smartGoalId) async {
    if (smartGoalId == null) return;
    emit(const ActivityTabLoading());
    final ApiResult<DeleteSmartGoalReponse> apiResult =
        await repository.deleteSmartGoal(smartGoalId);
    apiResult.when(success: (DeleteSmartGoalReponse response) {
      refreshData();
      emit(const ActivityTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(ActivityTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const ActivityTabInitial());
  }
}
