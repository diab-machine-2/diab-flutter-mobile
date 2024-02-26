import 'dart:async';
import 'package:collection/collection.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:health/health.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/health_setting.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure.dart';
import 'package:medical/src/modal/bmi/weight_input_data_model.dart';
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
import 'package:meta/meta.dart';

import '../models/syncSystolicAndDiastolic_model.dart';
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
  DateTime releaseDate = DateTime(2023, 4, 1);

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

    dateFrom = dateFrom.add(Duration(seconds: 1));

    if (dateFrom.difference(dateTo).inDays > 90) {
      dateFrom = dateTo.add(Duration(days: 90));
    }

    bool result = false;
    requestSyncData['syncSYSTOLICAndDIASTOLIC'] = true;
    List<SyncSystolicAndDiastolicModel> dataSync = [];

    List<HealthDataPoint> bloodPressureSystolic =
        await health.getHealthDataFromTypes(dateFrom, dateTo, [
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    ]);
    List<HealthDataPoint> bloodPressureDiastolic =
        await health.getHealthDataFromTypes(dateFrom, dateTo, [
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    ]);

    List<HealthDataPoint> healthRateList =
        await health.getHealthDataFromTypes(dateFrom, dateTo, [
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

      HealthDataPoint diastolicData = bloodPressureDiastolic
          .firstWhere((item) => item.dateFrom == element.dateFrom);

      dataSync.add(SyncSystolicAndDiastolicModel(
          dateFrom: element.dateFrom,
          diastolic: roundDouble(diastolicData.value),
          heartRate: heartRate,
          systolic: systolic));
    }

    if (dataSync.isNotEmpty) {
      // Bắt đầu sync
      int dataSyncLength = dataSync.length;
      int count = 0;
      if (count != dataSyncLength) {
        for (SyncSystolicAndDiastolicModel element in dataSync) {
          List<TimeFrameModel> timeFrames =
              await glucoseClient.fetchFlucoseTimeFrame(
                  time: DateUtil.getDayInMillis(element.dateFrom));

          await BloodPressureClient().postBloodPressureInput(
              element.systolic.toString(),
              element.diastolic.toString(),
              element.heartRate.toString(),
              element.dateFrom.millisecondsSinceEpoch ~/ 1000,
              timeFrames.first.id,
              "",
              "Đồng bộ dữ liệu từ Health App", []);
          count++;
        }
      }
      result = true;
    }
    responseSyncData['syncSYSTOLICAndDIASTOLIC'] = result;
  }

  syncSTEP() async {
    DateTime dateTo = DateTime.now();
    DateTime dateFrom = releaseDate;
    bool result = false;
    requestSyncData['syncSTEP'] = true;
    StepListModel stepData = await stepRepository.getStepList(1);
    if (stepData.items.isNotEmpty) {
      DateTime dateTime =
          DateUtil.parseTimespanToDateTime(stepData.items.last.dateFrom!)
              .add(Duration(days: -1));
      // Nếu ngày sync gần nhất nhỏ hơn ngày Release thì lấy ngày release làm mốc
      if (dateTime.difference(releaseDate).inDays > 0) {
        dateFrom = dateTime;
      }
    }

    if (dateFrom.difference(dateTo).inDays > 90) {
      dateFrom = dateTo.add(Duration(days: 90));
    }
    dateTo = DateTime(
        dateTo.year,
        dateTo.month,
        dateTo.day,
        23, // Giờ
        59);

    List<HealthDataPoint> steps = await health
        .getHealthDataFromTypes(dateFrom, dateTo, [HealthDataType.STEPS]);

    if (steps.isNotEmpty) {
      List<RequestSyncStepModel> stepCollected = [];

      steps.forEach((element) {
        int dateFrom = DateTime(element.dateFrom.year, element.dateFrom.month,
                    element.dateFrom.day)
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

    dateFrom = dateFrom.add(Duration(seconds: 1));

    if (dateFrom.difference(dateTo).inDays > 90) {
      dateFrom = dateTo.add(Duration(days: 90));
    }

    List<HealthDataPoint> weightList =
        await health.getHealthDataFromTypes(dateFrom, dateTo, [
      HealthDataType.WEIGHT,
    ]);

    List<HealthDataPoint> heightList =
        await health.getHealthDataFromTypes(dateFrom, dateTo, [
      HealthDataType.HEIGHT,
    ]);

    if (weightList.isNotEmpty) {
      double? height;
      int count = 0;
      int dataSyncLength = weightList.length;
      UserModel userInfo = AppSettings.userInfo!;

      if (count != dataSyncLength) {
        for (HealthDataPoint weightData in weightList) {
          HealthDataPoint? heightData = heightList.firstWhereOrNull((item) {
            Duration difference = item.dateFrom.difference(weightData.dateFrom);
            return difference.inDays == 0;
          });

          if (heightData == null && heightList.isNotEmpty) {
            heightData = heightList.first;
          }

          List<TimeFrameModel> timeFrames = await GlucoseClient()
              .fetchFlucoseTimeFrame(
                  time: weightData.dateFrom.millisecondsSinceEpoch ~/ 1000);

          print("PHUONG  ${weightData.dateFrom} === ${timeFrames.first.name}");

          if (heightData != null) {
            height = roundDouble(heightData.value) * 100;
          } else {
            height = userInfo.height;
          }
          if (height != null) {
            await WeightClient().postWeightInput(
              weightData.dateFrom.millisecondsSinceEpoch ~/ 1000,
              [],
              roundDouble(weightData.value).toString(),
              null,
              height != null ? height.toString() : userInfo.height.toString(),
              'Đồng bộ dữ liệu từ Health App',
              timeFrames.first.id,
            );
          }
          count++;
        }
      }
      if (heightList.isNotEmpty || userInfo.height != null) {
        await UserClient().updateUserInfo(
          AppSettings.userInfo!.id,
          userInfo.copyWith(
            weight: roundDouble(weightList.first.value),
            height: heightList.isNotEmpty
                ? roundDouble(heightList.first.value) * 100
                : userInfo.height,
          ),
        );
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

    dateFrom = dateFrom.add(Duration(seconds: 1));

    if (dateFrom.difference(dateTo).inDays > 90) {
      dateFrom = dateTo.add(Duration(days: 90));
    }

    List<HealthDataPoint> dataSync = await health.getHealthDataFromTypes(
        dateFrom, dateTo, [HealthDataType.BLOOD_GLUCOSE]);

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
          case 'syncSTEP':
            if (requestSyncData[key] == false) {
              await syncSTEP();
              needRetry =
                  true; // Gọi lại _requestSyncData() sau khi hoàn thành syncSTEP()
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
