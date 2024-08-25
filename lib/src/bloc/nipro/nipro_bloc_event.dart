part of 'nipro_bloc.dart';

@immutable
abstract class NiproEvent {}

class NiproEventFetchSavedDevice extends NiproEvent {
  NiproEventFetchSavedDevice();
}

class NiproEventStartScan extends NiproEvent {
  final bool isAutoConnect;
  NiproEventStartScan({this.isAutoConnect = false});
}

class NiproEventStopScan extends NiproEvent {
  NiproEventStopScan();
}

class NiproEventConnectDevice extends NiproEvent {
  final NiproDevice device;
  final bool connectOnly;

  NiproEventConnectDevice({required this.device, required this.connectOnly});
}
