import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/bloc/glucose/glucose_bloc.dart';
import 'package:medical/src/modal/food/food_calo_model.dart';
import 'package:medical/src/modal/food/food_statistic_trend_model.dart';
import 'package:medical/src/modal/glucose/glucose_data_trend.dart';
import 'package:medical/src/modal/glucose/glucose_trend.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/Food/food_detail_tabbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class FoodTrendChart extends StatefulWidget {
  FoodTrendChart({Key key}) : super(key: key);
  @override
  FoodTrendChartState createState() => FoodTrendChartState();
}

class FoodTrendChartState extends State<FoodTrendChart>
    with AutomaticKeepAliveClientMixin<FoodTrendChart> {
  @override
  bool get wantKeepAlive => true;

  BuildContext currentContext;
  int periodFilterType = 1;
  bool isEnergyTab = true;
  int touchIndex = -1;

  @override
  void initState() {
    periodFilterType = FoodDetailTabbarController.of(context).periodFilterType;
    super.initState();
  }

  reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    _refresh();
  }

  Future<bool> _refresh() async {
    BlocProvider.of<FoodBloc>(currentContext).add(FetchStatisticTrend(
      currentDateTime:
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      periodFilterType: periodFilterType.toString(),
    ));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final width = MediaQuery.of(context).size.width;
    return BlocProvider<FoodBloc>(
        create: (context) => FoodBloc(),
        child: BlocBuilder<FoodBloc, FoodState>(
            builder: (BuildContext context, FoodState state) {
          currentContext = context;
          FoodTrendModel model;
          if (state is FoodInitial) {
            BlocProvider.of<FoodBloc>(context).add(FetchStatisticTrend(
              currentDateTime:
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
              periodFilterType: periodFilterType.toString(),
            ));
          }
          if (state is FoodError) {
            Message.showToastMessage(context, state.message);
          }

          if (state is FoodStatisticTrendLoaded) {
            model = state.model;
          }
          return model == null
              ? Container(
                  height: 491.5,
                  child: Center(child: CircularProgressIndicator()))
              : Container(
                  color: R.color.transparent,
                  padding:
                      EdgeInsets.only(left: 18, right: 18, bottom: 18, top: 18),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Xu hướng dinh dưỡng',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        SizedBox(height: 23),
                        (isEnergyTab
                                ? model.energyChart.items.length == 0
                                : model.carbChart.items.length == 0)
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/add_food',
                                      arguments: {'type': 'input', 'id': null});
                                },
                                child:
                                    Image.asset(R.drawable.food_empty),
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
                                child: buildChart(isEnergyTab
                                    ? model.energyChart
                                    : model.carbChart))
                        // SizedBox(height: 26),
                      ]),
                );
        }));
  }

  buildChart(EnergyTrendModel model) {
    final width = (MediaQuery.of(context).size.width - 200) / 5;

    double minY = model.items.map<double>((e) => e.value).reduce(min);
    minY = (minY * (model.items.length == 1 ? 0.5 : 0.8)).roundToDouble();
    double maxY = model.items.map<double>((e) => (e.value)).reduce(max);
    maxY = (maxY * (model.items.length == 1 ? 1.5 : 1.2)).roundToDouble();
    final jumpValue = (maxY - minY) / 4;
    List<int> number =
        List.generate(5, (index) => (jumpValue * index + minY).round())
            .reversed
            .toList();

    return Padding(
      padding: EdgeInsets.only(top: 19, bottom: 0, right: 16, left: 0),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isEnergyTab = true;
                });
              },
              child: Container(
                  height: 32,
                  width: 135,
                  padding: EdgeInsets.only(left: 18, right: 18),
                  decoration: BoxDecoration(
                      color:
                          isEnergyTab ? R.color.mainColor : R.color.transparent,
                      border: Border.all(
                          color: isEnergyTab
                              ? R.color.mainColor
                              : R.color.primaryGreyColor,
                          width: 0.5),
                      borderRadius: BorderRadius.circular(16)),
                  child: Center(
                    child: Text('Năng lượng',
                        style: TextStyle(
                            color:
                                isEnergyTab ? R.color.white : R.color.primaryGreyColor,
                            fontSize: 14,
                            fontWeight: isEnergyTab
                                ? FontWeight.w700
                                : FontWeight.w400)),
                  )),
            ),
            SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  isEnergyTab = false;
                });
              },
              child: Container(
                  height: 32,
                  width: 135,
                  decoration: BoxDecoration(
                      color:
                          isEnergyTab ? R.color.transparent : R.color.mainColor,
                      border: Border.all(
                          color: isEnergyTab ? R.color.primaryGreyColor : R.color.white,
                          width: 0.5),
                      borderRadius: BorderRadius.circular(16)),
                  child: Center(
                    child: Text('Chất bột đường',
                        style: TextStyle(
                            color:
                                isEnergyTab ? R.color.primaryGreyColor : R.color.white,
                            fontSize: 14,
                            fontWeight: isEnergyTab
                                ? FontWeight.w400
                                : FontWeight.w700)),
                  )),
            )
          ]),
          SizedBox(height: 36),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 8),
            Container(
              width: 44,
              height: 300,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(number.length, (index) {
                    return Text(formatNumber(number[index].toDouble()),
                        style: TextStyle(
                            fontSize: 14,
                            color: R.color.black,
                            fontWeight: FontWeight.normal));
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
                    model.avgValue > maxY || model.avgValue < minY
                        ? SizedBox()
                        : Container(
                            height: 300,
                            padding: EdgeInsets.only(top: 8, bottom: 8),
                            child: Column(
                              children: [
                                SizedBox(
                                    height:
                                        284 - (284 * model.avgValue / maxY)),
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
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(
                              bottomTitles: SideTitles(
                                showTitles: true,
                                margin: 16,
                                reservedSize: -16,
                                getTextStyles: (context, value) {
                                  return TextStyle(
                                      color: R.color.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal);
                                },
                                getTitles: (double value) {
                                  if (value.toInt() > model.items.length - 1) {
                                    return '';
                                  }
                                  final date = model.items[value.toInt()].date;
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
                            maxX: model.items.length.toDouble(),
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
                return FlSpot((index).toDouble(), model.items[index].value);
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
