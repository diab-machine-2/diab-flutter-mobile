import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/modal/user/schedule_glucose_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/blood_sugar_template_response.dart';
import 'package:medical/src/model/response/save_survey_result_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/const.dart';
import 'blood_sugar_schedule_template.dart';

class BloodSugarScheduleTemplateCubit
    extends Cubit<BloodSugarScheduleTemplateState> {
  BloodSugarScheduleTemplateCubit(this.repository, {required this.templateCode})
      : super(const BloodSugarScheduleTemplateInitial());

  final AppRepository repository;
  final String templateCode;
  BloodSugarTemplateResponseData? templateDetail;

  bool isChanged = false;

  void scheduleChanged() {
    isChanged = true;
    refreshState();
  }

  void refreshState() {
    emit(const BloodSugarScheduleTemplateSuccess());
    emit(const BloodSugarScheduleTemplateInitial());
  }

  bool get isWeekTemplate =>
      templateDetail != null &&
      templateDetail!.isWeekTemplate == true &&
      templateDetail!.schedules != null &&
      templateDetail!.schedules!.length >= 7;

  Future<void> showLoading() async {
    await Future.delayed(const Duration());
    emit(const BloodSugarScheduleTemplateLoading());
  }

  Future<void> getTemplateDetail() async {
    emit(const BloodSugarScheduleTemplateLoading());
    final ApiResult<BloodSugarTemplateResponse> apiResult =
        await repository.getTemplateDetail(templateCode);
    apiResult.when(success: (BloodSugarTemplateResponse response) {
      if (response.data != null) {
        templateDetail = response.data;
        isChanged = false;
        if (templateDetail?.code == Const.TEMPLATE_NONE) {
          saveSurveyResult();
          emit(const BloodSugarScheduleTemplateNone());
        }
        emit(const BloodSugarScheduleTemplateSuccess());
      }
    }, failure: (NetworkExceptions error) {
      emit(BloodSugarScheduleTemplateFailure(
          NetworkExceptions.getErrorMessage(error)));
    });
    emit(const BloodSugarScheduleTemplateInitial());
  }

  BloodSugarTemplateResponseDataSchedules? getDayInWeek(int index) {
    final int? dataIndex = templateDetail?.schedules?.indexWhere(
      (templeteDetail) => templeteDetail?.day == index,
    );
    if (dataIndex != null && dataIndex == -1) {
      return null;
    }
    return templateDetail?.schedules?[dataIndex!];
  }

  Future<void> onSubmitSchedule() async {
    final ScheduleGlucoseModel? scheduleGlucoseModel =
        templateDetail?.scheduleGlucoseModel;
    if (scheduleGlucoseModel == null) return;
    try {
      await showLoading();
      await Future.wait([
        UserClient().updateScheduleGlucose(scheduleGlucoseModel),
        saveSurveyResult(),
      ]);
      emit(const BloodSugarScheduleSaveSuccess());
    } catch (e) {
      emit(BloodSugarScheduleTemplateFailure('$e'));
    }
  }

  Future<void> saveSurveyResult() async {
    final ApiResult<SaveSurveyResultResponse> apiResult =
        await repository.saveSurveyResult(templateDetail?.id ?? '');
    apiResult.when(
        success: (SaveSurveyResultResponse response) {},
        failure: (NetworkExceptions error) {
          emit(BloodSugarScheduleTemplateFailure(
              NetworkExceptions.getErrorMessage(error)));
        });
  }
}
