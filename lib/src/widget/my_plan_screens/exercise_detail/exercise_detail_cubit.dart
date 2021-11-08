import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/exercise_movement_response.dart';
import 'exercise_detail.dart';
import 'models/video_manager.dart';

class ExerciseDetailCubit extends Cubit<ExerciseDetailState> {
  ExerciseDetailCubit(this.repository) : super(const ExerciseDetailInitial());

  final AppRepository repository;

  late final ExerciseMovementResponseData exerciseData;
  late final VideoManager videoManager;
  bool isFeedbacked = false;

  void initData(ExerciseMovementResponseData exerciseData) {
    this.exerciseData = exerciseData;
    videoManager = VideoManager.fromExerciseData(
      exerciseData,
      onDone: () {
        emit(
          isFeedbacked
              ? const ExerciseDetailAllCompleted()
              : const ExerciseDetailMakeFeedback(),
        );
      },
    );
  }
}
