import 'package:app_settings/app_settings.dart' as Settings;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:permission_handler/permission_handler.dart';

class ConditionWidget extends StatefulWidget {
  const ConditionWidget({Key? key}) : super(key: key);

  @override
  State<ConditionWidget> createState() => _ConditionWidgetState();
}

class _ConditionWidgetState extends State<ConditionWidget> {
  late BluetoothState bluetoothState = BluetoothState.unknown;

  @override
  void initState() {
    initSDK();
    super.initState();
  }

  initSDK() async {
    await Permission.location.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothAdvertise.request();
    await Permission.bluetoothConnect.request();

    // final String blueToothPermission =
    //     await _channel.invokeMethod('request_permission');

    // setState(() {
    //   isActive = blueToothPermission == 'ble_already';
    // });

    FlutterBluePlus.instance.state.listen((state) {
      setState(() {
        bluetoothState = state;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Điều kiện kết nối bắt buộc',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 15),
        Column(
          children: [
            Row(
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
                    R.icons.ic_bluetooth,
                    fit: BoxFit.scaleDown,
                    color: R.color.textDark,
                  ),
                ),
                SizedBox(width: 10),
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
                        if (bluetoothState != BluetoothState.on)
                          GestureDetector(
                            onTap: () async {
                              Settings.AppSettings.openBluetoothSettings();
                            },
                            child: Text(
                              "Bật Bluetooth",
                              style: TextStyle(
                                fontSize: 16,
                                color: R.color.mainColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                      ],
                    ),
                    Tooltip(
                      message: bluetoothState == BluetoothState.on
                          ? 'Đã bật Bluetooth'
                          : 'Chưa bật Bluetooth',
                      child: Container(
                        width: 20,
                        height: 20,
                        margin: EdgeInsets.only(left: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: bluetoothState == BluetoothState.on
                              ? Color(0xFF00B533)
                              : Color(0xFFB0B0B0),
                        ),
                        child: Center(
                          child: Icon(
                            bluetoothState == BluetoothState.on
                                ? Icons.check
                                : Icons.remove,
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
            SizedBox(height: 15), 
            Row(
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
                    R.icons.ic_bluetooth,
                    fit: BoxFit.scaleDown,
                    color: R.color.textDark,
                  ),
                ),
                SizedBox(width: 10),
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
                      ],
                    ),
                    Tooltip(
                      message: bluetoothState == BluetoothState.on
                          ? 'Đã bật Bluetooth'
                          : 'Chưa bật Bluetooth',
                      child: Container(
                        width: 20,
                        height: 20,
                        margin: EdgeInsets.only(left: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: bluetoothState == BluetoothState.on
                              ? Color(0xFF00B533)
                              : Color(0xFFB0B0B0),
                        ),
                        child: Center(
                          child: Icon(
                            bluetoothState == BluetoothState.on
                                ? Icons.check
                                : Icons.remove,
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
          ],
        ),
        SizedBox(
          height: 30,
          child: Divider(
            height: 2,
            color: Color(0xffF2F2F2),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hướng dẫn kết nối',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 15),
            _guideLineItem(),
          ],
        ),
      ],
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
