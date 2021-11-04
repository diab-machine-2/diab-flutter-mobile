import 'package:equatable/equatable.dart';
import 'package:medical/src/model/response/survey_data.dart';
import 'package:meta/meta.dart';

@immutable
abstract class IntroduceSurveyState extends Equatable {
  const IntroduceSurveyState();

  @override
  List<Object> get props => [];
}

class InitialIntroduceSurveyState extends IntroduceSurveyState {
  @override
  String toString() {
    return 'InitialIntroduceSurveyState{}';
  }
}

class IntroduceSurveyFailure extends IntroduceSurveyState {
  final String error;

  const IntroduceSurveyFailure(this.error);

  @override
  String toString() {
    return 'IntroduceSurveyFailure{error: $error}';
  }
}

class IntroduceSurveyLoading extends IntroduceSurveyState {
  @override
  String toString() {
    return 'IntroduceSurveyLoading{}';
  }
}
class IntroduceSurveySuccess extends IntroduceSurveyState {
  @override
  String toString() {
    return 'IntroduceSurveySuccess{}';
  }
}

class GetDetailSurveySuccess extends IntroduceSurveyState {

  final SurveyData response;

  const GetDetailSurveySuccess(this.response);
  @override
  String toString() {
    return 'GetDetailSurveySuccess{response: ${response.toJson().toString()}}';
  }
}
