import 'package:equatable/equatable.dart';

abstract class LessonFilterState extends Equatable {
  const LessonFilterState() : super();

  @override
  List<Object> get props => [];
}

class LessonFilterInitial extends LessonFilterState {
  const LessonFilterInitial();
  @override
  String toString() {
    return 'LessonFilterInitial{}';
  }
}

class LessonFilterFailure extends LessonFilterState {
  final String? error;

  const LessonFilterFailure(this.error);

  @override
  String toString() {
    return 'LessonFilterFailure {error: $error}';
  }
}

class LessonFilterSuccess extends LessonFilterState {
  const LessonFilterSuccess();
  @override
  String toString() {
    return 'LessonFilterSuccess{}';
  }
}

class LessonFilterLoading extends LessonFilterState {
  const LessonFilterLoading();
  @override
  String toString() {
    return 'LessonFilterLoading{}';
  }
}

class LessonFilterDone extends LessonFilterState {
  const LessonFilterDone();
  @override
  String toString() {
    return 'LessonFilterDone{}';
  }
}
