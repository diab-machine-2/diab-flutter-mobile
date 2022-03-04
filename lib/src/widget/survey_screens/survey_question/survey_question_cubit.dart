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
  SurveyQuestionCubit(this.repository, this.sectionSurvey, this.surveyData, this.listAnsweredQuestionId,)
      : super(InitialSurveyQuestionState()) {
    questions = sectionSurvey?.questionList ?? [];
    isRecalculateListAnsweredQuestion = this.listAnsweredQuestionId.isEmpty;
    calculateProgress();
  }

  final SurveyData surveyData;
  final AppRepository repository;
  final SectionSurvey? sectionSurvey;
  List<QuizData> questions = [];

  Map<String, QuestionAnswerResults> answer = {};
  int selectedCourseIndex = 0;

  bool isShowed = true;
  List<String> listAnsweredQuestionId = [];
  List<String> listAllQuestionId = [];
  bool isRecalculateListAnsweredQuestion = true;

  int get lengthQuiz => questions.length;

 // double get progress => answer.length / lengthQuiz;

 double get progress => listAnsweredQuestionId.length / listAllQuestionId.length;

  bool get nextButtonEnable =>
      answer.containsKey(questions[selectedCourseIndex].id);

  QuizData? get currentQuestion => questions[selectedCourseIndex];

  void calculateProgress() {
    if(surveyData.sections != null){
      for(var section in surveyData.sections!){
        for (int index = 0; index < section.questionList.length; index++) {
          if(section.questionList[index].id != null){
            listAllQuestionId.add(section.questionList[index].id!);
            if (section.questionList[index].hasUserAnswer && isRecalculateListAnsweredQuestion) {
              listAnsweredQuestionId.add(section.questionList[index].id!);
            }
          }
        }
      }
    }
    
    print('countAnsweredQuestion = ${listAnsweredQuestionId.length}, countAllQuestion = ${listAllQuestionId.length}');
  }

  Future<void> scrollToNotAnsweredQuiz() async {
    int scrollIndex = 0;
    for (int index = 0; index < questions.length; index++) {
      scrollIndex = index;
      if (!questions[index].hasUserAnswer) {
        break;
      }
    }
    await Future.delayed(Duration.zero);
    emit(SurveyQuestionScrollToQuiz(scrollIndex));
  }

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
              ?.indexWhere((element) => element.id == answer?.mappedQuestionId);
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
          //If no selected answer linked to the question
          if (!hasAnswerLinkedToQuestion(
              answerResult, answer?.mappedQuestionId)) {
            //Remove mappedQuestion from question list
            questions.removeWhere(
                (element) => element.id == answer?.mappedQuestionId);
          }
        }
      }
    }
    emit(InitialSurveyQuestionState());
  }

  bool hasAnswerLinkedToQuestion(
    QuestionAnswerResults answerResult,
    String? mappedQuestionId,
  ) {
    for (int index = 0;
        index < (currentQuestion?.answers?.length ?? 0);
        index++) {
      final AnswerData? answer = currentQuestion?.answers?[index];
      if (answer?.isMappedToSurvey == true) {
        if (answerResult.surveyAnswerIdList?.contains(answer?.id) == true &&
            answer?.mappedQuestionId == mappedQuestionId) {
          return true;
        }
      }
    }
    return false;
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

  Future<void> submitAnswer({
    required String surveyId,
    required String sectionId,
    required String questionId,
  }) async {
    emit(SurveyQuestionLoading());
    final List<QuestionAnswerResults> list = [];
    answer.forEach((key, value) {
      list.add(value);
    });

    var listAnswer = list
            .where((element) => element.surveyQuestionId == questionId)
            .toList();

    final PostSurveyRequest request = PostSurveyRequest(
        questionAnswerResults: listAnswer.isNotEmpty ? listAnswer.first : null);
    final ApiResult<CommonResponse> apiResult =
        await repository.submitSurvey(request);
    apiResult.when(success: (CommonResponse response) {
      if(!listAnsweredQuestionId.contains(questionId)){
        listAnsweredQuestionId.add(questionId);
      }
      emit(SubmitSurveySuccess());
    }, failure: (NetworkExceptions error) {
      emit(SurveyQuestionFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }
}
