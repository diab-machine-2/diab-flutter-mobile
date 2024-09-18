// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/bloc/nipro/model/glucose_data.dart';
import 'package:medical/src/bloc/nipro/model/nipro_device.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/nipro/list_data.dart';
import 'package:medical/src/widget/nipro/roche_connection/roche_connection_view.dart';
import 'package:permission_handler/permission_handler.dart';

part 'nipro_bloc_event.dart';
part 'nipro_bloc_state.dart';

class NiproBloc extends Bloc<NiproEvent, NiproState> {
  final MethodChannel _channel = const MethodChannel('iBleSdk');
  final EventChannel _messageChannel = const EventChannel('eventChannelStreamiBle');
  StreamSubscription? _subscription;
  bool _initialized = false;

  NiproDevice? _connectedDevice;
  bool _connectOnly = false;
  bool _isAutoConnect = false;
  bool _isAutoConnectFoundDevice = false;
  final List<NiproDevice> _savedDevices = [];
  final List<NiproDevice> _devices = [];

  NiproBloc() : super(NiproStateInitial());

  @override
  Stream<NiproState> mapEventToState(
    NiproEvent event,
  ) async* {
    if (event is NiproEventFetchSavedDevice) {
      final savedDevices = AppSettings.getNiproDevices();
      if (savedDevices.length > 0) {
        _savedDevices.addAll(savedDevices
            .map((e) => NiproDevice(address: e['address']!, name: e['name']!, saved: true))
            .toList());
        _devices.addAll(_savedDevices);
        yield NiproStateListDevice(devices: _devices, isScanning: false);
      }
    } else if (event is NiproEventStartScan) {
      _devices.clear();
      _devices.addAll(_savedDevices);
      _isAutoConnect = event.isAutoConnect;
      _isAutoConnectFoundDevice = false;
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

  // Return any error?
  Future<String?> checkAndRequestPermission() async {
    String blueToothPermission = await requestPermission();

    final locationGranted = Platform.isIOS
        ? true
        : (await Permission.location.isGranted &&
            await Permission.location.serviceStatus.isEnabled);
    if (blueToothPermission != 'ble_already') {
      return 'Bạn chưa bật Bluetooth';
    } else if (!locationGranted) {
      return 'Bạn chưa bật vị trí';
    }
    // ok case
    return null;
  }

  void initialize() {
    // check for initialized to prevent multiple call
    if (_initialized) {
      return;
    }
    _initialized = true;

    // do init
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
          if (_isAutoConnect) {
            if (_isAutoConnectFoundDevice) {
              return;
            }
            if (data.length > 0) {
              int index = _savedDevices.indexWhere(
                (element) => element.address == data[0]['address'],
              );
              if (index != -1) {
                _isAutoConnectFoundDevice = true;
                add(NiproEventConnectDevice(device: _savedDevices[index], connectOnly: false));
              }
            }
            return;
          }
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
          emit(NiproStateListDevice(devices: [..._devices], isScanning: true));
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

  Future<bool> submitData(List<GlucoseData> input) {
    return GlucoseClient().postGlucoseInputs(input.map((e) => e.toJson()).toList());
  }

  void showListData(BuildContext context, List<GlucoseData> glucoseData) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) => ListData(glucoseData: glucoseData),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  // Nipro auto connect & get data
  void tryAutoConnect() async {
    void fallBackNavigate() {
      navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (BuildContext _) => RocheConnectionView()),
      );
    }

    final NiproBloc niproBloc = this;
    // start connect within 5s
    if (!niproBloc.haveSavedDevice()) {
      fallBackNavigate();
      return;
    }

    StreamSubscription? sub;
    bool haveDiscoverDevice = false;
    bool haveDiscoverData = false;
    final int timeout = 5;
    try {
      BotToast.showLoading();
      // init
      niproBloc.initialize();
      await Permission.location.request();
      await Permission.bluetoothScan.request();
      await Permission.bluetoothConnect.request();
      // listen for event
      sub = niproBloc.stream.listen((state) {
        if (state is NiproStateConnectingDevice) {
          haveDiscoverDevice = true;
          return;
        }
        // clear resource
        if (state is NiproStateFailure || state is NiproStateDeviceData) {
          BotToast.closeAllLoading();
          sub?.cancel();
          niproBloc.add(NiproEventStopScan());
        }
        // then navigate
        if (state is NiproStateFailure) {
          fallBackNavigate();
        } else if (state is NiproStateDeviceData) {
          haveDiscoverData = true;
          niproBloc.showListData(navigatorKey.currentContext!, state.glucoseData);
        }
      });

      String? anyError = await niproBloc.checkAndRequestPermission();
      if (anyError == null) {
        niproBloc.add(NiproEventStartScan(isAutoConnect: true));
        await Future.delayed(Duration(seconds: timeout));
      }
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    } finally {
      if (!haveDiscoverDevice) {
        sub?.cancel();
        BotToast.closeAllLoading();
        niproBloc.add(NiproEventStopScan());
        fallBackNavigate();
      } else {
        // Connecting device
        if (!haveDiscoverData) {
          // wait for 5s
          await Future.delayed(Duration(seconds: timeout));
          // then re-check
          if (!haveDiscoverData) {
            sub?.cancel();
            BotToast.closeAllLoading();
            niproBloc.add(NiproEventStopScan());
            fallBackNavigate();
          }
        }
      }
    }
  }
}
