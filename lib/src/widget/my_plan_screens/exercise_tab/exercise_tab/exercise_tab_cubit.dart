import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/SelectRoadmapRequest.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/exercise_movement_response.dart';
import 'package:medical/src/model/response/list_roadmap_response.dart';
import 'package:medical/src/model/response/week_states_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/widgets/day_in_week_widget.dart';

import '../../../../app_setting/app_setting.dart';
import '../../../../repo/home/home_client.dart';
import '../../my_plan/models/completion_status.dart';
import '../../my_plan/my_plan.dart';
import 'exercise_tab.dart';

class ExerciseTabCubit extends Cubit<ExerciseTabState> {
  ExerciseTabCubit(this.repository, this.myPlanCubit)
      : super(const ExerciseTabInitial());

  final AppRepository repository;
  final MyPlanCubit myPlanCubit;

  String roadmapId = '';
  int? currentWeekIndex;
  int currentDayIndex = 0;
  int mark = 0;
  List<WeekStatesResponseData> weekStatesList = [];
  ExerciseMovementResponse? exerciseMovementResponse;
  List<ListRoadmapResponseData?> roadMapList = [];
  ListRoadmapResponseData? currentRoadMap;

  int? get week => !isHasRoadmapUser
      ? null
      : currentWeekIndex == null
          ? 0
          : currentWeekIndex;
  // weekStatesList[currentWeekIndex!].week;

  int get dataLength => exerciseMovementResponse?.data?.length ?? 0;

  bool get isHasRoadmapUser => myPlanCubit.isHasRoadmapUser;

  bool get isFreeUser => myPlanCubit.isFreeUser;

  bool get isDayOff {
    if (isHasRoadmapUser && currentExercise == null) return true;
    if (!isHasRoadmapUser &&
        exerciseMovementResponse?.data?.isNotEmpty != true) {
      return true;
    }
    return false;
  }

  ExerciseMovementResponseData? get currentExercise {
    final ExerciseMovementResponseData? exercise = exerciseMovementResponse
        ?.getExerciseFromDayInWeek(week: week ?? 1, dayIndex: currentDayIndex);
    //if (exercise?.isBlank == true) return null;
    return exercise;
  }

  CompletionStatus? getExerciseOfDay(int dayIndex) {
    if (week == null) return null;
    if (exerciseMovementResponse?.data == null)
      return CompletionStatus.completed;
    return exerciseMovementResponse
        ?.getExerciseFromDayInWeek(week: week!, dayIndex: dayIndex)
        ?.completionStatus;
  }

  List<DayInWeekData> get dayInWeekList =>
      exerciseMovementResponse?.dayInWeekList ?? [];

  String roadMapName = '';

  void onSelectWeek(int newIndex) {
    currentWeekIndex = newIndex;
    getExerciseMovement(isShowLoading: true);
  }

  void onSelectDay(int newDayIndex) {
    if (newDayIndex == currentDayIndex)
      return;
    else {
      currentDayIndex = newDayIndex;
      emit(const ExerciseTabSuccess());
      emit(const ExerciseTabInitial());
    }
  }

  Future roadmapChanged(String newRoadmapId) async {
    emit(const ExerciseTabLoading());
    roadmapId = newRoadmapId;
    await myPlanCubit.getCurrentUserInfo();
    // Fetch updated home data to get the new roadMapName
    try {
      final homeClient = HomeClient();
      final homeModel = await homeClient.fetchHomes();
      roadMapName = homeModel.roadMapName ?? '';
      // Save the updated home data to cache
      await AppSettings.saveHome(homeModel.toJson());
    } catch (e) {
      // If fetch fails, fallback to reading from cache
      roadMapName = await getRoadMapName();
    }
    await onRefresh(isRefresh: true);
    //  await getExerciseMovement();
  }

  Future<void> onRefresh(
      {bool isRefresh = false, bool keepSelectedDayIndex = false}) async {
    //   if (myPlanCubit.isHasRoadmapUser) await getWeekStates(isRefresh: isRefresh);
    getExerciseMovement(
        isRefresh: isRefresh, keepSelectedDayIndex: keepSelectedDayIndex);
  }

  Future<String> getRoadMapName() async {
    final homeModel = await AppSettings.getHome();
    return homeModel?.roadMapName ?? '';
  }

  Future<void> initData() async {
    await myPlanCubit.checkUserInfo();
    roadmapId = myPlanCubit.roadmapId;
    roadMapName = await getRoadMapName();
    if (myPlanCubit.roadmapId.isNotEmpty != true) {
      // Fetch roadmap list when roadmap is empty
      await getRoadAppRoadMap();
      emit(const ExerciseTabRoadmapEmpty());
      emit(const ExerciseTabInitial());
      return;
    }

    emit(const ExerciseTabLoading());
    if (myPlanCubit.isHasRoadmapUser) {
      currentWeekIndex = myPlanCubit.currentStudyWeek!;
      if (currentWeekIndex == -1) currentWeekIndex = 0;
      await getWeekStates();
    } else {
      currentWeekIndex = 0;
    }
    Timer(const Duration(milliseconds: 100), () {
      emit(ExerciseTabWeekChanged(currentWeekIndex ?? 0));
    });
    await getExerciseMovement();
  }

  Future<void> getExerciseMovement(
      {bool isRefresh = false,
      bool keepSelectedDayIndex = false,
      bool isShowLoading = false}) async {
    if (!isRefresh) {
      await Future.delayed(Duration.zero);
    }

    if (isShowLoading) {
      emit(ExerciseTabLoading());
    }

    final ApiResult<ExerciseMovementResponse> apiResult =
        await repository.getExerciseMovement();
    apiResult.when(success: (ExerciseMovementResponse response) {
      exerciseMovementResponse = response;
      mark = exerciseMovementResponse?.getMarkNotLearnIndex(
              week: week ?? 1,
              userCurrentWeek: myPlanCubit.currentStudyWeek ?? 1) ??
          0;

      if (!keepSelectedDayIndex) {
        currentDayIndex =
            exerciseMovementResponse?.getCurrentDayIndex(week ?? 1) ?? 1;
      }
      Timer(const Duration(milliseconds: 100), () {
        emit(ExerciseTabScrollToLesson(response.firstExerciseIndex));
      });
      emit(const ExerciseTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(ExerciseTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const ExerciseTabInitial());
  }

  Future<void> getWeekStates({bool isRefresh = false}) async {
    //await Future.delayed(Duration.zero);
    //   emit(const ExerciseTabLoading());

    if (AppSettings.userInfo?.statistict?.exerciseMovements != null &&
        !isRefresh) {
      weekStatesList.clear();
      for (final state
          in AppSettings.userInfo?.statistict?.exerciseMovements ?? []) {
        if (state != null) {
          weekStatesList.add(state);
        }
      }
      weekStatesList.sort((a, b) => (a.week ?? 0) - (b.week ?? 0));
    } else {
      final ApiResult<WeekStatesResponse> apiResult =
          await repository.getExerciseWeekStates();
      apiResult.when(success: (WeekStatesResponse response) {
        weekStatesList.clear();
        for (final state in response.data ?? []) {
          if (state != null) {
            weekStatesList.add(state);
          }
        }
        weekStatesList.sort((a, b) => (a.week ?? 0) - (b.week ?? 0));
        //    emit(const ExerciseTabSuccess());
      }, failure: (NetworkExceptions error) {
        //    emit(ExerciseTabFailure(NetworkExceptions.getErrorMessage(error)));
      });
    }
    //  emit(const ExerciseTabInitial());
  }

  Future<bool> getRoadAppRoadMap({
    bool isLoadMore = false,
  }) async {
    await Future.delayed(Duration.zero);
    if (!isLoadMore) {
      emit(const ExerciseTabLoading());
    }
    final ApiResult<ListRoadmapResponse> apiResult =
        await repository.getRoadMap();
    apiResult.when(success: (ListRoadmapResponse response) {
      roadMapList = response.data ?? [];
      currentRoadMap = response.currentRoadMap;
      emit(const ExerciseTabSuccess());
      return true;
    }, failure: (NetworkExceptions error) {
      emit(ExerciseTabFailure(NetworkExceptions.getErrorMessage(error)));
      return false;
    });
    emit(const ExerciseTabInitial());
    return true;
  }

  String formatRoadmapName(String name) {
    name = name.replaceAll("vận động ít", "<strong>vận động ít</strong>");
    name = name.replaceAll("vận động nhiều", "<strong>vận động nhiều</strong>");
    return name;
  }

  Future<void> changeRoadMapInline(ListRoadmapResponseData? itemData) async {
    if (itemData == null) return;

    emit(const ExerciseTabLoading());
    DateTime dateTime0 = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);
    int startDate = (dateTime0.millisecondsSinceEpoch ~/ 1000).toInt();

    SelectRoadmapRequest request =
        SelectRoadmapRequest(roadmapId: itemData.id, startDate: startDate);

    final ApiResult<CommonResponse> apiResult =
        await repository.selectRoadmap(request);

    apiResult.when(success: (CommonResponse response) {
      // Update roadmapId and refresh
      roadmapId = itemData.id ?? '';
      roadmapChanged(itemData.id ?? '');
    }, failure: (NetworkExceptions error) {
      emit(ExerciseTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }
}
