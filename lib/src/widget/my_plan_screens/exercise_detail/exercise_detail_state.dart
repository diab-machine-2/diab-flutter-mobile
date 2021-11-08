import 'package:equatable/equatable.dart';

abstract class ExerciseDetailState extends Equatable {
  const ExerciseDetailState() : super();

  @override
  List<Object> get props => [];
}

class ExerciseDetailInitial extends ExerciseDetailState {
  const ExerciseDetailInitial();
  @override
  String toString() {
    return 'ExerciseDetailInitial{}';
  }
}

class ExerciseDetailFailure extends ExerciseDetailState {
  final String? error;

  const ExerciseDetailFailure(this.error);

  @override
  String toString() {
    return 'ExerciseDetailFailure {error: $error}';
  }
}

class ExerciseDetailSuccess extends ExerciseDetailState {
  const ExerciseDetailSuccess();
  @override
  String toString() {
    return 'ExerciseDetailSuccess{}';
  }
}

class ExerciseDetailLoading extends ExerciseDetailState {
  const ExerciseDetailLoading();
  @override
  String toString() {
    return 'ExerciseDetailLoading{}';
  }
}

class ExerciseDetailAllCompleted extends ExerciseDetailState {
  const ExerciseDetailAllCompleted();
  @override
  String toString() {
    return 'ExerciseDetailAllCompleted{}';
  }
}

class ExerciseDetailMakeFeedback extends ExerciseDetailState {
  const ExerciseDetailMakeFeedback();
  @override
  String toString() {
    return 'ExerciseDetailMakeFeedback{}';
  }
}
