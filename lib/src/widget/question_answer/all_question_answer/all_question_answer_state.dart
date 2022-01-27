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

class LoadmoreAllQuestionAnswerLoading extends AllQuestionAnswerState {
  @override
  String toString() => 'LoadmoreAllQuestionAnswerLoading';
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

class DeleteQuestionSuccess extends AllQuestionAnswerState {
  final String? message;

  const DeleteQuestionSuccess({this.message});

  @override
  String toString() => 'DeleteQuestionSuccess { message: $message }';
}

class DeleteQuestionFailure extends AllQuestionAnswerState {
  final String error;

  const DeleteQuestionFailure(this.error);

  @override
  String toString() => 'DeleteQuestionFailure { error: $error }';
}

class DeleteCommentSuccess extends AllQuestionAnswerState {
  final String? message;

  const DeleteCommentSuccess({this.message});

  @override
  String toString() => 'DeleteCommentSuccess { message: $message }';
}

class DeleteCommentFailure extends AllQuestionAnswerState {
  final String error;

  const DeleteCommentFailure(this.error);

  @override
  String toString() => 'DeleteCommentFailure { error: $error }';
}
