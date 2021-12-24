import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/response/quiz_lesson.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'course_quiz.dart';

class CourseQuizCubit extends Cubit<CourseQuizState> {
  CourseQuizCubit(this.repository) : super(InitialCourseQuizState());
  final AppRepository repository;

  List<QuizLesson?> listQuiz = [];
  Map<int, List<String>> answer = {};
  int selectedCourseIndex = 0;
  double minCompletePercent = 1;

  String quizName = '';

  bool isShowResult = false;

  bool get isAllCompleted => answer.length == listQuiz.length;

  bool get isOthersCompleted {
    for (int index = 0; index < listQuiz.length; index++) {
      if (index == selectedCourseIndex) continue;
      if (answer[index]?.isNotEmpty != true) return false;
    }
    return true;
  }

  bool? get canComplete {
    if (isShowResult) {
      if (selectedCourseIndex >= listQuiz.length - 1) {
        return true;
      } else {
        return null;
      }
    }
    if (isAllCompleted) return true;
    if (isOthersCompleted) return false;
    return null;
  }

  int get countAnswerRight {
    int countAnswerRight = 0;
    for (int index = 0; index < answer.length; index++) {
      if (answer[index].toString() ==
          listQuiz[index]
              ?.quiz
              ?.quizAnswers
              ?.where((e) => e?.isCorrect == true)
              .map((e) => e?.id)
              .toList()
              .toString()) {
        countAnswerRight++;
      }
    }
    return countAnswerRight;
  }

  bool get isPassed =>
      ((countAnswerRight / listQuiz.length) * 100) > minCompletePercent;

  Future<void> initData(
      {required String lessonId, LessonSectionItem? lessonSectionItem}) async {
    if (lessonSectionItem != null) {
      minCompletePercent = 0.8;
      listQuiz = lessonSectionItem.quizLessonSections ?? [];
      quizName = lessonSectionItem.name ?? '';
      if (listQuiz.isNotEmpty != true) {
        emit(const CourseQuizDone());
      }
      emit(CourseQuizLoading());
      await Future.delayed(Duration.zero);
      emit(CourseQuizSuccess());
      emit(InitialCourseQuizState());
      return;
    }
    getListQuiz(lessonId);
  }

  Future<void> getListQuiz(String lessonId) async {
    emit(CourseQuizLoading());
    final ApiResult<LessonSectionListResponse?> apiResult =
        await repository.getListQuiz(lessonId);
    apiResult.when(success: (LessonSectionListResponse? response) {
      minCompletePercent =
          response?.data?.minCompletePercent?.toDouble() ?? 0.8;
      if (response?.data?.quizLessons?.isNotEmpty != true) {
        listQuiz = [];
      } else {
        listQuiz = response?.data?.quizLessons ?? [];
      }
      quizName = response?.data?.name ?? '';
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
    if (listAnswerId.isEmpty) {
      answer.remove(index);
    }
    emit(InitialCourseQuizState());
  }

  void showAnswer() {
    emit(CourseQuizLoading());
    isShowResult = true;
    jumpToIndexCourse(0);
    emit(ShowAnswerQuizSuccess());
  }

  void retryQuiz() {
    emit(CourseQuizLoading());
    answer.clear();
    isShowResult = false;
    listQuiz.shuffle();
    emit(RetryQuizSuccess());
  }

  void jumpToIndexCourse(int index) {
    emit(CourseQuizLoading());
    selectedCourseIndex = index;
    emit(InitialCourseQuizState());
  }
}
