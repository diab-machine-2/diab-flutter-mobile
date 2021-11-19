import 'package:equatable/equatable.dart';

abstract class ListServiceState extends Equatable {
  const ListServiceState();

  @override
  List<Object> get props => [];
}

class ListServiceInitial extends ListServiceState {
  @override
  String toString() => 'ListServiceInitial';
}

class ListServiceLoading extends ListServiceState {
  @override
  String toString() => 'ListServiceLoading';
}

class ListServiceFailure extends ListServiceState {
  final String error;

  const ListServiceFailure(this.error);

  @override
  String toString() => 'ListServiceFailure { error: $error }';
}

class ListServiceSuccess extends ListServiceState {
  @override
  String toString() => 'ListServiceSuccess';
}