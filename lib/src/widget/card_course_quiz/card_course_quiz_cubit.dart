import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/list_quiz_lesson_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'card_course_quiz.dart';

class CardCourseQuizCubit extends Cubit<CardCourseQuizState> {
  final AppRepository repository;
  List<String> listAnswerApply = [];
  List<String> listAnswerChoosing = [];
  bool isAnswered = false;
  bool isShowAnswer = false;

  CardCourseQuizCubit(this.repository) : super(InitialCardCourseQuizState());

  void checkBox(String answerId, bool isSingleChoice) {
    emit(CardCourseQuizLoading());
    if (isSingleChoice) {
      listAnswerChoosing = [];
    }
    if (listAnswerChoosing.contains(answerId)) {
      listAnswerChoosing.remove(answerId);
    } else {
      listAnswerChoosing.add(answerId);
    }
    emit(InitialCardCourseQuizState());
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