part of 'nipro_bloc.dart';

@immutable
abstract class NiproEvent {}

class NiproEventStartScan extends NiproEvent {
  NiproEventStartScan();
}

class NiproEventStopScan extends NiproEvent {
  NiproEventStopScan();
}

class NiproEventConnectDevice extends NiproEvent {
  final NiproDevice device;
  final bool connectOnly;

  NiproEventConnectDevice({required this.device, required this.connectOnly});
}
