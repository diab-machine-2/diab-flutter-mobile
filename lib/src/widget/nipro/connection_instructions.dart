import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/nipro/model/nipro_device.dart';
import 'package:medical/src/bloc/nipro/nipro_bloc.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description_detail.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
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
  State<ConnectionInstructionsController> createState() => _ConnectionInstructionsControllerState();
}

class _ConnectionInstructionsControllerState extends State<ConnectionInstructionsController> {
  String userManual = '';

  Timer? _timer;
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _initSDK();
    _loadHowToUse();
  }

  void _initSDK() async {
    // listen failed connect
    final bloc = BlocProvider.of<NiproBloc>(context);
    _subscription = bloc.stream.listen((state) {
      if (state is NiproStateFailure) {
        BotToast.closeAllLoading();
        _showDialogConnectFaild(context);
      } else if (state is NiproStateDeviceData) {
        // Download data success
        BotToast.closeAllLoading();
        showModalBottomSheet(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          ),
          backgroundColor: R.color.white,
          context: context,
          isScrollControlled: true,
          builder: (context) => ListData(glucoseData: state.glucoseData),
        );
      }
    });

    bloc.initialize();
    await Permission.location.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();

    if (bloc.haveSavedDevice()) {
      _showPopupStartScan();
    }
  }

  void _startScan() {
    _timer?.cancel();
    _timer = new Timer.periodic(
      Duration(seconds: 1),
      (Timer timer) {
        if (timer.tick > 60) {
          _stopScan();
        }
      },
    );
    BlocProvider.of<NiproBloc>(context).add(NiproEventStartScan());
  }

  void _stopScan() {
    _timer?.cancel();
    BlocProvider.of<NiproBloc>(context).add(NiproEventStopScan());
  }

  void _loadHowToUse() async {
    try {
      BotToast.showLoading();
      userManual = await GlucoseClient().fetchUserManual();
      BotToast.closeAllLoading();
    } catch (e, stack) {
      BotToast.closeAllLoading();
      TrackingManager.recordError(e, stack);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(R.drawable.bg_splash), fit: BoxFit.cover)),
        child: Column(
          children: [
            CustomAppBar(
                backgroundColor: R.color.transparent,
                title: Text('Hướng dẫn kết nối',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600, color: R.color.textDark)),
                leadingIcon: IconButton(
                    splashColor: R.color.transparent,
                    highlightColor: R.color.transparent,
                    icon: Icon(Icons.arrow_back, color: R.color.textDark),
                    onPressed: () {
                      Navigator.pop(context);
                    })),
            Expanded(
              child: ListView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                              padding: EdgeInsets.only(left: 10, bottom: index != 2 ? 32 : 0),
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
                                      style: TextStyle(color: Color(0xff8E8E8E), fontSize: 14)),
                                  index != 0
                                      ? SizedBox()
                                      : Padding(
                                          padding: EdgeInsets.only(top: 10),
                                          child: GestureDetector(
                                            onTap: () async {
                                              String blueToothPermission =
                                                  await BlocProvider.of<NiproBloc>(context)
                                                      .requestPermission();

                                              if (blueToothPermission == 'ble_already') {
                                                Message.showToastMessage(
                                                    context, 'Bluetooth đã được bật');
                                              } else {
                                                Settings.AppSettings.openAppSettings(
                                                    type: Settings.AppSettingsType.bluetooth);
                                              }
                                            },
                                            child: Text('Bật Bluetooth',
                                                style: TextStyle(
                                                    color: R.color.greenGradientTop,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold)),
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
                                color: R.color.greenGradientTop, thickness: 0.75);
                          }),
                    ),
                    SizedBox(height: 32),
                    Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(left: 16, right: 16),
                      decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Image.asset(R.drawable.ic_lamp_charge, height: 24),
                        SizedBox(width: 10),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Bạn chưa biết cách bật Bluetooth?',
                              style: TextStyle(color: Colors.black, fontSize: 16)),
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              showDialog(
                                barrierColor: R.color.color0xff003F38.withOpacity(0.8),
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
              onTap: _showPopupStartScan,
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
                            colors: [R.color.greenGradientTop, R.color.greenGradientBottom])),
                    child: Center(
                        child: Text('Kết nối',
                            style: TextStyle(
                                color: R.color.white, fontWeight: FontWeight.w600, fontSize: 16)))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPopupStartScan() async {
    String blueToothPermission = await BlocProvider.of<NiproBloc>(context).requestPermission();

    final locationGranted = Platform.isIOS
        ? true
        : (await Permission.location.isGranted &&
            await Permission.location.serviceStatus.isEnabled);
    if (blueToothPermission != 'ble_already') {
      Message.showToastMessage(context, 'Bạn chưa bật Bluetooth');
    } else if (!locationGranted) {
      Message.showToastMessage(context, 'Bạn chưa bật vị trí');
    } else {
      _startScan();
      final result = await showModalBottomSheet(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          ),
          backgroundColor: R.color.white,
          context: context,
          isScrollControlled: true,
          builder: (context) => ListDevices(request: () {
                _startScan();
              }));
      if (result != null && result is NiproDevice) {
        BotToast.showLoading();
        BlocProvider.of<NiproBloc>(context)
            .add(NiproEventConnectDevice(device: result, connectOnly: widget.connectOnly!));
      }
      _stopScan();
    }
  }

  void _showDialogConnectFaild(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
              contentPadding: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
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
                              color: R.color.textDark, fontSize: 20, fontWeight: FontWeight.w700)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text('Bạn vui lòng bật Bluetooth của thiết bị lên để kết nối.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xff8E8E8E), fontSize: 16)),
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
                                  colors: [R.color.greenGradientTop, R.color.greenGradientBottom])),
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
