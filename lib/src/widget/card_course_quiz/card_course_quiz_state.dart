import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class CardCourseQuizState extends Equatable {
  CardCourseQuizState([List props = const []]) : super();

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class InitialCardCourseQuizState extends CardCourseQuizState {}

class CardCourseQuizLoading extends CardCourseQuizState {
  @override
  String toString() => 'CardCourseQuizLoading';
}

class CardCourseQuizSuccess extends CardCourseQuizState {
  @override
  String toString() {
    return 'CardCourseQuizSuccess';
  }
}

class CardCourseQuizFailure extends CardCourseQuizState {
  final String error;

  CardCourseQuizFailure(this.error);

  @override
  String toString() => 'CardCourseQuizFailure { error: $error }';
}
