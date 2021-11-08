import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/exercise_feedback_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'exercise_feedback.dart';

class ExerciseFeedbackCubit extends Cubit<ExerciseFeedbackState> {
  ExerciseFeedbackCubit(this.repository, this.exerciseMovementId)
      : super(const ExerciseFeedbackInitial());

  final AppRepository repository;

  String exerciseMovementId;
  int? selectedAnswer;
  String note = '';

  List<String> level = [
    R.string.exercise_level_1.tr(),
    R.string.exercise_level_2.tr(),
    R.string.exercise_level_3.tr(),
    R.string.exercise_level_4.tr(),
    R.string.exercise_level_5.tr(),
  ];

  void onSelectAnswer(int newAnswer) {
    selectedAnswer = newAnswer;
    emit(const ExerciseFeedbackSuccess());
    emit(const ExerciseFeedbackInitial());
  }

  Future<void> submitFeedback() async {
      emit(const ExerciseFeedbackLoading());
  final ExerciseFeedbackRequest request = ExerciseFeedbackRequest(
    exerciseMovementId: exerciseMovementId,
    rating: (selectedAnswer ?? -1) + 1,
    note: note,
    );
    final ApiResult<CommonResponse> apiResult =
        await repository.exerciseFeedback(request);
    apiResult.when(success: (CommonResponse response) {
      emit(const ExerciseFeedbackSent());
    }, failure: (NetworkExceptions error) {
      emit(ExerciseFeedbackFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const ExerciseFeedbackInitial());
  }
}
