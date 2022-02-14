import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/survey_data.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'introduce_survey.dart';

class IntroduceSurveyCubit extends Cubit<IntroduceSurveyState> {
  final AppRepository repository;
  SurveyData? surveyData;

  IntroduceSurveyCubit(this.repository) : super(InitialIntroduceSurveyState());

  Future<void> getDetailSurvey(String surveyId) async {
    emit(IntroduceSurveyLoading());
    final ApiResult<SurveyData> apiResult =
        await repository.getDetailSurvey(surveyId);
    apiResult.when(success: (SurveyData response) {
      surveyData = response;
      emit(GetDetailSurveySuccess(response));
    }, failure: (NetworkExceptions error) {
      emit(IntroduceSurveyFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }
}
