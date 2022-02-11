import 'package:equatable/equatable.dart';

abstract class ExpertCommentState extends Equatable {
  const ExpertCommentState([List props = const []]) : super();

  @override
  List<Object> get props => [];
}

class ExpertCommentInitial extends ExpertCommentState {
  @override
  String toString() => 'ExpertCommentInitial';
}

class ExpertCommentUnInitial extends ExpertCommentState {
  @override
  String toString() => 'ExpertCommentUnInitial';
}

class ExpertCommentLoading extends ExpertCommentState {
  @override
  String toString() => 'ExpertCommentLoading';
}

class ExpertCommentSuccess extends ExpertCommentState {
  final String? message;

  const ExpertCommentSuccess({this.message});

  @override
  String toString() => 'ExpertCommentSuccess { message: $message }';
}

class ExpertCommentFailure extends ExpertCommentState {
  final String error;

  const ExpertCommentFailure(this.error);

  @override
  String toString() => 'ExpertCommentFailure { error: $error }';
}