import 'package:equatable/equatable.dart';

abstract class BloodSugarScheduleTempleteState extends Equatable {
  const BloodSugarScheduleTempleteState([List props = const []]) : super();

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class BloodSugarScheduleTempleteInitial extends BloodSugarScheduleTempleteState {
  const BloodSugarScheduleTempleteInitial();
  @override
  String toString() {
    return 'BloodSugarScheduleTempleteInitial{}';
  }
}

class BloodSugarScheduleTempleteFailure extends BloodSugarScheduleTempleteState {
  final String? error;

  const BloodSugarScheduleTempleteFailure(this.error);

  @override
  String toString() {
    return 'BloodSugarScheduleTempleteFailure {error: $error}';
  }
}

class BloodSugarScheduleTempleteSuccess extends BloodSugarScheduleTempleteState {
  const BloodSugarScheduleTempleteSuccess();
  @override
  String toString() {
    return 'BloodSugarScheduleTempleteSuccess{}';
  }
}

class BloodSugarScheduleTempleteLoading extends BloodSugarScheduleTempleteState {
  const BloodSugarScheduleTempleteLoading();
  @override
  String toString() {
    return 'BloodSugarScheduleTempleteLoading{}';
  }
}

class BloodSugarScheduleSaveSuccess extends BloodSugarScheduleTempleteState {
  const BloodSugarScheduleSaveSuccess();
  @override
  String toString() {
    return 'BloodSugarScheduleTempleteLoading{}';
  }
}