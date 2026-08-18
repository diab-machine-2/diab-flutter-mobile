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
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/nipro/list_data.dart';
import 'package:medical/src/widget/nipro/roche_connection/roche_connection_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:medical/src/widget/helper/helper.dart';

part 'nipro_bloc_event.dart';
part 'nipro_bloc_state.dart';

class NiproBloc extends Bloc<NiproEvent, NiproState> {
  final MethodChannel _channel = const MethodChannel('iBleSdk');
  final EventChannel _messageChannel =
      const EventChannel('eventChannelStreamiBle');
  StreamSubscription? _subscription;
  bool _initialized = false;

  NiproDevice? _connectedDevice;
  bool _connectOnly = false;
  bool _isAutoConnect = false;
  bool _isAutoConnectFoundDevice = false;
  final List<NiproDevice> _savedDevices = [];
  final List<NiproDevice> _devices = [];

  List<TimeFrameModel> _timeFrames = [];
  bool _timeFramesLoaded = false;

  /// The server's glucose TimeFrame list (id/code/name), loaded once a
  /// device sync has run. Used by ListData to display the trước ăn/sau ăn
  /// label matching each record's `timeFrameId`.
  List<TimeFrameModel> get timeFrames => _timeFrames;

  NiproBloc() : super(NiproStateInitial());

  /// Loads the server's glucose TimeFrame list (id/code/name) once, so
  /// Nipro device-synced records can resolve `timeFrameId` the same way
  /// the Accu-Chek/Roche sync flow does.
  Future<void> _ensureTimeFramesLoaded() async {
    if (_timeFramesLoaded) return;
    try {
      _timeFrames = await GlucoseClient().fetchFlucoseTimeFrameV2();
      _timeFramesLoaded = true;
    } catch (e) {
      print('NiproSync: failed to load glucose timeframes: $e');
    }
  }

  /// Maps the iBLE SDK's raw meal-context flags (from BLE Glucose
  /// Measurement Context characteristic 0x2A34) to the server's TimeFrame
  /// `code` (see `/app/TimeFrame/Glucose`). Mirrors
  /// `GlucoseMeasurementRecord.timeFrameCode()` used for Accu-Chek.
  String? _mealTimeFrameCode(Map<String, String> raw) {
    // Android path: iBLE.jar decodes 0x2A34 into these int flags directly.
    final flagFasting = int.tryParse(raw['flag_fasting'] ?? '') ?? 0;
    final flagMeal = int.tryParse(raw['flag_meal'] ?? '') ?? 0;
    if (flagFasting == 1) return 'Prd16'; // Fasting - đường huyết đói
    if (flagMeal == -1) return 'Prd17'; // Preprandial - trước ăn
    if (flagMeal == 1) return 'Prd18'; // Postprandial - sau ăn

    // iOS path: ibtFramework exposes meal-context as a free-form `Meal`
    // string (via receivedContext(_:)) instead of int flags, and its
    // actual runtime values haven't been observed yet (no real iOS device
    // tested). Deliberately NOT mapped to a timeFrameId yet to avoid
    // guessing wrong and mis-tagging real readings — log it so the first
    // iOS sync test tells us the real values to map here.
    final meal = raw['meal'];
    if (meal != null && meal.isNotEmpty) {
      debugPrint('NiproSync: unmapped iOS meal value "$meal" — needs calibration');
    }
    return null;
  }

  String? _resolveTimeFrameId(String? code) {
    if (code == null) return null;
    for (final timeFrame in _timeFrames) {
      if (timeFrame.code == code) return timeFrame.id;
    }
    return null;
  }

  @override
  Stream<NiproState> mapEventToState(
    NiproEvent event,
  ) async* {
    if (event is NiproEventFetchSavedDevice) {
      final savedDevices = AppSettings.getNiproDevices();
      if (savedDevices.length > 0) {
        _savedDevices.addAll(savedDevices
            .map((e) => NiproDevice(
                address: e['address']!, name: e['name']!, saved: true))
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
    _subscription =
        _messageChannel.receiveBroadcastStream().listen((result) async {
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
                add(NiproEventConnectDevice(
                    device: _savedDevices[index], connectOnly: false));
              }
            }
            return;
          }
          // parse to NiproDevice
          for (int i = 0; i < data.length; i++) {
            if (_devices.indexWhere(
                    (element) => element.address == data[i]['address']) ==
                -1) {
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
            if (savedDevices.indexWhere((element) =>
                    element['address'] == _connectedDevice!.address) ==
                -1) {
              savedDevices.add({
                'address': _connectedDevice!.address,
                'name': _connectedDevice!.name
              });
              AppSettings.saveNiproDevices(savedDevices);
              _savedDevices.insert(0, _connectedDevice!);
            }
          }
          break;
        case 'get_data_success':
          for (final e in data) {
            debugPrint('NiproSync raw record: $e');
          }
          await _ensureTimeFramesLoaded();
          debugPrint(
              'NiproSync loaded ${_timeFrames.length} timeframes: '
              '${_timeFrames.map((t) => '${t.code}=${t.id}').join(', ')}');

          // Drop SDK-fabricated orphan records: when a meal-context (0x2A34)
          // packet arrives for a sequence number with no matching glucose
          // measurement, the SDK synthesizes an empty record with
          // glucoseData=0 and time=0 instead of a real reading. These would
          // otherwise sync as fake zero readings dated 1970-01-01.
          final validData = data.where((e) {
            final time = int.tryParse(e['date'] ?? '') ?? 0;
            final isOrphan = time == 0;
            if (isOrphan) {
              debugPrint('NiproSync dropping orphan record: $e');
            }
            return !isOrphan;
          }).toList();

          final List<GlucoseData> glucoseData = validData.map((e) {
            final rawGlucose = double.parse(e['glucose']!);
            final calibratedGlucose = roundAsFixed(roundDouble(calibrateDeviceGlucose(rawGlucose)));
            final mealCode = _mealTimeFrameCode(e);
            final timeFrameId = _resolveTimeFrameId(mealCode);
            debugPrint(
                'NiproSync record seq=${e['sequenceNumber']} date=${e['date']} '
                'glucose=${e['glucose']} flag_meal=${e['flag_meal']} '
                'flag_fasting=${e['flag_fasting']} flag_context=${e['flag_context']} '
                '=> mealCode=$mealCode timeFrameId=$timeFrameId');
            return GlucoseData(
              glucose: calibratedGlucose.toString(),
              date: e['date']!,
              timeFrameId: timeFrameId,
            );
          }).toList();
          if (state is NiproStateDeviceData) {
            final currentData = (state as NiproStateDeviceData).glucoseData;
            emit(NiproStateDeviceData(
                glucoseData: [...currentData, ...glucoseData]));
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
      // The GlucoseInputsNotExist API only echoes back glucose/createDate —
      // it never carries timeFrameId (not sent in the request either), so
      // rebuilding GlucoseData purely from the response would silently drop
      // any timeFrameId the device sync already resolved. Recover it from
      // the original input instead, matched by glucose+date.
      final glucose = double.tryParse(element['glucose'].toString()) ?? 0;
      final date = int.tryParse(element['createDate'].toString()) ?? 0;
      GlucoseData? matched;
      for (final e in input) {
        if (e.glucose == glucose && e.date == date) {
          matched = e;
          break;
        }
      }
      result.add(
        matched ??
            GlucoseData(
              glucose: element['glucose'].toString(),
              date: element['createDate'].toString(),
            ),
      );
    });
    return result;
  }

  Future<bool> submitData(List<GlucoseData> input) {
    return GlucoseClient().postGlucoseInputs(
        input.map((e) => e.toJson()).toList(),
        modelName: 'Nipro Premier α',
        modelNumber: '1');
  }

  void showListData(BuildContext context, List<GlucoseData> glucoseData) async {
    await TrackingManager.trackEvent(
      'glucose_pair',
      'kpi_glucose_device',
      params: {
        'status': 'success',
      },
    );
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
          niproBloc.showListData(
              navigatorKey.currentContext!, state.glucoseData);
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
