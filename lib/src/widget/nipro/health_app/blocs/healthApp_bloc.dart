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
import 'package:medical/src/utils/app_storages.dart';
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
  // late List<TimeFrameModel> timeFrames;
  // late TimeFrameModel? selectedTimeFrame;

  @override
  Stream<HealthAppState> mapEventToState(HealthAppEvent event) async* {
    if (event is SubmitSyncData) {
      if (event.isSyncing) {
        yield* _syncData(event);
      }
    }
    if (event is SyncDataSuccess) {
      yield* syncDataSuccess(event);
    }
  }

  double roundDouble(var value, {int places = 1}) {
    double val = double.parse(value.toString());
    num mod = pow(10.0, 2);
    return ((val * mod).round().toDouble() / mod);
  }

  // Tâm thu - Tâm trương - Nhịp tim
  syncSystolicAndDiastoluc() async {
    final dateTo = DateTime.now();
    late DateTime dateFrom;
    bool isFirstTimeSyncHealth = AppSettings.isFirstTimeSyncHealth;
    if (isFirstTimeSyncHealth) {
      dateFrom = DateTime(dateTo.year - 1, dateTo.month, dateTo.day);
    } else {
      dateFrom = DateTime(dateTo.year, dateTo.month, dateTo.day - 7);
    }
    DateTime? dateFromDataSync;
    String? timeFrameId;
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
        await health.getHealthDataFromTypes(dateFrom, dateTo, [
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
        dateFromDataSync = element.dateFrom;
      }
      if (element.type == HealthDataType.BLOOD_PRESSURE_DIASTOLIC &&
          diastolic == null) {
        diastolic = roundDouble(element.value);
      }
      if (element.type == HealthDataType.HEART_RATE && heartRate == null) {
        heartRate = roundDouble(element.value);
      }
    });

    if (dateFromDataSync != null) {
      List<TimeFrameModel> timeFrames =
          await glucoseClient.fetchFlucoseTimeFrame(
              time: dateFromDataSync!.millisecondsSinceEpoch ~/ 1000);

      if (timeFrames.isNotEmpty) {
        timeFrameId = timeFrames.first.id;
      }
    }

    // Step 2: Lấy dữ liệu gần nhất trong ngày
    if (timeFrameId != null && systolic != null && diastolic != null) {
      BloodPressureDataModel model = await BloodPressureClient()
          .fetchBloodPressureInput(
              "${dateFromDataSync!.millisecondsSinceEpoch ~/ 1000}",
              '1',
              null,
              1,
              size: '1');

      BloodPressureModel? latestData;
      if (model.inputs.isNotEmpty) {
        latestData = model.inputs.first;
      }

      // Step 3: Kiểm tra dữ liệu cũ và dữ liệu từ Health App
      if ((latestData == null ||
          ((latestData.diastolic != diastolic ||
              latestData.systolic != systolic)))) {
        result = await BloodPressureClient().postBloodPressureInput(
            systolic.toString(),
            diastolic.toString(),
            heartRate != null ? heartRate.toString() : "0.0",
            dateFromDataSync!.millisecondsSinceEpoch ~/ 1000,
            timeFrameId,
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

  syncSTEP() async {
    DateTime dateTo = DateTime.now();
    DateTime dateFrom = DateTime(dateTo.year, dateTo.month, dateTo.day - 6);
    bool result = false;
    requestSyncData['syncSTEP'] = true;
    StepListModel stepData = await stepRepository.getStepList(1);

    List<HealthDataPoint> steps = await health
        .getHealthDataFromTypes(dateFrom, dateTo, [HealthDataType.STEPS]);
    List<RequestSyncStepModel> stepCollected = [];

    steps.forEach((element) {
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

    // CHECK DATA IS UPDATED
    int index = 0;
    List<int> indexList = [];
    if (stepData.items.isNotEmpty) {
      stepCollected.forEach((healthItem) {
        stepData.items.forEach((stepItem) {
          DateTime timeOfHealth =
              DateUtil.parseTimespanToDateTime(healthItem.dateFrom);
          DateTime timeOfData =
              DateUtil.parseTimespanToDateTime(stepItem.dateFrom!);
          int diffInDays = DateUtil.diffInDays(timeOfHealth, timeOfData);
          if (diffInDays == 0 && healthItem.value == stepItem.value) {
            indexList.add(index);
          }
        });
        index++;
      });
    }
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

  syncWeight() async {
    bool result = false;
    String? timeFrameId;
    late DateTime dateFrom;
    DateTime? dateFromDataSync;
    DateTime dateTo = DateTime.now();
    bool isFirstTimeSyncHealth = AppSettings.isFirstTimeSyncHealth;

    if (isFirstTimeSyncHealth) {
      dateFrom = DateTime(dateTo.year - 1, dateTo.month, dateTo.day);
    } else {
      dateFrom = DateTime(dateTo.year, dateTo.month - 1, dateTo.day);
    }

    requestSyncData['syncWeight'] = true;
    UserModel userInfo = AppSettings.userInfo!;
    var weightList = await health.getHealthDataFromTypes(
        dateFrom, dateTo, [HealthDataType.WEIGHT, HealthDataType.HEIGHT]);
    double? weight;
    double? height;
    if (weightList.length != 0) {
      weightList.forEach((element) {
        if (element.type == HealthDataType.WEIGHT && weight == null) {
          weight = roundDouble(element.value);
          dateFromDataSync = element.dateFrom;
        }
        if (element.type == HealthDataType.HEIGHT && height == null) {
          height = roundDouble(element.value) * 100;
          dateFromDataSync = element.dateFrom;
        }
      });
    }

    if (dateFromDataSync != null) {
      List<TimeFrameModel> timeFrames =
          await glucoseClient.fetchFlucoseTimeFrame(
              time: dateFromDataSync!.millisecondsSinceEpoch ~/ 1000);
      if (timeFrames.isNotEmpty) {
        timeFrameId = timeFrames.first.id;
      }

      if (timeFrameId != null &&
          ((weight != null && weight != userInfo.weight) ||
              (height != null && height != userInfo.height))) {
        result = await WeightClient().postWeightInput(
          (dateFromDataSync!.millisecondsSinceEpoch ~/ 1000).toInt(),
          [],
          weight != null ? weight.toString() : userInfo.weight.toString(),
          null,
          height != null ? height.toString() : userInfo.height.toString(),
          'Đồng bộ dữ liệu từ Health App',
          timeFrameId,
        );
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
    }

    responseSyncData['syncWeight'] = result;
    _requestSyncData();
  }

  syncBlodGlucose() async {
    bool result = false;
    DateTime? dateFromDataSync;
    DateTime dateTo = DateTime.now();
    requestSyncData['syncBlodGlucose'] = true;
    bool isFirstTimeSyncHealth = AppSettings.isFirstTimeSyncHealth;
    DateTime dateFrom = DateTime(dateTo.year - 1, dateTo.month, dateTo.day);

    if (isFirstTimeSyncHealth) {
      dateFrom = DateTime(dateTo.year - 1, dateTo.month, dateTo.day);
    } else {
      InputGlucoseDataModel model = await glucoseClient.fetchInput(
          '${dateTo.millisecondsSinceEpoch ~/ 1000}', '1', 1, null, null,
          size: '1');
      if (model.inputs.isNotEmpty) {
        dateFrom =
            DateUtil.parseTimespanToDateTime(model.inputs.first.createDate!);
      }
    }

    var bloodGlucoseList = await health.getHealthDataFromTypes(
        dateFrom, dateTo, [HealthDataType.BLOOD_GLUCOSE]);

    if (bloodGlucoseList.length != 0) {
      double bloodGlucose = roundDouble(bloodGlucoseList.first.value);
      dateFromDataSync = bloodGlucoseList.first.dateFrom;
      bool isMilligramPerDeciliter = AppSettings.userInfo!.glucoseUnit == 1;
      final glucose = roundAsFixed(isMilligramPerDeciliter
          ? bloodGlucose
          : bloodGlucose / mmollToMgdlFactor);

      if (dateFrom != dateFromDataSync) {
        final timeFrames = await glucoseClient.fetchFlucoseTimeFrame(
            time: dateFromDataSync.millisecondsSinceEpoch ~/ 1000);

        if (timeFrames.isNotEmpty) {
          result = await GlucoseClient().postIndexGlucose(
              timeFrames.first.id,
              dateFromDataSync.millisecondsSinceEpoch ~/ 1000,
              glucose.toString(),
              null,
              '',
              false, []);
        }
      }
    }
    responseSyncData['syncBlodGlucose'] = result;
    _requestSyncData();
  }

  Stream<HealthAppState> syncDataSuccess(SyncDataSuccess event) async* {
    yield state.copyWith(blocStatus: BlocStatus.success);
  }

  Future<void> _requestSyncData() async {
    print('Phương _requestSyncData');
    if (responseSyncData.length == requestSyncData.length) {
      Console.logJson("responseSyncData", responseSyncData);
      bool isDataUpdated = responseSyncData.values
          .firstWhere((element) => element == true, orElse: () => false);
      bool isNotCompleteRequest = requestSyncData.values
          .firstWhere((element) => element == false, orElse: () => false);

      Console.logJson("Có cần refresh Home không? ",
          isDataUpdated && !isNotCompleteRequest ? "Có" : "Không");
      if (isDataUpdated && !isNotCompleteRequest) {
        Observable.instance.notifyObservers([], notifyName: "refresh_home");
      }
      add(SyncDataSuccess());
    } else {
      requestSyncData.forEach((key, value) async {
        switch (key) {
          case 'syncSYSTOLICAndDIASTOLIC':
            if (value == false) {
              await syncSystolicAndDiastoluc();
            }
            break;
          case 'syncSTEP':
            if (value == false) {
              await syncSTEP();
            }
            break;
          case 'syncWeight':
            if (value == false) {
              await syncWeight();
            }
            break;
          case 'syncBlodGlucose':
            if (value == false) {
              await syncBlodGlucose();
            }
            break;
        }
      });
    }
  }

  Stream<HealthAppState> _syncData(SubmitSyncData event) async* {
    yield state.copyWith(blocStatus: BlocStatus.loading);
    final List<HealthDataType> _types = HealthSetting.instance.types;
    requestSyncData = {
      'syncSYSTOLICAndDIASTOLIC': false,
      'syncSTEP': false,
      'syncWeight': false,
      'syncBlodGlucose': false,
    };

    await _requestSyncData();

    yield state.copyWith(
      types: _types,
    );
  }
}
