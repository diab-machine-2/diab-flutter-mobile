// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/bloc/nipro/model/glucose_data.dart';
import 'package:medical/src/bloc/nipro/model/nipro_device.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:meta/meta.dart';

part 'nipro_bloc_event.dart';
part 'nipro_bloc_state.dart';

class NiproBloc extends Bloc<NiproEvent, NiproState> {
  final MethodChannel _channel = const MethodChannel('iBleSdk');
  final EventChannel _messageChannel = const EventChannel('eventChannelStreamiBle');
  late StreamSubscription _subscription;

  NiproDevice? _connectedDevice;
  bool _connectOnly = false;
  final List<NiproDevice> _savedDevices = [];
  final List<NiproDevice> _devices = [];

  NiproBloc() : super(NiproStateInitial()) {
    final savedDevices = AppSettings.getNiproDevices();
    if (savedDevices.length > 0) {
      _savedDevices.addAll(savedDevices
          .map((e) => NiproDevice(address: e['address']!, name: e['name']!, saved: true))
          .toList());
      _devices.addAll(_savedDevices);
    }
    _subscription = _messageChannel.receiveBroadcastStream().listen((result) async {
      final String event = result['event'];
      final mapData = result['data'];
      List<Map<String, String>> data = [];
      if (mapData != null && mapData is List) {
        data = mapData.map((e) => Map<String, String>.from(e)).toList();
      }

      switch (event) {
        case 'ble_off':
        case 'ble_already':
        case 'init_success':
          // just log
          print('event: $event\ndata: $data');
          break;
        case 'new_device':
          // TODO:
          // parse to NiproDevice
          for (int i = 0; i < data.length; i++) {
            if (_devices.indexWhere((element) => element.address == data[i]['address']) == -1) {
              _devices.add(NiproDevice(
                address: data[i]['address']!,
                name: data[i]['name']!,
                saved: false,
              ));
            }
          }
          // emit event
          emit(NiproStateListDevice(devices: _devices, isScanning: true));
          break;
        case 'device_connected':
          if (!_connectOnly) {
            _channel.invokeMethod('get_data');
          }
          // or ???
          // then still state -> NiproStateConnectingDevice

          // store as saved device
          if (_connectedDevice != null) {
            final savedDevices = AppSettings.getNiproDevices();
            if (savedDevices
                    .indexWhere((element) => element['address'] == _connectedDevice!.address) ==
                -1) {
              savedDevices
                  .add({'address': _connectedDevice!.address, 'name': _connectedDevice!.name});
              AppSettings.saveNiproDevices(savedDevices);
              _savedDevices.insert(0, _connectedDevice!);
            }
          }
          break;
        case 'get_data_success':
          final List<GlucoseData> glucoseData = data.map((e) {
            return GlucoseData(
              glucose: e['glucose']!,
              date: e['date']!,
            );
          }).toList();
          if (state is NiproStateDeviceData) {
            final currentData = (state as NiproStateDeviceData).glucoseData;
            emit(NiproStateDeviceData(glucoseData: [...currentData, ...glucoseData]));
          } else {
            emit(NiproStateDeviceData(glucoseData: glucoseData));
          }
          break;
        case 'device_disconnect':
        case 'connect_error':
        case 'device_not_connect':
          // TODO:
          _devices.clear();
          if (event == 'connect_error' || event == 'device_not_connect') {
            // emit error
            emit(NiproStateFailure(error: 'Connect error'));
          }
          break;
        case 'is_scanning':
          // Scanning
          break;
        case 'stop_scan':
          // Stop scanning
          break;

        default:
          break;
      }
    });
  }

  @override
  Stream<NiproState> mapEventToState(
    NiproEvent event,
  ) async* {
    if (event is NiproEventStartScan) {
      _devices.clear();
      _devices.addAll(_savedDevices);
      _channel.invokeMethod('start_scan');
      yield NiproStateListDevice(devices: _devices, isScanning: true);
    } else if (event is NiproEventStopScan) {
      _channel.invokeMethod('stop_scan');
      yield NiproStateListDevice(devices: _devices, isScanning: false);
    } else if (event is NiproEventConnectDevice) {
      _connectedDevice = event.device;
      _connectOnly = event.connectOnly;
      _channel.invokeMethod('connect', event.device.address);
      yield NiproStateConnectingDevice(device: event.device);
    }
  }

  Future<String> requestPermission() async {
    return await _channel.invokeMethod('request_permission');
  }

  void initialize() {
    _channel.invokeMethod('init_IBle_Sdk');
  }

  bool haveSavedDevice() {
    return _savedDevices.length > 0;
  }

  Future<List<GlucoseData>> removeSyncedData(List<GlucoseData> input) async {
    final apiResult = await GlucoseClient().fetchGlucoseInputNotExist(input);
    final List<GlucoseData> result = [];
    apiResult.forEach((element) {
      result.add(
        GlucoseData(
          glucose: element['glucose'].toString(),
          date: element['createDate'].toString(),
        ),
      );
    });
    return result;
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
