import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import 'exercise_feedback.dart';

class ExerciseFeedbackCubit extends Cubit<ExerciseFeedbackState> {
  ExerciseFeedbackCubit(this.repository)
      : super(const ExerciseFeedbackInitial());

  final AppRepository repository;

  int? selectedAnswer;
  String note = '';

  List<String> level = ['Bài tập quá nhẹ', 'Bài tập nhẹ', 'Bài tập vừa sức', 'Bài tập nặng', 'Bài tập quá nặng'];

  void onSelectAnswer(int newAnswer) {
    selectedAnswer = newAnswer;
    emit(const ExerciseFeedbackSuccess());
    emit(const ExerciseFeedbackInitial());
  }

  void onSumit() {
    if (selectedAnswer == null) {
      emit(const ExerciseFeedbackFailure('Select one'));
    }
    print('LOG $note, ${level[selectedAnswer ?? 0]}');
  }
}
