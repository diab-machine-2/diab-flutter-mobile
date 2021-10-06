import 'package:bloc/bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/const.dart';

import 'blood_sugar_start_survey.dart';
import 'blood_sugar_start_survey_state.dart';

class BloodSugarStartSurveyCubit extends Cubit<BloodSugarStartSurveyState> {
  BloodSugarStartSurveyCubit(this.repository) : super(const BloodSugarStartSurveyInitial());

  final AppRepository repository;
  SurveyStatus surveyStatus = SurveyStatus.not_done;

  Future<bool> getOwnPackageCode() async {
    emit(const BloodSugarStartSurveyLoading());
    final ApiResult<String> apiResult = await repository.getOwnPackageCode();
    apiResult.when(success: (String response) {
      if (response.isEmpty || response == Const.BASIC) {
        surveyStatus = SurveyStatus.upgrade_require;
      }
      emit(const BloodSugarStartSurveySuccess());
      return true;
    }, failure: (NetworkExceptions error) {
      emit(BloodSugarStartSurveyFailure(NetworkExceptions.getErrorMessage(error)));
      return false;
    });
    return false;
  }
}
