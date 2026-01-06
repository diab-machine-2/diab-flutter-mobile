import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/app_setting/app_setting.dart';
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
import 'package:medical/src/widget/my_plan_screens/my_plan/models/completion_status.dart';
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
  List<SmartGoalList?> smartGoalNotCompleteInWeekly = [];
  List<SmartGoalList?> lessonsWeekly = [];

  List<WeekStatesResponseData?> get weekStatesList => statistic?.weeks ?? [];
  List<DayStatesResponseData?> get dayStatesList =>
      statistic?.daysInCurrentWeek ?? [];

  int currentWeekStudying = 0;

  int? get currentWeek => currentWeekIndex == null ? null : currentWeekIndex!;

  int? get currentDate => DateUtil.getCurrentDayInMillis();

  var user = AppSettings.userInfo!;

  bool isChangeNewWeek = false;

  int? get currentDay {
    // Always prioritize dayStatesList data when available
    if (dayStatesList.isNotEmpty && currentDayIndex < dayStatesList.length) {
      if (user.ownPackage == null) {
        // TODO: Need backend handle this case, basic account daysInCurrentWeek timestamp not match as package account
        DateTime dateTime = DateUtil.parseTimespanToDateTime(
          dayStatesList[currentDayIndex]?.day ?? currentDate!,
        );
        dateTime = dateTime.toLocal();
        final utcDatetime = DateTime.utc(dateTime.year, dateTime.month,
            dateTime.day, dateTime.hour, dateTime.minute, dateTime.second);
        final localDatetime = utcDatetime.toLocal();
        return DateUtil.getDayInMillis(localDatetime);
      }
      return dayStatesList[currentDayIndex]?.day;
    }

    // Fallback to complex calculation when dayStatesList is not available
    if (isChangeNewWeek && user.ownPackage?.endDateFirst != null) {
      if (currentWeek == currentWeekStudying) {
        DateTime dateTime0 = DateTime.utc(DateTime.now().year,
            DateTime.now().month, DateTime.now().day, 0, 0, 0);
        final localDateTime = dateTime0.toLocal();
        int current = (localDateTime.millisecondsSinceEpoch ~/ 1000).toInt();
        return current;
      } else if (currentWeek == 0) {
        return user.ownPackage?.activationDate ??
            DateUtil.getCurrentDayInMillis();
      } else {
        DateTime dateTime =
            DateUtil.parseTimespanToDateTime(user.ownPackage!.endDateFirst!);

        dateTime =
            DateTime.utc(dateTime.year, dateTime.month, dateTime.day, 0, 0, 0);
        if (dateTime.weekday == DateTime.sunday) {
          dateTime = dateTime.add(const Duration(days: 1));
        } //Because endDateFirst is Sunday so we add 1 day

        dateTime = dateTime.add(Duration(days: (currentWeek! - 1) * 7));
        // dateTime = dateTime.toLocal();

        final utcDatetime = DateTime.utc(dateTime.year, dateTime.month,
            dateTime.day, dateTime.hour, dateTime.minute, dateTime.second);
        final localDatetime = utcDatetime.toLocal();

        return DateUtil.getDayInMillis(localDatetime);
      }
    } else {
      // Final fallback to current date
      DateTime dateTime0 = DateTime.utc(DateTime.now().year,
          DateTime.now().month, DateTime.now().day, 0, 0, 0);
      dateTime0 = dateTime0.toLocal();
      int currentTimestamp = (dateTime0.millisecondsSinceEpoch ~/ 1000).toInt();
      return currentTimestamp;
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
      {bool hideLoadingAfterDone = false,
      bool selectFirstDay = false,
      bool selectLastDay = false}) async {
    currentWeekIndex = newWeekIndex;
    isChangeNewWeek = true;

    // Set flags for day selection after week change
    if (selectFirstDay) {
      _selectFirstDayAfterWeekChange = true;
    } else if (selectLastDay) {
      _selectLastDayAfterWeekChange = true;
    }

    refreshData(keepCurrentDay: false);
  }

  // Flags to handle day selection after week change
  bool _selectFirstDayAfterWeekChange = false;
  bool _selectLastDayAfterWeekChange = false;

  void onSelectDay(int newDayIndex) {
    if (newDayIndex < dayStatesList.length) {
      currentDayIndex = newDayIndex;
      isChangeNewWeek = false;
      getListSmartGoal(isShowLoading: true);
    }
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

    // Load persisted daily goal showed state
    // Check if popup was shown today - if shown on a different day, reset it
    final lastShownDate = await getDailyGoalShowedDateFromPreferences();
    if (lastShownDate != null) {
      final today = DateTime.now();
      final lastShown = DateTime.fromMillisecondsSinceEpoch(lastShownDate);
      // If last shown date is not today, reset the flag
      if (!DateUtil.isSameDate(lastShown, today)) {
        congratulationState.dailyShowed = false;
        await saveDailyGoalShowedDateFromPreferences(null);
      } else {
        congratulationState.dailyShowed = true;
      }
    } else {
      congratulationState.dailyShowed = false;
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

    // Process target date selection AFTER statistics are loaded but BEFORE API call
    // This ensures we use the correct day index for the API call
    if (!keepCurrentDay &&
        _targetDateToSelect != null &&
        dayStatesList.isNotEmpty) {
      final targetDate = _targetDateToSelect!;
      final targetDateUtc = DateTime.utc(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        0,
        0,
        0,
      );
      final targetTimestamp =
          (targetDateUtc.millisecondsSinceEpoch ~/ 1000).toInt();

      // Check if target date is within the current week's range
      if (dayStatesList.isNotEmpty) {
        final firstDay = dayStatesList.first?.day;
        final lastDay = dayStatesList.last?.day;
        if (firstDay != null && lastDay != null) {
          // If target date is after the last day of current week, try next week
          if (targetTimestamp > lastDay &&
              currentWeekIndex != null &&
              currentWeekIndex! < weekStatesList.length - 1) {
            _targetDateToSelect = targetDate;
            onSelectWeek(currentWeekIndex! + 1);
            return;
          }
          // If target date is before the first day of current week, try previous week
          else if (targetTimestamp < firstDay &&
              currentWeekIndex != null &&
              currentWeekIndex! > 0) {
            _targetDateToSelect = targetDate;
            onSelectWeek(currentWeekIndex! - 1);
            return;
          }
        }
      }

      // Try to find exact match
      bool found = false;
      for (int i = 0; i < dayStatesList.length; i++) {
        final ts = dayStatesList[i]?.day;
        if (ts == targetTimestamp) {
          currentDayIndex = i;
          isChangeNewWeek = false;
          found = true;
          break;
        }
      }

      // If not found, find closest
      if (!found && dayStatesList.isNotEmpty) {
        int closestIndex = 0;
        int minDifference = (dayStatesList[0]?.day ?? 0) - targetTimestamp;
        if (minDifference < 0) minDifference = -minDifference;

        for (int i = 1; i < dayStatesList.length; i++) {
          if (dayStatesList[i]?.day != null) {
            final diff = (dayStatesList[i]!.day! - targetTimestamp);
            final absDiff = diff < 0 ? -diff : diff;
            if (absDiff < minDifference) {
              minDifference = absDiff;
              closestIndex = i;
            }
          }
        }
        currentDayIndex = closestIndex;
        isChangeNewWeek = false;
      }

      _targetDateToSelect = null;
    }

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

    final dayParam = currentDay;
    final weekParam = currentWeek;

    final ApiResult<SmartGoalListReponse> apiResult =
        await repository.getListSmartGoal(day: dayParam, week: weekParam);
    apiResult.when(success: (SmartGoalListReponse response) {
      smartGoalDayList = response.data?.daily ?? [];
      smartGoalWeekList = response.data?.weekly ?? [];
      smartGoalNotCompleteInWeekly =
          response.data?.activitiesNotCompleteInWeekly ?? [];
      lessonsWeekly = response.data?.lessonsWeekly ?? [];

      // smartGoalDayList.removeWhere((element) => element?.state == 4);
      // smartGoalWeekList.removeWhere((element) => element?.state == 4);

      AppSettings.smartGoalDayList = smartGoalDayList;

      congratulationState.currentDate =
          DateUtil.parseTimespanToDateTime(currentDay!);

      // Show daily goal completed popup only when both conditions are met:
      // 1. Daily goals are completed
      // 2. Activities not complete in weekly are also completed
      if (response.isDailyGoalCompleted &&
          response.isActivitiesNotCompleteInWeekCompleted &&
          congratulationState.shouldShowDailyPopup) {
        congratulationState.dailyShowed = true;
        // Persist the current date so popup only shows once per day
        final today = DateTime.now();
        saveDailyGoalShowedDateFromPreferences(today.millisecondsSinceEpoch);
        emit(const ActivityTabDailyGoalCompleted());
      }

      congratulationState.currentDate = DateTime.now();

      // Handle day selection after week change
      if (_selectFirstDayAfterWeekChange) {
        _selectFirstDayAfterWeekChange = false;
        if (dayStatesList.isNotEmpty) {
          currentDayIndex = 0;
          isChangeNewWeek = false;
        }
      } else if (_selectLastDayAfterWeekChange) {
        _selectLastDayAfterWeekChange = false;
        if (dayStatesList.isNotEmpty) {
          currentDayIndex = dayStatesList.length - 1;
          isChangeNewWeek = false;
        }
      } else if (_targetDateToSelect != null) {
        // This should not happen if we process _targetDateToSelect in refreshData
        // But keep it as a fallback
        final targetDate = _targetDateToSelect!;
        final targetDateUtc = DateTime.utc(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          0,
          0,
          0,
        );
        final targetTimestamp =
            (targetDateUtc.millisecondsSinceEpoch ~/ 1000).toInt();

        for (int i = 0; i < dayStatesList.length; i++) {
          if (dayStatesList[i]?.day == targetTimestamp) {
            currentDayIndex = i;
            isChangeNewWeek = false;
            _targetDateToSelect = null;
            // Call API again with correct day index
            getListSmartGoal(isShowLoading: false);
            return;
          }
        }
        _targetDateToSelect = null;
      }

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

  // Future<void> markCompletedCalendar(String? calendarId) async {
  //   if (calendarId == null) return;
  //   emit(const ActivityTabLoading());
  //   final ApiResult<CommonResponse> apiResult =
  //       await repository.markCompletedCalendar(calendarId);
  //   apiResult.when(success: (CommonResponse response) {
  //     //   Observable.instance
  //     //         .notifyObservers([], notifyName: "food_change_data");
  //     refreshData(isRefresh: true);
  //     //   emit(const ActivityTabSuccess());
  //   }, failure: (NetworkExceptions error) {
  //     emit(ActivityTabFailure(NetworkExceptions.getErrorMessage(error)));
  //   });
  //   //   emit(const ActivityTabInitial());
  // }

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

  Future<void> saveDailyGoalShowedDateFromPreferences(int? dateMillis) async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    if (dateMillis != null) {
      prefs.setInt('dailyGoalShowedDate', dateMillis);
    } else {
      prefs.remove('dailyGoalShowedDate');
    }
  }

  Future<int?> getDailyGoalShowedDateFromPreferences() async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    final dateMillis = prefs.getInt('dailyGoalShowedDate');
    return dateMillis;
  }

  // Calendar navigation methods
  void onPreviousDay() {
    // Use the actual timestamp from current day to calculate previous day
    if (currentDay == null ||
        dayStatesList.isEmpty ||
        currentDayIndex >= dayStatesList.length) {
      return;
    }

    final currentTimestamp = dayStatesList[currentDayIndex]?.day;
    if (currentTimestamp == null) return;

    // Calculate previous day timestamp (subtract 1 day = 86400 seconds)
    final previousTimestamp = currentTimestamp - 86400;

    // Check if previous date is in current week's dayStatesList
    for (int i = 0; i < dayStatesList.length; i++) {
      if (dayStatesList[i]?.day == previousTimestamp) {
        onSelectDay(i);
        return;
      }
    }

    // If not found in current week, navigate to previous week and find the date
    if (currentWeekIndex != null && currentWeekIndex! > 0) {
      // Convert timestamp to DateTime for _targetDateToSelect
      final previousDate = DateTime.fromMillisecondsSinceEpoch(
              previousTimestamp * 1000,
              isUtc: true)
          .toLocal();
      _targetDateToSelect = previousDate;
      onSelectWeek(currentWeekIndex! - 1);
    }
  }

  void onNextDay() {
    // Use the actual timestamp from current day to calculate next day
    if (currentDay == null ||
        dayStatesList.isEmpty ||
        currentDayIndex >= dayStatesList.length) {
      return;
    }

    final currentTimestamp = dayStatesList[currentDayIndex]?.day;
    if (currentTimestamp == null) return;

    // Calculate next day timestamp (add 1 day = 86400 seconds)
    final nextTimestamp = currentTimestamp + 86400;

    // Check if next date is in current week's dayStatesList
    for (int i = 0; i < dayStatesList.length; i++) {
      if (dayStatesList[i]?.day == nextTimestamp) {
        onSelectDay(i);
        return;
      }
    }

    // If not found in current week, navigate to next week and find the date
    if (currentWeekIndex != null &&
        currentWeekIndex! < weekStatesList.length - 1) {
      // Convert timestamp to DateTime for _targetDateToSelect
      final nextDate =
          DateTime.fromMillisecondsSinceEpoch(nextTimestamp * 1000, isUtc: true)
              .toLocal();
      _targetDateToSelect = nextDate;
      onSelectWeek(currentWeekIndex! + 1);
    }
  }

  void onTodayPressed() {
    // Find today's date in the current week
    final today = DateTime.now();
    // Keep day-level comparison only; ignore time component

    // Check if today is in the current week
    for (int i = 0; i < dayStatesList.length; i++) {
      final ts = dayStatesList[i]?.day;
      if (ts == null) continue;
      final date =
          DateTime.fromMillisecondsSinceEpoch(ts * 1000, isUtc: true).toLocal();
      if (DateUtil.isSameDate(date, today)) {
        onSelectDay(i);
        return;
      }
    }

    // If today is not in current week, navigate to currentWeekStudying (the actual current week)
    // and select today
    int? targetWeekIndex;
    for (int i = 0; i < weekStatesList.length; i++) {
      if (weekStatesList[i]?.completionStatus == CompletionStatus.studying) {
        targetWeekIndex = i;
        break;
      }
    }

    // Navigate to the current studying week and select today
    if (targetWeekIndex != null) {
      _targetDateToSelect = today;
      onSelectWeek(targetWeekIndex);
    } else {
      // Fallback: try to calculate which week contains today
      _findAndNavigateToWeekContainingDate(today);
    }
  }

  void onDatePicked(DateTime pickedDate) {
    // Use the date components directly to avoid timezone issues
    // Create a local date at midnight for the picked date
    final pickedDateLocal = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      0,
      0,
      0,
    );

    // Convert to UTC at midnight for timestamp comparison
    final pickedDateUtc = DateTime.utc(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      0,
      0,
      0,
    );

    final pickedTimestamp =
        (pickedDateUtc.millisecondsSinceEpoch ~/ 1000).toInt();

    // Check if the picked date is in the current week
    for (int i = 0; i < dayStatesList.length; i++) {
      final ts = dayStatesList[i]?.day;
      if (ts == pickedTimestamp) {
        onSelectDay(i);
        return;
      }
    }

    // If picked date is not in current week, navigate to the week containing the picked date
    _findAndNavigateToWeekContainingDate(pickedDateLocal);
  }

  void _findAndNavigateToWeekContainingDate(DateTime targetDate) {
    // Store the target date to select after week change
    _targetDateToSelect = targetDate;

    // Calculate which week the target date belongs to
    final targetWeekIndex = _calculateWeekIndexForDate(targetDate);

    if (targetWeekIndex != null && targetWeekIndex != currentWeekIndex) {
      // Navigate to the week containing the target date
      onSelectWeek(targetWeekIndex);
    } else {
      // If we're already in the correct week, just refresh data
      refreshData(keepCurrentDay: false);
    }
  }

  int? _calculateWeekIndexForDate(DateTime targetDate) {
    if (user.ownPackage?.endDateFirst == null) {
      // For basic accounts, try to find the week by checking existing week data
      return _findWeekIndexForBasicAccount(targetDate);
    }

    // Calculate the week index based on the package's endDateFirst
    final endDateFirst =
        DateUtil.parseTimespanToDateTime(user.ownPackage!.endDateFirst!);
    var weekStartDate = DateTime.utc(
        endDateFirst.year, endDateFirst.month, endDateFirst.day, 0, 0, 0);

    // Adjust if endDateFirst is Sunday (add 1 day to get Monday)
    if (weekStartDate.weekday == DateTime.sunday) {
      weekStartDate = weekStartDate.add(const Duration(days: 1));
    }

    // Calculate the difference in days between target date and week start
    final targetDateOnly = DateTime.utc(
        targetDate.year, targetDate.month, targetDate.day, 0, 0, 0);
    final daysDifference = targetDateOnly.difference(weekStartDate).inDays;

    // Handle negative differences (dates before the first week)
    int weekIndex;
    if (daysDifference < 0) {
      // For dates before the first week, we need to calculate how many weeks back
      weekIndex = ((daysDifference - 6) / 7)
          .floor(); // -6 to round down properly for negative numbers
    } else {
      // For positive differences, calculate week index
      // When daysDifference is exactly divisible by 7, it's the START of the next week
      weekIndex = (daysDifference / 7).floor();

      // If daysDifference is exactly divisible by 7, the date is at the boundary
      // and belongs to the NEXT week (not the current calculated week)
      // Example: day 49 = 7*7, which should be week 8, not week 7
      if (daysDifference % 7 == 0 && daysDifference > 0) {
        weekIndex = weekIndex + 1;
      }
    }

    // Ensure the week index is within valid range
    if (weekIndex >= 0 && weekIndex < weekStatesList.length) {
      return weekIndex;
    }

    // If the calculated week is negative or out of range, try to find the closest valid week
    if (weekIndex < 0) {
      // Check if the target date falls within week 0 by checking the actual days
      return _checkIfDateInWeek(targetDate, 0) ? 0 : null;
    }

    return null;
  }

  bool _checkIfDateInWeek(DateTime targetDate, int weekIndex) {
    // This method checks if a target date falls within a specific week
    // by examining the actual day data for that week

    // For now, we'll use a simple heuristic
    // In a real implementation, you might want to check the actual week boundaries
    // from the backend or calculate them based on the week structure

    if (weekIndex == 0) {
      // For week 0, check if the date is within a reasonable range
      final today = DateTime.now();
      final daysDiff = targetDate.difference(today).inDays;
      return daysDiff >= -7 && daysDiff <= 7; // Within a week of today
    }

    return false;
  }

  int? _findWeekIndexForBasicAccount(DateTime targetDate) {
    // For basic accounts, we need to check if the target date falls within any existing week
    // This is a fallback method when we don't have package information

    // Try to find a week that contains the target date by checking week boundaries
    for (int i = 0; i < weekStatesList.length; i++) {
      // This is a simplified approach - in a real implementation, you might need
      // to check the actual week boundaries from the backend
      // For now, we'll use a heuristic based on the current week structure

      // If we're looking for today and it's in the current week range
      if (i == 0 &&
          targetDate
              .isAfter(DateTime.now().subtract(const Duration(days: 7)))) {
        return 0;
      }
    }

    // If we can't determine the week, return null to let the backend handle it
    return null;
  }

  // Store target date to select after week change
  DateTime? _targetDateToSelect;

  // Check if previous navigation is possible
  bool get canNavigatePrevious {
    if (currentDayIndex > 0) return true;
    if (currentWeekIndex != null && currentWeekIndex! > 0) return true;
    return false;
  }

  // Check if next navigation is possible
  bool get canNavigateNext {
    if (currentDayIndex < dayStatesList.length - 1) return true;
    if (currentWeekIndex != null &&
        currentWeekIndex! < weekStatesList.length - 1) return true;
    return false;
  }

  // Get current date as DateTime (local time, date only)
  DateTime get currentDateTime {
    if (currentDay != null) {
      // Parse timestamp as UTC and convert to local, then extract date components only
      final utcDate = DateUtil.parseTimespanToDateTime(currentDay!);
      final localDate = utcDate.toLocal();
      // Return a local DateTime with just the date components to avoid timezone issues
      return DateTime(localDate.year, localDate.month, localDate.day);
    }
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // Check if current date is today
  bool get isCurrentDateToday {
    return DateUtil.isSameDate(currentDateTime, DateTime.now());
  }

  // Get selected date for calendar highlighting
  DateTime? get selectedDateForCalendar {
    return currentDateTime;
  }

  // Get active dates for calendar highlighting (dates that have data)
  List<DateTime> get activeDatesForCalendar {
    final List<DateTime> activeDates = [];

    // Check if user has a package
    if (user.ownPackage?.activationDate == null ||
        user.ownPackage?.expirationDate == null) {
      // Fallback to current week if no package data
      for (var dayState in dayStatesList) {
        if (dayState?.day != null) {
          final date = DateUtil.parseTimespanToDateTime(dayState!.day!);
          activeDates.add(date);
        }
      }
      return activeDates;
    }

    // Get activation and expiration dates from package
    final activationDate =
        DateUtil.parseTimespanToDateTime(user.ownPackage!.activationDate!);
    final expirationDate =
        DateUtil.parseTimespanToDateTime(user.ownPackage!.expirationDate!);

    // Start date = activationDate + 1 day
    final startDate = activationDate.add(const Duration(days: 1));
    // End date = expirationDate + 1 day
    final endDate = expirationDate.add(const Duration(days: 1));

    // Calculate week-aligned dates based on the package structure
    // Week 1: from startDate to the Sunday of the following week
    // Week 2 onwards: full weeks (Monday to Sunday)

    final startDateWeekday = startDate.weekday;
    final endDateTime = DateTime(endDate.year, endDate.month, endDate.day);

    // Week 1: from startDate to the Sunday of the following week
    DateTime currentDate =
        DateTime(startDate.year, startDate.month, startDate.day);

    // Calculate the Sunday of the week after startDate
    // If startDate is Wednesday (3), we want the Sunday of the next week
    // Sunday is weekday 7, so we need to go to the next Sunday
    final daysToNextSunday = (7 - startDateWeekday) % 7;
    final nextSunday = startDate.add(
        Duration(days: daysToNextSunday + 7)); // +7 to get next week's Sunday
    final endOfWeek1 =
        DateTime(nextSunday.year, nextSunday.month, nextSunday.day);

    // Add all days from startDate to the end of Week 1
    while (currentDate.isBefore(endOfWeek1) ||
        currentDate.isAtSameMomentAs(endOfWeek1)) {
      if (currentDate.isBefore(endDateTime) ||
          currentDate.isAtSameMomentAs(endDateTime)) {
        activeDates.add(currentDate);
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Week 2 onwards: full weeks (Monday to Sunday)
    // Start from the Monday after Week 1 ends
    final week2Monday = endOfWeek1.add(const Duration(days: 1));
    DateTime currentWeekMonday =
        DateTime(week2Monday.year, week2Monday.month, week2Monday.day);

    while (currentWeekMonday.isBefore(endDateTime) ||
        currentWeekMonday.isAtSameMomentAs(endDateTime)) {
      // Add all 7 days of the current week (Monday to Sunday)
      for (int i = 0; i < 7; i++) {
        final weekDay = currentWeekMonday.add(Duration(days: i));
        if (weekDay.isBefore(endDateTime) ||
            weekDay.isAtSameMomentAs(endDateTime)) {
          activeDates.add(weekDay);
        }
      }
      currentWeekMonday = currentWeekMonday.add(const Duration(days: 7));
    }

    return activeDates;
  }
}
