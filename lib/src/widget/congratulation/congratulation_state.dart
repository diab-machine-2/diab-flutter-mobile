import 'package:equatable/equatable.dart';

abstract class CongratulationState extends Equatable {
  CongratulationState([List props = const []]) : super();

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class CongratulationInitial extends CongratulationState {
  @override
  String toString() => 'CongratulationInitial';
}

class CongratulationLoading extends CongratulationState {
  @override
  String toString() => 'CongratulationLoading';
}

class CongratulationFailure extends CongratulationState {
  final String error;

  CongratulationFailure(this.error);

  @override
  String toString() => 'CongratulationFailure { error: $error }';
}