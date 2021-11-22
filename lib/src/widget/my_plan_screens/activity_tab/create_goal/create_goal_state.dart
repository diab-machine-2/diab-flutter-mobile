import 'package:equatable/equatable.dart';

abstract class CreateGoalState extends Equatable {
  const CreateGoalState() : super();

  @override
  List<Object> get props => [];
}

class CreateGoalInitial extends CreateGoalState {
  const CreateGoalInitial();
  @override
  String toString() {
    return 'CreateGoalInitial{}';
  }
}

class CreateGoalFailure extends CreateGoalState {
  final String? error;

  const CreateGoalFailure(this.error);

  @override
  String toString() {
    return 'CreateGoalFailure {error: $error}';
  }
}

class CreateGoalSuccess extends CreateGoalState {
  const CreateGoalSuccess();
  @override
  String toString() {
    return 'CreateGoalSuccess{}';
  }
}

class CreateGoalLoading extends CreateGoalState {
  const CreateGoalLoading();
  @override
  String toString() {
    return 'CreateGoalLoading{}';
  }
}
