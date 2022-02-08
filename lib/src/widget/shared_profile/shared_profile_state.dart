import 'package:equatable/equatable.dart';

abstract class SharedProfileState extends Equatable {
  const SharedProfileState() : super();

  @override
  List<Object> get props => [];
}

class SharedProfileInitial extends SharedProfileState {
  const SharedProfileInitial();
  @override
  String toString() {
    return 'SharedProfileInitial{}';
  }
}

class SharedProfileFailure extends SharedProfileState {
  final String? error;

  const SharedProfileFailure(this.error);

  @override
  String toString() {
    return 'SharedProfileFailure {error: $error}';
  }
}

class SharedProfileSuccess extends SharedProfileState {
  const SharedProfileSuccess();
  @override
  String toString() {
    return 'SharedProfileSuccess{}';
  }
}

class SharedProfileLoading extends SharedProfileState {
  const SharedProfileLoading();
  @override
  String toString() {
    return 'SharedProfileLoading{}';
  }
}
