import 'package:equatable/equatable.dart';

abstract class MakeQuestionState extends Equatable {
  const MakeQuestionState([List props = const []]) : super();

  @override
  List<Object> get props => [];
}

class MakeQuestionInitial extends MakeQuestionState {
  @override
  String toString() => 'MakeQuestionInitial';
}

class MakeQuestionUnInitial extends MakeQuestionState {
  @override
  String toString() => 'MakeQuestionUnInitial';
}

class MakeQuestionLoading extends MakeQuestionState {
  @override
  String toString() => 'MakeQuestionLoading';
}

class MakeQuestionSuccess extends MakeQuestionState {
  final String? message;

  const MakeQuestionSuccess({this.message});

  @override
  String toString() => 'MakeQuestionSuccess { message: $message }';
}

class MakeQuestionFailure extends MakeQuestionState {
  final String error;

  const MakeQuestionFailure(this.error);

  @override
  String toString() => 'MakeQuestionFailure { error: $error }';
}