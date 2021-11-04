import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class CourseQuizState extends Equatable {
  const CourseQuizState();

  @override
  List<Object> get props => [];
}

class InitialCourseQuizState extends CourseQuizState {}

class CourseQuizLoading extends CourseQuizState {
  @override
  String toString() => 'CourseQuizLoading';
}

class CourseQuizSuccess extends CourseQuizState {
  @override
  String toString() {
    return 'CourseQuizSuccess';
  }
}

class CourseQuizFailure extends CourseQuizState {
  final String error;

  const CourseQuizFailure(this.error);

  @override
  String toString() => 'CourseQuizFailure { error: $error }';
}

class ShowAnswerQuizSuccess extends CourseQuizState {
  @override
  String toString() {
    return 'ShowAnswerQuizSuccess';
  }
}

class RetryQuizSuccess extends CourseQuizState {
  @override
  String toString() {
    return 'RetryQuizSuccess';
  }
}

class CourseQuizDone extends CourseQuizState {
  const CourseQuizDone();
  @override
  String toString() {
    return 'CourseQuizDone';
  }
}