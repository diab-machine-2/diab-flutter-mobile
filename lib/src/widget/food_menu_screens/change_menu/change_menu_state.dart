import 'package:equatable/equatable.dart';

abstract class ChangeMenuState extends Equatable {
  const ChangeMenuState() : super();

  @override
  List<Object> get props => [];
}

class ChangeMenuInitial extends ChangeMenuState {
  const ChangeMenuInitial();
  @override
  String toString() {
    return 'ChangeMenuInitial{}';
  }
}

class ChangeMenuFailure extends ChangeMenuState {
  final String? error;

  const ChangeMenuFailure(this.error);

  @override
  String toString() {
    return 'ChangeMenuFailure {error: $error}';
  }
}

class ChangeMenuSuccess extends ChangeMenuState {
  const ChangeMenuSuccess();
  @override
  String toString() {
    return 'ChangeMenuSuccess{}';
  }
}

class ChangeMenuLoading extends ChangeMenuState {
  const ChangeMenuLoading();
  @override
  String toString() {
    return 'ChangeMenuLoading{}';
  }
}

class ChangeMenuDone extends ChangeMenuState {
  const ChangeMenuDone();
  @override
  String toString() {
    return 'ChangeMenuDone{}';
  }
}