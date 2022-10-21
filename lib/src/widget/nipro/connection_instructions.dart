import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description_detail.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/nipro/list_data.dart';
import 'package:medical/src/widget/nipro/list_devices.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timelines/timelines.dart';
import 'package:app_settings/app_settings.dart' as Settings;
import 'dart:io' show Platform;

class ConnectionInstructionsController extends StatefulWidget {
  final bool? connectOnly;
  ConnectionInstructionsController({@required this.connectOnly});
  @override
  State<ConnectionInstructionsController> createState() =>
      _ConnectionInstructionsControllerState();
}

class _ConnectionInstructionsControllerState
    extends State<ConnectionInstructionsController> {
  MethodChannel _channel = const MethodChannel('iBleSdk');
  EventChannel messageChannel = const EventChannel('eventChannelStreamiBle');

  String userManual = '';

  GlobalKey<ListDevicesState> listDevicesKey = GlobalKey();
  GlobalKey<ListDataState> listDataKey = GlobalKey();

  bool initSuccess = false;
  bool isScanning = false;
  List<Map<String, String>> devices = [];
  String dataText = '';
  Map<String, String>? device;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    initSDK();
    loadHowToUse();
  }

  initSDK() async {
    messageChannel.receiveBroadcastStream().listen((result) async {
      final String event = result['event'];
      final mapData = result['data'];
      List<Map<String, String>> data = [];
      if (mapData != null && mapData is List) {
        data = mapData.map((e) => Map<String, String>.from(e)).toList();
      }

      dataText += (data.toString() + '/\/');
      setState(() {});
      // print(event.toString());
      // print(data);
      // showAboutDialog(context: context, applicationName: event);
      if (event == 'ble_off') {
      } else if (event == 'ble_already') {
      } else if (event == 'init_success') {
        BotToast.closeAllLoading();
      } else if (event == 'new_device' && data.length != 0) {
        BotToast.closeAllLoading();
        final savedDevices = AppSettings.getNiproDevices();
        savedDevices.forEach((element) {
          data.asMap().forEach((index, value) {
            if (element['address'] == value['address']) {
              data.removeAt(index);
            }
          });
        });
        devices = data;

        if (listDevicesKey.currentState != null) {
          listDevicesKey.currentState!.devices = devices;
          listDevicesKey.currentState!.setState(() {});
        }
      } else if (event == 'device_connected') {
        if (widget.connectOnly == null || !widget.connectOnly!) {
          _channel.invokeMethod('get_data');
        } else {
          BotToast.closeAllLoading();
          Message.showToastMessage(context, 'Kết nối thành công');
        }

        if (device != null) {
          List<Map<String, String>> savedDevices =
              AppSettings.getNiproDevices();
          bool exist = false;
          savedDevices.forEach((element) {
            if (element['address'] == device!['address']) {
              exist = true;
            }
          });
          if (!exist) {
            savedDevices.add(device!);
            AppSettings.saveNiproDevices(savedDevices);
          }
        }
      } else if (event == 'get_data_success' && data.length != 0) {
        BotToast.closeAllLoading();
        print(data);
        stopScan();
        if (listDataKey.currentState != null) {
          listDataKey.currentState!.glucoseData += data;
          listDataKey.currentState!.setState(() {});
        } else {
          showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(15))),
              backgroundColor: R.color.white,
              context: context,
              isScrollControlled: true,
              builder: (context) =>
                  ListData(key: listDataKey, glucoseData: data));
        }
      } else if (event == 'device_disconnect' ||
          event == 'connect_error' ||
          event == 'device_not_connect') {
        BotToast.closeAllLoading();
        devices = [];
        if (listDevicesKey.currentState != null) {
          listDevicesKey.currentState!.devices = devices;
          listDevicesKey.currentState!.setState(() {});
        }
        if (event == 'connect_error' || event == 'device_not_connect') {
          _showDialogConnectFaild(context);
        }
      } else if (event == 'is_scanning') {
        isScanning = true;
        if (listDevicesKey.currentState != null) {
          listDevicesKey.currentState!.isScanning = isScanning;
          listDevicesKey.currentState!.setState(() {});
        }
      } else if (event == 'stop_scan') {
        isScanning = false;
        if (listDevicesKey.currentState != null) {
          listDevicesKey.currentState!.isScanning = isScanning;
          listDevicesKey.currentState!.setState(() {});
        }
      }
    });
    _channel.invokeMethod('init_IBle_Sdk');
    await Permission.location.request();
  }

  startScan() {
    _timer?.cancel();
    _timer = new Timer.periodic(
      Duration(seconds: 1),
      (Timer timer) {
        if (timer.tick > 60) {
          stopScan();
        }
      },
    );
    isScanning = true;
    _channel.invokeMethod('start_scan');
  }

  stopScan() {
    _timer?.cancel();
    isScanning = true;
    _channel.invokeMethod('stop_scan');
  }

  loadHowToUse() async {
    try {
      BotToast.showLoading();
      userManual = await GlucoseClient().fetchUserManual();
      BotToast.closeAllLoading();
    } catch (e) {
      BotToast.closeAllLoading();
      print(e);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    //_channel.invokeMethod('destroy_sdk');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(R.drawable.bg_splash), fit: BoxFit.cover)),
        child: Column(
          children: [
            CustomAppBar(
                backgroundColor: R.color.transparent,
                title: Text('Hướng dẫn kết nối',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: R.color.textDark)),
                leadingIcon: IconButton(
                    splashColor: R.color.transparent,
                    highlightColor: R.color.transparent,
                    icon: Icon(Icons.arrow_back, color: R.color.textDark),
                    onPressed: () {
                      Navigator.pop(context);
                    })),
            Expanded(
              child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.only(top: 16),
                  children: [
                    Timeline.tileBuilder(
                      shrinkWrap: true,
                      padding: EdgeInsets.all(16),
                      physics: NeverScrollableScrollPhysics(),
                      builder: TimelineTileBuilder.connected(
                          itemCount: 3,
                          contentsBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  left: 10, bottom: index != 2 ? 32 : 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      index == 0
                                          ? 'Bật Bluetooth cho ứng dụng DiaB.'
                                          : index == 1
                                              ? 'Bật máy đo đường huyết.'
                                              : 'Chọn thiết bị trên app Diab và kết nối.',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 8),
                                  Text(
                                      index == 0
                                          ? 'Cho phép ứng dụng DiaB sử dụng Bluetooth để kết nối với máy đo đường huyết.'
                                          : index == 1
                                              ? 'Để ứng dụng DiaB có thể nhận dạng và kết nối máy.'
                                              : 'Sau khi bấm “Kết Nối” app DiaB sẽ hiển thị danh sách các thiết bị xung quanh có bật Bluetooth. Vui lòng chọn thiết bị đo đường huyết bạn muốn kết nối.',
                                      style: TextStyle(
                                          color: Color(0xff8E8E8E),
                                          fontSize: 14)),
                                  index != 0
                                      ? SizedBox()
                                      : Padding(
                                          padding: EdgeInsets.only(top: 10),
                                          child: GestureDetector(
                                            onTap: () async {
                                              final String blueToothPermission =
                                                  await _channel.invokeMethod(
                                                      'request_permission');

                                              if (blueToothPermission ==
                                                  'ble_already') {
                                                Message.showToastMessage(
                                                    context,
                                                    'Bluetooth đã được bật');
                                              } else {
                                                Settings.AppSettings
                                                    .openBluetoothSettings();
                                              }
                                            },
                                            child: Text('Bật Bluetooth',
                                                style: TextStyle(
                                                    color: R
                                                        .color.greenGradientTop,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        )
                                ],
                              ),
                            );
                          },
                          indicatorBuilder: (context, index) =>
                              // indexState != 0 && indexState <= index
                              //     ? Image.asset('assets/images/icon_step.png',
                              //         width: 24, height: 24)
                              //     :
                              Image.asset(
                                  index == 0
                                      ? R.drawable.ic_bluetooth
                                      : index == 1
                                          ? R.drawable.ic_glucose_meter
                                          : R.drawable.ic_clipboard,
                                  height: 32),
                          nodePositionBuilder: (context, index) => 0,
                          indicatorPositionBuilder: (context, index) => 0,

                          //itemExtentBuilder: (_, __) => 80,
                          connectorBuilder: (_, index, __) {
                            return SolidLineConnector(
                                color: R.color.greenGradientTop,
                                thickness: 0.75);
                          }),
                    ),
                    SizedBox(height: 32),
                    Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(left: 16, right: 16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(R.drawable.ic_lamp_charge, height: 24),
                            SizedBox(width: 10),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Bạn chưa biết cách bật Bluetooth?',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16)),
                                  SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () async {
                                      showDialog(
                                        barrierColor: R.color.color0xff003F38
                                            .withOpacity(0.8),
                                        useSafeArea: false,
                                        context: context,
                                        builder: (_) => DetailDescription(
                                            input: true,
                                            data: ShortGuiModel(
                                                content1: userManual,
                                                content2: userManual,
                                                content3: userManual,
                                                content4: userManual),
                                            title: 'Hướng dẫn bật Bluetooth'),
                                      );
                                    },
                                    child: Text('Hướng dẫn',
                                        style: TextStyle(
                                            color: R.color.greenGradientTop,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                  )
                                ])
                          ]),
                    )
                  ]),
            ),
            GestureDetector(
              onTap: () async {
                final String blueToothPermission =
                    await _channel.invokeMethod('request_permission');
                // !(await Permission.bluetooth.isPermanentlyDenied) &&
                //     await Permission.bluetooth.isGranted;
                final locationGranted = Platform.isIOS
                    ? true
                    : (await Permission.location.isGranted &&
                        await Permission.location.serviceStatus.isEnabled);
                if (blueToothPermission != 'ble_already') {
                  Message.showToastMessage(context, 'Bạn chưa bật Bluetooth');
                } else if (!locationGranted) {
                  Message.showToastMessage(context, 'Bạn chưa bật vị trí');
                } else {
                  // _channel.invokeMethod('request_permission');

                  startScan();
                  final result = await showModalBottomSheet(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(15))),
                      backgroundColor: R.color.white,
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => ListDevices(
                          key: listDevicesKey,
                          devices: devices,
                          request: () {
                            startScan();
                          }));
                  if (result != null) {
                    device = result;
                    BotToast.showLoading();
                    _channel.invokeMethod('connect', device!['address']);
                  }
                  stopScan();
                }
              },
              child: SafeArea(
                top: false,
                child: Container(
                    margin: EdgeInsets.all(16),
                    height: 48,
                    decoration: BoxDecoration(
                        color: R.color.mainColor,
                        borderRadius: BorderRadius.circular(200),
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.centerRight,
                            colors: [
                              R.color.greenGradientTop,
                              R.color.greenGradientBottom
                            ])),
                    child: Center(
                        child: Text('Kết nối',
                            style: TextStyle(
                                color: R.color.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16)))),
              ),
            )
          ],
        ),
      ),
    );
  }

  _showDialogConnectFaild(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
              contentPadding: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              content: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(R.drawable.ic_connect_faild, height: 170),
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Text('Kết nối thất bại',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 20,
                              fontWeight: FontWeight.w700)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                          'Bạn vui lòng bật Bluetooth của thiết bị lên để kết nối.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(0xff8E8E8E), fontSize: 16)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                          margin: EdgeInsets.only(top: 32),
                          height: 48,
                          decoration: BoxDecoration(
                              color: R.color.mainColor,
                              borderRadius: BorderRadius.circular(200),
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    R.color.greenGradientTop,
                                    R.color.greenGradientBottom
                                  ])),
                          child: Center(
                              child: Text('Đóng',
                                  style: TextStyle(
                                      color: R.color.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16)))),
                    ),
                  ],
                ),
              )),
        );
      },
    );
  }
}
