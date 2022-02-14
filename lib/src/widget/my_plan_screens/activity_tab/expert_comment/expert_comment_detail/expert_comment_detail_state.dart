import 'package:equatable/equatable.dart';

abstract class ExpertCommentDetailState extends Equatable {
  const ExpertCommentDetailState([List props = const []]) : super();

  @override
  List<Object> get props => [];
}

class ExpertCommentDetailInitial extends ExpertCommentDetailState {
  @override
  String toString() => 'ExpertCommentDetailInitial';
}

class ExpertCommentDetailUnInitial extends ExpertCommentDetailState {
  @override
  String toString() => 'ExpertCommentDetailUnInitial';
}

class ExpertCommentDetailLoading extends ExpertCommentDetailState {
  @override
  String toString() => 'ExpertCommentDetailLoading';
}

class ExpertCommentDetailSuccess extends ExpertCommentDetailState {
  final String? message;

  const ExpertCommentDetailSuccess({this.message});

  @override
  String toString() => 'ExpertCommentDetailSuccess { message: $message }';
}

class ExpertCommentDetailFailure extends ExpertCommentDetailState {
  final String error;

  const ExpertCommentDetailFailure(this.error);

  @override
  String toString() => 'ExpertCommentDetailFailure { error: $error }';
}