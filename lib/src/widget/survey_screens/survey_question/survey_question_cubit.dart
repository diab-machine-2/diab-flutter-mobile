import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/post_survey_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/list_quiz_lesson_response.dart';
import 'package:medical/src/model/response/survey_data.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import '../../../app_setting/app_setting.dart';
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
  String currentText = '';

  Map<String, QuestionAnswerResults> answer = {};
  int selectedCourseIndex = 0;

  bool isShowed = true;
  List<String> listAnsweredQuestionId = [];
  List<String> listAllQuestionId = [];
  bool isRecalculateListAnsweredQuestion = true;

  int get lengthQuiz => questions.length;

 // double get progress => answer.length / lengthQuiz;

 double get progress => listAnsweredQuestionId.length / listAllQuestionId.length;

  bool get nextButtonEnable {
    if(questions[selectedCourseIndex].answers == null 
      || questions[selectedCourseIndex].answers?.isEmpty == true){
        return currentText.isNotEmpty;
    } else {
      return answer.containsKey(questions[selectedCourseIndex].id);
    }
  }

  QuizData? get currentQuestion => questions[selectedCourseIndex];

  void calculateProgress() {
    String? accountIdCurrentUser = AppSettings.userInfo?.accountId;
    if(surveyData.sections != null){
      for(var section in surveyData.sections!){
        for (int index = 0; index < section.questionList.length; index++) {
          if(section.questionList[index].id != null){
            // if(section.questionList[index].answers == null || section.questionList[index].answers?.isEmpty == true){
            //   List<AnswerData> listAnswers = [];
            //   if(section.questionList[index].results != null){
            //     if(section.questionList[index].results!.accountId == accountIdCurrentUser){
            //       listAnswers.add(
            //         AnswerData(
            //           id: section.questionList[index].results!.surveyAnswerId, 
            //           content: section.questionList[index].results!.content, name: section.questionList[index].results!.content, 
            //           isCorrectAnswer: true, 
            //           textAnswer: section.questionList[index].results!.content)
            //         );
            //     }
            //   }
            //   section.questionList[index].setAnswers(listAnswers);
            // }
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
      if (!questions[index].hasUserAnswer) {
        scrollIndex = index;
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
   //   isShowed = true;
   //   emit(SurveyQuestionHideProgressMessage());
      return;
    }
    // if (isShowed) {
    //   emit(SurveyQuestionProgressChanged());
    //   isShowed = false;
    // }

    for (int index = 0;
        index < (currentQuestion?.answers?.length ?? 0);
        index++) {
      final AnswerData? answer = currentQuestion?.answers?[index];
      //Check if the answer is map to a question
      if (answer?.isMappedToSurvey == true) {
        //If the answer is selected
        if (answerResult.surveyAnswerIdList?.contains(answer?.id) == true) {
          for(var mappedQuestionId in answer?.mappedQuestionIds ?? []){
            final int? mappedQuestionIndex = sectionSurvey?.questions
                ?.indexWhere((element) => element.id == mappedQuestionId);
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
        }
        //If the answer is not selected
        else {
          //If no selected answer linked to the question
          for(var mappedQuestionId in answer?.mappedQuestionIds ?? []){
            if (!hasAnswerLinkedToQuestion(
                answerResult, mappedQuestionId)) {
              //Remove mappedQuestion from question list
              questions.removeWhere(
                  (element) => element.id == mappedQuestionId);
            }
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
        for(var id in answer?.mappedQuestionIds ?? []){
          if (answerResult.surveyAnswerIdList?.contains(answer?.id) == true &&
              id == mappedQuestionId) {
            return true;
          }
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
    required bool isRelatedQuestion,
  }) async {
    emit(SurveyQuestionLoading());
    final List<QuestionAnswerResults> list = [];
    answer.forEach((key, value) {
      list.add(value);
    });

    var listAnswer = list
            .where((element) => element.surveyQuestionId == questionId)
            .toList();

    QuestionAnswerResults? answerResult = listAnswer.isNotEmpty ? listAnswer.first : null;

    final PostSurveyRequest request = PostSurveyRequest(
        questionAnswerResults: answerResult);
    final ApiResult<CommonResponse> apiResult =
        await repository.submitSurvey(request);
    apiResult.when(success: (CommonResponse response) {
      if(isRelatedQuestion == false && !listAnsweredQuestionId.contains(questionId) && progress < 1){
        listAnsweredQuestionId.add(questionId);
      }
      if (answerResult?.surveyAnswerIdList?.isNotEmpty != true &&
        answerResult?.content?.isNotEmpty != true) {
    //  answer.remove(questionId);
        isShowed = true;
        emit(SurveyQuestionHideProgressMessage());
        return;
      }
      if (isShowed) {
        emit(SurveyQuestionProgressChanged());
        isShowed = false;
      }
      emit(SubmitSurveySuccess());
    }, failure: (NetworkExceptions error) {
      emit(SurveyQuestionFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }
}
