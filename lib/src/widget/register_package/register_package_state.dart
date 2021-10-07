import 'package:equatable/equatable.dart';

abstract class RegisterPackageState extends Equatable {
  RegisterPackageState([List props = const []]) : super();

  @override
  // TODO: implement props
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

  RegisterPackageFailure(this.error);

  @override
  String toString() => 'RegisterPackageFailure { error: $error }';
}