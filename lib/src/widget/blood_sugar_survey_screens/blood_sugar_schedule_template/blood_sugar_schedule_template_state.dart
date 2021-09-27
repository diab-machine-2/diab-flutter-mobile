import 'package:equatable/equatable.dart';

abstract class BloodSugarScheduleTemplateState extends Equatable {
  const BloodSugarScheduleTemplateState([List props = const []]) : super();

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class BloodSugarScheduleTemplateInitial
    extends BloodSugarScheduleTemplateState {
  const BloodSugarScheduleTemplateInitial();
  @override
  String toString() {
    return 'BloodSugarScheduleTemplateInitial{}';
  }
}

class BloodSugarScheduleTemplateFailure
    extends BloodSugarScheduleTemplateState {
  final String? error;

  const BloodSugarScheduleTemplateFailure(this.error);

  @override
  String toString() {
    return 'BloodSugarScheduleTemplateFailure {error: $error}';
  }
}

class BloodSugarScheduleTemplateSuccess
    extends BloodSugarScheduleTemplateState {
  const BloodSugarScheduleTemplateSuccess();
  @override
  String toString() {
    return 'BloodSugarScheduleTemplateSuccess{}';
  }
}

class BloodSugarScheduleTemplateLoading
    extends BloodSugarScheduleTemplateState {
  const BloodSugarScheduleTemplateLoading();
  @override
  String toString() {
    return 'BloodSugarScheduleTemplateLoading{}';
  }
}

class BloodSugarScheduleSaveSuccess extends BloodSugarScheduleTemplateState {
  const BloodSugarScheduleSaveSuccess();
  @override
  String toString() {
    return 'BloodSugarScheduleTemplateLoading{}';
  }
}
