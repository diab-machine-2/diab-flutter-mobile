import 'package:equatable/equatable.dart';

abstract class LessonDetailState extends Equatable {
  const LessonDetailState() : super();

  @override
  List<Object> get props => [];
}

class LessonDetailInitial extends LessonDetailState {
  const LessonDetailInitial();
  @override
  String toString() {
    return 'LessonDetailInitial{}';
  }
}

class LessonDetailFailure extends LessonDetailState {
  final String? error;

  const LessonDetailFailure(this.error);

  @override
  String toString() {
    return 'LessonDetailFailure {error: $error}';
  }
}

class LessonDetailSuccess extends LessonDetailState {
  const LessonDetailSuccess();
  @override
  String toString() {
    return 'LessonDetailSuccess{}';
  }
}

class LessonDetailLoading extends LessonDetailState {
  const LessonDetailLoading();
  @override
  String toString() {
    return 'LessonDetailLoading{}';
  }
}

class LessonDetailChangeType extends LessonDetailState {
  const LessonDetailChangeType();
  @override
  String toString() {
    return 'LessonDetailChangeType{}';
  }
}

class LessonDetailCompleted extends LessonDetailState {
  final bool showPopupShare;
  const LessonDetailCompleted({this.showPopupShare = false});
  @override
  String toString() {
    return 'LessonDetailCompleted{}';
  }
}
