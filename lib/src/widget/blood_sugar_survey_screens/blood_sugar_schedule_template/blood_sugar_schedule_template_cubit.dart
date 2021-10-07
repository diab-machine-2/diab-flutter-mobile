import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/modal/user/schedule_glucose_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/blood_sugar_template_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'blood_sugar_schedule_template.dart';

class BloodSugarScheduleTemplateCubit
    extends Cubit<BloodSugarScheduleTemplateState> {
  BloodSugarScheduleTemplateCubit(this.repository,
      {required this.initialTemplateDetail})
      : super(const BloodSugarScheduleTemplateInitial());

  final AppRepository repository;
  BloodSugarTemplateResponseData initialTemplateDetail;
  late BloodSugarTemplateResponseData templateDetail;

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
      templateDetail.isWeekTemplate == true &&
      templateDetail.schedules != null &&
      templateDetail.schedules!.length >= 7;

  Future<void> showLoading() async {
    await Future.delayed(const Duration());
    emit(const BloodSugarScheduleTemplateLoading());
  }

  void resetTemplateDetail() {
    templateDetail = initialTemplateDetail;
    isChanged = false;
    refreshState();
  }

  Future<void> refreshTemplateDetail() async {
    if (initialTemplateDetail.code == null) return;
    emit(const BloodSugarScheduleTemplateLoading());
    final ApiResult<BloodSugarTemplateResponse> apiResult =
        await repository.getTemplateDetail(initialTemplateDetail.code!);
    apiResult.when(success: (BloodSugarTemplateResponse response) {
      if (response.data != null) {
        initialTemplateDetail = response.data!;
        templateDetail = response.data!;
        isChanged = false;
        emit(const BloodSugarScheduleTemplateSuccess());
      }
    }, failure: (NetworkExceptions error) {
      emit(BloodSugarScheduleTemplateFailure(
          NetworkExceptions.getErrorMessage(error)));
    });
    emit(const BloodSugarScheduleTemplateInitial());
  }

  BloodSugarTemplateResponseDataSchedules? getDayInWeek(int index) {
    final int? dataIndex = templateDetail.schedules?.indexWhere(
      (templeteDetail) => templeteDetail?.day == index,
    );
    if (dataIndex != null && dataIndex == -1) {
      return null;
    }
    return templateDetail.schedules?[dataIndex!];
  }

  Future<void> onSubmitSchedule() async {
    final ScheduleGlucoseModel? scheduleGlucoseModel =
        templateDetail.scheduleGlucoseModel;
    if (scheduleGlucoseModel == null) return;
    try {
      await showLoading();
      await UserClient().updateScheduleGlucose(scheduleGlucoseModel);
      emit(const BloodSugarScheduleSaveSuccess());
    } catch (e) {
      emit(BloodSugarScheduleTemplateFailure('$e'));
    }
  }
}
