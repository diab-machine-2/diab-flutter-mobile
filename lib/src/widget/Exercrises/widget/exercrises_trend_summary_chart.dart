// import 'dart:math';

// import 'package:bot_toast/bot_toast.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:medical/res/R.dart';
// import 'package:medical/src/app_setting/app_setting.dart';
// import 'package:medical/src/bloc/exercrises/exercrises_bloc.dart';
// import 'package:medical/src/modal/exercrises/exercrise_trend_calo.dart';
// import 'package:medical/src/modal/exercrises/exercrise_trend_sumary.dart';
// import 'package:medical/src/repo/exercrises/exercrises_client.dart';
// import 'package:medical/src/repo/user/user_client.dart';
// import 'package:medical/src/utils/app_log.dart';
// import 'package:medical/src/utils/navigator_name.dart';
// import 'package:medical/src/widget/Exercrises/exercrises_detail_tabbar.dart';
// import 'package:medical/src/widget/HbA1C/hba1c_tabble.dart';
// import 'package:medical/src/widget/helper/helper.dart';
// import 'package:medical/src/widget/helper/show_message.dart';
// import 'package:medical/src/modal/error/error_model.dart';
// import 'package:medical/src/widget/tabbar/tabbar_v2.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:medical/src/widgets/empty_data_box.dart';

// import '../../../widgets/network_image_widget.dart';

// class ExercrisesSummaryChart extends StatefulWidget {
//   ExercrisesSummaryChart({Key? key}) : super(key: key);

//   @override
//   ExercrisesSummaryChartState createState() => ExercrisesSummaryChartState();
// }

// class ExercrisesSummaryChartState extends State<ExercrisesSummaryChart>
//     with AutomaticKeepAliveClientMixin<ExercrisesSummaryChart> {
//   @override
//   bool get wantKeepAlive => true;
//   late BuildContext currentContext;
//   int periodFilterType = 1;

//   int? touchIndex;

//   @override
//   void initState() {
//     final controller = ExercrisesDetailTabbarController.of(context);
//     if (controller != null) {
//       periodFilterType = controller.periodFilterType;
//     } else {
//       Console.log('ExercrisesDetailTabbarController is null');
//     }
//     super.initState();
//   }

//   reloadData(int periodFilter) {
//     periodFilterType = periodFilter;
//     _refresh();
//   }

//   Future<bool> _refresh() async {
//     BlocProvider.of<ExercrisesBloc>(currentContext).add(FetchCaloTrend(
//       currentDateTime:
//           (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
//       periodFilterType: periodFilterType.toString(),
//     ));

//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final width = MediaQuery.of(context).size.width;
//     return BlocProvider<ExercrisesBloc>(
//         create: (context) => ExercrisesBloc(),
//         child: BlocBuilder<ExercrisesBloc, ExercrisesState>(
//             builder: (BuildContext context, ExercrisesState state) {
//           currentContext = context;
//           ExercriseSummaryModel? model;
//           if (state is ExercrisesInitial) {
//             BlocProvider.of<ExercrisesBloc>(context).add(FetchCaloTrend(
//               currentDateTime:
//                   (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
//               periodFilterType: periodFilterType.toString(),
//             ));
//           }
//           if (state is ExercrisesError) {
//             Message.showToastMessage(context, state.message);
//           }
//           if (state is SummaryLoaded) {
//             model = state.model;
//           }
//           return model == null
//               ? Container(
//                   height: 491.5,
//                   child: Center(child: CircularProgressIndicator()))
//               : Container(
//                   color: R.color.transparent,
//                   padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
//                   child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         LineChart(
//                   LineChartData(
//                     borderData: FlBorderData(
//                       show: false,
//                     ),
//                     gridData: FlGridData(
//                       show: false,
//                     ),
//                     // minY: 0,
//                     minX: 0,
//                     lineBarsData: [
//                       LineChartBarData(
//                         // spots: data?.asMap().entries.map((e) {
//                         //       final index = e.key;
//                         //       final item = e.value;
//                         //       final value = item.$2;
//                         //       return FlSpot(index.toDouble(), value * 1.0);
//                         //     }).toList() ??
//                         //     [],
//                         spots: List.generate(model.trendItems.items.length, (index) {
//                           return FlSpot(
//                               index.toDouble(),
//                               model.trendItems.items[index].burnedCalories!
//                                   .toDouble());
//                         }),
//                         dotData: FlDotData(
//                           show: true,
//                           getDotPainter: (spot, percent, barData, index) {
//                             return FlDotCirclePainter(
//                               radius: 3,
//                               color: spot.y >= _targetAPI
//                                   ? R.color.greenGradientBottom
//                                   : R.color.orangeAccent,
//                               strokeWidth: 2,
//                               strokeColor: spot.y >= _targetAPI
//                                   ? R.color.greenGradientBottom
//                                   : R.color.orangeAccent,
//                             );
//                           },
//                         ),
//                         colors: [R.color.greenGradientMid],
//                         barWidth: 1,
//                         // shadow: Shadow(
//                         //   color: R.color.greenGradientMid,
//                         //   blurRadius: 2,
//                         // ),
//                         belowBarData: BarAreaData(
//                           show: true,
//                           colors: [
//                             R.color.greenGradientMid.withOpacity(0.2),
//                             R.color.greenGradientMid.withOpacity(0.0),
//                           ],
//                           gradientColorStops: const [0.5, 1.0],
//                           gradientFrom: const Offset(0.5, 0),
//                           gradientTo: const Offset(0.5, 1),
//                         ),
//                       ),
//                     ],
//                     lineTouchData: LineTouchData(
//                       touchSpotThreshold: 5,
//                       getTouchLineStart: (_, __) => -double.infinity,
//                       getTouchLineEnd: (_, __) => double.infinity,
//                       getTouchedSpotIndicator:
//                           (LineChartBarData barData, List<int> spotIndexes) {
//                         return spotIndexes.map((spotIndex) {
//                           return TouchedSpotIndicatorData(
//                             FlLine(
//                               color: AppColors.contentColorRed,
//                               strokeWidth: 1.5,
//                               dashArray: [8, 2],
//                             ),
//                             FlDotData(
//                               show: true,
//                               getDotPainter: (spot, percent, barData, index) {
//                                 return FlDotCirclePainter(
//                                   radius: 6,
//                                   color: AppColors.contentColorYellow,
//                                   strokeWidth: 0,
//                                   strokeColor: AppColors.contentColorYellow,
//                                 );
//                               },
//                             ),
//                           );
//                         }).toList();
//                       },
//                       touchTooltipData: LineTouchTooltipData(
//                         getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
//                           return touchedBarSpots.map((barSpot) {
//                             final price = barSpot.y;
//                             final date = data![barSpot.x.toInt()].$1;
//                             return LineTooltipItem(
//                               '',
//                               const TextStyle(
//                                 color: AppColors.contentColorBlack,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               children: [
//                                 TextSpan(
//                                   text:
//                                       '${date.year}/${date.month}/${date.day}',
//                                   style: TextStyle(
//                                     color:
//                                         AppColors.contentColorGreen.darken(20),
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                                 TextSpan(
//                                   text: '\n${AppUtils.getFormattedCurrency(
//                                     context,
//                                     price,
//                                     noDecimals: true,
//                                   )}',
//                                   style: const TextStyle(
//                                     color: AppColors.contentColorYellow,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ],
//                             );
//                           }).toList();
//                         },
//                         tooltipBgColor: AppColors.contentColorBlack,
//                       ),
//                     ),
//                     titlesData: FlTitlesData(
//                       show: true,
//                       rightTitles: SideTitles(showTitles: false),
//                       topTitles: SideTitles(showTitles: false),
//                       leftTitles: SideTitles(
//                         showTitles: false,
//                         reservedSize: leftReservedSize,
//                       ),
//                       bottomTitles: SideTitles(
//                         showTitles: false,
//                         // showTitles: true,
//                         // reservedSize: 38,
//                         // getTitles: (double value) {
//                         //   final date = _bitcoinPriceHistory![value.toInt()].$1;
//                         //   return '${date.month}/${date.day}';
//                         // },
//                       ),
//                     ),
//                     extraLinesData: ExtraLinesData(horizontalLines: [
//                       HorizontalLine(
//                         label: HorizontalLineLabel(
//                           show: true,
//                           style: TextStyle(
//                             color: R.color.textDark,
//                             fontSize: 12,
//                           ),
//                           alignment: Alignment.centerLeft,
//                           labelResolver: (value) {
//                             return AppUtils.getFormattedCurrency(
//                               context,
//                               value.y,
//                               noDecimals: true,
//                             );
//                           },
//                         ),
//                         // Adjusted to align with the chart's data range
//                         y: _targetAPI,
//                         color: R.color.color0xffDFE4E4,
//                         strokeWidth: 1,
//                         dashArray: [8, 2],
//                       ),
//                     ]),
//                   ),
//                   swapAnimationDuration: Duration.zero,
//                 ),
//               )),
//                       ]),
//                 );
//         }));
//   }

//   submitTarget(double time) async {
//     try {
//       BotToast.showLoading();
//       await ExercrisesClient().addExercriseTarget(
//           periodFilterType == 1 || periodFilterType == 2 ? 1 : 2,
//           2,
//           time,
//           null);
//       await UserClient().fetchUser();
//       Message.showToastMessage(context, R.string.them_muc_tieu_thanh_cong.tr());
//       _refresh();
//       BotToast.closeAllLoading();
//     } catch (e, _) {
//       BotToast.closeAllLoading();
//       if (e is Error) {
//         Message.showToastMessage(context, e.message);
//       } else {
//         Message.showToastMessage(context, e.toString());
//       }
//     }
//   }

//   Widget buildDescriptionItem(List model) {
//     final String color = model.last;
//     final String title = model.first;
//     return Row(children: [
//       Container(
//           width: 14,
//           height: 14,
//           color: Color(int.parse('0xff${color.split('#').join()}'))),
//       SizedBox(width: 4),
//       Text(title)
//     ]);
//   }

//   showTable(BuildContext context) {
//     Navigator.of(context).push(PageRouteBuilder(
//         opaque: false,
//         pageBuilder: (BuildContext context, _, __) => HbA1CTable()));
//   }

//   buildChart(ExercriseSummaryModel model) {
//     final width = (MediaQuery.of(context).size.width - 200) / 5;

//     double minY = model.trendItems.items
//         .map<double>((e) => e.burnedCalories ?? 0)
//         .reduce(min);
//     minY = (minY * (model.trendItems.items.length == 1 ? 0.5 : 0.8))
//         .roundToDouble();
//     double maxY = model.trendItems.items
//         .map<double>((e) => e.burnedCalories ?? 0)
//         .reduce(max);
//     maxY = (maxY * (model.trendItems.items.length == 1 ? 1.5 : 1.2))
//         .roundToDouble();
//     final jumpValue = (maxY - minY) / 2;
//     List<double> number =
//         List.generate(3, (index) => roundAsFixed(jumpValue * index + minY))
//             .reversed
//             .toList();

//     return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Container(
//         width: 36,
//         height: 200,
//         child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: List.generate(number.length, (index) {
//               return Text(formatNumber(number[index]),
//                   style: TextStyle(
//                       fontSize: 14,
//                       color: R.color.black,
//                       fontWeight: FontWeight.normal));
//             })),
//       ),
//       Expanded(
//         child: SingleChildScrollView(
//           reverse: true,
//           scrollDirection: Axis.horizontal,
//           child: Stack(children: [
//             Container(
//                 height: 200,
//                 child: Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: List.generate(
//                         number.length,
//                         (index) => Padding(
//                               padding:
//                                   EdgeInsets.only(left: 8, top: 8, bottom: 8),
//                               child: Container(
//                                 height: 1,
//                                 width: ((model.trendItems.items.length < 5
//                                                 ? 5
//                                                 : model
//                                                     .trendItems.items.length) *
//                                             (width + 20))
//                                         .toDouble() -
//                                     36,
//                                 color: R.color.grayComponentBorder,
//                               ),
//                             )))),
//             Container(
//                 width: ((model.trendItems.items.length < 5
//                             ? 5
//                             : model.trendItems.items.length) *
//                         (width + 20))
//                     .toDouble(),
//                 height: 200,
//                 padding: EdgeInsets.only(top: 8, bottom: 8),
//                 child: BarChart(
//                   BarChartData(
//                       alignment: BarChartAlignment.spaceAround,
//                       //groupsSpace: 50,
//                       maxY: maxY,
//                       minY: minY,
//                       barTouchData: BarTouchData(
//                           enabled: true,
//                           touchTooltipData: BarTouchTooltipData(
//                             fitInsideHorizontally: true,
//                             fitInsideVertically: true,
//                             tooltipBgColor: touchIndex == null
//                                 ? toColor(model
//                                     .trendItems
//                                     .items[model.trendItems.items.length - 1]
//                                     .targetColor)
//                                 : toColor(model
//                                     .trendItems.items[touchIndex!].targetColor),
//                             tooltipPadding: const EdgeInsets.only(
//                                 top: 8, bottom: 4, left: 8, right: 8),
//                             tooltipMargin: 8,
//                             getTooltipItem: (
//                               BarChartGroupData group,
//                               int groupIndex,
//                               BarChartRodData rod,
//                               int rodIndex,
//                             ) {
//                               if (model.trendItems.items[groupIndex]
//                                       .burnedCalories ==
//                                   0) {
//                                 return null;
//                               }
//                               return BarTooltipItem(
//                                 model.trendItems.items[groupIndex]
//                                         .burnedCalories!
//                                         .round()
//                                         .toString() +
//                                     ' ${R.string.kcal.tr()}',
//                                 TextStyle(
//                                     color: R.color.textDark,
//                                     fontWeight: FontWeight.w400,
//                                     fontSize: 12),
//                               );
//                             },
//                           ),
//                           touchCallback:
//                               (FlTouchEvent event, BarTouchResponse? barTouch) {
//                             if (event is! FlLongPressEnd &&
//                                 event is! FlPanEndEvent) {
//                               final value =
//                                   barTouch!.spot!.touchedBarGroupIndex;
//                               touchIndex = value.toInt();
//                             }
//                             setState(() {});
//                           }),
//                       titlesData: FlTitlesData(
//                         rightTitles: SideTitles(showTitles: false),
//                         topTitles: SideTitles(showTitles: false),
//                         show: true,
//                         bottomTitles: SideTitles(
//                           showTitles: true,
//                           margin: 16,
//                           reservedSize: -16,
//                           getTextStyles: (context, value) => TextStyle(
//                               color: R.color.black,
//                               fontSize: 10,
//                               fontWeight: FontWeight.normal),
//                           //margin: 10,
//                           getTitles: (double value) {
//                             if (model.trendItems.items[value.toInt()]
//                                         .firstDateOfWeek !=
//                                     null &&
//                                 model.trendItems.items[value.toInt()]
//                                         .lastDateOfWeek !=
//                                     null) {
//                               return convertToUTC(
//                                       model.trendItems.items[value.toInt()]
//                                           .firstDateOfWeek!,
//                                       'dd' + '-') +
//                                   convertToUTC(
//                                       model.trendItems.items[value.toInt()]
//                                           .lastDateOfWeek!,
//                                       'dd/MM');
//                             }
//                             return convertToUTC(
//                                 model.trendItems.items[value.toInt()].date!,
//                                 'dd/MM');
//                           },
//                         ),
//                         leftTitles: SideTitles(
//                           showTitles: false,
//                           getTextStyles: (context, value) =>
//                               TextStyle(color: R.color.black, fontSize: 14),
//                         ),
//                       ),
//                       gridData: FlGridData(show: false),
//                       borderData: FlBorderData(
//                         show: false,
//                       ),
//                       barGroups:
//                           List.generate(model.trendItems.items.length, (index) {
//                         return buildBarChartGroupData(model, index);
//                       })),
//                 )),
//             maxY == 0 || model.target! > maxY || model.target! < minY
//                 ? SizedBox()
//                 : Container(
//                     height: 200,
//                     padding: EdgeInsets.only(top: 8, bottom: 8),
//                     child: Column(
//                       children: [
//                         SizedBox(
//                             height: (184 -
//                                 (184 *
//                                     (model.target! - minY) /
//                                     (maxY - minY)))),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 8.0),
//                           child: Container(
//                             color: R.color.color0xff72CB9C,
//                             width: ((model.trendItems.items.length < 5
//                                             ? 5
//                                             : model.trendItems.items.length) *
//                                         (width + 20))
//                                     .toDouble() -
//                                 13,
//                             height: 0.75,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//             SizedBox(height: 240)
//           ]),
//         ),
//       ),
//     ]);
//   }

//   BarChartGroupData buildBarChartGroupData(
//       ExercriseSummaryModel model, int index) {
//     // final color = toColor(model.trendItems.items[index].color);
//     return BarChartGroupData(
//       x: index,
//       showingTooltipIndicators: touchIndex == index ||
//               (touchIndex == null && index == model.trendItems.items.length - 1)
//           ? [0]
//           : [],
//       //barsSpace: 60,
//       barRods: [
//         BarChartRodData(
//             width: 20,
//             borderRadius: BorderRadius.circular(0),
//             y: model.trendItems.items[index].burnedCalories!,
//             colors: [toColor(model.trendItems.items[index].targetColor)]),
//       ],
//     );
//   }

//   // List<LineChartBarData> linesBarData(TrendModel model) {
//   //   final LineChartBarData lineChartBarData1 = LineChartBarData(
//   //     spots: List.generate(model.trendItems.items.length, (index) {
//   //       return FlSpot(
//   //           (index + 0.5).toDouble(), model.trendItems.items[index].hbA1C);
//   //     }),
//   //     isCurved: false,
//   //     colors: [R.color.black],
//   //     barWidth: 1,
//   //     isStrokeCapRound: true,
//   //     dotData: FlDotData(
//   //         show: true,
//   //         checkToShowDot: (spot, barData) {
//   //           return spot.x == model.trendItems.items.length - 0.5;
//   //         },
//   //         getDotPainter: (spot, percent, barData, index) {
//   //           return FlDotCirclePainter(
//   //             radius: 6,
//   //             color: Color(0xffF44336),
//   //             strokeWidth: 12,
//   //             strokeColor: Color(0xffF44336).withOpacity(0.2),
//   //           );
//   //         }),
//   //     belowBarData: BarAreaData(
//   //       show: false,
//   //     ),
//   //   );

//   //   return [
//   //     lineChartBarData1,
//   //   ];
//   // }
// }

// typedef CaloCallback = Function(String);
