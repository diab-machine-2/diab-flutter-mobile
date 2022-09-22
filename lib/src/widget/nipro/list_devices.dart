import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/res/R.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class ListDevices extends StatefulWidget {
  ListDevices();
  @override
  _ListDevicesState createState() => _ListDevicesState();
}

class _ListDevicesState extends State<ListDevices> {
  MethodChannel _channel = const MethodChannel('iBleSdk');
  EventChannel messageChannel = const EventChannel('eventChannelStreamiBle');

  List<Map<String, String>> devices = [];

  List<Map<String, String>> glucoses = [];

  @override
  void initState() {
    super.initState();
    initSDK();
  }

  initSDK() async {
    messageChannel.receiveBroadcastStream().listen((event) async {
      print(event.toString());
      if (event is String && event == 'init_success') {
        final result = await _channel.invokeMethod('startScan', {});
        print(result);
      } else if (event is List && event.length != 0) {
        devices = [];
        event.forEach((element) {
          devices.add(Map<String, String>.from(element));
        });
        setState(() {});
      } else if (event is String && event == 'CallbackReadDeviceInfo') {
      } else if (event is Map) {
        if (event['data'] != null && event['data'] is List) {
          event['data'].forEach((element) {
            glucoses.add(Map<String, String>.from(element));
          });
          Message.showToastMessage(context, glucoses.toString());
        }
      }
    });
    final result = await _channel.invokeMethod('initIBleSdk', {});
    print(result);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
        child: Container(
      height: height / 2,
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Chọn thiết bị để kết nối',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 24,
                    width: 24,
                    child: Image.asset(R.drawable.ic_close),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(0),
                  itemCount: devices.length,
                  separatorBuilder: (context, index) =>
                      Container(height: 1, color: R.color.grayBorder),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        _channel.invokeMethod(
                            'connect', devices[index]['address']);
                        // _channel.invokeMethod('getData', {});
                      },
                      child: Container(
                          height: 54,
                          color: Colors.white,
                          child: Row(
                            children: [
                              Text('Nipro Premier a',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                            ],
                          )),
                    );
                  }),
            ),
          ],
        ),
      ),
    ));
  }
}
