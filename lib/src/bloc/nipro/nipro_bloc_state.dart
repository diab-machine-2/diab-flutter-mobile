part of 'nipro_bloc.dart';

@immutable
abstract class NiproState extends Equatable {
  @override
  List<Object> get props => [];
}

class NiproStateInitial extends NiproState {}

class NiproStateListDevice extends NiproState {
  final List<NiproDevice> devices;
  final bool isScanning;

  NiproStateListDevice({required this.devices, required this.isScanning});

  NiproStateListDevice copyWith({
    List<NiproDevice>? devices,
    bool? isScanning,
  }) {
    return NiproStateListDevice(
      devices: devices ?? this.devices,
      isScanning: isScanning ?? this.isScanning,
    );
  }

  @override
  List<Object> get props => [devices, DateTime.now()];
}

class NiproStateConnectingDevice extends NiproState {
  final NiproDevice device;

  NiproStateConnectingDevice({required this.device});

  @override
  List<Object> get props => [device];
}

class NiproStateDeviceData extends NiproState {
  final List<GlucoseData> glucoseData;

  NiproStateDeviceData({required this.glucoseData});

  @override
  List<Object> get props => [glucoseData];
}

class NiproStateFailure extends NiproState {
  final String error;

  NiproStateFailure({required this.error});

  @override
  List<Object> get props => [error];
}
