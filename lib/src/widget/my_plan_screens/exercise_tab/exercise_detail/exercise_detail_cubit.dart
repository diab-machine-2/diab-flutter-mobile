import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/app_setting/firebase_tracking/excercise_detail_tracking.dart';
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
  late final String resolvedVideoUrl;

  bool exerciseCompleted = false;
  bool _isCompletingExercise = false;
  final Set<String> _completedVideoCategoryIds = {};

  void initData(
      ExerciseMovementResponseData? exerciseData, BuildContext context) async {
    if (exerciseData == null) return;
    this.exerciseData = exerciseData;
    debugPrint('[EXERCISE] Exercise data initialized: ${exerciseData.name}');

    // Resolve playable video URL: only from first section, else empty
    final String sectionUrl = (exerciseData.sections?.isNotEmpty ?? false)
        ? (exerciseData.sections!.first?.videoUrl ?? '')
        : '';
    resolvedVideoUrl = sectionUrl;

    // Initialize videoManager
    videoManager = VideoManager.fromExerciseData(
      context,
      exerciseData,
      callbackEventListener: (eventType, duration) {
        ExcerciseDetailTracking.playVideo(
          eventType: eventType,
          videoDuration: duration,
          objectId: exerciseData.id,
          objectTitle: exerciseData.name,
        );

        if (!exerciseCompleted &&
            !_isCompletingExercise &&
            exerciseData.completionStatus != CompletionStatus.completed &&
            eventType == CustomPlayerEventType.videoCompleted &&
            duration.inMilliseconds > 0) {
          debugPrint(
              '[EXERCISE] Marking exercise as completed through event listener');
          completeExercise(exerciseData.id ?? '');
        }
      },
      onDone: () {
        if (!exerciseCompleted &&
            !_isCompletingExercise &&
            exerciseData.completionStatus != CompletionStatus.completed) {
          debugPrint('[EXERCISE] Marking exercise as completed through onDone');
          completeExercise(exerciseData.id ?? '');
        }
      },
      onCompleteVideo: (exerciseCategoryId, duration) async {
        debugPrint(
            '[EXERCISE] Video completed: $exerciseCategoryId, duration: ${duration}s');
        // Only complete video once per category ID
        if (!_completedVideoCategoryIds.contains(exerciseCategoryId) &&
            exerciseCategoryId.isNotEmpty) {
          _completedVideoCategoryIds.add(exerciseCategoryId);
          // TODO: Temporarily commented out - API not found
          // await completeVideo(exerciseCategoryId, duration);
          debugPrint(
              '[EXERCISE] completeVideo call commented out - would have called for category: $exerciseCategoryId');
        } else {
          debugPrint(
              '[EXERCISE] Skipping duplicate completeVideo call for category: $exerciseCategoryId');
        }
      },
      onExitFullScreen: () {
        debugPrint('[EXERCISE] Fullscreen exited via callback');
      },
    );

    // Ensure the video is properly initialized
    if (resolvedVideoUrl.isNotEmpty && videoManager.controller != null) {
      await videoManager.waitForVideoReady();
    }
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
    // Prevent multiple simultaneous calls
    if (_isCompletingExercise) {
      debugPrint(
          '[EXERCISE] Skipping duplicate completeExercise call - already in progress');
      return;
    }

    // Check if already completed to prevent duplicate calls
    if (exerciseCompleted) {
      debugPrint(
          '[EXERCISE] Skipping completeExercise call - already completed');
      return;
    }

    _isCompletingExercise = true;
    emit(const ExerciseDetailLoading());
    final CompleteExerciseRequest request = CompleteExerciseRequest(
      exerciseMovementId: exerciseMovementId,
      roadmapid: exerciseData.agendaId,
    );
    final ApiResult<CommonResponse> apiResult =
        await repository.completeExercise(request);
    apiResult.when(success: (CommonResponse response) {
      exerciseCompleted = true;
      emit(const ExerciseDetailAllCompleted());
      // Reset flag on success
      _isCompletingExercise = false;
    }, failure: (NetworkExceptions error) {
      emit(ExerciseDetailFailure(NetworkExceptions.getErrorMessage(error)));
      // Reset flag on failure so it can be retried
      _isCompletingExercise = false;
    });
    emit(const ExerciseDetailInitial());
  }
}
