import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widgets/app_bar_widget.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/normal_template.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/condition_widget.dart';
import 'scan_device_view.dart';

class DeviceDetailView extends StatefulWidget {
  const DeviceDetailView({Key? key}) : super(key: key);
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
              showModalScanDevices(context);
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (ctx) => ScanDeviceView()));
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
                        child: Image.network(
                          'https://placehold.co/100x100',
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


  static void showModalScanDevices(
    BuildContext context, {
    Function? onConfirm,
  }) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      builder: (BuildContext ctx) => ScanDeviceView(),
    );
  }
}
