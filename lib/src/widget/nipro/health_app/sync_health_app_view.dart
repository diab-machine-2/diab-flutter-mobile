// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:health/health.dart';
// import 'package:medical/res/R.dart';
// import 'package:medical/src/app_setting/health_setting.dart';
// import 'package:medical/src/utils/app_storages.dart';
// import 'package:medical/src/widgets/block_bottom_sheet.dart';
// import 'package:medical/src/widgets/button_widget.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'blocs/healthApp_bloc.dart';

// class SyncHealthApp extends StatelessWidget {
//   const SyncHealthApp({Key? key}) : super(key: key);

//   static showModal(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       isDismissible: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => SyncHealthApp(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<HealthAppBloc>(
//       create: (_) => HealthAppBloc(),
//       child: BlockBottomSheet(
//         title: '',
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisSize: MainAxisSize.max,
//             children: [
//               BlocBuilder<HealthAppBloc, HealthAppState>(
//                   builder: (context, state) {
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: state.types.map(
//                     (item) {
//                       late String textItem;
//                       textItem = item.name.toString();
//                       switch (item) {
//                         case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
//                           break;
//                         case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
//                           // TODO: Handle this case.
//                           break;
//                         case HealthDataType.HEIGHT:
//                           // TODO: Handle this case.
//                           break;
//                         case HealthDataType.STEPS:
//                           // TODO: Handle this case.
//                           break;
//                         case HealthDataType.WEIGHT:
//                           // TODO: Handle this case.
//                           break;
//                         default:
//                           textItem = "";
//                           break;
//                       }
//                       return Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(textItem),
//                         ],
//                       );
//                     },
//                   ).toList(),
//                 );
//               }),
//               SizedBox(height: 105),
//               SizedBox(height: 25),
//               ButtonWidget(
//                 title: "Để sau",
//                 textColor: R.color.textDark,
//                 backgroundColor: R.color.grayBorder,
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//               ),
//               ButtonWidget(
//                 title: "Kết nối với Apple Health",
//                 textColor: R.color.white,
//                 backgroundColor: R.color.mainColor,
//                 onPressed: () async {
//                   bool? _hasPermission = await HealthSetting.instance
//                       .requestConnectionPermission();
//                   if (_hasPermission != null) {
//                     if (Platform.isAndroid) {
//                       await Permission.activityRecognition.request();
//                     }
//                     AppStorages.setHealthAppPermission(_hasPermission);
//                     print('_hasPermission: $_hasPermission');
//                     Navigator.pop(context);
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
