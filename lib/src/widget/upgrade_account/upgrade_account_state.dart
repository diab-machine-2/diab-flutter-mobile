import 'package:equatable/equatable.dart';

abstract class UpgradeAccountState extends Equatable {
  UpgradeAccountState([List props = const []]) : super();

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class UpgradeAccountInitial extends UpgradeAccountState {
  @override
  String toString() => 'UpgradeAccountInitial';
}

class UpgradeAccountLoading extends UpgradeAccountState {
  @override
  String toString() => 'UpgradeAccountLoading';
}

class UpgradeAccountFailure extends UpgradeAccountState {
  final String error;

  UpgradeAccountFailure(this.error);

  @override
  String toString() => 'UpgradeAccountFailure { error: $error }';
}

class UpgradeAccountSuccess extends UpgradeAccountState {
  @override
  String toString() => 'UpgradeAccountSuccess';
}

class SendInterestSuccess extends UpgradeAccountState {
  @override
  String toString() => 'SendInterestSuccess';
}