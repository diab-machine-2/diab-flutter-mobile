import 'package:equatable/equatable.dart';

abstract class MyPlanState extends Equatable {
  const MyPlanState() : super();

  @override
  List<Object> get props => [];
}

class MyPlanInitial extends MyPlanState {
  const MyPlanInitial();
  @override
  String toString() {
    return 'MyPlanInitial{}';
  }
}

class MyPlanFailure extends MyPlanState {
  final String? error;

  const MyPlanFailure(this.error);

  @override
  String toString() {
    return 'MyPlanFailure {error: $error}';
  }
}

class MyPlanSuccess extends MyPlanState {
  const MyPlanSuccess();
  @override
  String toString() {
    return 'MyPlanSuccess{}';
  }
}

class MyPlanLoading extends MyPlanState {
  const MyPlanLoading();
  @override
  String toString() {
    return 'MyPlanLoading{}';
  }
}

class MyPlanChangeType extends MyPlanState {
  const MyPlanChangeType(this.index);
  final int index;
  @override
  String toString() {
    return 'MyPlanChangeType{}';
  }
}