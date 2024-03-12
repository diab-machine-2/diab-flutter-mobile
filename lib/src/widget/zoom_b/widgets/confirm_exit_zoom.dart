// import 'package:flutter/material.dart';
// import 'package:medical/res/R.dart';

// class ConfirmExitZoom extends StatelessWidget {
//   final VoidCallback onSubmit;
//   const ConfirmExitZoom({Key? key, required this.onSubmit}) : super(key: key);

//   static showDialogConfirm(
//     BuildContext context, {
//     required VoidCallback onSubmit,
//   }) {
//     showDialog(
//         context: context,
//         builder: (context) => ConfirmExitZoom(
//               onSubmit: onSubmit,
//             ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       contentPadding: const EdgeInsets.all(0),
//       content: Stack(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Image.asset(R.drawable.ic_earse, width: 64, height: 64),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 16.0),
//                   child: Text('Thoát cuộc họp',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                           color: R.color.textDark,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600)),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 16.0),
//                   child: Text(
//                     "Bạn có chắc muốn thoát cuộc họp?",
//                     textAlign: TextAlign.center,
//                     style: R.style.normalTextStyle,
//                   ),
//                 ),
//                 Container(
//                   margin: const EdgeInsets.only(top: 25),
//                   child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               Navigator.pop(context);
//                             },
//                             child: Container(
//                                 height: 43,
//                                 decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(200),
//                                     color: R.color.grayBorder),
//                                 child: Center(
//                                   child: Text('Ở lại',
//                                       style: TextStyle(
//                                           color: R.color.textDark,
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w600)),
//                                 )),
//                           ),
//                         ),
//                         const SizedBox(width: 14),
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: onSubmit,
//                             child: Container(
//                               height: 43,
//                               decoration: BoxDecoration(
//                                 color: Color(0xFFAF0000),
//                                 borderRadius: BorderRadius.circular(200),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   "Vẫn thoát",
//                                   style: TextStyle(
//                                     color: R.color.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ]),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
