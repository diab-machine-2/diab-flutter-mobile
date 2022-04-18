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

class CardCourseQuizFillText extends CardCourseQuizState {
  const CardCourseQuizFillText(this.text);

  final String text;

  @override
  String toString() => 'CardCourseQuizFillText { text: $text }';
}

class CardCourseQuizFillTextField extends CardCourseQuizState {
  const CardCourseQuizFillTextField(this.text);

  final String text;

  @override
  String toString() => 'CardCourseQuizFillTextField { text: $text }';
}
