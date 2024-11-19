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
    HealthDataType.TOTAL_CALORIES_BURNED,
     HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  final permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];
  Health health = Health();
  HealthSetting._privateConstructor();
  static final HealthSetting instance = HealthSetting._privateConstructor();

  // final rights = [
  //   HealthDataAccess.WRITE,
  //   HealthDataAccess.WRITE,
  //   HealthDataAccess.WRITE,
  //   HealthDataAccess.WRITE,
  //   HealthDataAccess.WRITE,
  //   HealthDataAccess.WRITE,
  //   HealthDataAccess.WRITE,
  // ];
  Future<bool?> requestConnectionPermission() async {
    bool? result =
        await health.requestAuthorization(types, permissions: permissions);
    return result;
  }

  Future<bool> isHealthConnectSdkStatusAvailable() async {
    bool? status;
    try {
      final healthStatus = await health.getHealthConnectSdkStatus();

      status = healthStatus == HealthConnectSdkStatus.sdkAvailable;
      print(
          "[HEALTH_CONNECT] is HealthConnect Sdk Status Available result: $status");
    } catch (e) {
      print("[HEALTH_CONNECT] Error getHealthConnectSdkStatus: $e");
      status = false;
    }
    return status;
  }

  Future<void> installHealthConnect() async {
    await health.installHealthConnect();
  }

  Future<bool?> checkConnectionPermission() async {
    bool hasPermissions = await health.requestAuthorization(
        [HealthDataType.BLOOD_GLUCOSE],
        permissions: [HealthDataAccess.READ]);

    // bool? hasPermissions =
    //     await HealthFactory.hasPermissions(types, permissions: rights);
    print('checkConnectionPermission: $hasPermissions');
    return hasPermissions;
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
            startTime: midnight,
            endTime: now,
            types: [HealthDataType.BLOOD_GLUCOSE]);
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
        steps = await health.getHealthDataFromTypes(
            startTime: midnight, endTime: now, types: types);
        print('getBloodPressureSystolic: $steps');
      } catch (error) {
        print("Caught exception in getTotalStepsInInterval: $error");
      }
    } else {
      print("Authorization not granted - error in authorization");
    }
  }
}
