import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/quiz_lesson.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'course_quiz.dart';

class CourseQuizCubit extends Cubit<CourseQuizState> {
  final AppRepository repository;
  List<QuizLesson?> listQuiz = [];
  Map<int, List<String>> answer = {};
  int selectedCourseIndex = 0;
  int countAnswerRight = 0;

  CourseQuizCubit(this.repository) : super(InitialCourseQuizState());

  Future<void> getListQuiz(String lessonId) async {
    emit(CourseQuizLoading());
    final ApiResult<List<QuizLesson?>> apiResult =
        await repository.getListQuiz(lessonId);
    apiResult.when(success: (List<QuizLesson?> response) {
      listQuiz = response;
      if (listQuiz.isNotEmpty != true) {
        emit(const CourseQuizDone());
      }
      emit(CourseQuizSuccess());
    }, failure: (NetworkExceptions error) {
      emit(CourseQuizFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  void recordAnswer(int index, List<String> listAnswerId) {
    emit(CourseQuizLoading());
    answer[index] = listAnswerId;
    final bool isRight = listAnswerId.toString() ==
        listQuiz[index]
            ?.quiz
            ?.quizAnswers
            ?.where((e) => e?.isCorrect == true)
            .map((e) => e?.quizId)
            .toList()
            .toString();
    if (isRight) {
      countAnswerRight++;
    }
    emit(InitialCourseQuizState());
  }

  void showAnswer() {
    emit(CourseQuizLoading());
    emit(ShowAnswerQuizSuccess());
  }

  void retryQuiz() {
    emit(CourseQuizLoading());
    answer.clear();
    countAnswerRight = 0;
    emit(RetryQuizSuccess());
  }

  void jumpToIndexCourse(int index) {
    emit(CourseQuizLoading());
    selectedCourseIndex = index;
    emit(InitialCourseQuizState());
  }
}
