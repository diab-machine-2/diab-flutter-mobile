import 'package:equatable/equatable.dart';

abstract class CongratulationState extends Equatable {
  const CongratulationState();

  @override
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

  const CongratulationFailure(this.error);

  @override
  String toString() => 'CongratulationFailure { error: $error }';
}