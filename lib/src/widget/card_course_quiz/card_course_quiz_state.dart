import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class CardCourseQuizState extends Equatable {
  const CardCourseQuizState();

  @override
  List<Object> get props => [];
}

class InitialCardCourseQuizState extends CardCourseQuizState {

  @override
  String toString() {
    return 'InitialCardCourseQuizState{}';
  }
}

class ChooseAnswerSuccess extends CardCourseQuizState {

  @override
  String toString() {
    return 'ChooseAnswerSuccess{}';
  }
}


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

  const CardCourseQuizFailure(this.error);

  @override
  String toString() => 'CardCourseQuizFailure { error: $error }';
}
