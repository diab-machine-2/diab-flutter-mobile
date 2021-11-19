import 'package:equatable/equatable.dart';

abstract class DetailPackageState extends Equatable {
  const DetailPackageState();

  @override
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

  const DetailPackageFailure(this.error);

  @override
  String toString() => 'DetailPackageFailure { error: $error }';
}

class DetailPackageSuccess extends DetailPackageState {
  @override
  String toString() => 'DetailPackageSuccess';
}

class SendInterestSuccess extends DetailPackageState {
  @override
  String toString() => 'DetailPackageSuccess';
}