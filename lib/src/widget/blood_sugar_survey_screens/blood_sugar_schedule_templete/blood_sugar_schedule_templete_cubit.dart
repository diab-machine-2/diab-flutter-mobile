import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/modal/user/schedule_glucose_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/blood_sugar_template_detail_response.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'blood_sugar_schedule_templete.dart';

class BloodSugarScheduleTempleteCubit
    extends Cubit<BloodSugarScheduleTempleteState> {
  BloodSugarScheduleTempleteCubit(this.repository)
      : super(const BloodSugarScheduleTempleteInitial());

  final AppRepository repository;
  List<BloodSugarTemplateDetailResponse> templeteDetailList = [];

  void refreshState() {
    emit(const BloodSugarScheduleTempleteLoading());
    emit(const BloodSugarScheduleTempleteInitial());
  }

  Future<void> getTempleteDetail() async {
    //TODO: Tuyen call Api to get BloodSugarTemplateDetail
    //Fake Data
    emit(const BloodSugarScheduleTempleteLoading());
    await Future.delayed(const Duration(seconds: 1));
    final List<BloodSugarTemplateDetailResponse> response = [
      BloodSugarTemplateDetailResponse.fromJson({
        "id": "09dbfa4f-c23c-4a5a-88ab-3f4b783b6893",
        "name": "Mẫu K",
        "category": 5,
        "template": 6,
        "isWeekTemplate": true,
        "day": 6,
        "isBeforeBreakfast": true,
        "isAfterBreakfast": true,
        "isBeforeLunch": true,
        "isAfterLunch": true,
        "isBeforeDinner": true,
        "isAfterDinner": true,
        "isBeforeSleeping": true
      }),
      BloodSugarTemplateDetailResponse.fromJson({
        "id": "2a8af514-b49b-406d-9ed4-602d9dd762da",
        "name": "Mẫu K",
        "category": 5,
        "template": 6,
        "isWeekTemplate": true,
        "day": 2,
        "isBeforeBreakfast": false,
        "isAfterBreakfast": true,
        "isBeforeLunch": false,
        "isAfterLunch": true,
        "isBeforeDinner": false,
        "isAfterDinner": false,
        "isBeforeSleeping": true,
      }),
      BloodSugarTemplateDetailResponse.fromJson({
        "id": "2bf19a4e-f181-4622-8279-c2b6feb6193f",
        "name": "Mẫu K",
        "category": 5,
        "template": 6,
        "isWeekTemplate": true,
        "day": 7,
        "isBeforeBreakfast": false,
        "isAfterBreakfast": false,
        "isBeforeLunch": true,
        "isAfterLunch": false,
        "isBeforeDinner": false,
        "isAfterDinner": true,
        "isBeforeSleeping": true,
      }),
      BloodSugarTemplateDetailResponse.fromJson({
        "id": "40c34d80-3adb-4569-bc67-a6744e265b2b",
        "name": "Mẫu K",
        "category": 5,
        "template": 6,
        "isWeekTemplate": true,
        "day": 1,
        "isBeforeBreakfast": false,
        "isAfterBreakfast": false,
        "isBeforeLunch": false,
        "isAfterLunch": false,
        "isBeforeDinner": false,
        "isAfterDinner": false,
        "isBeforeSleeping": false
      }),
      BloodSugarTemplateDetailResponse.fromJson({
        "id": "4990b7b9-2afd-43cd-8315-03f0b43ac20a",
        "name": "Mẫu K",
        "category": 5,
        "template": 6,
        "isWeekTemplate": true,
        "day": 5,
        "isBeforeBreakfast": true,
        "isAfterBreakfast": false,
        "isBeforeLunch": true,
        "isAfterLunch": false,
        "isBeforeDinner": true,
        "isAfterDinner": false,
        "isBeforeSleeping": true
      }),
      BloodSugarTemplateDetailResponse.fromJson({
        "id": "8d8e97f6-f9fc-4f5d-b1fe-b5dcdc1e32f8",
        "name": "Mẫu K",
        "category": 5,
        "template": 6,
        "isWeekTemplate": true,
        "day": 3,
        "isBeforeBreakfast": false,
        "isAfterBreakfast": false,
        "isBeforeLunch": false,
        "isAfterLunch": false,
        "isBeforeDinner": false,
        "isAfterDinner": false,
        "isBeforeSleeping": false
      }),
      BloodSugarTemplateDetailResponse.fromJson({
        "id": "a319dc8d-8e40-45b1-974a-df3d1d519e34",
        "name": "Mẫu K",
        "category": 5,
        "template": 6,
        "isWeekTemplate": true,
        "day": 4,
        "isBeforeBreakfast": true,
        "isAfterBreakfast": false,
        "isBeforeLunch": false,
        "isAfterLunch": false,
        "isBeforeDinner": false,
        "isAfterDinner": false,
        "isBeforeSleeping": false
      }),
    ];
    templeteDetailList = response;
    refreshState();
  }

  bool get isWeekTemplate => templeteDetailList.length >= 7;

  BloodSugarTemplateDetailResponse? getDayInWeek(int index) {
    final int dataIndex = templeteDetailList.indexWhere(
      (templeteDetail) => templeteDetail.day == index + 1,
    );
    if (dataIndex == -1) {
      return null;
    }
    return templeteDetailList[dataIndex];
  }

  Future<void> onSubmitSchedule() async {
    final ScheduleGlucoseModel? scheduleGlucoseModel = getScheduleGlucose();
    if (scheduleGlucoseModel == null) 
      return;
    try {
      emit(const BloodSugarScheduleTempleteLoading());
      await UserClient().updateScheduleGlucose(scheduleGlucoseModel);
      emit(const BloodSugarScheduleSaveSuccess());
    } catch (e) {
      emit(BloodSugarScheduleTempleteFailure('$e'));
    }
  }

  ScheduleGlucoseModel? getScheduleGlucose() {
    if (isWeekTemplate) {
      return ScheduleGlucoseModel(
        monday: getDayScheduleFromTempleteDetail(dayIndex: 1),
        tuesday: getDayScheduleFromTempleteDetail(dayIndex: 2),
        wednesday: getDayScheduleFromTempleteDetail(dayIndex: 3),
        thursday: getDayScheduleFromTempleteDetail(dayIndex: 4),
        friday: getDayScheduleFromTempleteDetail(dayIndex: 5),
        saturday: getDayScheduleFromTempleteDetail(dayIndex: 6),
        sunday: getDayScheduleFromTempleteDetail(dayIndex: 7),
      );
    }
    if (templeteDetailList.length == 1) {
      final ScheduleModel scheduleModel = getDayScheduleFromTempleteDetail();
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

  ScheduleModel getDayScheduleFromTempleteDetail({
    int? dayIndex,
  }) {
    final int dataIndex = dayIndex == null
        ? 0
        : templeteDetailList.indexWhere(
            (element) => element.day == dayIndex,
          );
    BloodSugarTemplateDetailResponse? templeteDetail;
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
