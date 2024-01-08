import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../res/R.dart';
import '../../../modal/food/food_statistic_trend_model.dart';
import '../../helper/helper.dart';

class FoodTrendChartTabView extends StatefulWidget {
  final EnergyTrendModel model;
  final double width;
  final int type;

  FoodTrendChartTabView({required this.model, required this.width, required this.type});

  @override
  FoodTrendChartTabViewState createState() => FoodTrendChartTabViewState();
}

class FoodTrendChartTabViewState extends State<FoodTrendChartTabView>
    with AutomaticKeepAliveClientMixin<FoodTrendChartTabView> {

  late EnergyTrendModel model;
  
  int touchIndex = -1;
  int? previousDate = 0;
  double minY = 0;
  double maxY = 0;
  List<int> number = [];
  double jumpValue = 0;
  double width = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    model = widget.model;
    width = widget.width;

    minY = model.items.map<double>((e) => e.value ?? 0).reduce(min);
    minY = (minY * (model.items.length == 1 ? 0.5 : 0.8)).roundToDouble();
    maxY = model.items.map<double>((e) => (e.value ?? 0)).reduce(max);
    maxY = (maxY * (model.items.length == 1 ? 1.5 : 1.2)).roundToDouble();
    jumpValue = (maxY - minY) / 4;
    number =
        List.generate(5, (index) => (jumpValue * index + minY).round())
            .reversed
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
            key: Key('food_trend_chart${widget.type}'),
            onVisibilityChanged: (visibilityInfo) {
              var visiblePercentage = visibilityInfo.visibleFraction * 100;
              if(visiblePercentage == 0){
                previousDate = 0;
              }
            },
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 8),
              Container(
                width: 44,
                height: 300,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(number.length, (index) {
                      return Text(formatNumber(number[index].toDouble()),
                          style: R.style.normalTextStyle);
                    })),
              ),
              SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                    reverse: model.items.length > 1,
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
                                            top: 8, bottom: 8, left: 8),
                                        child: Container(
                                          height: 1,
                                          width: ((model.items.length < 5
                                                          ? 5
                                                          : model.items.length) *
                                                      (width + 20))
                                                  .toDouble() -
                                              36,
                                          color: R.color.grayComponentBorder,
                                        ),
                                      )))),
                      model.avgValue! > maxY || model.avgValue! < minY
                          ? SizedBox()
                          : Container(
                              height: 300,
                              padding: EdgeInsets.only(top: 8, bottom: 8),
                              child: Column(
                                children: [
                                  SizedBox(
                                      height:
                                          284 - (284 * model.avgValue! / maxY)),
                                  Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Container(
                                      color: R.color.color0xff72CB9C,
                                      width: ((model.items.length < 5
                                                      ? 5
                                                      : model.items.length) *
                                                  (width + 20))
                                              .toDouble() -
                                          36,
                                      height: 0.5,
                                    ),
                                  )
                                ],
                              ),
                            ),
                      Container(
                          width:
                              ((model.items.length < 5 ? 5 : model.items.length) *
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
                                            color: toColor(
                                                model.items[index].colorCode),
                                            strokeWidth: 0.5),
                                        FlDotData(
                                          show: true,
                                          getDotPainter:
                                              (spot, percent, barData, index) =>
                                                  FlDotCirclePainter(
                                            radius: 6.5,
                                            color: toColor(
                                                model.items[index].colorCode),
                                            strokeWidth: 18,
                                            strokeColor: toColor(
                                                    model.items[index].colorCode)
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                      );
                                    }).toList();
                                  },
                                  touchTooltipData: LineTouchTooltipData(
                                    showOnTopOfTheChartBoxArea: true,
                                    fitInsideVertically: true,
                                    fitInsideHorizontally: true,
                                    tooltipBgColor: touchIndex == -1
                                        ? R.color.transparent
                                        : toColor(
                                                model.items[touchIndex].colorCode)
                                            .withOpacity(0.2),
                                    tooltipRoundedRadius: 8,
                                    getTooltipItems:
                                        (List<LineBarSpot> lineBarsSpot) {
                                      return lineBarsSpot.map((lineBarSpot) {
                                        return LineTooltipItem(
                                          formatNumber(lineBarSpot.y),
                                          TextStyle(
                                              color: toColor(model
                                                  .items[lineBarSpot.spotIndex]
                                                  .colorCode),
                                              fontWeight: FontWeight.bold),
                                        );
                                      }).toList();
                                    },
                                  ),
                                  touchCallback: (FlTouchEvent event, LineTouchResponse? lineTouch) {
                                    previousDate = 0;
                                    if (lineTouch?.lineBarSpots != null && lineTouch!.lineBarSpots!.length == 1 &&
                                        event is! FlLongPressEnd &&
                                        event is! FlPanEndEvent) {
                                      final value = lineTouch.lineBarSpots?[0].x;
                                  //    setState(() {
                                        touchIndex = value?.toInt() ?? -1;
                                  //    });
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
                                  reservedSize: -16,
                                  getTextStyles: (context, value) {
                                    return TextStyle(
                                        color: 
                                          touchIndex == value.toInt() ? 
                                          R.color.black
                                            : R.color.color0xffC0C2C5
                                          ,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal);
                                  },
                                  getTitles: (double value) {
                                    if (value.toInt() > model.items.length - 1) {
                                      return '';
                                    }
                                    var date = model.items[value.toInt()].date;
                                    if(previousDate == date) return '';
                                    previousDate = date;
                                    if (date == null) {
                                      return '';
                                    } else {
                                      final dateTime = DateTime.fromMillisecondsSinceEpoch(date * 1000);
                                      print('duc2111 dateTime.hour = ${dateTime.hour}, date = $date');
                                      if(dateTime.hour > 0 && dateTime.hour < 7){
                                        return convertToGMT0(date, 'dd/MM');
                                      } else {
                                        return convertToUTC(date, 'dd/MM');
                                      }
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
                              maxX: model.items.length.toDouble(),
                              maxY: maxY,
                              minY: minY,
                              lineBarsData: linesBarData(model),
                            ),
                            swapAnimationDuration: Duration(milliseconds: 250),
                          )
                        ),
                      SizedBox(height: 340)
                    ]
                  )
                ),
              )
            ],
          ),
        );
  }

  List<LineChartBarData> linesBarData(EnergyTrendModel model) {
    return model.items.length == 0
        ? []
        : [
            LineChartBarData(
              spots: List.generate(model.items.length, (index) {
                return FlSpot(index.toDouble(), model.items[index].value!);
              }),
              isCurved: false,
              colors: [R.color.black],
              barWidth: 0.75,
              isStrokeCapRound: true,
              dotData: FlDotData(
                  show: true,
                  // checkToShowDot: (spot, barData) {
                  //   return spot.x == trends.length - 1;
                  // },
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: model.items.length - 1 == index ? 8 : 4,
                      color: toColor(model.items[index].colorCode),
                      strokeWidth: model.items.length - 1 == index ? 18 : 0,
                      strokeColor:
                          toColor(model.items.last.colorCode).withOpacity(0.2),
                    );
                  }),
              belowBarData: BarAreaData(
                show: false,
              ),
            )
          ];
  }
}