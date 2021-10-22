import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SurveyState extends Equatable {
  SurveyState([List props = const []]) : super();

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class InitialSurveyState extends SurveyState {
  @override
  String toString() {
    return 'InitialSurveyState{}';
  }
}

class SurveyFailure extends SurveyState {
  final String error;

  SurveyFailure(this.error);

  @override
  String toString() {
    return 'SurveyFailure{error: $error}';
  }
}

class SurveyLoading extends SurveyState {
  @override
  String toString() {
    return 'SurveyLoading{}';
  }
}
class SurveySuccess extends SurveyState {
  @override
  String toString() {
    return 'SurveySuccess{}';
  }
}
