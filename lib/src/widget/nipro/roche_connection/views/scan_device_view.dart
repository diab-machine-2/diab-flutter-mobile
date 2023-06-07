import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/app_media_query.dart';
import 'package:medical/src/widgets/button_widget.dart';

import '../widgets/condition_widget.dart';
import '../widgets/scan_result.dart';

class ScanDeviceView extends StatefulWidget {
  const ScanDeviceView({Key? key}) : super(key: key);

  @override
  State<ScanDeviceView> createState() => _ScanDeviceViewState();
}

class _ScanDeviceViewState extends State<ScanDeviceView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<ScanResult> resultList = [];

  @override
  void initState() {
    startScan();
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  startScan() {
    FlutterBluePlus.instance.startScan(timeout: const Duration(seconds: 2));

    FlutterBluePlus.instance.scanResults.listen((scanResultList) {
      print(scanResultList.length);
    });
    // if (scanResultList.isNotEmpty) {
      //   setState(() {
      //     resultList = scanResultList;
      //   });
      // }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _angle = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
            vertical: AppMediaQuery.deviceSafeAreaTop, horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF141416),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                if (resultList.isNotEmpty)
                  StreamBuilder<bool>(
                    stream: FlutterBluePlus.instance.isScanning,
                    initialData: false,
                    builder: (c, snapshot) {
                      if (snapshot.data!) {
                        return Column(
                          children: [
                            Stack(
                              children: [
                                AnimatedBuilder(
                                  animation: _controller,
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    _angle = -_controller.value * 2.0 * 3.1415;
                                    return Transform.rotate(
                                      angle: _angle,
                                      child: Image.asset(
                                        R.drawable.rada_effect,
                                      ),
                                    );
                                  },
                                ),
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  right: 0,
                                  left: 0,
                                  child: Center(
                                    child: Image.asset(
                                      R.drawable.icon_bluetooth,
                                      width: 54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            Text(
                              'Đang kết nối thiết bị ...',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 15),
                              constraints: BoxConstraints(
                                maxWidth: 250,
                              ),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text:
                                      'Hãy đảm bảo thiết bị kết nối đang ở trạng thái ',
                                  style: R.style.normalTextStyle.copyWith(
                                    color: Color(0xFF777E90),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '“Paring”',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Container(
                          constraints: BoxConstraints(
                              minHeight:
                                  AppMediaQuery.deviceHeigthAvailable - 100),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Không tìm thấy thiết bị',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Hãy đảm bảo thiết bị kết nối đang ở trạng thái “Paring”',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF777E90),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  SizedBox(height: 25),
                                  ConditionWidget(),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(15, 15, 15, 25),
                                width: double.infinity,
                                child: ButtonWidget(
                                  title: 'Kết nối lại',
                                  onPressed: () {
                                    FlutterBluePlus.instance.startScan(
                                        timeout: const Duration(seconds: 2));
                                  },
                                ),
                              )
                            ],
                          ),
                        );
                      }
                    },
                  ),
                StreamBuilder<List<ScanResult>>(
                  stream: FlutterBluePlus.instance.scanResults,
                  initialData: const [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data!.map(
                      (r) {
                        if (r.device.name == '' ||
                            !r.device.name.contains('meter')) return SizedBox();
                        return ScanResultWidget(
                          result: r,
                          onTap: () async {
                            r.device.connect();
                            // await connectToDevice(r.device);
                            // await reconnectToDevice();
                            // Connect
                            // Navigator.of(context)
                            //     .push(MaterialPageRoute(builder: (context) {
                            // return DeviceDetailScreen(device: r.device);
                            // return SensorPage(device: r.device);
                            // }));
                          },
                        );
                      },
                    ).toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 34),
          ],
        ),
      ),
    );
  }

  connectToDevice() {}
}
