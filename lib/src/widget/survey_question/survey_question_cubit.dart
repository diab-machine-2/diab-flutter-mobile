import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/post_survey_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/list_quiz_lesson_response.dart';
import 'package:medical/src/model/response/survey_data.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'survey_question.dart';

class SurveyQuestionCubit extends Cubit<SurveyQuestionState> {
  SurveyQuestionCubit(this.repository, this.sectionSurvey)
      : super(InitialSurveyQuestionState()) {
    questions = sectionSurvey?.questionList ?? [];
  }

  final AppRepository repository;
  final SectionSurvey? sectionSurvey;
  List<QuizData> questions = [];

  Map<String, QuestionAnswerResults> answer = {};
  int selectedCourseIndex = 0;

  bool isShowed = true;

  int get lengthQuiz => questions.length;

  double get progress => answer.length / lengthQuiz;

  bool get nextButtonEnable =>
      answer.containsKey(questions[selectedCourseIndex].id);

  QuizData? get currentQuestion => questions[selectedCourseIndex];

  void recordAnswer({
    required String questionId,
    required QuestionAnswerResults answerResult,
  }) {
    emit(SurveyQuestionLoading());
    answer[questionId] = answerResult;
    if (answerResult.surveyAnswerIdList?.isNotEmpty != true &&
        answerResult.content?.isNotEmpty != true) {
      answer.remove(questionId);
      isShowed = true;
      emit(SurveyQuestionHideProgressMessage());
      return;
    }
    if (isShowed) {
      emit(SurveyQuestionProgressChanged());
      isShowed = false;
    }

    for (int index = 0;
        index < (currentQuestion?.answers?.length ?? 0);
        index++) {
      final AnswerData? answer = currentQuestion?.answers?[index];
      //Check if the answer is map to a question
      if (answer?.isMappedToSurvey == true) {
        //If the answer is selected
        if (answerResult.surveyAnswerIdList?.contains(answer?.id) == true) {
          final int? mappedQuestionIndex = sectionSurvey?.questions
              ?.indexWhere((element) => element.id == answer?.mappedSurveyId);
          if (mappedQuestionIndex != null &&
              sectionSurvey?.questions?[mappedQuestionIndex] != null) {
            final QuizData mappedQuestion =
                sectionSurvey!.questions![mappedQuestionIndex];
            // Check if the mappedQuestion is in question
            if (!isContainQuestion(mappedQuestion.id)) {
              final int indexInsert = findIndexToInsert(mappedQuestion.order);
              //Check if the mappedQuestion is after current question
              if (indexInsert != -1) {
                //Insert mappedQuestion to question list
                questions.insert(indexInsert, mappedQuestion);
              }
            }
          }
        }
        //If the answer is not selected
        else {
          //Remove mappedQuestion from question list
          questions
              .removeWhere((element) => element.id == answer?.mappedSurveyId);
        }
      }
    }
    emit(InitialSurveyQuestionState());
  }

  bool isContainQuestion(String? questionId) {
    if (questionId == null) return true;
    for (final question in questions) {
      if (question.id == questionId) {
        return true;
      }
    }
    return false;
  }

  int findIndexToInsert(int? order) {
    if (order == null) return 0;
    if (order <= (currentQuestion?.order ?? 0)) return -1;
    for (int index = 0; index < questions.length; index++) {
      if (questions[index].order != null && questions[index].order! >= order) {
        return index;
      }
    }
    return questions.length;
  }

  void jumpToIndexCourse(int index) {
    isShowed = true;
    emit(SurveyQuestionLoading());
    selectedCourseIndex = index;
    emit(InitialSurveyQuestionState());
  }

  Future<void> submitAnswer(
    String surveyId,
    String sectionId,
  ) async {
    emit(SurveyQuestionLoading());
    final List<QuestionAnswerResults> list = [];
    answer.forEach((key, value) {
      list.add(value);
    });
    final PostSurveyRequest request = PostSurveyRequest(
        surveyId: surveyId,
        surveySectionId: sectionId,
        questionAnswerResults: list);
    final ApiResult<CommonResponse> apiResult =
        await repository.submitSurvey(request);
    apiResult.when(success: (CommonResponse response) {
      emit(SubmitSurveySuccess());
    }, failure: (NetworkExceptions error) {
      emit(SurveyQuestionFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }
}
