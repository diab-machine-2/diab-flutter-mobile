import 'package:equatable/equatable.dart';

abstract class QuestionDetailState extends Equatable {
  const QuestionDetailState([List props = const []]) : super();

  @override
  List<Object> get props => [];
}

class QuestionDetailInitial extends QuestionDetailState {
  @override
  String toString() => 'QuestionDetailInitial';
}

class QuestionDetailUnInitial extends QuestionDetailState {
  @override
  String toString() => 'QuestionDetailUnInitial';
}

class QuestionDetailLoading extends QuestionDetailState {
  @override
  String toString() => 'QuestionDetailLoading';
}

class QuestionDetailSuccess extends QuestionDetailState {
  final String? message;

  const QuestionDetailSuccess({this.message});

  @override
  String toString() => 'QuestionDetailSuccess { message: $message }';
}

class QuestionDetailFailure extends QuestionDetailState {
  final String error;

  const QuestionDetailFailure(this.error);

  @override
  String toString() => 'QuestionDetailFailure { error: $error }';
}

class MakeCommentSuccess extends QuestionDetailState {
  final String? message;

  const MakeCommentSuccess({this.message});

  @override
  String toString() => 'MakeCommentSuccess { message: $message }';
}

class MakeCommentFailure extends QuestionDetailState {
  final String error;

  const MakeCommentFailure(this.error);

  @override
  String toString() => 'MakeCommentFailure { error: $error }';
}

class DeleteQuestionSuccess extends QuestionDetailState {
  final String? message;

  const DeleteQuestionSuccess({this.message});

  @override
  String toString() => 'DeleteQuestionSuccess { message: $message }';
}

class DeleteQuestionFailure extends QuestionDetailState {
  final String error;

  const DeleteQuestionFailure(this.error);

  @override
  String toString() => 'DeleteQuestionFailure { error: $error }';
}

class DeleteCommentSuccess extends QuestionDetailState {
  final String? message;

  const DeleteCommentSuccess({this.message});

  @override
  String toString() => 'DeleteCommentSuccess { message: $message }';
}

class DeleteCommentFailure extends QuestionDetailState {
  final String error;

  const DeleteCommentFailure(this.error);

  @override
  String toString() => 'DeleteCommentFailure { error: $error }';
}

class RatingCommentSuccess extends QuestionDetailState {
  final String? message;

  const RatingCommentSuccess({this.message});

  @override
  String toString() => 'DeleteCommentSuccess { message: $message }';
}

class RatingCommentFailure extends QuestionDetailState {
  const RatingCommentFailure();

  @override
  String toString() => 'RatingCommentFailure';
}
