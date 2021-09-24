import 'package:equatable/equatable.dart';

abstract class BloodSugarScheduleRecommendState extends Equatable {
  const BloodSugarScheduleRecommendState([List props = const []]) : super();

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class BloodSugarScheduleRecommendInitial extends BloodSugarScheduleRecommendState {
  const BloodSugarScheduleRecommendInitial();
  @override
  String toString() {
    return 'BloodSugarScheduleRecommendInitial{}';
  }
}

class BloodSugarScheduleRecommendFailure extends BloodSugarScheduleRecommendState {
  final String? error;

  const BloodSugarScheduleRecommendFailure(this.error);

  @override
  String toString() {
    return 'BloodSugarScheduleRecommendFailure {error: $error}';
  }
}

class BloodSugarScheduleRecommendSuccess extends BloodSugarScheduleRecommendState {
  const BloodSugarScheduleRecommendSuccess();
  @override
  String toString() {
    return 'BloodSugarScheduleRecommendSuccess{}';
  }
}

class BloodSugarScheduleRecommendLoading extends BloodSugarScheduleRecommendState {
  const BloodSugarScheduleRecommendLoading();
  @override
  String toString() {
    return 'BloodSugarScheduleRecommendLoading{}';
  }
}
