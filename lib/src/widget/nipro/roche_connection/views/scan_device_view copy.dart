// import 'dart:async';

// import 'package:bot_toast/bot_toast.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:flutter_observer/Observable.dart';
// import 'package:medical/res/R.dart';
// import 'package:medical/src/app_setting/app_setting.dart';
// import 'package:medical/src/repo/glucose/glucose_client.dart';
// import 'package:medical/src/utils/app_log.dart';
// import 'package:medical/src/utils/app_media_query.dart';
// import 'package:medical/src/utils/const.dart';
// import 'package:medical/src/utils/date_utils.dart';
// import 'package:medical/src/utils/navigator_name.dart';
// import 'package:medical/src/widget/helper/helper.dart';
// import 'package:medical/src/widget/helper/show_message.dart';
// import 'package:medical/src/widget/nipro/roche_connection/widgets/result_sync_data.dart';
// import 'package:medical/src/widgets/button_widget.dart';
// import 'package:medical/src/widgets/custom_checkbox_widget.dart';
// import '../blocs/rocheConnection_cubit.dart';
// import '../blocs/rocheConnection_state.dart';
// import '../data/models/GlucoseMeasurementRecord.dart';
// import '../data/models/glucose_config.dart';
// import '../data/models/glucose_functions.dart';
// import '../widgets/condition_widget.dart';
// import '../widgets/result_sync_data_new.dart';

// enum AppStatus {
//   isScanning,
//   isConnected,
//   isConnecting,
//   isSyncing,
//   isSyncCompleted
// }

// class ScanDeviceView extends StatefulWidget {
//   final RocheConnectionCubit cubit;
//   const ScanDeviceView({Key? key, required this.cubit}) : super(key: key);

//   @override
//   State<ScanDeviceView> createState() => _ScanDeviceViewState();
// }

// class _ScanDeviceViewState extends State<ScanDeviceView>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   List<ScanResult> resultList = [];
//   BluetoothDevice? device;
//   bool selectAllData = false;
//   AppStatus appStatus = AppStatus.isScanning;
//   // StreamController<List<GlucoseMeasurementRecord>> glucoseStreamController =
//   //     StreamController<List<GlucoseMeasurementRecord>>();

//   List<GlucoseMeasurementRecord> glucoseMeasurementRecordList = [];
//   List<GlucoseMeasurementRecord> dataSelected = [];
//   List<Map<String, String>> selectedGlucose = [];
//   List<Map<String, String>> glucosedList = [];

//   @override
//   void initState() {
//     startScan();
//     super.initState();
//     _controller = AnimationController(
//       duration: Duration(seconds: 3),
//       vsync: this,
//     )..repeat();
//   }

//   @override
//   void dispose() {
//     if (device != null) {
//       device!.disconnect();
//     }
//     _controller.dispose();
//     // glucoseStreamController.close();
//     super.dispose();
//   }

//   double _angle = 0.0;

//   @override
//   Widget build(BuildContext context) {
//     late Widget returnWidget;
//     Console.log('appStatus', appStatus);
//     switch (appStatus) {
//       case AppStatus.isScanning:
//         returnWidget = _scanningWidget();
//         break;
//       case AppStatus.isConnected:
//         returnWidget = _scanDeviceWidget();
//         break;
//       case AppStatus.isSyncing:
//         // if (glucoseMeasurementRecordList.isEmpty) {
//         //   returnWidget = _noDataWidget();
//         // } else {
//         returnWidget = _scanDeviceWidget();
//         // }
//         break;
//       case AppStatus.isConnecting:
//         returnWidget = _enterPinCode();
//         break;
//       case AppStatus.isSyncCompleted:
//         returnWidget = _selectData();
//         break;
//     }
//     return BlocProvider(
//       create: (context) => widget.cubit,
//       child: Scaffold(
//         body: Padding(
//           padding: EdgeInsets.symmetric(
//             vertical: AppMediaQuery.deviceSafeAreaTop,
//             horizontal: 15,
//           ),
//           child: BlocConsumer<RocheConnectionCubit, RocheConnectionState>(
//             listener: (context, state) async {
//               if (state is DataUpdated) {
//                 print('DataUpdated');
//                 setState(() {
//                   selectAllData = true;
//                   glucosedList = state.glucosedList;
//                   appStatus = AppStatus.isSyncCompleted;
//                   selectedGlucose = [...state.glucosedList];
//                 });
//               }
//               if (state is SyncDataSuccesed) {
//                 Observable.instance.notifyObservers([],
//                     notifyName: Const.NAVIGATE_TO_PROFILE_TAB);
//                 Navigator.of(context).popUntil(
//                     (route) => route.settings.name == NavigatorName.tabbar);
//                 Navigator.pushNamed(context, NavigatorName.detail_blood_sugar);
//                 Message.showToastMessage(
//                     context, "Đồng bộ chỉ số đường huyết thành công!");
//                 Future.delayed(Duration(minutes: 3)).then((value) => Observable
//                     .instance
//                     .notifyObservers([], notifyName: "glucose_change_data"));
//               }
//               if (state is RocheConnectionFailure) {
//                 Message.showToastMessage(context, state.error);
//               }
//             },
//             builder: (context, state) {
//               if (state is RocheConnectionLoading) {
//                 BotToast.showLoading();
//               } else {
//                 BotToast.closeAllLoading();
//               }
//               return returnWidget;
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _btnClose() {
//     return Align(
//       alignment: Alignment.topRight,
//       child: InkWell(
//         onTap: () async {
//           if (device != null) {
//             await device!.disconnect();
//           }
//           await FlutterBluePlus.instance.stopScan();
//           Navigator.pop(context);
//         },
//         child: Container(
//           height: 32,
//           width: 32,
//           margin: EdgeInsets.only(top: 15),
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: Color(0xFF141416),
//           ),
//           child: Center(
//             child: Icon(
//               Icons.close,
//               size: 18,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _selectData() {
//     glucosedList.sort(((a, b) {
//       return int.parse(b['date']!).compareTo(int.parse(a['date']!));
//     }));
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _btnClose(),
//             Text(
//               "Kết nối thành công",
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             SizedBox(height: 5),
//             Text(
//               "Chọn chỉ số bạn muốn cập nhật lên ứng dụng",
//               style: TextStyle(
//                 fontSize: 14,
//               ),
//             ),
//             SizedBox(height: 25),
//           ],
//         ),
//         // List<Map<String, String>> dataList = glucosedList;
//         // dataList.sort((a, b) => b.calendar!.compareTo(a.calendar!));
//         Expanded(
//           child: SingleChildScrollView(
//             child: Column(
//               children: glucosedList.map((glucoseData) {
//                 return ResultSyncDataNew(
//                   glucoseData,
//                   isSelected: isSelected(glucoseData),
//                   onTap: () {
//                     if (isSelected(glucoseData)) {
//                       selectedGlucose.remove(glucoseData);
//                     } else {
//                       selectedGlucose.add(glucoseData);
//                     }
//                     setState(() {});
//                   },
//                 );
//               }).toList(),
//             ),
//           ),
//         ),
//         // StreamBuilder<List<GlucoseMeasurementRecord>>(
//         //   stream: glucoseStreamController.stream,
//         //   builder: (BuildContext context,
//         //       AsyncSnapshot<List<GlucoseMeasurementRecord>> snapshot) {
//         //     if (snapshot.hasData) {
//         //       List<GlucoseMeasurementRecord> dataList = snapshot.data!;
//         //       dataList.sort((a, b) => b.calendar!.compareTo(a.calendar!));
//         //       return Expanded(
//         //         child: SingleChildScrollView(
//         //           child: Column(
//         //             children: dataList.map((glucoseData) {
//         //               int index = dataSelected.indexWhere((element) =>
//         //                   element.calendar == glucoseData.calendar);
//         //               return ResultSyncData(
//         //                 glucoseData,
//         //                 isSelected: !index.isNegative,
//         //                 onTap: () {
//         //                   if (index.isNegative) {
//         //                     setState(() {
//         //                       dataSelected.add(glucoseData);
//         //                     });
//         //                   } else {
//         //                     setState(() {
//         //                       dataSelected.remove(glucoseData);
//         //                     });
//         //                   }
//         //                 },
//         //               );
//         //             }).toList(),
//         //           ),
//         //         ),
//         //       );
//         //     } else {
//         //       return Center(child: CircularProgressIndicator());
//         //     }
//         //   },
//         // ),
//         SizedBox(height: 15),
//         CustomCheckboxWidget(
//           isChecked: selectAllData,
//           onTap: () {
//             if (selectAllData) {
//               setState(() {
//                 selectedGlucose = [];
//                 selectAllData = !selectAllData;
//               });
//             } else {
//               setState(() {
//                 selectAllData = !selectAllData;
//                 selectedGlucose = [...glucosedList];
//               });
//             }
//           },
//           title: 'Chọn tất cả dữ liệu',
//         ),
//         Container(
//           margin: EdgeInsets.only(top: 25),
//           width: double.infinity,
//           child: ButtonWidget(
//             title: 'Xác nhận & Xem dữ liệu',
//             onPressed: () {
//               widget.cubit.submitSyncDataNew(selectedGlucose);
//             },
//           ),
//         )
//       ],
//     );
//   }

//   Widget _scanDeviceWidget() {
//     String title = 'Đang kết nối thiết bị ...';
//     Widget description = RichText(
//       textAlign: TextAlign.center,
//       text: TextSpan(
//         text: 'Hãy đảm bảo thiết bị kết nối đang ở trạng thái ',
//         style: R.style.normalTextStyle.copyWith(
//           color: Color(0xFF777E90),
//         ),
//         children: [
//           TextSpan(
//             text: '“Paring”',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//     if (appStatus == AppStatus.isSyncing) {
//       title = 'Đang thu thập dữ liệu';
//       description = Text('Xin vui lòng đợi trong giây lát');
//     }
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         _btnClose(),
//         Column(
//           children: [
//             Stack(
//               children: [
//                 AnimatedBuilder(
//                   animation: _controller,
//                   builder: (BuildContext context, Widget? child) {
//                     _angle = -_controller.value * 2.0 * 3.1415;
//                     return Transform.rotate(
//                       angle: _angle,
//                       child: Image.asset(
//                         R.drawable.rada_effect,
//                       ),
//                     );
//                   },
//                 ),
//                 Positioned(
//                   top: 0,
//                   bottom: 0,
//                   right: 0,
//                   left: 0,
//                   child: Center(
//                     child: Image.asset(
//                       R.drawable.icon_bluetooth,
//                       width: 54,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 30),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             Container(
//               margin: EdgeInsets.only(top: 15),
//               constraints: BoxConstraints(
//                 maxWidth: 250,
//               ),
//               child: description,
//             ),
//           ],
//         ),
//         SizedBox(height: 40),
//       ],
//     );
//   }

//   Widget _noDeviceFound() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         _btnClose(),
//         Container(
//           constraints: BoxConstraints(
//               minHeight: AppMediaQuery.deviceHeigthAvailable - 100),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Column(
//                 children: [
//                   Image.asset(
//                     R.drawable.img_error,
//                     width: 170,
//                   ),
//                   Text(
//                     'Không tìm thấy thiết bị',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   Container(
//                     constraints: BoxConstraints(
//                       maxWidth: 281,
//                     ),
//                     child: Text(
//                       'Hãy đảm bảo thiết bị kết nối đang ở trạng thái “Paring”',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Color(0xFF777E90),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Column(
//                 children: [
//                   SizedBox(
//                     height: 30,
//                     child: Divider(),
//                   ),
//                   ConditionWidget(),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         Container(
//           width: double.infinity,
//           child: ButtonWidget(
//             title: 'Kết nối lại',
//             onPressed: () {
//               FlutterBluePlus.instance
//                   .startScan(timeout: const Duration(seconds: 20));
//             },
//           ),
//         )
//       ],
//     );
//   }

//   Widget _enterPinCode() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         _btnClose(),
//         Column(
//           children: [
//             Text(
//               "Nhập mã PIN",
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             SizedBox(height: 15),
//             RichText(
//               text: TextSpan(
//                 style: TextStyle(fontSize: 15, color: R.color.textDark),
//                 children: [
//                   TextSpan(
//                     text: 'Nhập mã PIN ở',
//                     style: TextStyle(
//                       fontSize: 15,
//                     ),
//                   ),
//                   TextSpan(
//                     text: ' 6 số ',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   TextSpan(
//                     text: 'ở ',
//                   ),
//                   TextSpan(
//                     text: 'phía sau màn hình',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 55),
//             Image.asset(
//               R.drawable.pin_example,
//             ),
//           ],
//         ),
//         Container(
//           width: double.infinity,
//           child: ButtonWidget(
//             title: 'Tôi đã hiểu',
//             onPressed: () {
//               connectDevice(device!);
//             },
//           ),
//         )
//       ],
//     );
//   }

//   Widget _scanningWidget() {
//     return StreamBuilder<bool>(
//       stream: FlutterBluePlus.instance.isScanning,
//       initialData: false,
//       builder: (c, snapshot) {
//         if (snapshot.data!) {
//           return _scanDeviceWidget();
//         } else {
//           if (appStatus == AppStatus.isConnecting) {
//             return _enterPinCode();
//           } else {
//             return _noDeviceFound();
//           }
//         }
//       },
//     );
//   }

//   startScan() async {
//     List<BluetoothDevice> connectedDevices =
//         await FlutterBluePlus.instance.connectedDevices;
//     connectedDevices.forEach((element) {
//       element.disconnect();
//     });

//     FlutterBluePlus.instance.startScan(timeout: const Duration(seconds: 25));
//     FlutterBluePlus.instance.scanResults.listen((scanResultList) {
//       if (appStatus == AppStatus.isScanning) {
//         connectToAvailableDevice(scanResultList);
//       }
//     });
//   }

//   Future checkConnectionStatus() async {
//     List<BluetoothDevice> connectedDevices =
//         await FlutterBluePlus.instance.connectedDevices;

//     Console.log('length', connectedDevices.length);
//     connectedDevices.forEach((element) {
//       Console.log('name', element.name);
//     });
//   }

//   connectToAvailableDevice(List<ScanResult> scanResultList) async {
//     // scanResultList.forEach((result) async {
//     // if (result.device.name.contains('meter+')) {
//     // List<BluetoothDevice> connectedDevices =
//     //     await FlutterBluePlus.instance.connectedDevices;
//     // if (connectedDevices.contains(result.device)) {
//     //   setState(() {
//     //     device = result.device;
//     //     appStatus = AppStatus.isConnecting;
//     //   });
//     //   await FlutterBluePlus.instance.stopScan();
//     //   return;
//     // } else {
//     //     await result.device.connect();
//     //     appStatus = AppStatus.isConnecting;
//     //     await FlutterBluePlus.instance.stopScan();
//     //     return;
//     //     // }
//     //   }
//     // });

//     scanResultList.forEach((result) async {
//       if (result.device.name.contains('meter')) {
//         Console.log('device name', result.device.name);
//         await result.device.connect();
//         device = result.device;
//         appStatus = AppStatus.isConnecting;
//         await FlutterBluePlus.instance.stopScan();
//         return;
//       }
//     });
//   }

//   Future<void> connectDevice(BluetoothDevice deviceFounded) async {
//     List<BluetoothService> services = await deviceFounded.discoverServices();

//     // Tìm Service 0x1808
//     BluetoothService serviceGlucoseMeasurement = services.firstWhere((service) {
//       return service.uuid.toString() ==
//           GlucoseProfileConfiguration.GLUCOSE_SERVICE_UUID;
//     });

//     // Tim Characteristic 0x2A18
//     BluetoothCharacteristic charGlucoseMeasurement =
//         serviceGlucoseMeasurement.characteristics.firstWhere((characteristic) =>
//             characteristic.uuid.toString() ==
//             GlucoseProfileConfiguration
//                 .GLUCOSE_MEASUREMENT_CHARACTERISTIC_UUID);

//     // Bật noti cho 0x2A18
//     await charGlucoseMeasurement.setNotifyValue(true);

//     await Future.delayed(Duration(milliseconds: 300));

//     appStatus = AppStatus.isConnected;

//     for (BluetoothCharacteristic characteristic
//         in serviceGlucoseMeasurement.characteristics) {
//       // Tim Characteristic 0x2A18
//       if (characteristic.uuid.toString() ==
//           GlucoseProfileConfiguration.GLUCOSE_MEASUREMENT_CHARACTERISTIC_UUID) {
//         await characteristic.setNotifyValue(true);
//         setState(() {
//           appStatus = AppStatus.isSyncing;
//           glucoseMeasurementRecordList = [];
//         });
//         // List<GlucoseMeasurementRecord> glucoseDataList = [];
//         characteristic.value.listen((data) async {
//           GlucoseMeasurementRecord glucoseMeasurementRecord =
//               GlucoseFunctions().readDataFrom2A18(data);
//           // dataSelected.add(glucoseMeasurementRecord);
//           glucoseMeasurementRecordList.add(glucoseMeasurementRecord);
//           // List<GlucoseMeasurementRecord> glucoseDataListCopy =
//           //     List.from(glucoseMeasurementRecordList);
//           // glucoseStreamController.sink.add(glucoseDataListCopy);
//         });
//       }

//       // Tim Characteristic 0x2A52
//       if (characteristic.uuid.toString() ==
//           GlucoseProfileConfiguration
//               .RECORD_ACCESS_CONTROL_POINT_CHARACTERISTIC_UUID) {
//         await characteristic.setNotifyValue(true);
//         List<int> requestData = [0x01, 0x01];
//         await characteristic.write(requestData);
//         await Future.delayed(Duration(seconds: 2));
//         fetchGlucoseInputNotExist(glucoseMeasurementRecordList);
//       }
//     }

//     // for (BluetoothCharacteristic characteristic
//     //     in serviceGlucoseMeasurement.characteristics) {
//     //   // Tim Characteristic 0x2A18
//     //   if (characteristic.uuid.toString() ==
//     //       GlucoseProfileConfiguration.GLUCOSE_MEASUREMENT_CHARACTERISTIC_UUID) {
//     //     setState(() {
//     //       appStatus = AppStatus.isSyncing;
//     //     });
//     //     // List<GlucoseMeasurementRecord> glucoseDataList = [];
//     //     // characteristic.value.listen((data) async {
//     //     //   GlucoseMeasurementRecord glucoseMeasurementRecord =
//     //     //       GlucoseFunctions().readDataFrom2A18(data);
//     //     //   glucoseDataList.add(glucoseMeasurementRecord);
//     //     //   List<GlucoseMeasurementRecord> glucoseDataListCopy =
//     //     //       List.from(glucoseDataList);
//     //     //   Console.log("PHUONG", glucoseDataListCopy);
//     //     //   glucoseStreamController.sink.add(glucoseDataListCopy                                                                                                            );
//     //     // });
//     //   }
//     // }
//   }

//   bool isSelected(Map<String, String> glucose) {
//     bool isSelected = false;
//     selectedGlucose.forEach((element) {
//       if (element['glucose'] == glucose['glucose'] &&
//           element['date'] == glucose['date']) {
//         isSelected = true;
//       }
//     });
//     return isSelected;
//   }

//   Future<void> fetchGlucoseInputNotExist(
//       List<GlucoseMeasurementRecord> dataSelected) async {
//     List<Map<String, String>> glucoseDataList = [];
//     List<Map<String, String>> glucoseDataRequest = [];
//     bool isMilligramPerDeciliter = AppSettings.userInfo!.glucoseUnit == 1;

//     dataSelected.forEach((element) {
//       final glucose = roundAsFixed(isMilligramPerDeciliter
//           ? roundDouble(element
//               .convertGlucoseConcentrationValueToMilligramsPerDeciliter())
//           : roundDouble(element
//                   .convertGlucoseConcentrationValueToMilligramsPerDeciliter()) /
//               Const.mmollToMgdlFactor);
//       glucoseDataRequest.add({
//         'glucose': glucose.toString(),
//         'date': DateUtil.getDayInMillis(element.calendar!).toString(),
//       });
//     });

//     final result =
//         await GlucoseClient().fetchGlucoseInputNotExist(glucoseDataRequest);

//     result.forEach((element) {
//       glucoseDataList.add({
//         'glucose': element['glucose'].toString(),
//         'date': element['createDate'].toString()
//       });
//     });
//     Console.log(
//         'glucoseDataRequest ${glucoseDataRequest.length}', glucoseDataRequest);
//     Console.log('fetchGlucoseInputNotExist ${result.length}', result);
//     setState(() {
//       selectAllData = true;
//       glucosedList = glucoseDataList;
//       appStatus = AppStatus.isSyncCompleted;
//       selectedGlucose = [...glucoseDataList];
//     });
//   }
// }
