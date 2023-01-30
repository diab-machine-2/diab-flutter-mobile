import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/list_quiz_lesson_response.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

import 'card_course_quiz.dart';

class CardCourseQuizCubit extends Cubit<CardCourseQuizState> {
  final AppRepository repository;
  List<String> listAnswerApply = [];
  List<String> listAnswerChoosing = [];
  bool isAnswered = false;
  bool isShowAnswer = false;

  CardCourseQuizCubit(this.repository) : super(InitialCardCourseQuizState());

  void fillAnswer(QuizData quizData) {
    for (final AnswerData data in quizData.answers ?? []) {
      if (data.isCorrectAnswer == true) {
        listAnswerChoosing.add(data.id ?? '');
      }
      if (data.content?.isNotEmpty == true) {
        emit(CardCourseQuizFillText(data.content ?? ''));
      }
    }
  }

  void fillTextField(QuizData quizData) {
    if (quizData.results != null && quizData.answers?.isEmpty == true) {
      emit(CardCourseQuizFillTextField(quizData.results!.isNotEmpty == true
          ? quizData.results!.first.content ?? ''
          : ''));
    }
  }

  Future<void> checkBox(String answerId, bool isSingleChoice) async {
    emit(CardCourseQuizLoading());
    if (isSingleChoice) {
      listAnswerChoosing = [];
    }
    if (listAnswerChoosing.contains(answerId)) {
      listAnswerChoosing.remove(answerId);
    } else {
      listAnswerChoosing.add(answerId);
    }
    emit(ChooseAnswerSuccess());
  }

  void applyAnswer() {
    emit(CardCourseQuizLoading());
    if (!isAnswered) {
      isAnswered = true;
      listAnswerApply = listAnswerChoosing;
    }
    emit(InitialCardCourseQuizState());
  }

  void showAnswer() {
    emit(CardCourseQuizLoading());
    isShowAnswer = true;
    emit(InitialCardCourseQuizState());
  }

  void clearAllAnswer() {
    emit(CardCourseQuizLoading());
    isShowAnswer = false;
    isAnswered = false;
    listAnswerChoosing.clear();
    listAnswerApply.clear();
    emit(InitialCardCourseQuizState());
  }
}
