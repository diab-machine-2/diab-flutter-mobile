import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/modal/user/schedule_glucose_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/blood_sugar_template_detail_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'blood_sugar_schedule_template.dart';

class BloodSugarScheduleTemplateCubit
    extends Cubit<BloodSugarScheduleTemplateState> {
  BloodSugarScheduleTemplateCubit(this.repository)
      : super(const BloodSugarScheduleTemplateInitial());

  final AppRepository repository;
  List<BloodSugarTemplateDetailResponseData?> templeteDetailList = [];

  void refreshState() {
    emit(const BloodSugarScheduleTemplateLoading());
    emit(const BloodSugarScheduleTemplateInitial());
  }

  Future<void> getTemplateDetail(String? id) async {
    final ApiResult<BloodSugarTemplateDetailResponse> apiResult =
        await repository.getListTemplateDetail(id ?? '');
    apiResult.when(success: (BloodSugarTemplateDetailResponse response) {
      if (response.data != null) {
        final List<BloodSugarTemplateDetailResponseData?> data = response.data!;
        templeteDetailList = data;
        refreshState();
      }
    }, failure: (NetworkExceptions error) {
      emit(BloodSugarScheduleTemplateFailure(
          NetworkExceptions.getErrorMessage(error)));
    });
  }

  bool get isWeekTemplate => templeteDetailList.length >= 7;

  BloodSugarTemplateDetailResponseData? getDayInWeek(int index) {
    final int dataIndex = templeteDetailList.indexWhere(
      (templeteDetail) => templeteDetail?.day == index + 1,
    );
    if (dataIndex == -1) {
      return null;
    }
    return templeteDetailList[dataIndex];
  }

  Future<void> onSubmitSchedule() async {
    final ScheduleGlucoseModel? scheduleGlucoseModel = getScheduleGlucose();
    if (scheduleGlucoseModel == null) return;
    try {
      emit(const BloodSugarScheduleTemplateLoading());
      await UserClient().updateScheduleGlucose(scheduleGlucoseModel);
      emit(const BloodSugarScheduleSaveSuccess());
    } catch (e) {
      emit(BloodSugarScheduleTemplateFailure('$e'));
    }
  }

  ScheduleGlucoseModel? getScheduleGlucose() {
    if (isWeekTemplate) {
      return ScheduleGlucoseModel(
        monday: getDayScheduleFromTemplateDetail(dayIndex: 1),
        tuesday: getDayScheduleFromTemplateDetail(dayIndex: 2),
        wednesday: getDayScheduleFromTemplateDetail(dayIndex: 3),
        thursday: getDayScheduleFromTemplateDetail(dayIndex: 4),
        friday: getDayScheduleFromTemplateDetail(dayIndex: 5),
        saturday: getDayScheduleFromTemplateDetail(dayIndex: 6),
        sunday: getDayScheduleFromTemplateDetail(dayIndex: 7),
      );
    }
    if (templeteDetailList.length == 1) {
      final ScheduleModel scheduleModel = getDayScheduleFromTemplateDetail();
      return ScheduleGlucoseModel(
        monday: scheduleModel,
        tuesday: scheduleModel,
        wednesday: scheduleModel,
        thursday: scheduleModel,
        friday: scheduleModel,
        saturday: scheduleModel,
        sunday: scheduleModel,
      );
    }
    return null;
  }

  ScheduleModel getDayScheduleFromTemplateDetail({
    int? dayIndex,
  }) {
    final int dataIndex = dayIndex == null
        ? 0
        : templeteDetailList.indexWhere(
            (element) => element?.day == dayIndex,
          );
    BloodSugarTemplateDetailResponseData? templeteDetail;
    if (dataIndex != -1) {
      templeteDetail = templeteDetailList[dataIndex];
    }
    return ScheduleModel(
      isBeforeBreakfast: templeteDetail?.isBeforeBreakfast,
      isAfterBreakfast: templeteDetail?.isAfterBreakfast,
      isBeforeLunch: templeteDetail?.isBeforeLunch,
      isAfterLunch: templeteDetail?.isAfterLunch,
      isBeforeDinner: templeteDetail?.isBeforeDinner,
      isAfterDinner: templeteDetail?.isAfterDinner,
      isBeforeSleeping: templeteDetail?.isBeforeSleeping,
    );
  }
}
