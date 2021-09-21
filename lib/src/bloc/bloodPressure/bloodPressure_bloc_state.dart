part of 'bloodPressure_bloc.dart';

@immutable
abstract class BloodPressureState {}

class BloodPressureInitial extends BloodPressureState {}

class BloodPressureError extends BloodPressureState {
  final String? message;

  BloodPressureError({
    required this.message,
  });
}

class BloodPressureLoading extends BloodPressureState {}

class BloodPressureLoaded extends BloodPressureState {
  BloodPressureLoaded(List<TimeFrameModel> list);
}

class BloodPressureDataLoaded extends BloodPressureState {
  final List<BloodPressureModel> bloodPressureModel;
  final bool? hasMore;
  BloodPressureDataLoaded(
      {required this.bloodPressureModel, required this.hasMore});
}

class BloodPressureDataHeartRateLoaded extends BloodPressureState {
  final BloodPressureHeartRateModel bloodPressureHeartRateModel;
  final BloodPressureModel lastestSummaryModel;

  BloodPressureDataHeartRateLoaded(
      {required this.bloodPressureHeartRateModel,
      required this.lastestSummaryModel});
}

class BloodPressureDistributionLoaded extends BloodPressureState {
  final BloodPressureDistributionModel listDistribution;
  BloodPressureDistributionLoaded({required this.listDistribution});
}

class BloodPressureTrendLoaded extends BloodPressureState {
  final BloodPressureTrendModel model;
  BloodPressureTrendLoaded({required this.model});
}

class BloodPulseRateTrendLoaded extends BloodPressureState {
  final BloodPressureTrendModel model;
  BloodPulseRateTrendLoaded({required this.model});
}
