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