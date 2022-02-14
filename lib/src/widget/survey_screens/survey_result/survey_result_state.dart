import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SurveyResultState extends Equatable {
  const SurveyResultState();

  @override
  List<Object> get props => [];
}

class InitialSurveyResultState extends SurveyResultState {
  @override
  String toString() {
    return 'InitialSurveyResultState{}';
  }
}

class SurveyResultFailure extends SurveyResultState {
  final String error;

  const SurveyResultFailure(this.error);

  @override
  String toString() {
    return 'SurveyResultFailure{error: $error}';
  }
}

class SurveyResultLoading extends SurveyResultState {
  @override
  String toString() {
    return 'SurveyResultLoading{}';
  }
}
class SurveyResultSuccess extends SurveyResultState {
  @override
  String toString() {
    return 'SurveyResultSuccess{}';
  }
}
