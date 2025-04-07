import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/bloodPressure/bloodPressure_bloc.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure_trend.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodPressure/bloodPressure_detail_tabbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widgets/empty_data_box.dart';
import 'package:visibility_detector/visibility_detector.dart';

class BloodPressureChart extends StatefulWidget {
  BloodPressureChart({Key? key}) : super(key: key);
  @override
  BloodPressureChartState createState() => BloodPressureChartState();
}

class BloodPressureChartState extends State<BloodPressureChart>
    with AutomaticKeepAliveClientMixin<BloodPressureChart> {
  @override
  bool get wantKeepAlive => true;

  int touchIndex = -1;

  int periodFilterType = 1;
  late BuildContext currentContext;
  int? previousDate = 0;

  final double _mediumLow = 90;
  final double _mediumHigh = 140;

  @override
  void initState() {
    periodFilterType = BloodPressureDetailTabbarController.of(context)!.periodFilterType;
    super.initState();
  }

  reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    _refresh();
  }

  Future<bool> _refresh() async {
    BlocProvider.of<BloodPressureBloc>(currentContext).add(FetchBloodPressureTrend(
      currentDateTime: (DateTime.now().millisecondsSinceEpoch ~/ 1000),
      periodFilterType: periodFilterType,
    ));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<BloodPressureBloc>(
        create: (context) => BloodPressureBloc(),
        child: BlocBuilder<BloodPressureBloc, BloodPressureState>(
            builder: (BuildContext context, BloodPressureState state) {
          currentContext = context;
          BloodPressureTrendModel? model;

          if (state is BloodPressureInitial) {
            BlocProvider.of<BloodPressureBloc>(context).add(FetchBloodPressureTrend(
              currentDateTime: (DateTime.now().millisecondsSinceEpoch ~/ 1000),
              periodFilterType: periodFilterType,
            ));
          }
          if (state is BloodPressureError) {
            Message.showToastMessage(context, state.message);
          }

          if (state is BloodPressureTrendLoaded) {
            model = state.model;
          }
          return model == null
              ? Container(height: 240, child: Center(child: CircularProgressIndicator()))
              : VisibilityDetector(
                  key: Key('blood_pressure_chart'),
                  onVisibilityChanged: (visibilityInfo) {
                    var visiblePercentage = visibilityInfo.visibleFraction * 100;
                    if (visiblePercentage == 0) {
                      previousDate = 0;
                    }
                  },
                  child: Container(
                    color: R.color.transparent,
                    padding: EdgeInsets.only(left: 18, right: 18),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(R.string.blood_pressure_trend.tr(),
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 14),
                      model.trendItems.items.length == 0
                          ? EmptyDataBox(
                              text: 'chỉ số huyết áp',
                              onTap: () {
                                Navigator.pushNamed(context, NavigatorName.add_blood_pressure,
                                    arguments: {'type': 'input', 'id': null});
                              },
                            )
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: R.color.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: R.color.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 7,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: buildChart(model)),
                      SizedBox(height: 26),
                    ]),
                  ),
                );
        }));
  }

  double _customYTransform(double y) {
    if (y <= 90) {
      // Map 0–90 to 0–30
      return (y / 90) * 30;
    } else if (y <= 140) {
      // Map 90–140 to 30–70
      return 30 + ((y - 90) / 50) * 40;
    } else {
      // Map 140–180+ to 70–100 (you can clamp or allow more)
      return 70 + ((y - 140) / 40) * 30;
    }
  }

  Widget buildChart(BloodPressureTrendModel model) {
    final width = (MediaQuery.of(context).size.width - 200) / 5;

    List<int?> dates = [];
    List<SubTrendItemModel> trends = [];
    model.trendItems.items.forEach((element) {
      dates.add(element.date);
      trends.addAll(element.subTrendItems);
      List.generate(element.subTrendItems.length - 1, (index) => dates.add(null));
    });

    // double minY = trends
    //     .map<double>((e) => (e.diastolic! < e.systolic! ? e.diastolic! : e.systolic!))
    //     .reduce(min);
    // minY = (minY * (trends.length == 1 ? 0.5 : 0.8)).roundToDouble();
    // double maxY = trends
    //     .map<double>((e) => (e.diastolic! > e.systolic! ? e.diastolic! : e.systolic!))
    //     .reduce(max);
    // maxY = (maxY * (trends.length == 1 ? 1.5 : 1.2)).roundToDouble();
    // final jumpValue = (maxY - minY) / 4;
    // List<int> leftTitleValues =
    //     List.generate(5, (index) => (jumpValue * index + minY).round()).reversed.toList();
    double minY = 0;
    double maxY = 100;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 120,
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child: Column(
                children: [
                  Spacer(flex: 1),
                  Text(_mediumHigh.toString(), style: TextStyle(color: R.color.black, fontSize: 14)),
                  Spacer(flex: 1),
                  Text(_mediumLow.toString(), style: TextStyle(color: R.color.black, fontSize: 14)),
                  Spacer(flex: 2),
                  SizedBox(height: 16),
                ],
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: SingleChildScrollView(
                reverse: trends.length > 1,
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: ((trends.length < 5 ? 5 : trends.length) * (width + 20)).toDouble(),
                  height: 120,
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                          getTouchLineStart: (barData, index) => -double.infinity,
                          getTouchLineEnd: (barData, index) => double.infinity,
                          getTouchedSpotIndicator:
                              (LineChartBarData barData, List<int> spotIndexes) {
                            return spotIndexes.map((index) {
                              return TouchedSpotIndicatorData(
                                FlLine(color: R.color.black, strokeWidth: 0.5),
                                FlDotData(show: false),
                              );
                            }).toList();
                          },
                          touchTooltipData: LineTouchTooltipData(
                            showOnTopOfTheChartBoxArea: true,
                            fitInsideVertically: true,
                            fitInsideHorizontally: true,
                            tooltipBgColor: toColor(model.colors!.first).withOpacity(0.2),
                            tooltipRoundedRadius: 8,
                            getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                              return lineBarsSpot.map((lineBarSpot) {
                                if (lineBarSpot.barIndex == 0) {
                                  if (lineBarSpot.spotIndex < 0 || 
                                      lineBarSpot.spotIndex >= trends.length ||
                                      trends[lineBarSpot.spotIndex].systolic == null ||
                                      trends[lineBarSpot.spotIndex].diastolic == null) {
                                    return LineTooltipItem(
                                      '0/0',
                                      TextStyle(
                                          color: toColor(model.colors!.first),
                                          fontWeight: FontWeight.bold),
                                    );
                                  }
                                  final trend = trends[lineBarSpot.spotIndex];
                                  return LineTooltipItem(
                                    trend.systolic!.round().toString() +
                                        '/' +
                                        trend.diastolic!.round().toString(),
                                    TextStyle(
                                        color: toColor(model.colors!.first),
                                        fontWeight: FontWeight.bold),
                                  );
                                }
                              }).toList();
                            },
                          ),
                          touchCallback: (FlTouchEvent event, LineTouchResponse? lineTouch) {
                            previousDate = 0;
                            if (event is! FlLongPressEnd && event is! FlPanEndEvent) {
                              final value = lineTouch?.lineBarSpots?[0].x;
                              if (value != null) {
                                //  setState(() {
                                touchIndex = value.toInt();
                                //  });
                              }
                            } else {
                              touchIndex = -1;
                            }
                          }),
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        rightTitles: SideTitles(showTitles: false),
                        topTitles: SideTitles(showTitles: false),
                        bottomTitles: SideTitles(
                          showTitles: true,
                          margin: 16,
                          reservedSize: 16,
                          interval: 1,
                          getTextStyles: (context, value) {
                            return TextStyle(
                                color: touchIndex == value.toInt()
                                    ? R.color.black
                                    : R.color.color0xffC0C2C5,
                                fontSize: 14,
                                fontWeight: FontWeight.normal);
                          },
                          getTitles: (double value) {
                            int index = value.toInt();
                            if (index < 0 ||
                                index >= trends.length ||
                                trends[index].pulseRate == null) {
                              return '0';
                            }
                            // return heart rate value
                            return trends[index].pulseRate!.round().toString();
                          },
                        ),
                        leftTitles: SideTitles(
                          showTitles: false,
                          reservedSize: 36,
                          interval: 10,
                          getTitles: (double value) {
                            // map [_customYTransform]
                            if (value == _customYTransform(90)) {
                              return '90';
                            }
                            if (value == _customYTransform(140)) {
                              return '140';
                            }
                            return '';
                          },
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: trends.length.toDouble(),
                      maxY: maxY,
                      minY: minY,
                      lineBarsData: linesBarData(model),
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: _customYTransform(_mediumLow),
                            color: Colors.grey,
                            dashArray: [8, 4],
                            strokeWidth: 1,
                          ),
                          HorizontalLine(
                            y: _customYTransform(_mediumHigh),
                            color: Colors.grey,
                            dashArray: [8, 4],
                            strokeWidth: 1,
                          ),
                        ],
                      ),
                    ),
                    swapAnimationDuration: Duration(milliseconds: 250),
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  List<LineChartBarData> linesBarData(BloodPressureTrendModel model) {
    List<SubTrendItemModel> trends = [];
    model.trendItems.items.forEach((item) {
      trends.addAll(item.subTrendItems);
    });

    if (trends.length == 0) {
      return [];
    }

    return [
      LineChartBarData(
        spots: List.generate(trends.length, (index) {
          return FlSpot((index).toDouble(), _customYTransform(trends[index].systolic!));
        }),
        isCurved: false,
        colors: [Color(0xFF008479)],
        barWidth: 1,
        isStrokeCapRound: true,
        dotData: FlDotData(
            show: true,
            // checkToShowDot: (spot, barData) {
            //   return spot.x == trends.length - 1;
            // },
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: trends.length - 1 == index ? 6.5 : 4,
                color: toColor(model.colors!.first),
                strokeWidth: trends.length - 1 == index ? 18 : 0,
                strokeColor: toColor(model.colors!.first).withOpacity(0.2),
              );
            }),
        belowBarData: BarAreaData(show: false),
      ),
      LineChartBarData(
        spots: List.generate(trends.length, (index) {
          return FlSpot((index).toDouble(), _customYTransform(trends[index].diastolic!));
        }),
        isCurved: false,
        colors: [Color(0xFF95682E)],
        barWidth: 1,
        isStrokeCapRound: true,
        dotData: FlDotData(
            show: true,
            // checkToShowDot: (spot, barData) {
            //   return spot.x == trends.length - 1;
            // },
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: trends.length - 1 == index ? 6.5 : 4,
                color: toColor(model.colors!.last),
                strokeWidth: trends.length - 1 == index ? 18 : 0,
                strokeColor: toColor(model.colors!.last).withOpacity(0.2),
              );
            }),
        belowBarData: BarAreaData(show: false),
      )
    ];
  }
}
