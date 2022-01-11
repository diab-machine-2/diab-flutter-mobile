import 'package:equatable/equatable.dart';

abstract class AllQuestionAnswerState extends Equatable {
  const AllQuestionAnswerState([List props = const []]) : super();

  @override
  List<Object> get props => [];
}

class AllQuestionAnswerInitial extends AllQuestionAnswerState {
  @override
  String toString() => 'AllQuestionAnswerInitial';
}

class AllQuestionAnswerUnInitial extends AllQuestionAnswerState {
  @override
  String toString() => 'AllQuestionAnswerUnInitial';
}

class AllQuestionAnswerLoading extends AllQuestionAnswerState {
  @override
  String toString() => 'AllQuestionAnswerLoading';
}

class AllQuestionAnswerSuccess extends AllQuestionAnswerState {
  final String? message;

  const AllQuestionAnswerSuccess({this.message});

  @override
  String toString() => 'AllQuestionAnswerSuccess { message: $message }';
}

class AllQuestionAnswerFailure extends AllQuestionAnswerState {
  final String error;

  const AllQuestionAnswerFailure(this.error);

  @override
  String toString() => 'AllQuestionAnswerFailure { error: $error }';
}