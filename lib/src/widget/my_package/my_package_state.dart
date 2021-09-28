import 'package:equatable/equatable.dart';

abstract class MyPackageState extends Equatable {
  MyPackageState([List props = const []]) : super();

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class MyPackageInitial extends MyPackageState {
  @override
  String toString() => 'MyPackageInitial';
}

class MyPackageLoading extends MyPackageState {
  @override
  String toString() => 'MyPackageLoading';
}

class MyPackageFailure extends MyPackageState {
  final String error;

  MyPackageFailure(this.error);

  @override
  String toString() => 'MyPackageFailure { error: $error }';
}

class MyPackageSuccess extends MyPackageState {
  @override
  String toString() => 'MyPackageSuccess';
}