import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/bloc/exercrises/exercrises_bloc.dart';
import 'package:medical/src/modal/exercrises/exercrise_trend_time.dart';
import 'package:medical/src/repo/exercrises/exercrises_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Exercrises/exercrises_detail_tabbar.dart';
import 'package:medical/src/widget/Exercrises/input_detail_exercrise.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/widget/tabbar/tabbar_v2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widgets/empty_data_box.dart';

import '../../../widgets/network_image_widget.dart';

class ExercrisesTrendChartLine extends StatefulWidget {
  ExercrisesTrendChartLine({Key? key}) : super(key: key);

  @override
  ExercrisesTrendChartLineState createState() =>
      ExercrisesTrendChartLineState();
}

class ExercrisesTrendChartLineState extends State<ExercrisesTrendChartLine>
    with AutomaticKeepAliveClientMixin<ExercrisesTrendChartLine> {
  @override
  bool get wantKeepAlive => true;
  late BuildContext currentContext;
  int periodFilterType = 1;

  late double touchedValue;

  @override
  void initState() {
    final controller = ExercrisesDetailTabbarController.of(context);
    if (controller != null) {
      periodFilterType = controller.periodFilterType;
    } else {
      Console.log('ExercrisesDetailTabbarController is null');
    }
    touchedValue = -1;
    super.initState();
  }

  reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    _refresh();
  }

  Future<bool> _refresh() async {
    BlocProvider.of<ExercrisesBloc>(currentContext).add(FetchTimeTrend(
      currentDateTime:
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      periodFilterType: periodFilterType.toString(),
    ));

    return true;
  }

  final chartLineHeight = 150.0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final width = MediaQuery.of(context).size.width;
    return BlocProvider<ExercrisesBloc>(
        create: (context) => ExercrisesBloc(),
        child: BlocBuilder<ExercrisesBloc, ExercrisesState>(
            builder: (BuildContext context, ExercrisesState state) {
          currentContext = context;
          ExercriseTrendTimeModel? model;
          if (state is ExercrisesInitial) {
            BlocProvider.of<ExercrisesBloc>(context).add(FetchTimeTrend(
              currentDateTime:
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
              periodFilterType: periodFilterType.toString(),
            ));
          }
          if (state is ExercrisesError) {
            Message.showToastMessage(context, state.message);
          }

          if (state is TimeTrendTrendLoaded) {
            model = state.model;
          }
          return model == null
              ? Container(
                  height: chartLineHeight + 200,
                  child: Center(child: CircularProgressIndicator()))
              : Container(
                  color: R.color.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      buildChart(model, chartLineHeight)
                    ],
                  ));
        }));
  }

  buildChart(ExercriseTrendTimeModel model, double? height) {
    final width = (MediaQuery.of(context).size.width - 200) / 5;

    double minY =
        model.trendItems.items.map<double>((e) => e.duration ?? 0).reduce(min);
    minY = ((minY * (model.trendItems.items.length == 1 ? 0.5 : 0.8))
            .roundToDouble() /
        60);
    double maxY =
        model.trendItems.items.map<double>((e) => e.duration ?? 0).reduce(max);
    maxY = ((maxY * (model.trendItems.items.length == 1 ? 1.5 : 2))
            .roundToDouble() /
        60);
    const leftReservedSize = 52.0;

    final double target = model.target! / 60;

    return Container(
        alignment: Alignment.centerLeft,
        width: MediaQuery.of(context).size.width,
        height: height ?? 120,
        padding: EdgeInsets.only(top: 8, bottom: 8),
        child: LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            borderData: FlBorderData(
              show: false,
            ),
            gridData: FlGridData(
              show: false,
            ),
            lineBarsData: [
              LineChartBarData(
                spots: model.trendItems.items
                    .map((e) => FlSpot(
                        model!.trendItems.items.indexOf(e).toDouble(),
                        (e.duration! / 60)))
                    .toList(),
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 3,
                      color: spot.y >= model!.target! / 60
                          ? R.color.greenGradientBottom
                          : R.color.orangeAccent,
                      strokeWidth: 2,
                      strokeColor: spot.y >= model!.target! / 60
                          ? R.color.greenGradientBottom
                          : R.color.orangeAccent,
                    );
                  },
                ),
                colors: [R.color.greenGradientMid],
                barWidth: 1,
                // shadow: Shadow(
                //   color: R.color.greenGradientMid,
                //   blurRadius: 2,
                // ),
                belowBarData: BarAreaData(
                  show: true,
                  colors: [
                    R.color.greenGradientMid.withOpacity(0.2),
                    R.color.greenGradientMid.withOpacity(0.0),
                  ],
                  gradientColorStops: const [0.5, 1.0],
                  gradientFrom: const Offset(0.5, 0),
                  gradientTo: const Offset(0.5, 1),
                ),
              ),
              LineChartBarData(
                spots: [
                  FlSpot(0, target),
                  FlSpot(model.trendItems.items.length - 1, target)
                ],
                colors: [R.color.greenGradientMid],
                barWidth: 1,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(show: false),
                dashArray: [8, 2],
                isCurved: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 3,
                      color: spot.y >= model!.target! / 60
                          ? R.color.greenGradientBottom
                          : R.color.orangeAccent,
                      strokeWidth: 2,
                      strokeColor: spot.y >= model!.target! / 60
                          ? R.color.greenGradientBottom
                          : R.color.orangeAccent,
                    );
                  },
                ),
              ),
            ],
            // lineTouchData: LineTouchData(
            //   enabled: true,
            //   touchSpotThreshold: 5,
            //   getTouchLineStart: (_, __) => -double.infinity,
            //   getTouchLineEnd: (_, __) => double.infinity,
            //   getTouchedSpotIndicator:
            //       (LineChartBarData barData, List<int> spotIndexes) {
            //     return spotIndexes.map((spotIndex) {
            //       return TouchedSpotIndicatorData(
            //         FlLine(
            //           color: spotIndex == touchIndex
            //               ? R.color.greenGradientMid
            //               : R.color.greenGradientMid,
            //           strokeWidth: 1,
            //           dashArray: [8, 2],
            //         ),
            //         FlDotData(
            //           show: true,
            //           getDotPainter: (spot, percent, barData, index) {
            //             return FlDotCirclePainter(
            //               radius: 6,
            //               color: spot.y >= model.target! / 60
            //                   ? R.color.greenGradientBottom
            //                   : R.color.orangeAccent,
            //               strokeWidth: 10,
            //               strokeColor: spot.y >= model.target! / 60
            //                   ? R.color.greenGradientBottom
            //                       .withOpacity(0.5)
            //                   : R.color.orangeAccent.withOpacity(0.5),
            //             );
            //           },
            //         ),
            //       );
            //     }).toList();
            //   },
            //   touchTooltipData: LineTouchTooltipData(
            //     getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            //       return touchedBarSpots.map((barSpot) {
            //         final duration = barSpot.y;
            //         final date =
            //             model.trendItems.items[barSpot.x.toInt()].date!;
            //         final dateTime = DateTime.fromMillisecondsSinceEpoch(
            //             DateTime.fromMillisecondsSinceEpoch(date)
            //                 .millisecondsSinceEpoch);
            //         return LineTooltipItem(
            //           'hello',
            //           const TextStyle(
            //             color: Color(0xffFDC798),
            //             fontWeight: FontWeight.bold,
            //           ),
            //           children: [
            //             TextSpan(
            //               text:
            //                   '${dateTime.year}/${dateTime.month}/${dateTime.day}',
            //               style: TextStyle(
            //                 color: R.color.greenGradientBottom,
            //                 fontWeight: FontWeight.bold,
            //                 fontSize: 12,
            //               ),
            //             ),
            //             TextSpan(
            //               text:
            //                   '${duration.toInt()} ${R.string.minute.tr()}',
            //               style: const TextStyle(
            //                 color: Color(0xffFDC798),
            //                 fontWeight: FontWeight.bold,
            //                 fontSize: 16,
            //               ),
            //             ),
            //           ],
            //         );
            //       }).toList();
            //     },
            //     tooltipBgColor: R.color.dark,
            //   ),
            // ),

            lineTouchData: LineTouchData(
              enabled: true,
              touchSpotThreshold: 5,
              getTouchLineStart: (_, __) => -double.infinity,
              getTouchLineEnd: (_, __) => double.infinity,
              handleBuiltInTouches: true,
              getTouchedSpotIndicator:
                  (LineChartBarData barData, List<int> spotIndexes) {
                return spotIndexes.map((spotIndex) {
                  final spot = barData.spots[spotIndex];
                  if (spot.x == 0 || spot.x == 6) {
                    return null;
                  }
                  final spotColor = spot.y >= model.target! / 60
                      ? R.color.greenGradientTop02
                      : R.color.orangeAccent;
                  return TouchedSpotIndicatorData(
                    FlLine(
                      color: spotColor,
                      strokeWidth: 1.5,
                      dashArray: [8, 2],
                    ),
                    FlDotData(
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: spotColor,
                          strokeWidth: 8,
                          strokeColor: spotColor.withOpacity(0.5),
                        );
                      },
                    ),
                  );
                }).toList();
              },
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: R.color.greenGradientTop02,
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  return touchedBarSpots.map((barSpot) {
                    final flSpot = barSpot;
                    TextAlign textAlign;
                    switch (flSpot.x.toInt()) {
                      case 1:
                        textAlign = TextAlign.left;
                        break;
                      case 5:
                        textAlign = TextAlign.right;
                        break;
                      default:
                        textAlign = TextAlign.center;
                    }
                    var item = model.trendItems.items[flSpot.x.toInt()];
                    var dateString = '';
                    if (item.firstDateOfWeek != null &&
                        item.lastDateOfWeek != null) {
                      dateString =
                          convertToUTC(item.firstDateOfWeek!, 'dd' + '-') +
                              convertToUTC(item.lastDateOfWeek!, 'dd/MM');
                    } else {
                      dateString = convertToUTC(item.date!, 'dd/MM');
                    }

                    return LineTooltipItem(
                      dateString + '\n',
                      TextStyle(
                        color: R.color.textDark,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'fspro',
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text:
                              '${item.duration!.toInt()} ${R.string.minute.tr()}',
                          style: TextStyle(
                            color: R.color.textDark,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'fspro',
                            fontSize: 12,
                          ),
                        ),
                      ],
                      textAlign: textAlign,
                    );
                  }).toList();
                },
              ),
              touchCallback:
                  (FlTouchEvent event, LineTouchResponse? lineTouch) {
                if (!event.isInterestedForInteractions ||
                    lineTouch == null ||
                    lineTouch.lineBarSpots == null) {
                  setState(() {
                    touchedValue = -1;
                  });
                  return;
                }
                final value = lineTouch.lineBarSpots![0].x;

                setState(() {
                  touchedValue = value;
                });
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: SideTitles(
                showTitles: false,
              ),
              topTitles: SideTitles(showTitles: false),
              leftTitles: SideTitles(
                showTitles: true,
                getTitles: (double value) {
                  return '${value.toInt()} ${R.string.minute.tr()}';
                },
                margin: leftReservedSize,
                reservedSize: leftReservedSize,
              ),
              bottomTitles: SideTitles(
                showTitles: false,
              ),
            ),
            // extraLinesData:
            //     ExtraLinesData(extraLinesOnTop: false, horizontalLines: [
            //   HorizontalLine(
            //     label: HorizontalLineLabel(
            //       show: true,
            //       style: TextStyle(
            //           color: R.color.textDark,
            //           fontSize: 14,
            //           fontWeight: FontWeight.w400),
            //       alignment: Alignment.centerLeft,
            //       padding: EdgeInsets.only(left: 0),
            //       labelResolver: (value) {
            //         return '${value.y.toInt()} ${R.string.minute.tr()}';
            //       },
            //     ),
            //     // Adjusted to align with the chart's data range
            //     y: model.target! / 60,
            //     color: R.color.color0xffDFE4E4,
            //     strokeWidth: 1,
            //     dashArray: [8, 2],
            //   ),
            // ]),
          ),
          swapAnimationDuration: Duration.zero,
        ));
  }

  // BarChartGroupData buildLineChartGroupData(
  //     ExercriseTrendTimeModel model, int index) {
  //   // final color = toColor(model.trendItems.items[index].color);
  //   return BarChartGroupData(
  //     x: index,
  //     showingTooltipIndicators: touchIndex == index ||
  //             (touchIndex == null && index == model.trendItems.items.length - 1)
  //         ? [0]
  //         : [],
  //     //barsSpace: 60,
  //     barRods: [
  //       BarChartRodData(
  //           width: 20,
  //           borderRadius: BorderRadius.circular(0),
  //           y: (model.trendItems.items[index].duration! / 60),
  //           colors: [toColor(model.trendItems.items[index].targetColor)]),
  //     ],
  //   );
  // }

  submitTarget(double time, String? exerciseCategoryId) async {
    try {
      BotToast.showLoading();
      await ExercrisesClient().addExercriseTarget(
          periodFilterType == 1 || periodFilterType == 2 ? 1 : 2,
          1,
          time,
          exerciseCategoryId);
      UserClient().fetchUser();
      Message.showToastMessage(context, R.string.them_muc_tieu_thanh_cong.tr());
      _refresh();
      BotToast.closeAllLoading();
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }
}
