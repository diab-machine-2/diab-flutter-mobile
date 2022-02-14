import 'package:equatable/equatable.dart';

abstract class BloodSugarStartSurveyState extends Equatable {
  const BloodSugarStartSurveyState() : super();

  @override
  List<Object> get props => [];
}

class BloodSugarStartSurveyInitial extends BloodSugarStartSurveyState {
  const BloodSugarStartSurveyInitial();
  @override
  String toString() {
    return 'BloodSugarStartSurveyInitial{}';
  }
}

class BloodSugarStartSurveyFailure extends BloodSugarStartSurveyState {
  final String? error;

  const BloodSugarStartSurveyFailure(this.error);

  @override
  String toString() {
    return 'BloodSugarStartSurveyFailure {error: $error}';
  }
}

class BloodSugarStartSurveySuccess extends BloodSugarStartSurveyState {
  const BloodSugarStartSurveySuccess();
  @override
  String toString() {
    return 'BloodSugarStartSurveySuccess{}';
  }
}

class BloodSugarStartSurveyLoading extends BloodSugarStartSurveyState {
  const BloodSugarStartSurveyLoading();
  @override
  String toString() {
    return 'BloodSugarStartSurveyLoading{}';
  }
}
