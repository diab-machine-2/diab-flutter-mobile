import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:medical/src/bloc/nipro/model/nipro_device.dart';
import 'package:medical/src/bloc/nipro/nipro_bloc.dart';

class ListDevices extends StatelessWidget {
  final VoidCallback request;
  ListDevices({Key? key, required this.request}) : super(key: key);

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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
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
            Expanded(child: BlocBuilder<NiproBloc, NiproState>(
              builder: (context, state) {
                List<NiproDevice> savedDevices = [];
                List<NiproDevice> devices = [];
                bool isScanning = true;
                if (state is NiproStateListDevice) {
                  isScanning = state.isScanning;
                  savedDevices = state.devices.where((element) => element.saved).toList();
                  devices = state.devices.where((element) => !element.saved).toList();
                } else if (state is NiproStateFailure) {
                  isScanning = false;
                }
                return !isScanning && (savedDevices.length + devices.length == 0)
                    ? SingleChildScrollView(
                        child: Column(children: [
                          SizedBox(height: 32),
                          Image.asset(R.drawable.ic_no_device, height: 110),
                          SizedBox(height: 24),
                          Text('Không tìm thấy thiết bị',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 18),
                          Text(
                              'DiaB không tìm thấy thiết bị nào gần đây. Vui lòng kiểm tra lại thiết bị đã được bật chưa?',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Color(0xff8E8E8E))),
                          // Buttons
                          SafeArea(
                            top: false,
                            child: Container(
                                margin: EdgeInsets.all(16),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                            height: 48,
                                            width: 164,
                                            decoration: BoxDecoration(
                                              color: R.color.grayBorder,
                                              borderRadius: BorderRadius.circular(200),
                                            ),
                                            child: Center(
                                              child: Text('Hủy',
                                                  style: TextStyle(
                                                      color: R.color.black,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600)),
                                            )),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          request();
                                        },
                                        child: Container(
                                          height: 48,
                                          width: 164,
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
                                            child: Text('Thử lại',
                                                style: TextStyle(
                                                    color: R.color.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600)),
                                          ),
                                        ),
                                      ),
                                    ])),
                          ),
                        ]),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.all(0),
                                itemCount: savedDevices.length,
                                separatorBuilder: (context, index) =>
                                    Container(height: 1, color: R.color.grayBorder),
                                itemBuilder: (BuildContext context, int index) {
                                  final device = savedDevices[index];
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      index == 0 && savedDevices.length != 0
                                          ? Padding(
                                              padding: EdgeInsets.only(bottom: 16),
                                              child: Text('Máy đã kết nối',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xff8E8E8E),
                                                      fontWeight: FontWeight.w700)),
                                            )
                                          : SizedBox(),
                                      buildItem(context, device)
                                    ],
                                  );
                                }),
                            savedDevices.length + devices.length == 0
                                ? SizedBox()
                                : Container(
                                    height: 1,
                                    color: R.color.grayBorder,
                                    margin: EdgeInsets.only(bottom: 16)),
                            ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.all(0),
                                itemCount: devices.length,
                                separatorBuilder: (context, index) =>
                                    Container(height: 1, color: R.color.grayBorder),
                                itemBuilder: (BuildContext context, int index) {
                                  final device = devices[index];
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      index == 0 && devices.length != 0
                                          ? Padding(
                                              padding: EdgeInsets.only(bottom: 16),
                                              child: Text('Danh sách thiết bị khác',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xff8E8E8E),
                                                      fontWeight: FontWeight.w700)),
                                            )
                                          : SizedBox(),
                                      buildItem(context, device),
                                    ],
                                  );
                                }),
                            !isScanning
                                ? SizedBox()
                                : SpinKitFadingCircle(
                                    color: Colors.black,
                                    size: 20.0,
                                  )
                          ],
                        ),
                      );
              },
            )),
          ],
        ),
      ),
    ));
  }

  Widget buildItem(BuildContext context, NiproDevice device) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(device);
      },
      child: Container(
          height: 54,
          color: Colors.white,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(device.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  Text(device.address,
                      style: TextStyle(
                          color: R.color.grayCaption, fontSize: 14, fontWeight: FontWeight.w400))
                ],
              ),
            ],
          )),
    );
  }
}
