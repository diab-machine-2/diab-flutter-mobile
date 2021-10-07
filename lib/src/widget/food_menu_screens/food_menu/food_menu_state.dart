import 'package:equatable/equatable.dart';

abstract class FoodMenuState extends Equatable {
  const FoodMenuState() : super();

  @override
  List<Object> get props => [];
}

class FoodMenuInitial extends FoodMenuState {
  const FoodMenuInitial();
  @override
  String toString() {
    return 'FoodMenuInitial{}';
  }
}

class FoodMenuFailure extends FoodMenuState {
  final String? error;

  const FoodMenuFailure(this.error);

  @override
  String toString() {
    return 'FoodMenuFailure {error: $error}';
  }
}

class FoodMenuSuccess extends FoodMenuState {
  const FoodMenuSuccess();
  @override
  String toString() {
    return 'FoodMenuSuccess{}';
  }
}

class FoodMenuLoading extends FoodMenuState {
  const FoodMenuLoading();
  @override
  String toString() {
    return 'FoodMenuLoading{}';
  }
}

class FoodMenuEmpty extends FoodMenuState {
  const FoodMenuEmpty();
  @override
  String toString() {
    return 'FoodMenuEmpty{}';
  }
}