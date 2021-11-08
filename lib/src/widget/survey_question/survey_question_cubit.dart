import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/post_survey_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'survey_question.dart';

class SurveyQuestionCubit extends Cubit<SurveyQuestionState> {
  final AppRepository repository;
  Map<String, List<String>> answer = {};
  int selectedCourseIndex = 0;
  int countAnswerRight = 0;
  bool isEnableNext = false;

  SurveyQuestionCubit(this.repository) : super(InitialSurveyQuestionState());

  void recordAnswer(String questionId, List<String> listAnswerId,
      List<String> rightAnswerId) {
    emit(SurveyQuestionLoading());
    answer[questionId] = listAnswerId;
    final bool isRight = listAnswerId.toString() == rightAnswerId.toString();
    if (isRight) {
      countAnswerRight++;
    }
    emit(InitialSurveyQuestionState());
  }

  void showAnswer() {
    emit(SurveyQuestionLoading());
    emit(ShowAnswerQuizSuccess());
  }

  void enableNextButton(bool isEnable) {
    emit(SurveyQuestionLoading());
    isEnableNext = isEnable;
    emit(InitialSurveyQuestionState());
  }

  void jumpToIndexCourse(int index) {
    emit(SurveyQuestionLoading());
    selectedCourseIndex = index;
    isEnableNext = false;
    emit(InitialSurveyQuestionState());
  }

  Future<void> submitAnswer(
    String surveyId,
    String sectionId,
  ) async {
    emit(SurveyQuestionLoading());
    final List<QuestionAnswerResults> list = [];
    answer.forEach((key, value) {
      list.add(QuestionAnswerResults(
          surveyQuestionId: key, surveyAnswerIdList: value));
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
