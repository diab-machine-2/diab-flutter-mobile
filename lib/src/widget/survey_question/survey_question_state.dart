import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SurveyQuestionState extends Equatable {
  const SurveyQuestionState();

  @override
  List<Object> get props => [];
}

class InitialSurveyQuestionState extends SurveyQuestionState {
  @override
  String toString() {
    return 'InitialSurveyQuestionState{}';
  }
}

class SurveyQuestionFailure extends SurveyQuestionState {
  final String error;

  const SurveyQuestionFailure(this.error);

  @override
  String toString() {
    return 'SurveyQuestionFailure{error: $error}';
  }
}

class SurveyQuestionLoading extends SurveyQuestionState {
  @override
  String toString() {
    return 'SurveyQuestionLoading{}';
  }
}

class SurveyQuestionSuccess extends SurveyQuestionState {
  @override
  String toString() {
    return 'SurveyQuestionSuccess{}';
  }
}

class ShowAnswerQuizSuccess extends SurveyQuestionState {
  @override
  String toString() {
    return 'ShowAnswerQuizSuccess{}';
  }
}

class SubmitSurveySuccess extends SurveyQuestionState {
  @override
  String toString() {
    return 'SubmitSurveySuccess{}';
  }
}

class SurveyQuestionProgressChanged extends SurveyQuestionState {
  @override
  String toString() {
    return 'SurveyQuestionProgressChanged{}';
  }
}

class SurveyQuestionHideProgressMessage extends SurveyQuestionState {
  @override
  String toString() {
    return 'SurveyQuestionHideProgressMessage{}';
  }
}
