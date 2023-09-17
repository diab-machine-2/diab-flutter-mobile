import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/complete_smart_goal_request.dart';
import 'package:medical/src/model/request/complete_update_profile_request.dart';
import 'package:medical/src/model/request/mark_completed_calendar_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/delete_smart_goal_reponse.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/model/response/smart_goal_statistic_response.dart';
import 'package:medical/src/model/response/week_states_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'package:medical/src/widgets/day_in_week_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../model/response/report_model.dart';
import '../../../../model/response/report_response.dart';
import '../../my_plan/my_plan.dart';
import 'activity_tab.dart';
import 'models/congratulation_state.dart';

class ActivityTabCubit extends Cubit<ActivityTabState> {
  ActivityTabCubit(this.repository, this.myPlanCubit)
      : super(const ActivityTabInitial());

  final AppRepository repository;
  final MyPlanCubit myPlanCubit;

  SmartGoalStatisticResponseData? statistic;

  int mark = 0;
  int? currentWeekIndex;
  int currentDayIndex = 0;

  List<ReportModel> reports = [];
  bool hasNewReports = false;

  CongratulationState congratulationState =
      CongratulationState(currentDate: DateTime.now());

  List<SmartGoalList?> smartGoalDayList = [];
  List<SmartGoalList?> smartGoalWeekList = [];

  List<WeekStatesResponseData?> get weekStatesList => statistic?.weeks ?? [];
  List<DayStatesResponseData?> get dayStatesList =>
      statistic?.daysInCurrentWeek ?? [];

  int currentWeekStudying = 0;

  int? get currentWeek => currentWeekIndex == null ? null : currentWeekIndex!;

  int? get currentDate => DateUtil.getCurrentDayInMillis();

  var user = AppSettings.userInfo!;

  bool isChangeNewWeek = false;

  int? get currentDay {
    if (isChangeNewWeek && user.ownPackage?.endDateFirst != null) {
      if (currentWeek == currentWeekStudying) {
        return DateUtil.getCurrentDayInMillis();
      } else if (currentWeek == 0) {
        return user.ownPackage?.activationDate ??
            DateUtil.getCurrentDayInMillis();
      } else {
        DateTime dateTime =
            DateUtil.parseTimespanToDateTime(user.ownPackage!.endDateFirst!);
        dateTime = dateTime.add(Duration(days: (currentWeek! - 1) * 7));
        return DateUtil.getDayInMillis(dateTime);
      }
    } else {
      if (dayStatesList.isEmpty) {
        return currentDate;
      } else {
        return dayStatesList[currentDayIndex]?.day;
      }
    }
  }

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
    isChangeNewWeek = true;
    refreshData(keepCurrentDay: false);
  }

  void onSelectDay(int newDayIndex) {
    currentDayIndex = newDayIndex;
    isChangeNewWeek = false;
    getListSmartGoal(isShowLoading: true);
  }

  Future<void> initData() async {
    isChangeNewWeek = false;
    await myPlanCubit.checkUserInfo(
        isRequired: AppSettings.isReloadCurrentUserInfo);

    if (myPlanCubit.isHasRoadmapUser) {
      currentWeekIndex = myPlanCubit.currentStudyWeek!;
      if (currentWeekIndex == -1) currentWeekIndex = 0;
    } else {
      currentWeekIndex = 0;
    }

    //  await getSmartGoalStatistics(hideLoadingAfterDone: false);
    await refreshData(
        keepCurrentDay: false, isRefresh: false, isReloadStatistic: false);
    //  emit(const ActivityTabProgressChanged());
  }

  Future<void> refreshData(
      {bool isReloadStatistic = true,
      bool isRefresh = false,
      bool keepCurrentDay = true}) async {
    if (!isRefresh) {
      await Future.delayed(Duration(milliseconds: 1));
      emit(const ActivityTabLoading());
    }
    await getSmartGoalStatistics(
        isReloadStatistic: isReloadStatistic,
        isRefresh: isRefresh,
        hideLoadingAfterDone: true,
        keepCurrentDay: keepCurrentDay);
    await getListSmartGoal(isRefresh: isRefresh);
  }

  Future<void> getListSmartGoal(
      {bool isRefresh = false, bool isShowLoading = false}) async {
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

      // smartGoalDayList.removeWhere((element) => element?.state == 4);
      // smartGoalWeekList.removeWhere((element) => element?.state == 4);

      AppSettings.smartGoalDayList = smartGoalDayList;

      congratulationState.currentDate =
          DateUtil.parseTimespanToDateTime(currentDay!);

      if (response.isWeeklyGoalCompleted &&
          congratulationState.shouldShowWeekPopup) {
        congratulationState.weeklyShowed = true;
        emit(const ActivityTabWeeklyGoalCompleted());
      }
      if (response.isDailyGoalCompleted &&
          congratulationState.shouldShowDailyPopup) {
        congratulationState.dailyShowed = true;
        emit(const ActivityTabDailyGoalCompleted());
      }

      congratulationState.currentDate = DateTime.now();

      emit(const ActivityTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(ActivityTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
    BotToast.closeAllLoading();
    emit(const ActivityTabInitial());
  }

  Future<void> getSmartGoalStatistics({
    bool isReloadStatistic = true,
    bool isRefresh = false,
    bool hideLoadingAfterDone = true,
    bool keepCurrentDay = false,
  }) async {
    //   await Future.delayed(Duration.zero);
//    if (!isRefresh) emit(const ActivityTabLoading());
    if (AppSettings.userInfo?.statistict?.targets != null &&
        !isReloadStatistic) {
      statistic = AppSettings.userInfo?.statistict?.targets;
      if (statistic?.weeks != null) {
        for (var item in statistic!.weeks!) {
          if (item?.state == 2) {
            currentWeekStudying = item?.week ?? 0;
          }
        }
      }
      if (!keepCurrentDay) currentDayIndex = statistic?.initDayIndex ?? 0;
      mark = statistic?.getCompletedMarkIndex(
              currentWeek: currentWeek,
              userCurrentWeek: myPlanCubit.currentStudyWeek) ??
          statistic?.initDayIndex ??
          0;
    } else {
      final ApiResult<SmartGoalStatisticResponse> apiResult = await repository
          .getSmartGoalStatistics(day: currentDate, week: currentWeek);
      apiResult.when(success: (SmartGoalStatisticResponse response) {
        statistic = response.data;

        if (statistic?.weeks != null && statistic!.weeks!.isNotEmpty) {
          for (var item in statistic!.weeks!) {
            if (item?.state == 2) {
              currentWeekStudying = item?.week ?? 0;
            }
          }
        } else {
          statistic = AppSettings.userInfo?.statistict?.targets;
        }
        if (!keepCurrentDay) currentDayIndex = response.initDayIndex;
        mark = response.getCompletedMarkIndex(
            currentWeek: currentWeek,
            userCurrentWeek: myPlanCubit.currentStudyWeek);
        //     if (hideLoadingAfterDone) emit(const ActivityTabSuccess());
        //   emit(const ActivityTabProgressChanged());
      }, failure: (NetworkExceptions error) {
        //     emit(ActivityTabFailure(NetworkExceptions.getErrorMessage(error)));
      });
    }
    Timer(const Duration(milliseconds: 100), () {
      emit(ActivityTabWeekChanged(currentWeekIndex ?? 0));
    });
    //   if (hideLoadingAfterDone) emit(const ActivityTabInitial());
  }

  Future<void> completeSmartGoal(String? smartGoalId, int? executeDayTimes,
      int? type, int? appointmentDate) async {
    if (smartGoalId == null) return;
    emit(const ActivityTabLoading());
    final CompleteSmartGoalRequest request = CompleteSmartGoalRequest(
        id: smartGoalId,
        executeTimes: executeDayTimes,
        type: type,
        appointmentDate: appointmentDate);
    final ApiResult<CommonResponse> apiResult =
        await repository.completeSmartGoal(request);
    apiResult.when(success: (CommonResponse response) {
      //  Observable.instance
      //       .notifyObservers([], notifyName: "food_change_data");
      refreshData(isRefresh: true);
      //   emit(const ActivityTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(ActivityTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
    //   emit(const ActivityTabInitial());
  }

  Future<void> markCompletedUpdateProfile(String? id) async {
    emit(const ActivityTabLoading());
    //  final CompleteUpdateProfileRequest request =
    //     CompleteUpdateProfileRequest(id: id ?? '');
    final ApiResult<CommonResponse> apiResult =
        await repository.markCompletedUpdateProfile(id ?? '');
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
    final ApiResult<DeleteSmartGoalReponse> apiResult =
        await repository.deleteSmartGoal(smartGoalId);
    apiResult.when(success: (DeleteSmartGoalReponse response) {
      //  Observable.instance
      //        .notifyObservers([], notifyName: "food_change_data");
      refreshData(isRefresh: true);
      //  emit(const ActivityTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(ActivityTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
    // emit(const ActivityTabInitial());
  }

  Future<void> markCompletedCalendar(String? calendarId) async {
    if (calendarId == null) return;
    emit(const ActivityTabLoading());
    final ApiResult<CommonResponse> apiResult =
        await repository.markCompletedCalendar(calendarId);
    apiResult.when(success: (CommonResponse response) {
      //   Observable.instance
      //         .notifyObservers([], notifyName: "food_change_data");
      refreshData(isRefresh: true);
      //   emit(const ActivityTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(ActivityTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
    //   emit(const ActivityTabInitial());
  }

  Future<void> getReports({bool isRefresh = false}) async {
    await Future.delayed(Duration.zero);
    emit(const ActivityTabLoading());
    final ApiResult<ReportListResponse> apiResult =
        await repository.getReports();
    apiResult.when(success: (ReportListResponse response) {
      reports = response.data ?? [];
      BotToast.closeAllLoading();
      emit(const ActivityTabSuccess());
    }, failure: (NetworkExceptions error) {
      BotToast.closeAllLoading();
      emit(const ActivityTabSuccess());
    });
  }

  Future<void> saveReportsFromPreferences(List<ReportModel> reports) async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    var json = jsonEncode(reports.map((e) => e.toJson()).toList());
    prefs.setString('reports', json);
  }

  Future<List<ReportModel>> getReportsFromPreferences() async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    final reportsString = prefs.getString('reports');
    List<ReportModel> reports = [];

    if (reportsString != null) {
      Iterable l = json.decode(reportsString);
      reports =
          List<ReportModel>.from(l.map((model) => ReportModel.fromJson(model)));
    }
    return reports;
  }

  Future<void> saveHasNewReportsFromPreferences(bool hasNewReports) async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    prefs.setBool('hasNewReports', hasNewReports);
  }

  Future<bool> getHasNewReportsFromPreferences() async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    final hasNewReports = prefs.getBool('hasNewReports') ?? false;
    return hasNewReports;
  }
}
