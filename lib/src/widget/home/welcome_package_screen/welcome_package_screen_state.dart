import 'package:equatable/equatable.dart';

abstract class WelcomePackageScreenState extends Equatable {
  const WelcomePackageScreenState([List props = const []]) : super();

  @override
  List<Object> get props => [];
}

class WelcomePackageScreenInitial extends WelcomePackageScreenState {
  @override
  String toString() => 'WelcomePackageScreenInitial';
}

class WelcomePackageScreenUnInitial extends WelcomePackageScreenState {
  @override
  String toString() => 'WelcomePackageScreenUnInitial';
}

class WelcomePackageScreenLoading extends WelcomePackageScreenState {
  @override
  String toString() => 'WelcomePackageScreenLoading';
}

class WelcomePackageScreenSuccess extends WelcomePackageScreenState {
  final String? message;

  const WelcomePackageScreenSuccess({this.message});

  @override
  String toString() => 'WelcomePackageScreenSuccess { message: $message }';
}

class WelcomePackageScreenFailure extends WelcomePackageScreenState {
  final String error;

  const WelcomePackageScreenFailure(this.error);

  @override
  String toString() => 'WelcomePackageScreenFailure { error: $error }';
}