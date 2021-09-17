import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/bloodPressure/bloodPressure_bloc.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure_trend.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/BloodPressure/bloodPressure_detail_tabbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class BloodPressureChart extends StatefulWidget {
  BloodPressureChart({Key key}) : super(key: key);
  @override
  BloodPressureChartState createState() => BloodPressureChartState();
}

class BloodPressureChartState extends State<BloodPressureChart>
    with AutomaticKeepAliveClientMixin<BloodPressureChart> {
  @override
  bool get wantKeepAlive => true;

  int touchIndex = -1;

  int periodFilterType = 1;
  BuildContext currentContext;

  @override
  void initState() {
    periodFilterType =
        BloodPressureDetailTabbarController.of(context).periodFilterType;
    super.initState();
  }

  reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    _refresh();
  }

  Future<bool> _refresh() async {
    BlocProvider.of<BloodPressureBloc>(currentContext)
        .add(FetchBloodPressureTrend(
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
          BloodPressureTrendModel model;

          if (state is BloodPressureInitial) {
            BlocProvider.of<BloodPressureBloc>(context)
                .add(FetchBloodPressureTrend(
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
              ? Container(
                  height: 240,
                  child: Center(child: CircularProgressIndicator()))
              : Container(
                  color: R.color.transparent,
                  padding: EdgeInsets.only(left: 18, right: 18),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text('Xu hướng huyết áp',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 14),
                        model.trendItems.items.length == 0
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, '/add_bloodPressure',
                                      arguments: {'type': 'input', 'id': null});
                                },
                                child: Image.asset(
                                    'assets/images/blood_pressure_trend_empty.png'),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: R.color.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 7,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: buildChart(model))),
                        SizedBox(height: 26),
                      ]),
                );
        }));
  }

  buildChart(BloodPressureTrendModel model) {
    final width = (MediaQuery.of(context).size.width - 200) / 5;

    List<int> dates = [];
    List<SubTrendItemModel> trends = [];
    model.trendItems.items.forEach((element) {
      dates.add(element.date);
      trends.addAll(element.subTrendItems);
      List.generate(
          element.subTrendItems.length - 1, (index) => dates.add(null));
    });

    double minY = trends
        .map<double>(
            (e) => (e.diastolic < e.systolic ? e.diastolic : e.systolic))
        .reduce(min);
    minY = (minY * (trends.length == 1 ? 0.5 : 0.8)).roundToDouble();
    double maxY = trends
        .map<double>(
            (e) => (e.diastolic > e.systolic ? e.diastolic : e.systolic))
        .reduce(max);
    maxY = (maxY * (trends.length == 1 ? 1.5 : 1.2)).roundToDouble();
    final jumpValue = (maxY - minY) / 4;
    List<int> number =
        List.generate(5, (index) => (jumpValue * index + minY).round())
            .reversed
            .toList();

    return Padding(
      padding: EdgeInsets.only(top: 18, bottom: 0, right: 0, left: 0),
      child: Column(
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 30,
              height: 300,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(number.length, (index) {
                    return Text(number[index].toString(),
                        style: TextStyle(
                            fontSize: 14,
                            color: R.color.black,
                            fontWeight: FontWeight.normal));
                  })),
            ),
            Expanded(
              child: SingleChildScrollView(
                  reverse: trends.length > 1,
                  scrollDirection: Axis.horizontal,
                  child: Stack(children: [
                    Container(
                        height: 300,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                                number.length,
                                (index) => Padding(
                                      padding: EdgeInsets.only(
                                          left: 8, top: 8, bottom: 8),
                                      child: Container(
                                        height: 1,
                                        width: ((trends.length < 5
                                                        ? 5
                                                        : trends.length) *
                                                    (width + 20))
                                                .toDouble() -
                                            36,
                                        color: Color(0xffDDDDDD),
                                      ),
                                    )))),
                    Container(
                        width: ((trends.length < 5 ? 5 : trends.length) *
                                (width + 20))
                            .toDouble(),
                        height: 300,
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: LineChart(
                          LineChartData(
                            lineTouchData: LineTouchData(
                                getTouchLineStart: (barData, index) => -double.infinity, // default: from bottom
                                getTouchLineEnd: (barData, index) => double.infinity, //to top
                                getTouchedSpotIndicator:
                                    (LineChartBarData barData,
                                        List<int> spotIndexes) {
                                  return spotIndexes.map((index) {
                                    return TouchedSpotIndicatorData(
                                      FlLine(
                                          color: R.color.black,
                                          strokeWidth: 0.5),
                                      FlDotData(
                                        show: false,
                                      ),
                                    );
                                  }).toList();
                                },
                                touchTooltipData: LineTouchTooltipData(
                                  showOnTopOfTheChartBoxArea: true,
                                  fitInsideVertically: true,
                                  fitInsideHorizontally: true,
                                  tooltipBgColor: toColor(model.colors.first)
                                      .withOpacity(0.2),
                                  tooltipRoundedRadius: 8,
                                  getTooltipItems:
                                      (List<LineBarSpot> lineBarsSpot) {
                                    return lineBarsSpot.map((lineBarSpot) {
                                      if (lineBarSpot.barIndex == 0) {
                                        return LineTooltipItem(
                                          lineBarsSpot[0].y.round().toString() +
                                              '/' +
                                              lineBarsSpot[1]
                                                  .y
                                                  .round()
                                                  .toString(),
                                          TextStyle(
                                              color:
                                                  toColor(model.colors.first),
                                              fontWeight: FontWeight.bold),
                                        );
                                      }
                                    }).toList();
                                  },
                                ),
                                touchCallback: (FlTouchEvent event, LineTouchResponse lineTouch) {
                                  if (event is! FlLongPressEnd &&
                                      event is! FlPanEndEvent) {
                                    final value = lineTouch.lineBarSpots[0].x;
                                    setState(() {
                                      touchIndex = value.toInt();
                                    });
                                  } else {
                                    touchIndex = -1;
                                  }
                                }),
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(
                              bottomTitles: SideTitles(
                                showTitles: true,
                                margin: 16,
                                reservedSize: -16,
                                getTextStyles: (context, value) {
                                  return TextStyle(
                                      color: touchIndex == value.toInt()
                                          ? R.color.black
                                          : Color(0xffC0C2C5),
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal);
                                },
                                getTitles: (double value) {
                                  if (value.toInt() > dates.length - 1) {
                                    return '';
                                  }
                                  final date = dates[value.toInt()];
                                  if (date == null) {
                                    return '';
                                  } else {
                                    return convertToUTC(date, 'dd/MM');
                                  }
                                },
                              ),
                              leftTitles: SideTitles(
                                  showTitles: true,
                                  getTitles: (double value) {
                                    return '';
                                  }),
                            ),
                            borderData: FlBorderData(
                              show: false,
                            ),
                            minX: 0,
                            maxX: trends.length.toDouble(),
                            maxY: maxY,
                            minY: minY,
                            lineBarsData: linesBarData(model),
                          ),
                          swapAnimationDuration: Duration(milliseconds: 250),
                        )),
                    SizedBox(height: 340)
                  ])),
            )
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Row(children: [
              Container(
                  width: 14, height: 14, color: toColor(model.colors.first)),
              SizedBox(width: 8),
              Text(model.legends.first)
            ]),
            Row(children: [
              Container(
                  width: 14, height: 14, color: toColor(model.colors.last)),
              SizedBox(width: 8),
              Text(model.legends.last)
            ])
          ]),
          SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/bloodPressureTable', arguments: {
                'title': '',
                'bloodPressureType': null,
                'periodFilterType': periodFilterType,
                'isPulseRate': false
              });
            },
            child: Container(
              color: R.color.transparent,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Xem chi tiết', style: TextStyle(color: mainColor)),
                Image.asset('assets/images/icon_arrow_right.png',
                    width: 20, height: 20)
              ]),
            ),
          )
        ],
      ),
    );
  }

  List<LineChartBarData> linesBarData(BloodPressureTrendModel model) {
    List<SubTrendItemModel> trends = [];
    model.trendItems.items.forEach((item) {
      trends.addAll(item.subTrendItems);
    });

    return trends.length == 0
        ? []
        : [
            LineChartBarData(
              spots: List.generate(trends.length, (index) {
                return FlSpot((index).toDouble(), trends[index].systolic);
              }),
              isCurved: false,
              colors: [toColor(model.colors.first)],
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
                      color: toColor(model.colors.first),
                      strokeWidth: trends.length - 1 == index ? 18 : 0,
                      strokeColor: toColor(model.colors.first).withOpacity(0.2),
                    );
                  }),
              belowBarData: BarAreaData(
                show: false,
              ),
            ),
            LineChartBarData(
              spots: List.generate(trends.length, (index) {
                return FlSpot((index).toDouble(), trends[index].diastolic);
              }),
              isCurved: false,
              colors: [toColor(model.colors.last)],
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
                      color: toColor(model.colors.last),
                      strokeWidth: trends.length - 1 == index ? 18 : 0,
                      strokeColor: toColor(model.colors.last).withOpacity(0.2),
                    );
                  }),
              belowBarData: BarAreaData(
                show: false,
              ),
            )
          ];
  }
}
