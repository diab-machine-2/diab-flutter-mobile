import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/exercise_movement_response.dart';
import 'package:medical/src/model/response/week_states_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/const.dart';

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
  DateTime? packageTimeExpired;
  List<WeekStatesResponseData> weekStatesList = [];
  ExerciseMovementResponse? exerciseMovementResponse;

  int? get week =>
      currentWeekIndex == null ? null : weekStatesList[currentWeekIndex!].week;

  ExerciseMovementResponseData? get currentExercise => exerciseMovementResponse
      ?.getExerciseFromDayInWeek(week: week ?? 1, dayInWeek: currentDayIndex);

  CompletionStatus? getExerciseOfDay(int dayIndex) {
    if (week == null) return null;
    if (exerciseMovementResponse?.data == null)
      return CompletionStatus.completed;
    return exerciseMovementResponse
        ?.getExerciseFromDayInWeek(week: week!, dayInWeek: dayIndex)
        ?.completionStatus;
  }

  void onSelectWeek(int newIndex) {
    currentWeekIndex = newIndex;
    getExerciseMovement();
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

  void roadmapChanged(String newRoadmapId) {
    roadmapId = newRoadmapId;
    myPlanCubit.getCurrentUserInfo();
    getExerciseMovement();
  }

  Future<void> initData() async {
    await myPlanCubit.checkUserInfo();
    roadmapId = myPlanCubit.roadmapId;
    if (myPlanCubit.roadmapId.isNotEmpty != true) {
      emit(const ExerciseTabRoadmapEmpty());
      emit(const ExerciseTabInitial());
      return;
    }
    if (myPlanCubit.packageCode == Const.PRO &&
        myPlanCubit.currentStudyWeek != null) {
      currentWeekIndex = myPlanCubit.currentStudyWeek! - 1;
      await getWeekStates();
    }
    await getExerciseMovement();
    emit(ExerciseTabWeekChanged(currentWeekIndex ?? 0));
  }

  Future<void> getExerciseMovement({bool isRefresh = false}) async {
    if (!isRefresh) {
      await Future.delayed(Duration.zero);
      emit(const ExerciseTabLoading());
    }
    final ApiResult<ExerciseMovementResponse> apiResult = await repository
        .getExerciseMovement(roadmapId: roadmapId, week: week ?? 1);
    apiResult.when(success: (ExerciseMovementResponse response) {
      exerciseMovementResponse = response;
      mark = exerciseMovementResponse?.getMarkNotLearnIndex(week ?? 1) ?? 0;
      currentDayIndex =
          exerciseMovementResponse?.getCurrentDayIndex(week ?? 1) ?? 1;
      emit(const ExerciseTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(ExerciseTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const ExerciseTabInitial());
  }

  Future<void> getWeekStates() async {
    await Future.delayed(Duration.zero);
    emit(const ExerciseTabLoading());
    final ApiResult<WeekStatesResponse> apiResult =
        await repository.getExerciseWeekStates(roadmapId: roadmapId);
    apiResult.when(success: (WeekStatesResponse response) {
      weekStatesList.clear();
      for (final state in response.data ?? []) {
        if (state != null) {
          weekStatesList.add(state);
        }
      }
      weekStatesList.sort((a, b) => (a.week ?? 0) - (b.week ?? 0));
      emit(const ExerciseTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(ExerciseTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const ExerciseTabInitial());
  }
}
