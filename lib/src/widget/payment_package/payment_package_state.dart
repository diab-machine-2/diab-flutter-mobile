import 'package:equatable/equatable.dart';

abstract class PaymentPackageState extends Equatable {
  PaymentPackageState([List props = const []]) : super();

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class PaymentPackageInitial extends PaymentPackageState {
  @override
  String toString() => 'PaymentPackageInitial';
}

class PaymentPackageLoading extends PaymentPackageState {
  @override
  String toString() => 'PaymentPackageLoading';
}

class PaymentPackageFailure extends PaymentPackageState {
  final String error;

  PaymentPackageFailure(this.error);

  @override
  String toString() => 'PaymentPackageFailure { error: $error }';
}

class PurchaseSuccess extends PaymentPackageState {
  @override
  String toString() => 'PurchaseSuccess';
}
