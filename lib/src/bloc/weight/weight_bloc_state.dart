part of 'weight_bloc.dart';

@immutable
abstract class WeightState {}

class WeightInitial extends WeightState {}

class WeightError extends WeightState {
  final String message;

  WeightError({
    @required this.message,
  });
}

class WeightLoading extends WeightState {}

// class WeightInputLoaded extends WeightState {
//   final List<InputBmiModel> inputbmiModel;
//   final bool hasMore;
//   WeightInputLoaded({@required this.inputbmiModel, @required this.hasMore});
// }

class WeightTrendLoaded extends WeightState {
  final TrendWeightModel trend;
  WeightTrendLoaded({@required this.trend});
}

class WeightTrendBMILoaded extends WeightState {
  final TrendBmiModel trendBMI;
  WeightTrendBMILoaded({@required this.trendBMI});
}

class WeightAllLoaded extends WeightState {
  final List<InputWeightModel> inputWeightModel;
  final bool hasMore;
  WeightAllLoaded({@required this.inputWeightModel, @required this.hasMore});
}
