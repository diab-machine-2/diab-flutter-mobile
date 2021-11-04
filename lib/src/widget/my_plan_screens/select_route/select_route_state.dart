import 'package:equatable/equatable.dart';

abstract class SelectRouteState extends Equatable {
  const SelectRouteState() : super();

  @override
  List<Object> get props => [];
}

class SelectRouteInitial extends SelectRouteState {
  const SelectRouteInitial();
  @override
  String toString() {
    return 'SelectRouteInitial{}';
  }
}

class SelectRouteFailure extends SelectRouteState {
  final String? error;

  const SelectRouteFailure(this.error);

  @override
  String toString() {
    return 'SelectRouteFailure {error: $error}';
  }
}

class SelectRouteSuccess extends SelectRouteState {
  const SelectRouteSuccess();
  @override
  String toString() {
    return 'SelectRouteSuccess{}';
  }
}

class SelectRouteLoading extends SelectRouteState {
  const SelectRouteLoading();
  @override
  String toString() {
    return 'SelectRouteLoading{}';
  }
}
