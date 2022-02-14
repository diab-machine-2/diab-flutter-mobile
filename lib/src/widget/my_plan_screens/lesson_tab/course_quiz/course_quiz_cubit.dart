import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/update_lesson_section_request.dart';
import 'package:medical/src/model/request/update_quiz_lesson_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/response/quiz_lesson.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'course_quiz.dart';

class CourseQuizCubit extends Cubit<CourseQuizState> {
  CourseQuizCubit(this.repository, {required this.lessonId, required this.lessonSectionItem})
      : super(InitialCourseQuizState());
  final AppRepository repository;

  final String lessonId;
  final LessonSectionItem? lessonSectionItem;

  List<QuizLesson?> listQuiz = [];
  Map<int, List<String>> answer = {};
  int selectedCourseIndex = 0;
  double minCompletePercent = 100;

  String quizName = '';

  bool isShowResult = false;

  bool get isAllCompleted => answer.length == listQuiz.length;

  bool get isQuizLesson => lessonSectionItem == null;

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

  bool get isPassed => ((countAnswerRight / listQuiz.length) * 100) > minCompletePercent;

  Future<void> initData() async {
    if (!isQuizLesson) {
      minCompletePercent = 80;
      listQuiz = lessonSectionItem?.quizLessonSections ?? [];
      quizName = lessonSectionItem?.name ?? '';
      if (listQuiz.isNotEmpty != true) {
        emit(const CourseQuizDone());
      }
      emit(const CourseQuizLoading());
      await Future.delayed(Duration.zero);
      emit(const CourseQuizSuccess());
      emit(InitialCourseQuizState());
      return;
    }
    getListQuiz();
  }

  void recordAnswer(int index, List<String> listAnswerId) {
    emit(const CourseQuizLoading());
    answer[index] = listAnswerId;
    if (listAnswerId.isEmpty) {
      answer.remove(index);
    }
    emit(InitialCourseQuizState());
  }

  void showAnswer() {
    emit(const CourseQuizLoading());
    isShowResult = true;
    jumpToIndexCourse(0);
    emit(ShowAnswerQuizSuccess());
  }

  void retryQuiz() {
    emit(const CourseQuizLoading());
    answer.clear();
    isShowResult = false;
    listQuiz.shuffle();
    emit(RetryQuizSuccess());
  }

  void jumpToIndexCourse(int index) {
    emit(const CourseQuizLoading());
    selectedCourseIndex = index;
    emit(InitialCourseQuizState());
  }

  void setCompleteQuiz() {
    //  if (!isPassed) return;
    if (!isQuizLesson) {
      completeLearningCurrentSection();
    }
    setCompletedLessonQuiz();
  }

  Future<void> getListQuiz() async {
    emit(const CourseQuizLoading());
    final ApiResult<LessonSectionListResponse?> apiResult = await repository.getListQuiz(lessonId);
    apiResult.when(success: (LessonSectionListResponse? response) {
      minCompletePercent = response?.data?.minCompletePercent?.toDouble() ?? 80;
      if (response?.data?.quizLessons?.isNotEmpty != true) {
        listQuiz = [];
      } else {
        listQuiz = response?.data?.quizLessons ?? [];
      }
      quizName = response?.data?.name ?? '';
      if (listQuiz.isNotEmpty != true) {
        emit(const CourseQuizDone());
      }
      emit(const CourseQuizSuccess());
    }, failure: (NetworkExceptions error) {
      emit(CourseQuizFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  Future<void> completeLearningCurrentSection() async {
    await Future.delayed(Duration.zero);
    emit(const CourseQuizLoading());
    final ApiResult<CommonResponse> apiResult = await repository.setCompletedLessonAccount(
      UpdateLessonSectionRequest(
        lessonId: lessonId,
        type: lessonSectionItem?.type,
        lessonSectionId: lessonSectionItem?.id,
      ),
    );
    apiResult.when(success: (CommonResponse response) {
      if (response.meta?.success == true) {
        lessonSectionItem?.isComplete = true;
      }
      emit(const CourseQuizSuccess());
    }, failure: (NetworkExceptions error) {
      emit(CourseQuizFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(InitialCourseQuizState());
  }

  Future<void> setCompletedLessonQuiz() async {
    await Future.delayed(Duration.zero);
    emit(const CourseQuizLoading());
    final ApiResult<CommonResponse> apiResult = await repository.setCompletedLessonQuiz(UpdateQuizLessonRequest(
      lessonId: lessonId,
    ));
    apiResult.when(success: (CommonResponse response) {
      emit(const CourseQuizSuccess());
    }, failure: (NetworkExceptions error) {
      emit(CourseQuizFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(InitialCourseQuizState());
  }
}
