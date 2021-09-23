import 'package:equatable/equatable.dart';

abstract class BloodSugarScheduleSampleState extends Equatable {
  const BloodSugarScheduleSampleState([List props = const []]) : super();

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class BloodSugarScheduleSampleInitial extends BloodSugarScheduleSampleState {
  const BloodSugarScheduleSampleInitial();
  @override
  String toString() {
    return 'BloodSugarScheduleSampleInitial{}';
  }
}

class BloodSugarScheduleSampleFailure extends BloodSugarScheduleSampleState {
  final String? error;

  const BloodSugarScheduleSampleFailure(this.error);

  @override
  String toString() {
    return 'BloodSugarScheduleSampleFailure {error: $error}';
  }
}

class BloodSugarScheduleSampleSuccess extends BloodSugarScheduleSampleState {
  const BloodSugarScheduleSampleSuccess();
  @override
  String toString() {
    return 'BloodSugarScheduleSampleSuccess{}';
  }
}

class BloodSugarScheduleSampleLoading extends BloodSugarScheduleSampleState {
  const BloodSugarScheduleSampleLoading();
  @override
  String toString() {
    return 'BloodSugarScheduleSampleLoading{}';
  }
}
