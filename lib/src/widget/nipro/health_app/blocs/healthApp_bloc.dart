import 'dart:async';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:health/health.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/health_setting.dart';
import 'package:medical/src/modal/bmi/weight_trend.dart';
import 'package:medical/src/modal/glucose/Glucose_Input_data_model.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/repo/home/home_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/repo/weight/weight_client.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'package:meta/meta.dart';
part 'healthApp_bloc_state.dart';
part 'healthApp_bloc_event.dart';

class HealthAppBloc extends Bloc<HealthAppEvent, HealthAppState> {
  HealthAppBloc() : super(HealthAppState());
  HealthFactory health = HealthFactory();
  final client = WeightClient();
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

    _types.forEach((element) async {
      switch (element) {
        case HealthDataType.STEPS:
          int? steps = await health.getTotalStepsInInterval(midnight, now);
          print("steps: $steps");
          // TODO: Làm sau
          break;
        case HealthDataType.HEIGHT:
          List<HealthDataPoint> heightValue =
              await health.getHealthDataFromTypes(midnight, now, [element]);
          if (heightValue.length != 0) {
            double valueCentimet = roundDouble(heightValue.first.value) * 100;
            if (valueCentimet != userInfo.height) {
              await UserClient().updateUserInfo(
                AppSettings.userInfo!.id,
                userInfo.copyWith(height: valueCentimet),
              );
            }
          }
          break;
        case HealthDataType.WEIGHT:
          var weightList =
              await health.getHealthDataFromTypes(midnight, now, [element]);
          if (weightList.length != 0) {
            double valueKilogram = roundDouble(weightList.first.value);
            if (valueKilogram != userInfo.weight) {
              final timeFrames =
                  await glucoseClient.fetchFlucoseTimeFrame(time: timeFrame);
              TimeFrameModel? selectedTimeFrame =
                  timeFrames.length == 0 ? null : timeFrames.first;

              final result = await WeightClient().postWeightInput(
                timeFrame,
                [],
                '$valueKilogram',
                null,
                '$valueKilogram',
                '',
                selectedTimeFrame!.id,
              );
              if (result == true) {
                await UserClient().updateUserInfo(
                  AppSettings.userInfo!.id,
                  userInfo.copyWith(weight: valueKilogram),
                );
              }
            }
          }
          break;
        case HealthDataType.HEART_RATE:
          var heartRate =
              await health.getHealthDataFromTypes(midnight, now, [element]);
          // print('heartRate:  $heartRate');
          break;
        case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
          var bloodGlucose =
              await health.getHealthDataFromTypes(midnight, now, [element]);
          // print('bloodGlucose:  $bloodGlucose');
          break;
        case HealthDataType.BLOOD_GLUCOSE:
          var bloodGlucoseList =
              await health.getHealthDataFromTypes(midnight, now, [element]);
          if (bloodGlucoseList.length != 0) {
            double bloodGlucose = roundDouble(bloodGlucoseList.first.value);
            bool isMilligramPerDeciliter =
                AppSettings.userInfo!.glucoseUnit == 1;
            final glucose = roundAsFixed(isMilligramPerDeciliter
                ? bloodGlucose
                : bloodGlucose / mmollToMgdlFactor);

            InputGlucoseDataModel model = await glucoseClient
                .fetchInput('$timeFrame', '1', 1, null, null, size: '1');
            if (model != null &&
                model.inputs.length > 0 &&
                model.inputs.first.glucose != glucose) {
              final timeFrames =
                  await glucoseClient.fetchFlucoseTimeFrame(time: timeFrame);
              TimeFrameModel? selectedTimeFrame =
                  timeFrames.length == 0 ? null : timeFrames.first;
              final result = await GlucoseClient().postIndexGlucose(
                  selectedTimeFrame!.id,
                  timeFrame,
                  glucose.toString(),
                  null,
                  '',
                  false, []);
            }
          }
          break;
        case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
          break;
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
