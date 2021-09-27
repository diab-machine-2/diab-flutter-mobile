import 'package:equatable/equatable.dart';

abstract class ListServiceState extends Equatable {
  ListServiceState([List props = const []]) : super();

  @override
  // TODO: implement props
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

  ListServiceFailure(this.error);

  @override
  String toString() => 'ListServiceFailure { error: $error }';
}

class ListServiceSuccess extends ListServiceState {
  @override
  String toString() => 'ListServiceSuccess';
}