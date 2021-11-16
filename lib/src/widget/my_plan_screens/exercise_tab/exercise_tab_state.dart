import 'package:equatable/equatable.dart';

abstract class ExerciseTabState extends Equatable {
  const ExerciseTabState() : super();

  @override
  List<Object> get props => [];
}

class ExerciseTabInitial extends ExerciseTabState {
  const ExerciseTabInitial();
  @override
  String toString() {
    return 'ExerciseTabInitial{}';
  }
}

class ExerciseTabFailure extends ExerciseTabState {
  final String? error;

  const ExerciseTabFailure(this.error);

  @override
  String toString() {
    return 'ExerciseTabFailure {error: $error}';
  }
}

class ExerciseTabSuccess extends ExerciseTabState {
  const ExerciseTabSuccess();
  @override
  String toString() {
    return 'ExerciseTabSuccess{}';
  }
}

class ExerciseTabLoading extends ExerciseTabState {
  const ExerciseTabLoading();
  @override
  String toString() {
    return 'ExerciseTabLoading{}';
  }
}

class ExerciseTabRoadmapEmpty extends ExerciseTabState {
  const ExerciseTabRoadmapEmpty();
  @override
  String toString() {
    return 'ExerciseTabRoadmapEmpty{}';
  }
}