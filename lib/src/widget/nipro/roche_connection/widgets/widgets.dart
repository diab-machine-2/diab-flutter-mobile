// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:medical/res/R.dart';
// import 'package:medical/src/utils/app_media_query.dart';
// import 'package:medical/src/widget/nipro/roche_connection/views/scan_device_view.dart';
// import 'package:medical/src/widgets/button_widget.dart';
// import 'package:medical/src/widgets/custom_checkbox_widget.dart';

// Widget scanDeviceWidget() {
//   String title = 'Đang kết nối thiết bị ...';
//   Widget description = RichText(
//     textAlign: TextAlign.center,
//     text: TextSpan(
//       text: 'Hãy đảm bảo thiết bị kết nối đang ở trạng thái ',
//       style: R.style.normalTextStyle.copyWith(
//         color: Color(0xFF777E90),
//       ),
//       children: [
//         TextSpan(
//           text: '“Paring”',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ],
//     ),
//   );
//   if (appStatus == AppStatus.isSyncing) {
//     title = 'Đang thu thập dữ liệu';
//     description = Text('Xin vui lòng đợi trong giây lát');
//   }
//   return Column(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       _btnClose(),
//       Column(
//         children: [
//           Stack(
//             children: [
//               AnimatedBuilder(
//                 animation: _controller,
//                 builder: (BuildContext context, Widget? child) {
//                   _angle = -_controller.value * 2.0 * 3.1415;
//                   return Transform.rotate(
//                     angle: _angle,
//                     child: Image.asset(
//                       R.drawable.rada_effect,
//                     ),
//                   );
//                 },
//               ),
//               Positioned(
//                 top: 0,
//                 bottom: 0,
//                 right: 0,
//                 left: 0,
//                 child: Center(
//                   child: Image.asset(
//                     R.drawable.icon_bluetooth,
//                     width: 54,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 30),
//           Text(
//             title,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           Container(
//             margin: EdgeInsets.only(top: 15),
//             constraints: BoxConstraints(
//               maxWidth: 250,
//             ),
//             child: description,
//           ),
//         ],
//       ),
//       SizedBox(height: 40),
//     ],
//   );
// }

// Widget noDeviceFound() {
//   return Column(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       btnClose(),
//       Container(
//         constraints: BoxConstraints(
//             minHeight: AppMediaQuery.deviceHeigthAvailable - 100),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Column(
//               children: [
//                 Image.asset(
//                   R.drawable.img_error,
//                   width: 170,
//                 ),
//                 Text(
//                   'Không tìm thấy thiết bị',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Container(
//                   constraints: BoxConstraints(
//                     maxWidth: 281,
//                   ),
//                   child: Text(
//                     'Hãy đảm bảo thiết bị kết nối đang ở trạng thái “Paring”',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Color(0xFF777E90),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Column(
//               children: [
//                 SizedBox(
//                   height: 30,
//                   child: Divider(),
//                 ),
//                 ConditionWidget(),
//               ],
//             ),
//           ],
//         ),
//       ),
//       Container(
//         width: double.infinity,
//         child: ButtonWidget(
//           title: 'Kết nối lại',
//           onPressed: () {
//             FlutterBluePlus.instance
//                 .startScan(timeout: const Duration(seconds: 20));
//           },
//         ),
//       )
//     ],
//   );
// }

// Widget enterPinCode() {
//   return Column(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       _btnClose(),
//       Column(
//         children: [
//           Text(
//             "Nhập mã PIN",
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           SizedBox(height: 15),
//           RichText(
//             text: TextSpan(
//               style: TextStyle(fontSize: 15, color: R.color.textDark),
//               children: [
//                 TextSpan(
//                   text: 'Nhập mã PIN ở',
//                   style: TextStyle(
//                     fontSize: 15,
//                   ),
//                 ),
//                 TextSpan(
//                   text: ' 6 số ',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 TextSpan(
//                   text: 'ở ',
//                 ),
//                 TextSpan(
//                   text: 'phía sau màn hình',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 55),
//           Image.asset(
//             R.drawable.pin_example,
//           ),
//         ],
//       ),
//       Container(
//         width: double.infinity,
//         child: ButtonWidget(
//           title: 'Tôi đã hiểu',
//           onPressed: () {
//             connectDevice(device!);
//           },
//         ),
//       )
//     ],
//   );
// }

// Widget scanningWidget(AppStatus appStatus) {
//   return StreamBuilder<bool>(
//     stream: FlutterBluePlus.instance.isScanning,
//     initialData: false,
//     builder: (c, snapshot) {
//       if (snapshot.data!) {
//         return scanDeviceWidget();
//       } else {
//         if (appStatus == AppStatus.isConnecting) {
//           return enterPinCode();
//         } else {
//           return noDeviceFound();
//         }
//       }
//     },
//   );
// }

// Widget btnClose() {
//   return Align(
//     alignment: Alignment.topRight,
//     child: InkWell(
//       onTap: () async {
//         if (device != null) {
//           await device!.disconnect();
//         }
//         await FlutterBluePlus.instance.stopScan();
//         Navigator.pop(context);
//       },
//       child: Container(
//         height: 32,
//         width: 32,
//         margin: EdgeInsets.only(top: 15),
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Color(0xFF141416),
//         ),
//         child: Center(
//           child: Icon(
//             Icons.close,
//             size: 18,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     ),
//   );
// }

// Widget selectData() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           btnClose(),
//           Text(
//             "Kết nối thành công",
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           SizedBox(height: 5),
//           Text(
//             "Chọn chỉ số bạn muốn cập nhật lên ứng dụng",
//             style: TextStyle(
//               fontSize: 14,
//             ),
//           ),
//           SizedBox(height: 25),
//         ],
//       ),
//       StreamBuilder<List<GlucoseMeasurementRecord>>(
//         stream: glucoseStreamController.stream,
//         builder: (BuildContext context,
//             AsyncSnapshot<List<GlucoseMeasurementRecord>> snapshot) {
//           if (snapshot.hasData) {
//             List<GlucoseMeasurementRecord> dataList = snapshot.data!;
//             dataList.sort((a, b) => b.calendar!.compareTo(a.calendar!));
//             return Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: dataList.map((glucoseData) {
//                     int index = dataSelected.indexWhere(
//                         (element) => element.calendar == glucoseData.calendar);
//                     return ResultSyncData(
//                       glucoseData,
//                       isSelected: !index.isNegative,
//                       onTap: () {
//                         if (index.isNegative) {
//                           setState(() {
//                             dataSelected.add(glucoseData);
//                           });
//                         } else {
//                           setState(() {
//                             dataSelected.remove(glucoseData);
//                           });
//                         }
//                       },
//                     );
//                   }).toList(),
//                 ),
//               ),
//             );
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//       SizedBox(height: 15),
//       CustomCheckboxWidget(
//         isChecked: selectAllData,
//         onTap: () {
//           if (selectAllData) {
//             setState(() {
//               selectAllData = !selectAllData;
//               dataSelected = [];
//             });
//           } else {
//             setState(() {
//               selectAllData = !selectAllData;
//               dataSelected = []..addAll(glucoseMeasurementRecordList);
//             });
//           }
//         },
//         title: 'Chọn tất cả dữ liệu',
//       ),
//       Container(
//         margin: EdgeInsets.only(top: 25),
//         width: double.infinity,
//         child: ButtonWidget(
//           title: 'Xác nhận & Xem dữ liệu',
//           onPressed: () {
//             widget.cubit.submitSyncData(dataSelected);
//           },
//         ),
//       )
//     ],
//   );
// }
