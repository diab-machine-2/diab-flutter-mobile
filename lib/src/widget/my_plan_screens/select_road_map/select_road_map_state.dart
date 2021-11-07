import 'package:equatable/equatable.dart';

abstract class SelectRoadMapState extends Equatable {
  const SelectRoadMapState() : super();

  @override
  List<Object> get props => [];
}

class SelectRoadMapInitial extends SelectRoadMapState {
  const SelectRoadMapInitial();
  @override
  String toString() {
    return 'SelectRoadMapInitial{}';
  }
}

class SelectRoadMapFailure extends SelectRoadMapState {
  final String? error;

  const SelectRoadMapFailure(this.error);

  @override
  String toString() {
    return 'SelectRoadMapFailure {error: $error}';
  }
}

class SelectRoadMapSuccess extends SelectRoadMapState {
  const SelectRoadMapSuccess();
  @override
  String toString() {
    return 'SelectRoadMapSuccess{}';
  }
}

class SelectRoadMapLoading extends SelectRoadMapState {
  const SelectRoadMapLoading();
  @override
  String toString() {
    return 'SelectRoadMapLoading{}';
  }
}

class SelectRoadMapChange extends SelectRoadMapState {
  const SelectRoadMapChange();
  @override
  String toString() {
    return 'SelectRoadMapChange{}';
  }
}
