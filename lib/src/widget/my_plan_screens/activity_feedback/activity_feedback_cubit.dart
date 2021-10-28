import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import 'activity_feedback.dart';

class ActivityFeedbackCubit extends Cubit<ActivityFeedbackState> {
  ActivityFeedbackCubit(this.repository)
      : super(const ActivityFeedbackInitial());

  final AppRepository repository;

  int? selectedAnswer;
  String note = '';

  List<String> level = ['Bài tập quá nhẹ', 'Bài tập nhẹ', 'Bài tập vừa sức', 'Bài tập nặng', 'Bài tập quá nặng'];

  void onSelectAnswer(int newAnswer) {
    selectedAnswer = newAnswer;
    emit(const ActivityFeedbackSuccess());
    emit(const ActivityFeedbackInitial());
  }

  void onSumit() {
    if (selectedAnswer == null) {
      emit(const ActivityFeedbackFailure('Select one'));
    }
    print('LOG $note, ${level[selectedAnswer ?? 0]}');
  }
}
