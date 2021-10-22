import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class CourseFeedbackState extends Equatable {
  CourseFeedbackState([List props = const []]) : super();

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class InitialCourseFeedbackState extends CourseFeedbackState {}

class CourseFeedbackLoading extends CourseFeedbackState {
  @override
  String toString() => 'CourseFeedbackLoading';
}

class CourseFeedbackSuccess extends CourseFeedbackState {
  @override
  String toString() {
    return 'CourseFeedbackSuccess';
  }
}

class CourseFeedbackFailure extends CourseFeedbackState {
  final String error;

  CourseFeedbackFailure(this.error);

  @override
  String toString() => 'CourseFeedbackFailure { error: $error }';
}
