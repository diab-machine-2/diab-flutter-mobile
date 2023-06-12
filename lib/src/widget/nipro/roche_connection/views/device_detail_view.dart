import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widgets/app_bar_widget.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/normal_template.dart';
import '../blocs/rocheConnection_cubit.dart';
import '../widgets/condition_widget.dart';
import 'scan_device_view.dart';

class DeviceDetailView extends StatefulWidget {
  final RocheConnectionCubit cubit;
  const DeviceDetailView({Key? key, required this.cubit}) : super(key: key);
  @override
  State<DeviceDetailView> createState() => _DeviceDetailViewState();
}

class _DeviceDetailViewState extends State<DeviceDetailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NormalTemplate(
        footer: Container(
          margin: EdgeInsets.fromLTRB(15, 15, 15, 25),
          width: double.infinity,
          child: ButtonWidget(
            title: 'Kết nối thiết bị',
            onPressed: () {
              // showModalScanDevices(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (ctx) => ScanDeviceView(cubit: widget.cubit)));
            },
          ),
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
                          R.drawable.img_error,
                          height: 100,
                          width: 100,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          'Accu Chek Instant',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConditionWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
