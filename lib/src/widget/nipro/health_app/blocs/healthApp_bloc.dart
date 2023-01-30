import 'dart:async';
import 'package:collection/collection.dart';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz_unsafe.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:health/health.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/health_setting.dart';
import 'package:medical/src/modal/blood_pressure/bloodPressure_Input_data_model.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure.dart';
import 'package:medical/src/modal/bmi/weight_trend.dart';
import 'package:medical/src/modal/glucose/Glucose_Input_data_model.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/repo/blood_pressure/bloodPressure_client.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/repo/home/home_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/repo/weight/weight_client.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/widget/Exercrises/steps/data/models/getStepList_model.dart';
import 'package:medical/src/widget/Exercrises/steps/data/models/requestSyncStep_model.dart';
import 'package:medical/src/widget/Exercrises/steps/data/step_repository.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'package:meta/meta.dart';
part 'healthApp_bloc_state.dart';
part 'healthApp_bloc_event.dart';

class HealthAppBloc extends Bloc<HealthAppEvent, HealthAppState> {
  HealthAppBloc() : super(HealthAppState());
  HealthFactory health = HealthFactory();
  final client = WeightClient();
  final stepRepository = StepRepository();
  final glucoseClient = GlucoseClient();
  double mmollToMgdlFactor = 18.018;

  @override
  Stream<HealthAppState> mapEventToState(HealthAppEvent event) async* {
    if (event is SyncData) {
      yield* _syncData(event);
    }
  }

  double roundDouble(var value, {int places = 1}) {
    double val = double.parse(value.toString());
    num mod = pow(10.0, 2);
    return ((val * mod).round().toDouble() / mod);
  }

  Stream<HealthAppState> _syncData(SyncData event) async* {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    final List<HealthDataType> _types = HealthSetting.instance.types;

    int timeFrame = now.millisecondsSinceEpoch ~/ 1000;
    UserModel userInfo = AppSettings.userInfo!;
    bool callToUpdate = false;

    // Tâm thu - Tâm trương - Nhịp tim
    // Step 1: Kiểm tra Permission BLOOD_PRESSURE_DIASTOLIC & BLOOD_PRESSURE_SYSTOLIC\
    // ******* Nếu không có quyền => Break;
    // ******* Nếu có quyền => xử lý tiếp bước 3
    double? systolic;
    double? diastolic;
    List<HealthDataPoint> bloodPressureData =
        await health.getHealthDataFromTypes(midnight, now, [
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    ]);
    final timeFrames =
        await glucoseClient.fetchFlucoseTimeFrame(time: timeFrame);
    TimeFrameModel? selectedTimeFrame =
        timeFrames.length == 0 ? null : timeFrames.first;
    bloodPressureData.forEach((element) {
      if (element.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC &&
          systolic == null) {
        systolic = roundDouble(element.value);
      }
      if (element.type == HealthDataType.BLOOD_PRESSURE_DIASTOLIC &&
          diastolic == null) {
        diastolic = roundDouble(element.value);
      }
    });
    // Step 2: Lấy dữ liệu gần nhất trong ngày
    if (systolic != null && diastolic != null) {
      BloodPressureDataModel model = await BloodPressureClient()
          .fetchBloodPressureInput(timeFrame.toString(), '1', null, 1,
              size: '1');
      if (model.inputs.isNotEmpty) {
        BloodPressureModel? latestData = model.inputs.first;
        // Step 3: Kiểm tra dữ liệu cũ và dữ liệu từ Health App
        if (latestData.diastolic != diastolic ||
            latestData.systolic != systolic) {
          final result = await BloodPressureClient().postBloodPressureInput(
              systolic.toString(),
              diastolic.toString(),
              "0.0",
              timeFrame,
              selectedTimeFrame?.id,
              "",
              "Sync data from health app", []);
          if (result) {
            callToUpdate = true;
          }
        }
      }
    }
    // ******* Nếu trùng khớp nhau => thì ko cần đồng bộ => Break
    // ******* Nếu không trùng khớp nhau => xử lý tiếp bước 4
    // Step 4: Kiểm tra dữ liệu cũ và dữ liệu từ Health App
    if (callToUpdate) {
      Observable.instance.notifyObservers([], notifyName: "refresh_home");
    }
    return;
    _types.forEach((element) async {
      switch (element) {
        case HealthDataType.STEPS:
          // Check Step Data
          StepListModel stepData = await stepRepository.getStepList(1);
          DateTime? lastDateSync = DateTime(now.year, now.month, now.day - 1);
          if (stepData.items.isNotEmpty) {
            lastDateSync =
                DateUtil.parseTimespanToDateTime(stepData.items.last.dateFrom!);
            print('lastDateSync: $lastDateSync');
            lastDateSync = DateTime(
                lastDateSync.year, lastDateSync.month, lastDateSync.day);
          }
          List<HealthDataPoint> steps =
              await health.getHealthDataFromTypes(lastDateSync, now, [element]);
          List<RequestSyncStepModel> stepCollected = [];
          steps.forEach((element) {
            int dateFrom = DateTime(element.dateFrom.year,
                        element.dateFrom.month, element.dateFrom.day)
                    .millisecondsSinceEpoch ~/
                1000;

            int index =
                stepCollected.indexWhere((item) => item.dateFrom == dateFrom);
            int newValue = roundDouble(element.value).toInt();
            int newTotalMinute =
                element.dateTo.difference(element.dateFrom).inMinutes;

            if (index.isNegative) {
              RequestSyncStepModel requestSyncStepModel = RequestSyncStepModel(
                dateTo: dateFrom,
                dateFrom: dateFrom,
                value: newValue,
                totalMinute: newTotalMinute,
                platform: steps.first.platform == PlatformType.IOS
                    ? 'ios'
                    : 'android',
              );
              stepCollected.add(requestSyncStepModel);
            } else {
              newValue = stepCollected[index].value + newValue;
              newTotalMinute =
                  stepCollected[index].totalMinute + newTotalMinute;

              RequestSyncStepModel requestSyncStepModel =
                  stepCollected[index].copyWith(
                value: newValue,
                totalMinute: newTotalMinute,
              );
              stepCollected[index] = requestSyncStepModel;
            }
          });

          bool result = await stepRepository.syncStepData(stepCollected);
          break;
        // case HealthDataType.HEIGHT:
        //   List<HealthDataPoint> heightValue =
        //       await health.getHealthDataFromTypes(midnight, now, [element]);
        //   if (heightValue.length != 0) {
        //     double valueCentimet = roundDouble(heightValue.first.value) * 100;
        //     if (valueCentimet != userInfo.height) {
        //       await UserClient().updateUserInfo(
        //         AppSettings.userInfo!.id,
        //         userInfo.copyWith(height: valueCentimet),
        //       );
        //     }
        //   }
        //   break;
        // case HealthDataType.WEIGHT:
        //   var weightList =
        //       await health.getHealthDataFromTypes(midnight, now, [element]);
        //   if (weightList.length != 0) {
        //     double valueKilogram = roundDouble(weightList.first.value);
        //     if (valueKilogram != userInfo.weight) {
        //       final timeFrames =
        //           await glucoseClient.fetchFlucoseTimeFrame(time: timeFrame);
        //       TimeFrameModel? selectedTimeFrame =
        //           timeFrames.length == 0 ? null : timeFrames.first;

        //       final result = await WeightClient().postWeightInput(
        //         timeFrame,
        //         [],
        //         '$valueKilogram',
        //         null,
        //         '$valueKilogram',
        //         '',
        //         selectedTimeFrame!.id,
        //       );
        //       if (result == true) {
        //         await UserClient().updateUserInfo(
        //           AppSettings.userInfo!.id,
        //           userInfo.copyWith(weight: valueKilogram),
        //         );
        //       }
        //     }
        //   }
        //   break;

        // case HealthDataType.BLOOD_GLUCOSE:
        //   var bloodGlucoseList =
        //       await health.getHealthDataFromTypes(midnight, now, [element]);
        //   if (bloodGlucoseList.length != 0) {
        //     double bloodGlucose = roundDouble(bloodGlucoseList.first.value);
        //     bool isMilligramPerDeciliter =
        //         AppSettings.userInfo!.glucoseUnit == 1;
        //     final glucose = roundAsFixed(isMilligramPerDeciliter
        //         ? bloodGlucose
        //         : bloodGlucose / mmollToMgdlFactor);

        //     InputGlucoseDataModel model = await glucoseClient
        //         .fetchInput('$timeFrame', '1', 1, null, null, size: '1');
        //     if (model != null &&
        //         model.inputs.length > 0 &&
        //         model.inputs.first.glucose != glucose) {
        //       final timeFrames =
        //           await glucoseClient.fetchFlucoseTimeFrame(time: timeFrame);
        //       TimeFrameModel? selectedTimeFrame =
        //           timeFrames.length == 0 ? null : timeFrames.first;
        //       final result = await GlucoseClient().postIndexGlucose(
        //           selectedTimeFrame!.id,
        //           timeFrame,
        //           glucose.toString(),
        //           null,
        //           '',
        //           false, []);
        //     }
        //   }
        //   break;
        // case HealthDataType.HEART_RATE:
        //   var heartRate =
        //       await health.getHealthDataFromTypes(midnight, now, [element]);
        //   // print('heartRate:  $heartRate');
        //   break;
        // case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
        //   var bloodGlucose =
        //       await health.getHealthDataFromTypes(midnight, now, [element]);
        //   // print('bloodGlucose:  $bloodGlucose');
        //   break;
        // case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
        //   break;
      }
    });

    // await UserClient().fetchUser();

    // List<HealthDataPoint>? requested =
    //     await health.getHealthDataFromTypes(midnight, now, _types);

    yield state.copyWith(
      types: _types,
    );
  }
}
