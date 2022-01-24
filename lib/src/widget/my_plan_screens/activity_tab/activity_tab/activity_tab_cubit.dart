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
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/widgets/day_in_week_widget.dart';

import '../../my_plan/my_plan.dart';
import 'activity_tab.dart';
import 'models/congratulation_state.dart';

class ActivityTabCubit extends Cubit<ActivityTabState> {
  ActivityTabCubit(this.repository, this.myPlanCubit) : super(const ActivityTabInitial());

  final AppRepository repository;
  final MyPlanCubit myPlanCubit;

  SmartGoalStatisticResponseData? statistic;

  int mark = 0;
  int? currentWeekIndex;
  int currentDayIndex = 0;

  CongratulationState congratulationState = CongratulationState(currentDate: DateTime.now());

  List<SmartGoalList?> smartGoalDayList = [];
  List<SmartGoalList?> smartGoalWeekList = [];

  List<WeekStatesResponseData?> get weekStatesList => statistic?.weeks ?? [];
  List<DayStatesResponseData?> get dayStatesList => statistic?.daysInCurrentWeek ?? [];

  int? get currentWeek => currentWeekIndex == null ? null : currentWeekIndex! + 1;

  int? get currentDay => dayStatesList.isEmpty ? 0 : dayStatesList[currentDayIndex]?.day;

  List<DayInWeekData> get dayInWeekList => statistic?.dayInWeekList ?? [];

  void goToLessonTab() {
    myPlanCubit.changePlanType(1);
  }

  void goToExerciseTab() {
    myPlanCubit.changePlanType(2);
  }

  Future<void> onSelectWeek(int newWeekIndex, {bool hideLoadingAfterDone = false}) async {
    currentWeekIndex = newWeekIndex;
    refreshData(keepCurrentDay: false);
  }

  void onSelectDay(int newDayIndex) {
    currentDayIndex = newDayIndex;
    getListSmartGoal(isShowLoading: true);
  }

  Future<void> initData() async {
    await myPlanCubit.checkUserInfo();
    if (myPlanCubit.isHasRoadmapUser) {
      currentWeekIndex = myPlanCubit.currentStudyWeek! - 1;
      if (currentWeekIndex == -1) currentWeekIndex = 0;
    } else {
      currentWeekIndex = 0;
    }

    //  await getSmartGoalStatistics(hideLoadingAfterDone: false);
    await refreshData(keepCurrentDay: false);
    Timer(const Duration(milliseconds: 100), () {
      emit(ActivityTabWeekChanged(currentWeekIndex ?? 0));
    });
    //  emit(const ActivityTabProgressChanged());
  }

  Future<void> refreshData({bool isRefresh = false, bool keepCurrentDay = true}) async {
    if (!isRefresh) {
      emit(const ActivityTabLoading());
    }
    await getSmartGoalStatistics(isRefresh: isRefresh, hideLoadingAfterDone: true, keepCurrentDay: keepCurrentDay);
    await getListSmartGoal(isRefresh: isRefresh);
  }

  Future<void> getListSmartGoal({bool isRefresh = false, bool isShowLoading = false}) async {
    if (!isRefresh) {
      await Future.delayed(Duration.zero);
    }
    if (isShowLoading) {
      emit(const ActivityTabLoading());
    }
    final ApiResult<SmartGoalListReponse> apiResult =
        await repository.getListSmartGoal(day: currentDay, week: currentWeek);
    apiResult.when(success: (SmartGoalListReponse response) {
      smartGoalDayList = response.data?.daily ?? [];
      smartGoalWeekList = response.data?.weekly ?? [];

      congratulationState.currentDate = DateUtil.parseTimespanToDateTime(currentDay!);

      if (response.isWeeklyGoalCompleted && congratulationState.shouldShowWeekPopup) {
        congratulationState.weeklyShowed = true;
        emit(const ActivityTabWeeklyGoalCompleted());
      }
      if (response.isDailyGoalCompleted && congratulationState.shouldShowDailyPopup) {
        congratulationState.dailyShowed = true;
        emit(const ActivityTabDailyGoalCompleted());
      }

      congratulationState.currentDate = DateTime.now();

      emit(const ActivityTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(ActivityTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const ActivityTabInitial());
  }

  Future<void> getSmartGoalStatistics({
    bool isRefresh = false,
    bool hideLoadingAfterDone = true,
    bool keepCurrentDay = false,
  }) async {
    await Future.delayed(Duration.zero);
//    if (!isRefresh) emit(const ActivityTabLoading());
    final ApiResult<SmartGoalStatisticResponse> apiResult = await repository.getSmartGoalStatistics(week: currentWeek);
    apiResult.when(success: (SmartGoalStatisticResponse response) {
      statistic = response.data;
      if (!keepCurrentDay) currentDayIndex = response.initDayIndex;
      mark = response.getCompletedMarkIndex(currentWeek: currentWeek, userCurrentWeek: myPlanCubit.currentStudyWeek);
      //     if (hideLoadingAfterDone) emit(const ActivityTabSuccess());
      //   emit(const ActivityTabProgressChanged());
    }, failure: (NetworkExceptions error) {
      //     emit(ActivityTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
    //   if (hideLoadingAfterDone) emit(const ActivityTabInitial());
  }

  Future<void> completeSmartGoal(String? smartGoalId, int? executeDayTimes, int? type) async {
    if (smartGoalId == null) return;
    emit(const ActivityTabLoading());
    final CompleteSmartGoalRequest request =
        CompleteSmartGoalRequest(id: smartGoalId, executeTimes: executeDayTimes, type: type);
    final ApiResult<CommonResponse> apiResult = await repository.completeSmartGoal(request);
    apiResult.when(success: (CommonResponse response) {
      refreshData(isRefresh: true);
      //   emit(const ActivityTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(ActivityTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
    //   emit(const ActivityTabInitial());
  }

  Future<void> deleteSmartGoal(String? smartGoalId) async {
    if (smartGoalId == null) return;
    emit(const ActivityTabLoading());
    final ApiResult<DeleteSmartGoalReponse> apiResult = await repository.deleteSmartGoal(smartGoalId);
    apiResult.when(success: (DeleteSmartGoalReponse response) {
      refreshData(isRefresh: true);
      //  emit(const ActivityTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(ActivityTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
    // emit(const ActivityTabInitial());
  }
}
