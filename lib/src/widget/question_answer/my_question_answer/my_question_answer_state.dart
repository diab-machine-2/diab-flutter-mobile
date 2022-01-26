import 'package:equatable/equatable.dart';

abstract class MyQuestionAnswerState extends Equatable {
  const MyQuestionAnswerState([List props = const []]) : super();

  @override
  List<Object> get props => [];
}

class MyQuestionAnswerInitial extends MyQuestionAnswerState {
  @override
  String toString() => 'MyQuestionAnswerInitial';
}

class MyQuestionAnswerUnInitial extends MyQuestionAnswerState {
  @override
  String toString() => 'MyQuestionAnswerUnInitial';
}

class MyQuestionAnswerLoading extends MyQuestionAnswerState {
  @override
  String toString() => 'MyQuestionAnswerLoading';
}

class MyQuestionAnswerSuccess extends MyQuestionAnswerState {
  final String? message;

  const MyQuestionAnswerSuccess({this.message});

  @override
  String toString() => 'MyQuestionAnswerSuccess { message: $message }';
}

class MyQuestionAnswerFailure extends MyQuestionAnswerState {
  final String error;

  const MyQuestionAnswerFailure(this.error);

  @override
  String toString() => 'MyQuestionAnswerFailure { error: $error }';
}