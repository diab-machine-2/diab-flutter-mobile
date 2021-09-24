import 'package:equatable/equatable.dart';

abstract class BloodSugarScheduleState extends Equatable {
  const BloodSugarScheduleState([List props = const []]) : super();

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class BloodSugarScheduleInitial extends BloodSugarScheduleState {
  const BloodSugarScheduleInitial();
  @override
  String toString() {
    return 'BloodSugarScheduleInitial{}';
  }
}

class BloodSugarScheduleFailure extends BloodSugarScheduleState {
  final String? error;

  const BloodSugarScheduleFailure(this.error);

  @override
  String toString() {
    return 'BloodSugarScheduleFailure {error: $error}';
  }
}

class BloodSugarScheduleSuccess extends BloodSugarScheduleState {
  const BloodSugarScheduleSuccess();
  @override
  String toString() {
    return 'BloodSugarScheduleSuccess{}';
  }
}

class BloodSugarScheduleLoading extends BloodSugarScheduleState {
  const BloodSugarScheduleLoading();
  @override
  String toString() {
    return 'BloodSugarScheduleLoading{}';
  }
}
