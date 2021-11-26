import 'package:bloc/bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/user_info_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'blood_sugar_start_survey.dart';
import 'blood_sugar_start_survey_state.dart';

class BloodSugarStartSurveyCubit extends Cubit<BloodSugarStartSurveyState> {
  BloodSugarStartSurveyCubit(this.repository)
      : super(const BloodSugarStartSurveyInitial());

  final AppRepository repository;

  bool isBasicUser = false;
  String surveyCode = '';

  Future<void> getCurrentUserInfo() async {
    emit(const BloodSugarStartSurveyLoading());
    final ApiResult<UserInfoResponse> apiResult =
        await repository.getCurrentUserInfo();
    apiResult.when(success: (UserInfoResponse response) {
      final String packageCode = response.data?.packageCode ?? '';
      // isBasicUser = packageCode.isEmpty || packageCode == Const.BASIC;
      surveyCode = response.data?.bloodSugarTemplates ?? '';
      emit(const BloodSugarStartSurveySuccess());
    }, failure: (NetworkExceptions error) {
      emit(BloodSugarStartSurveyFailure(
          NetworkExceptions.getErrorMessage(error)));
    });
  }
}
