import 'package:equatable/equatable.dart';

abstract class DetailPackageState extends Equatable {
  DetailPackageState([List props = const []]) : super();

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class DetailPackageInitial extends DetailPackageState {
  @override
  String toString() => 'DetailPackageInitial';
}

class DetailPackageLoading extends DetailPackageState {
  @override
  String toString() => 'DetailPackageLoading';
}

class DetailPackageFailure extends DetailPackageState {
  final String error;

  DetailPackageFailure(this.error);

  @override
  String toString() => 'DetailPackageFailure { error: $error }';
}