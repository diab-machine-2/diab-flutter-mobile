part of 'bloodPressure_bloc.dart';

@immutable
abstract class BloodPressureEvent {}

class FetchBloodPressureTimeFrame extends BloodPressureEvent {
  FetchBloodPressureTimeFrame();
}

class FetchInputBloodPressure extends BloodPressureEvent {
  final String currentDateTime;
  final String periodFilterType;
  final String bloodPressureType;
  final int page;

  FetchInputBloodPressure({
    this.currentDateTime,
    this.periodFilterType,
    this.page,
    this.bloodPressureType,
  });
}

class FetchHeartRateBloodPressure extends BloodPressureEvent {
  final String currentDateTime;
  final String periodFilterType;

  FetchHeartRateBloodPressure({this.currentDateTime, this.periodFilterType});
}

class FetchDistributionBloodPressure extends BloodPressureEvent {
  final String currentDateTime;
  final String periodFilterType;

  FetchDistributionBloodPressure({this.currentDateTime, this.periodFilterType});
}

class FetchBloodPressureTrend extends BloodPressureEvent {
  final int currentDateTime;
  final int periodFilterType;

  FetchBloodPressureTrend({this.currentDateTime, this.periodFilterType});
}

class FetchPulseRateTrend extends BloodPressureEvent {
  final int currentDateTime;
  final int periodFilterType;

  FetchPulseRateTrend({this.currentDateTime, this.periodFilterType});
}
