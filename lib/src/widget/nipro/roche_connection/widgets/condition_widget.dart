import 'dart:io';
import 'package:app_settings/app_settings.dart' as Settings;
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/nipro/roche_connection/views/guideline_view.dart';
import 'package:medical/src/widgets/block_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/models/device_info_model.dart';

class ConditionWidget extends StatefulWidget {
  final DeviceInfoModel deviceInfo;
  final Function? onConnectDevice;
  const ConditionWidget({
    Key? key,
    required this.deviceInfo,
    this.onConnectDevice,
  }) : super(key: key);

  @override
  State<ConditionWidget> createState() => _ConditionWidgetState();
}

class _ConditionWidgetState extends State<ConditionWidget> {
  bool isBlueOn = false;

  @override
  void initState() {
    initSDK();
    _checkDeviceBluetoothIsOn();
    super.initState();
  }

  initSDK() async {
    final locationGranted = Platform.isIOS
        ? true
        : (await Permission.location.isGranted &&
            await Permission.location.serviceStatus.isEnabled);

    if (!locationGranted) {
      await Permission.location.request();
    }

    await Permission.bluetoothScan.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothAdvertise.request();
    await Permission.bluetoothConnect.request();
  }

  Future<void> _checkDeviceBluetoothIsOn() async {
    bool _isBlueOn = false;
    try {
      final state = await FlutterBluePlus.adapterState.first;
      _isBlueOn = state == BluetoothAdapterState.on;
    } catch (e) {}
    setState(() {
      isBlueOn = _isBlueOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothAdapterState>(
        stream: FlutterBluePlus.adapterState,
        initialData: BluetoothAdapterState.unknown,
        builder: (context, snapshot) {
          bool isDiviceOn = snapshot.data == BluetoothAdapterState.on || isBlueOn;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Điều kiện kết nối bắt buộc',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 37,
                    height: 37,
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Color(0xFFF4F5F6),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(5),
                    child: SvgPicture.asset(
                      R.icons.ic_bluetooth,
                      fit: BoxFit.scaleDown,
                      color: R.color.textDark,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Đảm bảo',
                              style: R.style.normalTextStyle,
                              children: [
                                TextSpan(
                                  text: ' Bluetooth điện thoại ',
                                  style: TextStyle(
                                    color: R.color.textDark,
                                    fontSize: 14,
                                  ),
                                ),
                                TextSpan(
                                  text: 'đang bật.',
                                  style: TextStyle(
                                    color: R.color.textDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          if (!isDiviceOn)
                            GestureDetector(
                              onTap: () async {
                                if (Platform.isAndroid) {
                                  FlutterBluePlus.turnOn();
                                } else {
                                  Settings.AppSettings
                                      .openAppSettings(type: Settings.AppSettingsType.bluetooth);
                                }
                              },
                              child: Text(
                                "Bật Bluetooth",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: R.color.mainColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        margin: EdgeInsets.only(left: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDiviceOn
                              ? Color(0xFF00B533)
                              : Color(0xFFB0B0B0),
                        ),
                        child: Center(
                          child: Icon(
                            isDiviceOn ? Icons.check : Icons.remove,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Container(
                    width: 37,
                    height: 37,
                    decoration: BoxDecoration(
                      color: Color(0xFFF4F5F6),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(5),
                    child: SvgPicture.asset(
                      R.icons.ic_bluetooth,
                      fit: BoxFit.scaleDown,
                      color: R.color.textDark,
                    ),
                  ),
                  SizedBox(width: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Đảm bảo',
                          style: R.style.normalTextStyle,
                          children: [
                            TextSpan(
                              text: ' Bluetooth App ',
                              style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: 'đang bật.',
                              style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 14,
                              ),
                            )
                          ],
                        ),
                      ),
                      Tooltip(
                        message: isDiviceOn
                            ? 'Đã bật Bluetooth'
                            : 'Chưa bật Bluetooth',
                        child: Container(
                          width: 20,
                          height: 20,
                          margin: EdgeInsets.only(left: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDiviceOn
                                ? Color(0xFF00B533)
                                : Color(0xFFB0B0B0),
                          ),
                          child: Center(
                            child: Icon(
                              isDiviceOn ? Icons.check : Icons.remove,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 30,
                child: Divider(
                  height: 2,
                  color: Color(0xffF2F2F2),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (widget.deviceInfo.name.contains('Guide')) {
                    _showAccuCheckGuidGuideline(context);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => GuidelineView(
                          deviceInfo: widget.deviceInfo,
                          onConnectDevice: () {
                            if (widget.onConnectDevice != null) {
                              widget.onConnectDevice!();
                            }
                          },
                        ),
                      ),
                    );
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hướng dẫn kết nối',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 15),
                    _guideLineItem(),
                  ],
                ),
              ),
            ],
          );
        });
  }

  _showAccuCheckGuidGuideline(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlockBottomSheet(
        title: 'Chọn lần hướng dẫn',
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _itemNavigationWidget(
                label: 'Kết nối lần đầu',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => GuidelineView(
                        deviceInfo: widget.deviceInfo,
                        onConnectDevice: () {
                          if (widget.onConnectDevice != null) {
                            widget.onConnectDevice!();
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
              _itemNavigationWidget(
                label: 'Đồng bộ dữ liệu',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => GuidelineView(
                        deviceInfo: guideReconnection,
                        onConnectDevice: () {
                          if (widget.onConnectDevice != null) {
                            widget.onConnectDevice!();
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  _itemNavigationWidget({
    required String label,
    required GestureTapCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE6E8EC)))),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: R.color.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _guideLineItem() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Color(0xFFF4F5F6),
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(5),
            child: SvgPicture.asset(
              R.icons.ic_docs,
              fit: BoxFit.scaleDown,
              color: R.color.textDark,
            ),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Máy đo đường huyết ở chế độ ',
                  style: R.style.normalTextStyle,
                  children: [
                    TextSpan(
                      text: '“Paring”',
                      style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  text: 'Hướng dẫn bật ',
                  style: R.style.normalTextStyle.copyWith(
                    color: R.color.mainColor,
                  ),
                  children: [
                    TextSpan(
                      text: 'Paring',
                      style: TextStyle(
                        color: R.color.mainColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
