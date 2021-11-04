import 'package:equatable/equatable.dart';

abstract class ExerciseFeedbackState extends Equatable {
  const ExerciseFeedbackState() : super();

  @override
  List<Object> get props => [];
}

class ExerciseFeedbackInitial extends ExerciseFeedbackState {
  const ExerciseFeedbackInitial();
  @override
  String toString() {
    return 'ExerciseFeedbackInitial{}';
  }
}

class ExerciseFeedbackFailure extends ExerciseFeedbackState {
  final String? error;

  const ExerciseFeedbackFailure(this.error);

  @override
  String toString() {
    return 'ExerciseFeedbackFailure {error: $error}';
  }
}

class ExerciseFeedbackSuccess extends ExerciseFeedbackState {
  const ExerciseFeedbackSuccess();
  @override
  String toString() {
    return 'ExerciseFeedbackSuccess{}';
  }
}

class ExerciseFeedbackLoading extends ExerciseFeedbackState {
  const ExerciseFeedbackLoading();
  @override
  String toString() {
    return 'ExerciseFeedbackLoading{}';
  }
}
