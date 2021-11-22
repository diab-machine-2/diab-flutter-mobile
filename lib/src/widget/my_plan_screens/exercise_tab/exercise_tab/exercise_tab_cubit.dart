import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/exercise_movement_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/const.dart';

import '../../my_plan/my_plan.dart';
import 'exercise_tab.dart';
import 'models/completion_status.dart';

class ExerciseTabCubit extends Cubit<ExerciseTabState> {
  ExerciseTabCubit(this.repository, this.myPlanCubit)
      : super(const ExerciseTabInitial());

  final AppRepository repository;
  final MyPlanCubit myPlanCubit;

  String roadmapId = '';
  int? currentWeekIndex;
  List? weekList;
  DateTime? packageTimeExpired;
  List<ExerciseMovementResponseData?>? exerciseList;

  int? get week => currentWeekIndex == null ? null : (currentWeekIndex! + 1);

  void onSelectWeek(int newIndex) {
    currentWeekIndex = newIndex;
    getExerciseMovement();
  }

  Future<void> generateWeek() async {
    final int current = currentWeekIndex ?? 0;
    weekList = List.generate(52, (index) {
      if (index > current) return CompletionStatus.not_start_yet;
      if (index == current)
        return CompletionStatus.studying;
      else
        return CompletionStatus.completed;
    });
  }

  Future<void> initData() async {
    await myPlanCubit.checkUserInfo();
    if (myPlanCubit.packageCode == Const.PRO &&
        myPlanCubit.currentStudyWeek != null) {
      currentWeekIndex = myPlanCubit.currentStudyWeek! - 1;
      generateWeek();
    }

    if (myPlanCubit.roadmapId?.isNotEmpty != true) {
      emit(const ExerciseTabRoadmapEmpty());
      emit(const ExerciseTabInitial());
      return;
    }
    await getExerciseMovement();
    emit(ExerciseTabWeekChanged(currentWeekIndex ?? 0));
  }

  Future<void> getExerciseMovement({bool isRefresh = false}) async {
    if (!isRefresh) {
      await Future.delayed(Duration.zero);
      emit(const ExerciseTabLoading());
    }
    final ApiResult<ExerciseMovementResponse> apiResult =
        await repository.getExerciseMovement(roadmapId: roadmapId, week: week);
    apiResult.when(success: (ExerciseMovementResponse response) {
      exerciseList = response.data ?? [];
      emit(const ExerciseTabSuccess());
    }, failure: (NetworkExceptions error) {
      emit(ExerciseTabFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const ExerciseTabInitial());
  }
}
