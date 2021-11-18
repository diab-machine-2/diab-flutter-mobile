import 'package:equatable/equatable.dart';

abstract class LessonTabState extends Equatable {
  const LessonTabState() : super();

  @override
  List<Object> get props => [];
}

class LessonTabInitial extends LessonTabState {
  const LessonTabInitial();
  @override
  String toString() {
    return 'LessonTabInitial{}';
  }
}

class LessonTabFailure extends LessonTabState {
  final String? error;

  const LessonTabFailure(this.error);

  @override
  String toString() {
    return 'LessonTabFailure {error: $error}';
  }
}

class LessonTabSuccess extends LessonTabState {
  const LessonTabSuccess();
  @override
  String toString() {
    return 'LessonTabSuccess{}';
  }
}

class LessonTabLoading extends LessonTabState {
  const LessonTabLoading();
  @override
  String toString() {
    return 'LessonTabLoading{}';
  }
}

class LessonTabChangeType extends LessonTabState {
  const LessonTabChangeType();
  @override
  String toString() {
    return 'LessonTabChangeType{}';
  }
}

class LessonTabWeekChanged extends LessonTabState {
  const LessonTabWeekChanged(this.newIndex);
  final int newIndex;
  @override
  String toString() {
    return 'LessonTabWeekChanged{}';
  }
}