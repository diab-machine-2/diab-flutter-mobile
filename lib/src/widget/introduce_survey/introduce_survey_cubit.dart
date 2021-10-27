import 'package:medical/src/model/repository/app_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/request/send_feedback_course_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/list_package_response.dart';
import 'package:medical/src/model/response/survey_data.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'introduce_survey.dart';

class IntroduceSurveyCubit extends Cubit<IntroduceSurveyState> {
  final AppRepository repository;
  SurveyData? surveyData;

  IntroduceSurveyCubit(this.repository) : super(InitialIntroduceSurveyState());
  
  void getMySurvey() async {
    emit(IntroduceSurveyLoading());
    ApiResult<ListPackageResponse> apiResult = await repository.getListPackage();
    apiResult.when(success: (ListPackageResponse response) {
      emit(IntroduceSurveySuccess());
    }, failure: (NetworkExceptions error) {
      emit(IntroduceSurveyFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  void getDetailSurvey(String surveyId) async {
    emit(IntroduceSurveyLoading());
    ApiResult<SurveyData> apiResult = await repository.getDetailSurvey(surveyId);
    apiResult.when(success: (SurveyData response) {
      surveyData = response;
      emit(GetDetailSurveySuccess(response));
    }, failure: (NetworkExceptions error) {
      emit(IntroduceSurveyFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }
}
