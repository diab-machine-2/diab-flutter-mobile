import 'package:medical/src/model/repository/app_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'survey_question.dart';

class SurveyQuestionCubit extends Cubit<SurveyQuestionState> {
  final AppRepository repository;
  Map<int, List<String>> answer = Map();
  int selectedCourseIndex = 0;
  int countAnswerRight = 0;

  SurveyQuestionCubit(this.repository) : super(InitialSurveyQuestionState());

  void recordAnswer(int index, List<String> listAnswerId) {
    emit(SurveyQuestionLoading());
    answer[index] = listAnswerId;
    bool isRight = listAnswerId.toString() ==
        listQuiz[index].answers?.where((e) => e.isCorrect == true).map((e) => e.id).toList().toString();
    if (isRight) {
      countAnswerRight++;
    }
    emit(InitialSurveyQuestionState());
  }

  void showAnswer() {
    emit(SurveyQuestionLoading());
    emit(ShowAnswerQuizSuccess());
  }

  void jumpToIndexCourse(int index) {
    emit(SurveyQuestionLoading());
    selectedCourseIndex = index;
    emit(InitialSurveyQuestionState());
  }
}
