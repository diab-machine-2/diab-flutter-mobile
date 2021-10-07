import 'package:bloc/bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/const.dart';

import 'blood_sugar_start_survey.dart';
import 'blood_sugar_start_survey_state.dart';

class BloodSugarStartSurveyCubit extends Cubit<BloodSugarStartSurveyState> {
  BloodSugarStartSurveyCubit(this.repository)
      : super(const BloodSugarStartSurveyInitial());

  final AppRepository repository;

  bool isBasicUser = true;
  bool didSurvey = false;

  Future<void> getOwnPackageCode() async {
    emit(const BloodSugarStartSurveyLoading());
    final ApiResult<String> apiResult = await repository.getOwnPackageCode();
    apiResult.when(success: (String response) {
      isBasicUser = response.isEmpty || response == Const.BASIC;
      emit(const BloodSugarStartSurveySuccess());
    }, failure: (NetworkExceptions error) {
      emit(BloodSugarStartSurveyFailure(
          NetworkExceptions.getErrorMessage(error)));
    });
  }
}
