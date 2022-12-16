import 'package:health/health.dart';

class HealthSetting {
  final List<HealthDataType> types = [
    HealthDataType.STEPS,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
  ];

  final permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];
  HealthFactory health = HealthFactory();
  HealthSetting._privateConstructor();
  static final HealthSetting instance = HealthSetting._privateConstructor();

  Future<bool> requestConnect() async {
    final rights = [
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
    ];
    bool requested =
        await health.requestAuthorization(types, permissions: permissions);
    return requested;
    // bool? hasPermissions =
    //     await HealthFactory.hasPermissions(types, permissions: permissions);
    // if (requested && hasPermissions == true) {
    //   return requested;
    // } else {
    //   bool requested =
    //       await health.requestAuthorization(types, permissions: rights);
    //   return requested;
    // }
  }

  Future<bool?> checkConnectionPermission() async {
    bool? result =
        await health.requestAuthorization(types, permissions: permissions);
    print("result: $result");
    return result;
  }

  Future getBloodGlucose() async {
    List<HealthDataPoint>? steps;
    final now = DateTime.now();
    // final midnight = DateTime.parse('1969-07-20 20:18:04Z');
    final midnight = DateTime(now.year, now.month, now.day);
    final permissions = [
      HealthDataAccess.READ,
    ];
    bool requested = await health.requestAuthorization(
        [HealthDataType.BLOOD_GLUCOSE],
        permissions: permissions);

    if (requested) {
      try {
        steps = await health.getHealthDataFromTypes(
            midnight, now, [HealthDataType.BLOOD_GLUCOSE]);
      } catch (error) {
        print("Caught exception in getTotalStepsInInterval: $error");
      }
      print('getBloodGlucose: $steps');
    } else {
      print("Authorization not granted - error in authorization");
    }
  }

  Future getBloodPressureSystolic() async {
    List<HealthDataPoint>? steps;
    final now = DateTime.now();
    // final midnight = DateTime.parse('1969-07-20 20:18:04Z');
    final midnight = DateTime(now.year, now.month, now.day);
    bool requested =
        await health.requestAuthorization(types, permissions: permissions);
    print("requested 1: $requested");
    if (requested) {
      try {
        steps = await health.getHealthDataFromTypes(midnight, now, types);
        print('getBloodPressureSystolic: $steps');
      } catch (error) {
        print("Caught exception in getTotalStepsInInterval: $error");
      }
    } else {
      print("Authorization not granted - error in authorization");
    }
  }
}
