import 'package:equatable/equatable.dart';

abstract class WelcomeServiceState extends Equatable {
  const WelcomeServiceState();

  @override
  List<Object> get props => [];
}

class WelcomeServiceInitial extends WelcomeServiceState {
  @override
  String toString() => 'WelcomeServiceInitial';
}

class WelcomeServiceLoading extends WelcomeServiceState {
  @override
  String toString() => 'WelcomeServiceLoading';
}

class WelcomeServiceFailure extends WelcomeServiceState {
  final String error;

  const WelcomeServiceFailure(this.error);

  @override
  String toString() => 'WelcomeServiceFailure { error: $error }';
}