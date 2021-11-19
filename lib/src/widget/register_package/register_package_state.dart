import 'package:equatable/equatable.dart';

abstract class RegisterPackageState extends Equatable {
  const RegisterPackageState();

  @override
  List<Object> get props => [];
}

class RegisterPackageInitial extends RegisterPackageState {
  @override
  String toString() => 'RegisterPackageInitial';
}

class RegisterPackageLoading extends RegisterPackageState {
  @override
  String toString() => 'RegisterPackageLoading';
}

class RegisterPackageFailure extends RegisterPackageState {
  final String error;

  const RegisterPackageFailure(this.error);

  @override
  String toString() => 'RegisterPackageFailure { error: $error }';
}