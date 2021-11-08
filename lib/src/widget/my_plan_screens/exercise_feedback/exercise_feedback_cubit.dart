import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import 'exercise_feedback.dart';

class ExerciseFeedbackCubit extends Cubit<ExerciseFeedbackState> {
  ExerciseFeedbackCubit(this.repository)
      : super(const ExerciseFeedbackInitial());

  final AppRepository repository;

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

  void onSubmit() {
    if (selectedAnswer == null) {
      emit(const ExerciseFeedbackFailure('Select one'));
    }
    print('LOG $note, ${level[selectedAnswer ?? 0]}');
  }
}
