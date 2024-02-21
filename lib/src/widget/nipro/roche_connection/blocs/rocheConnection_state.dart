import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';


@immutable
abstract class RocheConnectionState extends Equatable {
  const RocheConnectionState();

  @override
  List<Object> get props => [];
}

class RocheConnectionInitial extends RocheConnectionState {
  @override
  String toString() {
    return 'InitialRocheConnectionState{}';
  }
}

class DataUpdated extends RocheConnectionState {
  final List<Map<String, String>> glucosedList;
  DataUpdated(this.glucosedList);
  @override
  String toString() {
    return 'DateUpdated{}';
  }
}

class StatusUpdated extends RocheConnectionState {
  StatusUpdated();
  @override
  String toString() {
    return 'DateUpdated{}';
  }
}

class SyncDataSuccesed extends RocheConnectionState {
  SyncDataSuccesed();
  @override
  String toString() {
    return 'DateUpdated{}';
  }
}

class RocheConnectionLoading extends RocheConnectionState {
  @override
  String toString() {
    return 'RocheConnectionLoading{}';
  }
}

class RocheConnectionFailure extends RocheConnectionState {
  final String error;

  const RocheConnectionFailure(this.error);

  @override
  String toString() {
    return 'RocheConnectionFailure{error: $error}';
  }
}

class RocheConnectionSuccess extends RocheConnectionState {
  const RocheConnectionSuccess();
  @override
  String toString() {
    return 'RocheConnectionSuccess{}';
  }
}
