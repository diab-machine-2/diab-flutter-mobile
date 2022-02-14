import 'dart:math';
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/HbA1C/HbA1C_bloc.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_trend.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/HbA1C/hba1c_detail_tabbar.dart';
import 'package:medical/src/widget/HbA1C/hba1c_tabble.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:easy_localization/easy_localization.dart';

class HbA1CChart extends StatefulWidget {
  HbA1CChart({Key? key}) : super(key: key);
  @override
  HbA1CChartState createState() => HbA1CChartState();
}

class HbA1CChartState extends State<HbA1CChart>
    with AutomaticKeepAliveClientMixin<HbA1CChart> {
  @override
  bool get wantKeepAlive => true;
  late BuildContext currentContext;
  int periodFilterType = 1;
  int touchIndex = -1;

  @override
  void initState() {
    periodFilterType = Hba1cDetailTabbarController.of(context)!.periodFilterType;
    super.initState();
  }

  reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    BlocProvider.of<HbA1CBloc>(currentContext)
        .add(FetchHbA1CTrend(type: periodFilterType));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final width = MediaQuery.of(context).size.width;
    return BlocProvider<HbA1CBloc>(
        create: (context) => HbA1CBloc(),
        child: BlocBuilder<HbA1CBloc, HbA1CState>(
            builder: (BuildContext context, HbA1CState state) {
          currentContext = context;
          TrendModel? model;
          if (state is HbA1CInitial) {
            BlocProvider.of<HbA1CBloc>(context)
                .add(FetchHbA1CTrend(type: periodFilterType));
          }
          if (state is HbA1CError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is HbA1CTrendLoaded) {
            model = state.trendModel;
          }
          return model == null
              ? Container(
                  height: 491.5,
                  child: Center(child: CircularProgressIndicator()))
              : Container(
                  color: R.color.transparent,
                  padding: EdgeInsets.all(18),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(R.string.xu_huong_hba1c.tr(),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                        SizedBox(height: 20),
                        model.trendItems == null
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, NavigatorName.add_hba1c,
                                      arguments: {'type': 'input', 'id': null});
                                },
                                child: Image.asset(
                                  R.drawable.img_nothing,
                                ),
                              )
                            : Container(
                                width: width,
                                decoration: BoxDecoration(
                                  color: R.color.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(
                                            left: 8,
                                            right: 18,
                                            bottom: 0,
                                            top: 36),
                                        child: buildChart(model)),
                                    SizedBox(height: 16),
                                    buildDescription(model)
                                  ],
                                ))
                      ]),
                );
        }));
  }

  Widget buildDescription(TrendModel model) {
    List<Widget> items = [];
    model.legends!.forEach((element) {
      items.add(buildDescriptionItem(element));
    });
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 32),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, children: items),
    );
  }

  Widget buildDescriptionItem(List model) {
    final String color = model.last;
    final String title = model.first;
    return Row(children: [
      Container(
          width: 14,
          height: 14,
          color: Color(int.parse('0xff${color.split('#').join()}'))),
      SizedBox(width: 4),
      Text(title)
    ]);
  }

  showDialog(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => HbA1CTable()));
  }

  buildChart(TrendModel model) {
    double minY =
        model.trendItems!.items.map<double>((e) => e.hbA1C ?? 0).reduce(min);
    minY = (minY * (model.trendItems!.items.length == 1 ? 0.5 : 0.8))
        .roundToDouble();
    double maxY =
        model.trendItems!.items.map<double>((e) => e.hbA1C ?? 0).reduce(max);
    maxY = (maxY * (model.trendItems!.items.length == 1 ? 1.5 : 1.2))
        .roundToDouble();
    final jumpValue = (maxY - minY) / 4;
    List<double> number =
        List.generate(5, (index) => roundAsFixed(jumpValue * index + minY))
            .reversed
            .toList();

    final width = (MediaQuery.of(context).size.width - 200) / 5;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 36,
        height: 300,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(number.length, (index) {
              return Text(number[index].toString().split('.').join(','),
                  style: TextStyle(
                      fontSize: 14,
                      color: R.color.black,
                      fontWeight: FontWeight.normal));
            })),
      ),
      Expanded(
        child: SingleChildScrollView(
          reverse: true,
          scrollDirection: Axis.horizontal,
          child: Stack(children: [
            Container(
                height: 300,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                        number.length,
                        (index) => Padding(
                              padding:
                                  EdgeInsets.only(left: 8, top: 8, bottom: 8),
                              child: Container(
                                height: 1,
                                width: ((model.trendItems!.items.length < 5
                                                ? 5
                                                : model
                                                    .trendItems!.items.length) *
                                            (width + 20))
                                        .toDouble() -
                                    36,
                                color: R.color.grayComponentBorder,
                              ),
                            )))),
            Container(
                decoration: BoxDecoration(),
                width: ((model.trendItems!.items.length < 5
                            ? 5
                            : model.trendItems!.items.length) *
                        (width + 20))
                    .toDouble(),
                padding: EdgeInsets.only(top: 8, bottom: 8),
                height: 300,
                child: BarChart(
                  BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY.toDouble(),
                      minY: minY.toDouble(),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchCallback: (FlTouchEvent event, BarTouchResponse? barTouch) {
                          if (event is! FlLongPressEnd &&
                              event is! FlPanEndEvent) {
                            final value = barTouch!.spot!.touchedBarGroupIndex;
                            setState(() {
                              touchIndex = value.toInt();
                            });
                          } else {
                            touchIndex = -1;
                          }
                        },
                        touchTooltipData: BarTouchTooltipData(
                          fitInsideVertically: true,
                          tooltipBgColor: touchIndex == -1
                              ? R.color.transparent
                              : toColor(model.trendItems!.items[touchIndex]
                                  .backgroundColor),
                          tooltipPadding: const EdgeInsets.only(
                              left: 8, right: 8, top: 4, bottom: 0),
                          tooltipMargin: 22,
                          getTooltipItem: (
                            BarChartGroupData group,
                            int groupIndex,
                            BarChartRodData rod,
                            int rodIndex,
                          ) {
                            return BarTooltipItem(
                              rod.y.toString().split('.').join(',') + '%',
                              TextStyle(
                                color: touchIndex == -1
                                    ? R.color.white
                                    : toColor(model.trendItems!.items[touchIndex]
                                        .fontColor),
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: SideTitles(showTitles: false),
                        topTitles: SideTitles(showTitles: false),
                        show: true,
                        bottomTitles: SideTitles(
                          showTitles: true,
                          getTextStyles: (context, value) => TextStyle(
                              color: R.color.black,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                          margin: 16,
                          reservedSize: -16,
                          getTitles: (double value) {
                            return convertToUTC(
                                model.trendItems!.items[value.toInt()].date!,
                                'dd/MM');
                          },
                        ),
                        leftTitles: SideTitles(
                          showTitles: false,
                          getTextStyles: (context, value) => TextStyle(
                              color: R.color.black, fontSize: 14),
                        ),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups:
                          List.generate(model.trendItems!.items.length, (index) {
                        return buildBarChartGroupData(model, index);
                      })),
                )),
            IgnorePointer(
              child: Container(
                  decoration: BoxDecoration(),
                  width: ((model.trendItems!.items.length < 5
                              ? 5
                              : model.trendItems!.items.length) *
                          (width + 20))
                      .toDouble(),
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      showingTooltipIndicators: [
                        ShowingTooltipIndicators([
                          LineBarSpot(
                              LineChartBarData(show: true),
                              model.trendItems!.items.length - 1,
                              FlSpot(
                                  (model.trendItems!.items.length - 1 + 0.5)
                                      .toDouble(),
                                  model.trendItems!.items.last.hbA1C!)),
                        ])
                      ],
                      lineTouchData: LineTouchData(
                        enabled: false,
                        touchTooltipData: LineTouchTooltipData(
                            // showOnTopOfTheChartBoxArea: true,
                            fitInsideVertically: true,
                            tooltipBgColor:
                                toColor(model.trendItems!.items.last.color),
                            tooltipPadding: const EdgeInsets.only(
                                left: 8, right: 8, top: 4, bottom: 4),
                            tooltipMargin: 22,
                            getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                              return lineBarsSpot.map((lineBarSpot) {
                                return LineTooltipItem(
                                  model.trendItems!.items.last.hbA1C
                                          .toString()
                                          .split('.')
                                          .join(',') +
                                      '%',
                                  TextStyle(
                                      color: toColor(model
                                          .trendItems!.items.last.fontColor),
                                      fontWeight: FontWeight.bold),
                                );
                              }).toList();
                            }),
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: SideTitles(showTitles: false),
                        topTitles: SideTitles(showTitles: false),
                        bottomTitles: SideTitles(
                          margin: 16,
                          reservedSize: -16,
                          showTitles: true,
                          getTitles: (value) {
                            return '';
                          },
                        ),
                        leftTitles: SideTitles(
                          showTitles: false,
                          getTitles: (value) {
                            return '';
                          },
                        ),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      minX: 0,
                      maxX: model.trendItems!.items.length.toDouble(),
                      maxY: maxY.toDouble(),
                      minY: minY.toDouble(),
                      lineBarsData: linesBarData(model),
                    ),
                    swapAnimationDuration: Duration(milliseconds: 250),
                  )),
            ),
            SizedBox(height: 340)
          ]),
        ),
      )
    ]);
  }

  BarChartGroupData buildBarChartGroupData(TrendModel model, int index) {
    final color = toColor(model.trendItems!.items[index].color);
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
            width: 20,
            borderRadius: BorderRadius.circular(0),
            y: model.trendItems!.items[index].hbA1C!,
            colors: [color.withOpacity(0.5), color]),
      ],
    );
  }

  List<LineChartBarData> linesBarData(TrendModel model) {
    final LineChartBarData lineChartBarData1 = LineChartBarData(
      spots: List.generate(model.trendItems!.items.length, (index) {
        return FlSpot(
            (index + 0.5).toDouble(), model.trendItems!.items[index].hbA1C!);
      }),
      isCurved: false,
      colors: [R.color.black],
      barWidth: 1,
      isStrokeCapRound: true,
      dotData: FlDotData(
          show: true,
          checkToShowDot: (spot, barData) {
            return spot.x == model.trendItems!.items.length - 0.5;
          },
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 6,
              color: toColor(model.trendItems!.items.last.backgroundColor),
              strokeWidth: 12,
              strokeColor: toColor(model.trendItems!.items.last.backgroundColor)
                  .withOpacity(0.2),
            );
          }),
      belowBarData: BarAreaData(
        show: false,
      ),
    );

    return [
      lineChartBarData1,
    ];
  }
}
