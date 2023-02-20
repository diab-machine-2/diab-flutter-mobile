import 'dart:async';
import 'package:collection/collection.dart';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:health/health.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/health_setting.dart';
import 'package:medical/src/modal/blood_pressure/bloodPressure_Input_data_model.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure.dart';
import 'package:medical/src/modal/glucose/Glucose_Input_data_model.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/repo/blood_pressure/bloodPressure_client.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/repo/weight/weight_client.dart';
import 'package:medical/src/utils/app_log.dart';
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
  Map<String, bool> responseSyncData = {};
  Map<String, bool> requestSyncData = {};
  late List<TimeFrameModel> timeFrames;
  late TimeFrameModel? selectedTimeFrame;

  @override
  Stream<HealthAppState> mapEventToState(HealthAppEvent event) async* {
    if (event is SubmitSyncData) {
      if (event.isSyncing) {
        yield* _syncData(event);
      }
    }
  }

  double roundDouble(var value, {int places = 1}) {
    double val = double.parse(value.toString());
    num mod = pow(10.0, 2);
    return ((val * mod).round().toDouble() / mod);
  }

  // Tâm thu - Tâm trương - Nhịp tim
  syncSYSTOLICAndDIASTOLIC({
    required DateTime midnight,
    required DateTime now,
    required int timeFrame,
  }) async {
    bool result = false;
    requestSyncData['syncSYSTOLICAndDIASTOLIC'] = true;
    // Tâm thu - Tâm trương - Nhịp tim
    // Step 1: Kiểm tra Permission BLOOD_PRESSURE_DIASTOLIC & BLOOD_PRESSURE_SYSTOLIC\
    // ******* Nếu không có quyền => Break;
    // ******* Nếu có quyền => xử lý tiếp bước 3
    double? systolic;
    double? diastolic;
    double? heartRate;
    List<HealthDataPoint> bloodPressureData =
        await health.getHealthDataFromTypes(midnight, now, [
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      HealthDataType.HEART_RATE,
    ]);
    // final timeFrames =
    //     await glucoseClient.fetchFlucoseTimeFrame(time: timeFrame);
    // TimeFrameModel? selectedTimeFrame =
    //     timeFrames.length == 0 ? null : timeFrames.first;
    bloodPressureData.forEach((element) {
      if (element.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC &&
          systolic == null) {
        systolic = roundDouble(element.value);
      }
      if (element.type == HealthDataType.BLOOD_PRESSURE_DIASTOLIC &&
          diastolic == null) {
        diastolic = roundDouble(element.value);
      }
      if (element.type == HealthDataType.HEART_RATE && heartRate == null) {
        heartRate = roundDouble(element.value);
      }
    });
    // Step 2: Lấy dữ liệu gần nhất trong ngày
    if (systolic != null && diastolic != null) {
      BloodPressureDataModel model = await BloodPressureClient()
          .fetchBloodPressureInput(timeFrame.toString(), '1', null, 1,
              size: '1');

      BloodPressureModel? latestData;
      if (model.inputs.isNotEmpty) {
        latestData = model.inputs.first;
      }

      // Step 3: Kiểm tra dữ liệu cũ và dữ liệu từ Health App
      //  (latestData != null && (latestData.diastolic != diastolic ||  latestData.systolic != systolic)
      if (latestData == null ||
          ((latestData.diastolic != diastolic ||
              latestData.systolic != systolic))) {
        result = await BloodPressureClient().postBloodPressureInput(
            systolic.toString(),
            diastolic.toString(),
            heartRate != null ? heartRate.toString() : "0.0",
            timeFrame,
            selectedTimeFrame?.id,
            "",
            "Đồng bộ dữ liệu từ Health App", []);
        Console.log("syncSYSTOLICAndDIASTOLIC result", result);
      }
    }
    responseSyncData['syncSYSTOLICAndDIASTOLIC'] = result;
    _requestSyncData();
    // ******* Nếu trùng khớp nhau => thì ko cần đồng bộ => Break
    // ******* Nếu không trùng khớp nhau => xử lý tiếp bước 4
    // Step 4: Kiểm tra dữ liệu cũ và dữ liệu từ Health App
  }

  syncSTEP({
    required DateTime midnight,
    required DateTime now,
  }) async {
    bool result = true;
    requestSyncData['syncSTEP'] = true;
    StepListModel stepData = await stepRepository.getStepList(1);
    DateTime? lastDateSync = DateTime(now.year, now.month, now.day - 1);
    if (stepData.items.isNotEmpty) {
      lastDateSync =
          DateUtil.parseTimespanToDateTime(stepData.items.last.dateFrom!);
      print('lastDateSync: $lastDateSync');
      lastDateSync =
          DateTime(lastDateSync.year, lastDateSync.month, lastDateSync.day);
    }
    List<HealthDataPoint> steps = await health
        .getHealthDataFromTypes(lastDateSync, now, [HealthDataType.STEPS]);
    List<RequestSyncStepModel> stepCollected = [];
    steps.forEach((element) {
      print("element: ${element.dateFrom}");
      int dateFrom = DateTime(element.dateFrom.year, element.dateFrom.month,
                  element.dateFrom.day)
              .millisecondsSinceEpoch ~/
          1000;

      int index = stepCollected.indexWhere((item) => item.dateFrom == dateFrom);
      int newValue = roundDouble(element.value).toInt();
      int newTotalMinute =
          element.dateTo.difference(element.dateFrom).inMinutes;

      if (index.isNegative) {
        RequestSyncStepModel requestSyncStepModel = RequestSyncStepModel(
          dateTo: dateFrom,
          dateFrom: dateFrom,
          value: newValue,
          totalMinute: newTotalMinute,
          platform:
              steps.first.platform == PlatformType.IOS ? 'ios' : 'android',
        );
        stepCollected.add(requestSyncStepModel);
      } else {
        newValue = stepCollected[index].value + newValue;
        newTotalMinute = stepCollected[index].totalMinute + newTotalMinute;

        RequestSyncStepModel requestSyncStepModel =
            stepCollected[index].copyWith(
          value: newValue,
          totalMinute: newTotalMinute,
        );
        stepCollected[index] = requestSyncStepModel;
      }
    });

    List<int> indexList = [];
    int index = 0;
    stepCollected.forEach((item) {
      final RequestSyncStepModel? valueExisted = stepCollected.firstWhereOrNull(
          (element) =>
              element.dateFrom == item.dateFrom && element.value == item.value);
      if (valueExisted != null) {
        indexList.add(index);
      }
      index++;
    });
    indexList.sort((a, b) => b.compareTo(a));

    indexList.forEach((index) {
      stepCollected.removeAt(index);
    });

    if (stepCollected.isNotEmpty) {
      result = await stepRepository.syncStepData(stepCollected);
    }
    responseSyncData['syncSTEP'] = result;
    _requestSyncData();
  }

  syncWeight({
    required DateTime midnight,
    required DateTime now,
    required int timeFrame,
  }) async {
    bool result = true;
    requestSyncData['syncWeight'] = true;
    UserModel userInfo = AppSettings.userInfo!;
    var weightList = await health.getHealthDataFromTypes(
        midnight, now, [HealthDataType.WEIGHT, HealthDataType.HEIGHT]);
    double? weight;
    double? height;
    if (weightList.length != 0) {
      weightList.forEach((element) {
        if (element.type == HealthDataType.WEIGHT) {
          weight = roundDouble(weightList.first.value);
        }
        if (element.type == HealthDataType.HEIGHT) {
          height = roundDouble(weightList.first.value);
        }
      });
    }

    if ((weight != null && weight != userInfo.weight) ||
        (height != null && height != userInfo.height)) {
      result = await WeightClient().postWeightInput(
          (now.millisecondsSinceEpoch ~/ 1000).toInt(),
          [],
          weight != null ? weight.toString() : userInfo.weight.toString(),
          null,
          height != null ? height.toString() : userInfo.height.toString(),
          'Đồng bộ dữ liệu từ Health App',
          selectedTimeFrame!.id);
      if (result) {
        await UserClient().updateUserInfo(
          AppSettings.userInfo!.id,
          userInfo.copyWith(
            weight: weight,
            height: height,
          ),
        );
      }
    }

    responseSyncData['syncWeight'] = result;
    _requestSyncData();
  }

  syncBlodGlucose({
    required DateTime midnight,
    required DateTime now,
    required int timeFrame,
  }) async {
    bool result = true;
    requestSyncData['syncBlodGlucose'] = true;
    var bloodGlucoseList = await health
        .getHealthDataFromTypes(midnight, now, [HealthDataType.BLOOD_GLUCOSE]);
    if (bloodGlucoseList.length != 0) {
      double bloodGlucose = roundDouble(bloodGlucoseList.first.value);
      bool isMilligramPerDeciliter = AppSettings.userInfo!.glucoseUnit == 1;
      final glucose = roundAsFixed(isMilligramPerDeciliter
          ? bloodGlucose
          : bloodGlucose / mmollToMgdlFactor);

      InputGlucoseDataModel model = await glucoseClient
          .fetchInput('$timeFrame', '1', 1, null, null, size: '1');
      if ((model.inputs.isEmpty) ||
          (model.inputs.length > 0 && model.inputs.first.glucose != glucose)) {
        // final timeFrames =
        //     await glucoseClient.fetchFlucoseTimeFrame(time: timeFrame);

        result = await GlucoseClient().postIndexGlucose(selectedTimeFrame!.id,
            timeFrame, glucose.toString(), null, '', false, []);
      }
    }
    responseSyncData['syncBlodGlucose'] = result;
    _requestSyncData();
  }

  Future<void> _requestSyncData() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    int timeFrame = now.millisecondsSinceEpoch ~/ 1000;
    Console.log(
        "responseSyncData", responseSyncData.length == requestSyncData.length);

    if (responseSyncData.length == requestSyncData.length) {
      bool isDataUpdated = responseSyncData.values
          .firstWhere((element) => element == true, orElse: () => false);
      bool isNotCompleteRequest = requestSyncData.values
          .firstWhere((element) => element == false, orElse: () => false);
      Console.log("isDataUpdated && !isNotCompleteRequest",
          isDataUpdated && !isNotCompleteRequest);
      if (isDataUpdated && !isNotCompleteRequest) {
        Observable.instance.notifyObservers([], notifyName: "refresh_home");
      }
    } else {
      requestSyncData.forEach((key, value) async {
        switch (key) {
          case 'syncSYSTOLICAndDIASTOLIC':
            if (value == false) {
              await syncSYSTOLICAndDIASTOLIC(
                  midnight: midnight, now: now, timeFrame: timeFrame);
            }
            break;
          case 'syncSTEP':
            if (value == false) {
              await syncSTEP(midnight: midnight, now: now);
            }
            break;
          // case 'syncHeight':
          //   if (value == false) {
          //     await syncHeight(midnight: midnight, now: now);
          //   }
          //   break;
          case 'syncWeight':
            if (value == false) {
              await syncWeight(
                  midnight: midnight, now: now, timeFrame: timeFrame);
            }
            break;
          case 'syncBlodGlucose':
            if (value == false) {
              await syncBlodGlucose(
                  midnight: midnight, now: now, timeFrame: timeFrame);
            }
            break;
        }
      });
    }
  }

  Stream<HealthAppState> _syncData(SubmitSyncData event) async* {
    yield state.copyWith(blocStatus: BlocStatus.loading);
    final List<HealthDataType> _types = HealthSetting.instance.types;
    final now = DateTime.now();
    int timeFrame = now.millisecondsSinceEpoch ~/ 1000;
    timeFrames = await glucoseClient.fetchFlucoseTimeFrame(time: timeFrame);
    selectedTimeFrame = timeFrames.length == 0 ? null : timeFrames.first;

    requestSyncData = {
      'syncSYSTOLICAndDIASTOLIC': false,
      'syncSTEP': false,
      // 'syncHeight': false,
      'syncWeight': false,
      'syncBlodGlucose': false,
    };

    await _requestSyncData();

    yield state.copyWith(
      types: _types,
    );
  }
}
