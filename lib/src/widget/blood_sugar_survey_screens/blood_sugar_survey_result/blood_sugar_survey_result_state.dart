import 'package:equatable/equatable.dart';

abstract class BloodSugarSurveyResultState extends Equatable {
  const BloodSugarSurveyResultState([List props = const []]) : super();

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class BloodSugarSurveyResultInitial extends BloodSugarSurveyResultState {
  const BloodSugarSurveyResultInitial();
  @override
  String toString() {
    return 'BloodSugarSurveyResultInitial{}';
  }
}

class BloodSugarSurveyResultFailure extends BloodSugarSurveyResultState {
  final String? error;

  const BloodSugarSurveyResultFailure(this.error);

  @override
  String toString() {
    return 'BloodSugarSurveyResultFailure {error: $error}';
  }
}

class BloodSugarSurveyResultSuccess extends BloodSugarSurveyResultState {
  const BloodSugarSurveyResultSuccess();
  @override
  String toString() {
    return 'BloodSugarSurveyResultSuccess{}';
  }
}

class BloodSugarSurveyResultLoading extends BloodSugarSurveyResultState {
  const BloodSugarSurveyResultLoading();
  @override
  String toString() {
    return 'BloodSugarSurveyResultLoading{}';
  }
}
