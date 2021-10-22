import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/list_quiz_lesson_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'course_quiz.dart';

class CourseQuizCubit extends Cubit<CourseQuizState> {
  final AppRepository repository;
  List<QuizData> listQuiz = [];
  Map<int, List<String>> answer = Map();
  int selectedCourseIndex = 0;
  int countAnswerRight = 0;

  CourseQuizCubit(this.repository) : super(InitialCourseQuizState());

  void getListQuiz(String lessonId) async {
    emit(CourseQuizLoading());
    ApiResult<List<QuizData>> apiResult =
    await repository.getListQuiz(lessonId);
    apiResult.when(success: (List<QuizData> response) {
      listQuiz = response;
      emit(CourseQuizSuccess());
    }, failure: (NetworkExceptions error) {
      emit(CourseQuizFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  void recordAnswer(int index, List<String> listAnswerId) {
    emit(CourseQuizLoading());
    answer[index] = listAnswerId;
    bool isRight = listAnswerId.toString() ==
        listQuiz[index].answers?.where((e) => e.isCorrect == true).map((e) => e.id).toList().toString();
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