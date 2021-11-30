import 'package:equatable/equatable.dart';

abstract class MyProgressState extends Equatable {
  const MyProgressState() : super();

  @override
  List<Object> get props => [];
}

class MyProgressInitial extends MyProgressState {
  const MyProgressInitial();
  @override
  String toString() {
    return 'MyProgressInitial{}';
  }
}

class MyProgressFailure extends MyProgressState {
  final String? error;

  const MyProgressFailure(this.error);

  @override
  String toString() {
    return 'MyProgressFailure {error: $error}';
  }
}

class MyProgressSuccess extends MyProgressState {
  const MyProgressSuccess();
  @override
  String toString() {
    return 'MyProgressSuccess{}';
  }
}

class MyProgressLoading extends MyProgressState {
  const MyProgressLoading();
  @override
  String toString() {
    return 'MyProgressLoading{}';
  }
}