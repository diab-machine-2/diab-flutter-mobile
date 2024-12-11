import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widgets/app_bar_widget.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/normal_template.dart';
import 'package:permission_handler/permission_handler.dart';
import '../blocs/rocheConnection_cubit.dart';
import '../widgets/condition_widget.dart';
import 'scan_device_view.dart';

class DeviceDetailView extends StatelessWidget {
  final RocheConnectionCubit cubit;
  const DeviceDetailView({Key? key, required this.cubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NormalTemplate(
        footer: Container(
          margin: EdgeInsets.fromLTRB(15, 15, 15, 25),
          width: double.infinity,
          child: ButtonWidget(
              title: 'Kết nối thiết bị',
              onPressed: () async {
                await TrackingManager.trackEvent(
                  'glucose_pair_start',
                  'kpi_glucose_device',
                  params: {
                    'object_title': cubit.deviceInfo?.name,
                  },
                );
                _connectToDevice(context);
              }),
        ),
        appBar: AppBarWidget(
          title: 'Thiết bị kết nối & hướng dẫn',
        ),
        child: Column(
          children: [
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thiết bị kết nối',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Container(
                        height: 96,
                        width: 96,
                        padding: EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xffF2F2F2),
                          ),
                        ),
                        child: Image.asset(
                          cubit.deviceInfo!.image,
                          height: 100,
                          width: 100,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          cubit.deviceInfo!.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: Color(0xFFF4F5F6)),
            Padding(
              padding: EdgeInsets.all(15),
              child: ConditionWidget(
                deviceInfo: cubit.deviceInfo!,
                onConnectDevice: () async => _connectToDevice(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _connectToDevice(BuildContext context) async {
    final locationGranted = Platform.isIOS
        ? true
        : (await Permission.location.isGranted &&
            await Permission.location.serviceStatus.isEnabled);
    if (!locationGranted) {
      Message.showToastMessage(context, 'Bạn chưa bật vị trí');
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (ctx) => ScanDeviceView(cubit: cubit)));
    }
  }
}
