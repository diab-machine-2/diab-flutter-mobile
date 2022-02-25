import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/complete_exercise_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/exercise_movement_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import '../../../../model/request/complete_video_request.dart';
import '../../my_plan/models/completion_status.dart';
import 'exercise_detail.dart';
import 'models/video_manager.dart';

class ExerciseDetailCubit extends Cubit<ExerciseDetailState> {
  ExerciseDetailCubit(this.repository) : super(const ExerciseDetailInitial());

  final AppRepository repository;

  late final ExerciseMovementResponseData exerciseData;
  late final VideoManager videoManager;

  bool exerciseCompleted = false;

  void initData(ExerciseMovementResponseData? exerciseData, BuildContext context) async {
    if (exerciseData == null) return;
    this.exerciseData = exerciseData;
    videoManager = VideoManager.fromExerciseData(
      context,
      exerciseData,
      onCompleteVideo: (exerciseCategoryId, duration) async {
        await completeVideo(exerciseCategoryId, duration);
      },
      onDone: () {
        if (!exerciseCompleted &&
            exerciseData.completionStatus != CompletionStatus.completed) {
          exerciseCompleted = true;
          completeExercise(exerciseData.id ?? '');
        }
      },
    );
  }

  Future<void> completeVideo(String exerciseCategoryId, int duration) async {
    emit(const ExerciseDetailLoading());
    final CompleteVideoRequest request = CompleteVideoRequest(
      exerciseCategoryId: exerciseCategoryId,
      duration: duration,
    );
    final ApiResult<CommonResponse> apiResult =
        await repository.completeVideo(request);
    apiResult.when(success: (CommonResponse response) {
      emit(const ExerciseDetailVideoCompleted());
    }, failure: (NetworkExceptions error) {
      emit(ExerciseDetailFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const ExerciseDetailInitial());
  }

  Future<void> completeExercise(String exerciseMovementId) async {
    emit(const ExerciseDetailLoading());
    final CompleteExerciseRequest request = CompleteExerciseRequest(
      exerciseMovementId: exerciseMovementId,
      roadmapid: exerciseData.roadmapId,
    );
    final ApiResult<CommonResponse> apiResult =
        await repository.completeExercise(request);
    apiResult.when(success: (CommonResponse response) {
      emit(const ExerciseDetailAllCompleted());
    }, failure: (NetworkExceptions error) {
      emit(ExerciseDetailFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const ExerciseDetailInitial());
  }
}
