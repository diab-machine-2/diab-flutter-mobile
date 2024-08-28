import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:health/health.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/health_setting.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure.dart';
import 'package:medical/src/modal/bmi/weight_input_data_model.dart';
import 'package:medical/src/modal/glucose/Glucose_Input_data_model.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/repo/blood_pressure/bloodPressure_client.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/repo/weight/weight_client.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/Exercrises/steps/data/models/getStepList_model.dart';
import 'package:medical/src/widget/Exercrises/steps/data/models/requestSyncStep_model.dart';
import 'package:medical/src/widget/Exercrises/steps/data/step_repository.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:meta/meta.dart';

import '../models/syncSystolicAndDiastolic_model.dart';

part 'healthApp_bloc_event.dart';
part 'healthApp_bloc_state.dart';

class HealthAppBloc extends Bloc<HealthAppEvent, HealthAppState> {
  HealthAppBloc() : super(HealthAppState());
  Health health = Health();
  final client = WeightClient();
  final stepRepository = StepRepository();
  final glucoseClient = GlucoseClient();
  double mmollToMgdlFactor = 18.018;
  Map<String, bool> responseSyncData = {};
  Map<String, bool> requestSyncData = {};
  DateTime releaseDate = DateTime(2023, 4, 1);

  @override
  Stream<HealthAppState> mapEventToState(HealthAppEvent event) async* {
    if (event is SubmitSyncData) {
      if (event.isSyncing && !(await AppSettings.getIsSyncing())) {
        await AppSettings.setIsSyncing(true);
        yield* _syncData(event);
      }
    }
    if (event is SyncDataSuccess) {
      yield* syncDataSuccess(event);
    }
  }

  // Tâm thu - Tâm trương - Nhịp tim
  syncSystolicAndDiastolic() async {
    DateTime dateTo = DateTime.now();
    DateTime dateFrom = releaseDate;

    // Lấy thời gian sync dữ liệu gần nhất
    BloodPressureModel? lastestSummaryModel =
        await BloodPressureClient().fetchBloodPressureLatest();

    if (lastestSummaryModel != null) {
      DateTime dateTime =
          DateUtil.parseTimespanToDateTime(lastestSummaryModel.date!);
      // Nếu ngày sync gần nhất nhỏ hơn ngày Release thì lấy ngày release làm mốc
      if (dateTime.difference(releaseDate).inDays > 0) {
        dateFrom = dateTime;
      }
    }

    dateFrom = dateFrom.add(Duration(milliseconds: 1));

    if (dateFrom.difference(dateTo).inDays.abs() > 90) {
      DateTime targetDate = dateTo.add(Duration(days: -90));
      dateFrom = DateTime(targetDate.year, targetDate.month, targetDate.day);
    }

    bool result = false;
    requestSyncData['syncSYSTOLICAndDIASTOLIC'] = true;
    List<SyncSystolicAndDiastolicModel> dataSync = [];

    List<HealthDataPoint> bloodPressureSystolic =
        await health.getHealthDataFromTypes(startTime: dateFrom, endTime: dateTo, types: [
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    ]);
    List<HealthDataPoint> bloodPressureDiastolic =
        await health.getHealthDataFromTypes(startTime: dateFrom, endTime: dateTo, types: [
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    ]);

    List<HealthDataPoint> healthRateList =
        await health.getHealthDataFromTypes(startTime: dateFrom, endTime: dateTo, types: [
      HealthDataType.HEART_RATE,
    ]);

    double heartRate = 0;
    for (var element in bloodPressureSystolic) {
      double systolic = roundDouble(element.value);

      HealthDataPoint? heartRateData = healthRateList.firstWhereOrNull((item) {
        Duration difference = item.dateFrom.difference(element.dateFrom);
        return difference.inMinutes <= 5 && difference.inMinutes >= -5;
      });

      if (heartRateData != null) {
        heartRate = roundDouble(heartRateData.value);
      } else {
        heartRate = 0;
      }

      HealthDataPoint? diastolicData = bloodPressureDiastolic
          .firstWhereOrNull((item) => item.dateFrom == element.dateFrom);
      if (diastolicData != null) {
        dataSync.add(SyncSystolicAndDiastolicModel(
            dateFrom: element.dateFrom,
            diastolic: roundDouble(diastolicData.value),
            heartRate: heartRate,
            systolic: systolic));
      }
    }

    if (dataSync.isNotEmpty) {
      // Bắt đầu sync
      int dataSyncLength = dataSync.length;
      int count = 0;
      List<Map<String, dynamic>> syncData = [];
      if (count != dataSyncLength) {
        for (SyncSystolicAndDiastolicModel element in dataSync) {
          syncData.add({
            'systolic': element.systolic.toString(),
            'diastolic': element.diastolic.toString(),
            'pulseRate': element.heartRate
                .toString(), // Assuming element.heartRate is of type int or double
            'date': element.dateFrom.millisecondsSinceEpoch ~/ 1000,
            'timeFrameId': "",
            "timeFrameValue": DateUtil.getDayInMillis(element.dateFrom),
            'note': "",
            'reason': "Đồng bộ dữ liệu từ Health App",
            'files': [],
          });
          count++;
        }
      }
      if (syncData.isNotEmpty)
        BloodPressureClient().postBloodPressureInputs(syncData);
      result = true;
    }
    responseSyncData['syncSYSTOLICAndDIASTOLIC'] = result;
  }

  static bool isStepRemain = false;
  static DateTime? latestStep;

  syncStepLatestWeek() async {
    // case đang sync thì out app => sync status trước
    isStepRemain = await AppSettings.getIsRemainStep();
    String? latestTimeStepFromStorage = await AppSettings.getLatestTimeStep();
    if (latestTimeStepFromStorage != null && latestTimeStepFromStorage != "0") {
      latestStep = DateTime.parse(latestTimeStepFromStorage!);
    }
    DateTime dateTo = DateTime.now();
    DateTime dateFrom = dateTo.add(Duration(days: -7));
    StepListModel stepData = await stepRepository.getStepList(4);
    bool result = false;
    DateTime? latestTime;
    StepItemModel? latestStepModel;
    requestSyncData['syncStepLatestWeek'] = true;

    if (stepData.items.isNotEmpty)
      for (int i = stepData.items.length - 1; i >= 0; i--) {
        var step = stepData.items[i];
        if (step.value != 0) {
          latestTime = DateUtil.parseTimespanToDateTime(step.dateFrom!);
          latestStepModel = step;
          break;
        }
      }

    if (latestTime == null) {
      // Chưa sync lần nào latestStep = null =>  latestStep sẽ là 90 ngày trước
      DateTime targetDate = dateTo.add(Duration(days: -90));
      latestStep = DateTime(targetDate.year, targetDate.month, targetDate.day);
      isStepRemain = true; // Còn sync tiếp
      AppSettings.setIsRemainStep(isStepRemain);
      AppSettings.setLatestTimeStep(latestStep!.toIso8601String());
    } else {
      if (latestTime.isAfter(dateFrom)) {
        // latest nằm trong 1 tuần gần nhất thì datefrom = latest
        dateFrom = latestTime;
      } else {
        isStepRemain = true; // Còn sync tiếp
        latestStep = latestTime; // Cập nhật lần cuối cùng sync
        AppSettings.setIsRemainStep(isStepRemain);
        AppSettings.setLatestTimeStep(latestStep!.toIso8601String());
      }
    }

    dateTo = DateTime(
        dateTo.year,
        dateTo.month,
        dateTo.day,
        23, // Giờ
        59, // Phút
        59, // Giây
        999, // millisecond
        999999); // microsecond
    dateFrom = DateTime(
      dateFrom.year,
      dateFrom.month,
      dateFrom.day - 1,
    );

    result =
        await syncStepByDateV2(dateFrom, dateTo, latestStep: latestStepModel);
    responseSyncData['syncStepLatestWeek'] = result;
  }

  syncStepRemain() async {
    DateTime dateTo = DateTime.now().add(Duration(days: -8));
    DateTime dateFrom = latestStep ?? DateTime.now().add(Duration(days: -90));
    bool result = false;
    requestSyncData['syncStepRemain'] = true;
    dateFrom = DateTime(dateFrom.year, dateFrom.month, dateFrom.day);
    dateTo = DateTime(
        dateTo.year,
        dateTo.month,
        dateTo.day,
        23, // Giờ
        59, // Phút
        59, // Giây
        999, // millisecond
        999999); // microsecond
    result = await syncStepByDateV2(dateFrom, dateTo);
    responseSyncData['syncStepRemain'] = result;
    isStepRemain = false;
    AppSettings.clearStepStatus();
  }

  syncStepByDateV2(DateTime dateFrom, DateTime dateTo,
      {StepItemModel? latestStep}) async {
    List<HealthDataPoint> steps = await health
        .getHealthDataFromTypes(startTime: dateFrom, endTime: dateTo, types: [HealthDataType.STEPS]);
    if (steps.isNotEmpty) {
      List<RequestSyncStepModel> stepCollected = [];
      for (int i = 0; i < steps.length; i++) {
        final element = steps[i];
        int dateFrom = DateTime(element.dateFrom.year, element.dateFrom.month,
                    element.dateFrom.day)
                .millisecondsSinceEpoch ~/
            1000;
        DateTime dateTo = DateTime(
            element.dateFrom.year,
            element.dateFrom.month,
            element.dateFrom.day,
            23,
            59,
            59,
            999,
            999999);
        int index =
            stepCollected.indexWhere((item) => item.dateFrom == dateFrom);
        int newValue = await health.getTotalStepsInInterval(
                DateTime(element.dateFrom.year, element.dateFrom.month,
                    element.dateFrom.day),
                dateTo) ??
            0;

        int newTotalMinute =
            element.dateTo.difference(element.dateFrom).inMinutes;

        if (index.isNegative) {
          RequestSyncStepModel requestSyncStepModel = RequestSyncStepModel(
            dateTo: dateFrom,
            dateFrom: dateFrom,
            value: newValue,
            totalMinute: newTotalMinute,
            platform:
                steps.first.sourcePlatform == HealthPlatformType.appleHealth ? 'ios' : 'android',
          );
          stepCollected.add(requestSyncStepModel);
        } else {
          newTotalMinute = stepCollected[index].totalMinute + newTotalMinute;
          RequestSyncStepModel requestSyncStepModel =
              stepCollected[index].copyWith(
            value: newValue,
            totalMinute: newTotalMinute,
          );
          stepCollected[index] = requestSyncStepModel;
        }
      }
      if (stepCollected.isNotEmpty) {
        try {
          stepCollected =
              stepCollected.where((element) => element.value != 0).toList();
          // // Check if latestStep exists
          // if (latestStep != null) {
          //   // Remove elements with the same value as latestStep and the same dateFrom
          //   stepCollected.removeWhere((element) =>
          //       element.value == latestStep.value &&
          //       DateUtil.parseTimespanToDateTime(element.dateFrom)
          //               .difference(DateUtil.parseTimespanToDateTime(
          //                   latestStep.dateFrom ?? 0))
          //               .inDays
          //               .abs() ==
          //           0);
          // }
          for (RequestSyncStepModel step in stepCollected) {
            if (step.totalMinute >= 1400) {
              DateTime target = DateUtil.parseTimespanToDateTime(step.dateFrom);
              DateTime start = DateTime(target.year, target.month, target.day);
              DateTime end =
                  DateTime(start.year, start.month, start.day, 23, 59, 59);
              // get min move of this day
              List<HealthDataPoint> minutes = await health
                  .getHealthDataFromTypes(
                      startTime: start, endTime: end, types: [HealthDataType.MOVE_MINUTES]);
              // get total value of this day
              int totalMinuteValue = 0;
              for (HealthDataPoint minute in minutes) {
                totalMinuteValue +=
                    minute.dateTo.difference(minute.dateFrom).inMinutes.abs();
              }
              step.totalMinute = totalMinuteValue;
            }
          }
          if (stepCollected.length > 0)
            stepRepository.syncStepData(stepCollected);
        } catch (e) {
          return false;
        }
      }
    }
    return true;
  }

  syncSTEP() async {
    DateTime dateTo = DateTime.now();
    DateTime dateFrom = releaseDate;
    bool result = false;
    requestSyncData['syncSTEP'] = true;
    StepListModel stepData = await stepRepository.getStepList(1);
    int? latestTime = 0;
    for (int i = stepData.items.length - 1; i >= 0; i--) {
      var step = stepData.items[i];
      if (step.value != 0) {
        latestTime = step.dateFrom ?? stepData.items.last.dateFrom;
        break;
      }
    }
    if (stepData.items.isNotEmpty) {
      DateTime dateTime = DateUtil.parseTimespanToDateTime(latestTime!)
          .add(Duration(hours: -7));
      // Nếu ngày sync gần nhất nhỏ hơn ngày Release thì lấy ngày release làm mốc
      if (dateTime.difference(releaseDate).inDays > 0) {
        dateFrom = dateTime;
      }
    }

    if (dateFrom.difference(dateTo).inDays.abs() > 90) {
      DateTime targetDate = dateTo.add(Duration(days: -90));
      dateFrom = DateTime(targetDate.year, targetDate.month, targetDate.day);
    }
    dateTo = DateTime(
        dateTo.year,
        dateTo.month,
        dateTo.day,
        23, // Giờ
        59, // Phút
        59, // Giây
        999, // millisecond
        999999); // microsecond
    List<HealthDataPoint> steps = await health
        .getHealthDataFromTypes(startTime: dateFrom, endTime: dateTo, types: [HealthDataType.STEPS]);

    if (steps.isNotEmpty) {
      List<RequestSyncStepModel> stepCollected = [];

      for (int i = 0; i < steps.length; i++) {
        final element = steps[i];
        int dateFrom = DateTime(element.dateFrom.year, element.dateFrom.month,
                    element.dateFrom.day)
                .millisecondsSinceEpoch ~/
            1000;
        DateTime dateTo = DateTime(
            element.dateFrom.year,
            element.dateFrom.month,
            element.dateFrom.day,
            23,
            59,
            59,
            999,
            999999);
        int index =
            stepCollected.indexWhere((item) => item.dateFrom == dateFrom);
        int newValue = await health.getTotalStepsInInterval(
                DateTime(element.dateFrom.year, element.dateFrom.month,
                    element.dateFrom.day),
                dateTo) ??
            0;
        int newTotalMinute =
            element.dateTo.difference(element.dateFrom).inMinutes;

        if (index.isNegative) {
          RequestSyncStepModel requestSyncStepModel = RequestSyncStepModel(
            dateTo: dateFrom,
            dateFrom: dateFrom,
            value: newValue,
            totalMinute: newTotalMinute,
            platform:
                steps.first.sourcePlatform == HealthPlatformType.appleHealth ? 'ios' : 'android',
          );
          stepCollected.add(requestSyncStepModel);
        } else {
          newTotalMinute = stepCollected[index].totalMinute + newTotalMinute;

          RequestSyncStepModel requestSyncStepModel =
              stepCollected[index].copyWith(
            value: newValue,
            totalMinute: newTotalMinute,
          );
          stepCollected[index] = requestSyncStepModel;
        }
      }

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
        stepRepository.syncStepData(stepCollected);
      }
    }
    responseSyncData['syncSTEP'] = result;
    // await _requestSyncData();
  }

  syncWeight() async {
    bool result = false;
    DateTime dateTo = DateTime.now();
    DateTime dateFrom = releaseDate;
    requestSyncData['syncWeight'] = true;

    // Lấy thời gian sync dữ liệu gần nhất
    int dateToSync = DateUtil.getDayInMillis(dateTo);
    InputWeightDataModel lastestSummaryModel =
        await client.fetchInput('$dateToSync', '4', 1, size: 1);

    if (lastestSummaryModel.inputs.isNotEmpty) {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
          lastestSummaryModel.inputs.first.date! * 1000);
      // Nếu ngày sync gần nhất nhỏ hơn ngày Release thì lấy ngày release làm mốc
      if (dateTime.difference(releaseDate).inDays > 0) {
        dateFrom = dateTime;
      }
    }

    dateFrom = dateFrom.add(Duration(milliseconds: 1));

    if (dateFrom.difference(dateTo).inDays.abs() > 90) {
      DateTime targetDate = dateTo.add(Duration(days: -90));
      dateFrom = DateTime(targetDate.year, targetDate.month, targetDate.day);
    }

    List<HealthDataPoint> weightList =
        await health.getHealthDataFromTypes(startTime: dateFrom, endTime: dateTo, types: [
      HealthDataType.WEIGHT,
    ]);

    List<HealthDataPoint> heightList =
        await health.getHealthDataFromTypes(startTime: dateFrom, endTime: dateTo, types: [
      HealthDataType.HEIGHT,
    ]);

    if (weightList.isNotEmpty) {
      double? height;
      int count = 0;
      int dataSyncLength = weightList.length;
      UserModel userInfo = AppSettings.userInfo!;
      List<Map<String, dynamic>> syncData = [];
      bool isGestationalDiabetes = Utils.isGestationalDiabetes();
      if (count != dataSyncLength) {
        for (HealthDataPoint weightData in weightList) {
          HealthDataPoint? heightData = heightList.firstWhereOrNull((item) {
            Duration difference = item.dateFrom.difference(weightData.dateFrom);
            return difference.inDays == 0;
          });

          if (heightData == null && heightList.isNotEmpty) {
            heightData = heightList.first;
          }

          if (heightData != null) {
            height = roundDouble(heightData.value) * 100;
          } else {
            height = userInfo.height;
          }
          if (height != null) {
            syncData.add({
              "date": weightData.dateFrom.millisecondsSinceEpoch ~/ 1000,
              "weight": roundDouble(weightData.value).toString(),
              "height": height != null
                  ? height.toString()
                  : userInfo.height.toString(),
              "timeFrameValue": DateUtil.getDayInMillis(weightData.dateFrom),
              // 'timeFrameId': "",
              "note": 'Đồng bộ dữ liệu từ Health App',
              // "waist": null,
              "files": [],
              "thresholdType": isGestationalDiabetes ? '1' : '0'
            });
          }
          count++;
        }
        if (syncData.isNotEmpty) WeightClient().postWeightInputs(syncData);
      }
      if (heightList.isNotEmpty || userInfo.height != null) {
        try {
          await UserClient().updateUserInfo(
            AppSettings.userInfo!.id,
            userInfo.copyWith(
              weight: roundDouble(weightList.first.value),
              height: heightList.isNotEmpty
                  ? roundDouble(heightList.first.value) * 100
                  : userInfo.height,
            ),
          );
        } catch (e, stackTrace) {
          print('Error in updateUserInfo: $e');
          print('Stack trace: $stackTrace');
        } finally {
          await AppSettings.setIsSyncing(false);
        }
        result = true;
      }
    }

    responseSyncData['syncWeight'] = result;
    // await _requestSyncData();
  }

  syncBlodGlucose() async {
    DateTime dateTo = DateTime.now();
    DateTime dateFrom = releaseDate;
    bool result = false;
    requestSyncData['syncBlodGlucose'] = true;

    // Lấy thời gian sync dữ liệu gần nhất
    int dayToSync = DateUtil.getDayInMillis(dateTo);
    InputGlucoseDataModel lastestSummaryModel = await glucoseClient
        .fetchInput('$dayToSync', '4', 1, null, null, size: '1');
    if (lastestSummaryModel.inputs.isNotEmpty) {
      DateTime dateTime = DateUtil.parseTimespanToDateTime(
          lastestSummaryModel.inputs.first.createDate!);
      if (dateTime.difference(releaseDate).inDays > 0) {
        dateFrom = dateTime;
      }
    }

    dateFrom = dateFrom.add(Duration(milliseconds: 1));

    if (dateFrom.difference(dateTo).inDays.abs() > 90) {
      DateTime targetDate = dateTo.add(Duration(days: -90));
      dateFrom = DateTime(targetDate.year, targetDate.month, targetDate.day);
    }

    List<HealthDataPoint> dataSync = await health.getHealthDataFromTypes(
        startTime: dateFrom, endTime: dateTo, types: [HealthDataType.BLOOD_GLUCOSE]);

    if (dataSync.isNotEmpty) {
      // Bắt đầu sync
      bool isMilligramPerDeciliter =
          dataSync.first.unit == HealthDataUnit.MILLIGRAM_PER_DECILITER;
      List<Map<String, String>> glucosedList = [];
      dataSync.forEach((element) {
        double glucose = roundAsFixed(isMilligramPerDeciliter
            ? roundDouble(element.value)
            : roundDouble(element.value) / mmollToMgdlFactor);
        glucosedList.add({
          'glucose': glucose.toString(),
          'date': DateUtil.getDayInMillis(element.dateFrom).toString(),
        });
      });
      await GlucoseClient().postGlucoseInputs(glucosedList);
      result = true;
    }

    responseSyncData['syncBlodGlucose'] = result;
  }

  Stream<HealthAppState> syncDataSuccess(SyncDataSuccess event) async* {
    yield state.copyWith(blocStatus: BlocStatus.success);
  }

  Future<void> _requestSyncData() async {
    if (responseSyncData.length == requestSyncData.length) {
      bool isDataUpdated = responseSyncData.values
          .firstWhere((element) => element == true, orElse: () => false);
      bool isNotCompleteRequest = requestSyncData.values
          .firstWhere((element) => element == false, orElse: () => false);
      Console.log(
          'isNotCompleteRequest: ${isDataUpdated && !isNotCompleteRequest}');
      if (isDataUpdated && !isNotCompleteRequest) {
        Observable.instance.notifyObservers([], notifyName: "refresh_home");
      }
      add(SyncDataSuccess());
    } else {
      bool needRetry =
          false; // Biến đánh dấu có cần gọi lại _requestSyncData() hay không
      for (String key in requestSyncData.keys) {
        switch (key) {
          case 'syncSYSTOLICAndDIASTOLIC':
            if (requestSyncData[key] == false) {
              await syncSystolicAndDiastolic();
              needRetry =
                  true; // Gọi lại _requestSyncData() sau khi hoàn thành syncSystolicAndDiastolic()
            }
            break;
          case 'syncStepRemain':
            if (isStepRemain && requestSyncData[key] == false) {
              await syncStepRemain();
              needRetry =
                  true; // Gọi lại _requestSyncData() sau khi hoàn thành syncSTEP()
            }
            break;
          case 'syncStepLatestWeek':
            if (requestSyncData[key] == false) {
              await syncStepLatestWeek();
              needRetry = true;
            }
            break;
          case 'syncWeight':
            if (requestSyncData[key] == false) {
              await syncWeight();
              needRetry =
                  true; // Gọi lại _requestSyncData() sau khi hoàn thành syncWeight()
            }
            break;
          case 'syncBlodGlucose':
            if (requestSyncData[key] == false) {
              await syncBlodGlucose();
              needRetry =
                  true; // Gọi lại _requestSyncData() sau khi hoàn thành syncBlodGlucose()
            }
            break;
        }
        if (needRetry) {
          break; // Thoát vòng lặp nếu cần gọi lại _requestSyncData()
        }
      }

      if (needRetry) {
        await _requestSyncData(); // Gọi lại _requestSyncData() nếu cần
      }
    }
  }

  Stream<HealthAppState> _syncData(SubmitSyncData event) async* {
    print("PHUONG Stream<HealthAppState> _syncData");
    yield state.copyWith(blocStatus: BlocStatus.loading);
    final List<HealthDataType> _types = HealthSetting.instance.types;
    requestSyncData = {
      'syncStepLatestWeek': false,
      'syncSYSTOLICAndDIASTOLIC': false,
      'syncWeight': false,
      'syncBlodGlucose': false,
      'syncStepRemain': false,
    };

    try {
      await _requestSyncData();
    } catch (e) {
      print('Error in x: $e');
    } finally {
      await AppSettings.setIsSyncing(false);
    }
    yield state.copyWith(
      types: _types,
    );
  }
}
