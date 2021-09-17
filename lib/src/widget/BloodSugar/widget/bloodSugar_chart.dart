import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/glucose/glucose_bloc.dart';
import 'package:medical/src/modal/glucose/glucose_data_trend.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/BloodSugar/bloodSugar_detail_tabbar.dart';
import 'package:medical/src/widget/BloodSugar/widget/action_list_filter_trend.dart';
import 'package:medical/src/widget/HbA1C/hba1c_tabble.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/modal/glucose/glucose_trend.dart';

class BloodSugarChart extends StatefulWidget {
  BloodSugarChart({Key key}) : super(key: key);
  @override
  BloodSugarChartState createState() => BloodSugarChartState();
}

class BloodSugarChartState extends State<BloodSugarChart>
    with AutomaticKeepAliveClientMixin<BloodSugarChart> {
  @override
  bool get wantKeepAlive => true;
  BuildContext currentContext;
  int value = 0;
  int touchIndex = -1;
  String trendType = 'Tất cả';
  int trendTypeIndex = 1;
  int periodFilterType = 1;

  void initState() {
    periodFilterType =
        BloodSugarDetailTabbarController.of(context).periodFilterType;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // final width = MediaQuery.of(context).size.width;
    // final height = 37.0;
    return BlocProvider<GlucoseBloc>(
        create: (context) => GlucoseBloc(),
        child: BlocBuilder<GlucoseBloc, GlucoseState>(
            builder: (BuildContext context, GlucoseState state) {
          currentContext = context;
          TrendDataModel model;

          if (state is GlucoseInitial) {
            BlocProvider.of<GlucoseBloc>(context).add(FetchTrendGlucose(
                trendType: trendTypeIndex.toString(),
                currentDateTime:
                    (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
                periodFilterType: periodFilterType.toString(),
                page: '1'));
          }
          if (state is GlucoseError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is GlucoseTrendLoaded) {
            model = state.trend;
          }

          return model == null
              ? Container(
                  height: 450,
                  child: Center(child: CircularProgressIndicator()))
              : Padding(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('Xu hướng đường huyết',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Container(
                              decoration: BoxDecoration(
                                  color: R.color.white,
                                  borderRadius: BorderRadius.circular(200.0),
                                  border: Border.all(color: R.color.grayBorder)),
                              child: GestureDetector(
                                onTap: () {
                                  showActionTrendFilter(context);
                                },
                                child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      color: R.color.transparent,
                                      padding: const EdgeInsets.only(
                                          top: 4,
                                          bottom: 4,
                                          left: 12,
                                          right: 8),
                                      child: Row(
                                        children: [
                                          Text(trendType != null
                                              ? trendType
                                              : 'Tất cả'),
                                          SizedBox(width: 4),
                                          Image.asset(
                                              'assets/images/chevron_down.png',
                                              width: 24,
                                              height: 24)
                                        ],
                                      ),
                                    )),
                              )),
                        ],
                      ),
                      SizedBox(height: 23),
                      model.trendItems.items.length == 0
                          ? GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/add_bloodSugar',
                                    arguments: {'type': 'input', 'id': null});
                              },
                              child: Image.asset(
                                  'assets/images/glucose_trend.png'),
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
                                    offset: Offset(
                                        0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              //padding: EdgeInsets.all(16),
                              child: Column(children: [
                                //SizedBox(height: 32),
                                buildChart(model),

                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, '/bloodSugarTable',
                                        arguments: {
                                          'title': trendType,
                                          'timeFrameType': trendTypeIndex,
                                          'periodFilterType': periodFilterType,
                                          'glucoseDistributionType': null
                                        });
                                  },
                                  child: Container(
                                    color: R.color.transparent,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text('Xem chi tiết',
                                              style:
                                                  TextStyle(color: R.color.mainColor)),
                                          Image.asset(
                                              'assets/images/icon_arrow_right.png',
                                              width: 20,
                                              height: 20)
                                        ]),
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                )
                              ])),
                    ],
                  ),
                );
        }));
  }

  buildChart(TrendDataModel model) {
    final width = (MediaQuery.of(context).size.width - 200) / 5;

    int length = 0;
    List<int> dates = [];
    List<TrendModel> trends = [];
    model.trendItems.items.forEach((element) {
      length += element.subTrends.length;
      dates.add(element.date);
      trends.addAll(element.subTrends);
      List.generate(element.subTrends.length - 1, (index) => dates.add(null));
    });

    double minY = trends.map<double>((e) => e.glucose).reduce(min);
    minY = (minY * (trends.length == 1 ? 0.5 : 0.8)).roundToDouble();
    double maxY = trends.map<double>((e) => e.glucose).reduce(max);
    maxY = (maxY * (trends.length == 1 ? 1.5 : 1.2)).roundToDouble();
    final jumpValue = (maxY - minY) / 4;
    List<int> number =
        List.generate(5, (index) => (jumpValue * index + minY).round())
            .reversed
            .toList();

    return Padding(
      padding: EdgeInsets.only(top: 32, bottom: 0, right: 18, left: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //SizedBox(width: 8),
        Container(
          width: 36,
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
        SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
              reverse: length > 1,
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
                                    width: ((length < 5 ? 5 : length) *
                                                (width + 20))
                                            .toDouble() -
                                        36,
                                    color: Color(0xffDDDDDD),
                                  ),
                                )))),
                trendTypeIndex == 1 ||
                        (model.goodRange.value == 0 &&
                            model.goodRange.key == 0) ||
                        model.goodRange.value > maxY ||
                        model.goodRange.key < minY
                    ? Container()
                    : Container(
                        height: 300,
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: Column(
                          children: [
                            SizedBox(
                                height: 284 -
                                    (284 *
                                        (model.goodRange.value - minY) /
                                        (maxY - minY))),
                            Container(
                                width:
                                    ((length < 5 ? 5 : length) * (width + 20))
                                            .toDouble() -
                                        36,
                                height: 0.75,
                                color: Color(0xff21A567)),
                            Container(
                                width:
                                    ((length < 5 ? 5 : length) * (width + 20))
                                            .toDouble() -
                                        36,
                                height: ((model.goodRange.value -
                                        model.goodRange.key) *
                                    (284 / (maxY - minY))),
                                color: Color(0xff21A567).withOpacity(0.1)),
                            Container(
                                width:
                                    ((length < 5 ? 5 : length) * (width + 20))
                                            .toDouble() -
                                        36,
                                height: 0.75,
                                color: Color(0xff21A567)),
                          ],
                        ),
                      ),
                Container(
                    width:
                        ((length < 5 ? 5 : length) * (width + 20)).toDouble(),
                    height: 300,
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                             getTouchLineStart: (barData, index) => -double.infinity, // default: from bottom
                                getTouchLineEnd: (barData, index) => double.infinity, //to top
                            getTouchedSpotIndicator: (LineChartBarData barData,
                                List<int> spotIndexes) {
                              return spotIndexes.map((index) {
                                return TouchedSpotIndicatorData(
                                  FlLine(
                                      color: toColor(trends[index].color),
                                      strokeWidth: 0.5),
                                  FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) =>
                                            FlDotCirclePainter(
                                      radius: 6.5,
                                      color: toColor(trends[index].color),
                                      strokeWidth: 18,
                                      strokeColor: toColor(trends[index].color)
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                );
                              }).toList();
                            },
                            touchTooltipData: LineTouchTooltipData(
                              showOnTopOfTheChartBoxArea: true,
                              fitInsideHorizontally: true,
                              fitInsideVertically: true,
                              tooltipBgColor: touchIndex == -1
                                  ? R.color.transparent
                                  : toColor(trends[touchIndex].color)
                                      .withOpacity(0.2),
                              tooltipRoundedRadius: 8,
                              getTooltipItems:
                                  (List<LineBarSpot> lineBarsSpot) {
                                return lineBarsSpot.map((lineBarSpot) {
                                  return LineTooltipItem(
                                    lineBarSpot.y.round() == lineBarSpot.y
                                        ? lineBarSpot.y.round().toString()
                                        : lineBarSpot.y.toString(),
                                    TextStyle(
                                        color: toColor(
                                            trends[lineBarSpot.spotIndex]
                                                .color),
                                        fontWeight: FontWeight.bold),
                                  );
                                }).toList();
                              },
                            ),
                            touchCallback: (FlTouchEvent event, LineTouchResponse lineTouch) {
                              if (lineTouch.lineBarSpots.length == 1 &&
                                  event is! FlLongPressEnd &&
                                  event is! FlPanEndEvent) {
                                final value = lineTouch.lineBarSpots[0].x;
                                setState(() {
                                  touchIndex = value.toInt();
                                });
                              } else {
                                touchIndex = -1;
                              }
                            }),
                        gridData: FlGridData(
                          show: false,
                        ),
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
                        maxX: length.toDouble(),
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
    );
  }

  List<LineChartBarData> linesBarData(TrendDataModel model) {
    List<TrendModel> trends = [];
    model.trendItems.items.forEach((item) {
      trends.addAll(item.subTrends);
    });

    return trends.length == 0
        ? []
        : [
            LineChartBarData(
              spots: List.generate(trends.length, (index) {
                return FlSpot((index).toDouble(), trends[index].glucose);
              }),
              isCurved: false,
              colors:
                  trendTypeIndex == 1 ? [R.color.transparent] : [R.color.black],
              barWidth: 0.75,
              isStrokeCapRound: true,
              dotData: FlDotData(
                  show: true,
                  // checkToShowDot: (spot, barData) {
                  //   return spot.x == trends.length - 1;
                  // },
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: toColor(trends[index].color),
                      strokeWidth: trends.length - 1 == index ? 18 : 0,
                      strokeColor: toColor(trends.last.color).withOpacity(0.2),
                    );
                  }),
              belowBarData: BarAreaData(
                show: false,
              ),
            )
          ];
  }

  showDialog(BuildContext context) {
    //Navigator.pushNamed(context, '/hba1c_tabble');
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => HbA1CTable()));
  }

  showActionTrendFilter(BuildContext context) {
    // setState(() {
    //   this.isChoose = !isChoose;
    // });
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        backgroundColor: R.color.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => ActionListFilterTrend(
            selectedIndex: trendTypeIndex,
            callback: (value, index) {
              trendType = value;
              trendTypeIndex = index + 1;
              reloadData(periodFilterType);
            }));
  }

  reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    BlocProvider.of<GlucoseBloc>(currentContext).add(FetchTrendGlucose(
        trendType: trendTypeIndex.toString(),
        currentDateTime:
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        periodFilterType: periodFilterType.toString(),
        page: '1'));
  }
}
