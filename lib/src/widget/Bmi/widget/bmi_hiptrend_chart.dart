import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/weight/weight_bloc.dart';
import 'package:medical/src/modal/bmi/weight_trend.dart';
import 'package:medical/src/repo/weight/weight_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/bmi/bmi_detail_tabbar.dart';
import 'package:medical/src/widget/bmi/widget/add_bmi.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widgets/empty_data_box.dart';
import 'package:visibility_detector/visibility_detector.dart';

class BmiHipTrendChart extends StatefulWidget {
  BmiHipTrendChart({Key? key}) : super(key: key);

  @override
  BmiHipTrendChartState createState() => BmiHipTrendChartState();
}

class BmiHipTrendChartState extends State<BmiHipTrendChart>
    with AutomaticKeepAliveClientMixin<BmiHipTrendChart> {
  @override
  bool get wantKeepAlive => true;

  late BuildContext currentContext;
  int periodFilterType = 3;
  int trendTypeIndex = 1;
  int touchIndex = -1;
  String trendType = R.string.all.tr();
  int? previousDate = 0;

  @override
  void initState() {
    periodFilterType = BmiDetailTabbarController.of(context)!.periodFilterType;
    super.initState();
  }

  reloadData(int periodFilter) async {
    periodFilterType = periodFilter;
    BlocProvider.of<WeightBloc>(currentContext).add(FetchTrendHip(
        currentDateTime:
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        periodFilterType: periodFilterType.toString(),
        page: periodFilterType.toString()));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final width = MediaQuery.of(context).size.width;
    return BlocProvider<WeightBloc>(
        create: (context) => WeightBloc(),
        child: BlocBuilder<WeightBloc, WeightState>(
            builder: (BuildContext context, WeightState state) {
          currentContext = context;
          TrendWeightModel? model;

          if (state is WeightInitial) {
            BlocProvider.of<WeightBloc>(context).add(FetchTrendHip(
                currentDateTime:
                    (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
                periodFilterType: periodFilterType.toString(),
                page: '1'));
          }
          if (state is WeightError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is WeightTrendLoaded) {
            model = state.trend;
          }
          return model == null
              ? Container(
                  height: 491.5,
                  child: Center(child: CircularProgressIndicator()))
              : VisibilityDetector(
                  key: Key('bmi_hiptrend_chart'),
                  onVisibilityChanged: (visibilityInfo) {
                    var visiblePercentage =
                        visibilityInfo.visibleFraction * 100;
                    if (visiblePercentage == 0) {
                      previousDate = 0;
                    }
                  },
                  child: Container(
                    color: R.color.transparent,
                    padding: EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(R.string.waist_trend.tr(),
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    barrierColor: R.color.color0xff003F38
                                        .withOpacity(0.5),
                                    context: context,
                                    builder: (_) => CustomNumPicker(
                                        callback: (number) {
                                          if (number != null)
                                            submitTarget(number);
                                        },
                                        title: R.string.muc_tieu_vong_eo.tr(),
                                        max: 180,
                                        numberDefault:
                                            (model!.goal ?? 60).toInt(),
                                        unit: R.string.cm.tr()),
                                  );
                                },
                                child: Container(
                                  color: R.color.transparent,
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        R.drawable.ic_circle_plus_exe,
                                        width: 24,
                                        height: 24,
                                      ),
                                      SizedBox(width: 4),
                                      Text(R.string.muc_tieu_moi.tr(),
                                          style: TextStyle(
                                              color: R.color.mainColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Container(
                              width: width,
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
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 18,
                                        bottom: 18,
                                        left: 20,
                                        right: 20),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(R.string.hien_tai.tr(),
                                                  style:
                                                      R.style.normalTextStyle),
                                              Row(
                                                children: [
                                                  // model. ?
                                                  model.current == 0
                                                      ? Text('--',
                                                          style: TextStyle(
                                                              color: R.color
                                                                  .textDark,
                                                              fontSize: 24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700))
                                                      : Text(
                                                          model.current!
                                                              .toInt()
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Viga',
                                                              color: R.color
                                                                  .textDark,
                                                              fontSize: 24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 6.0,
                                                            left: 2,
                                                            right: 2),
                                                    child: Text(
                                                      R.string.cm.tr(),
                                                      style: R.style
                                                          .normalTextStyle,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 16,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(R.string.muc_tieu.tr(),
                                                  style:
                                                      R.style.normalTextStyle),
                                              Row(
                                                children: [
                                                  model.goal == null
                                                      ? Text('--',
                                                          style: TextStyle(
                                                              color: R.color
                                                                  .textDark,
                                                              fontSize: 24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700))
                                                      : Text(
                                                          model.goal!
                                                              .toInt()
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Viga',
                                                              color:
                                                                  R.color.green,
                                                              fontSize: 24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 6.0, left: 2),
                                                    child: Text(
                                                      R.string.cm.tr(),
                                                      style: R.style
                                                          .normalTextStyle,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ]),
                                  ),
                                  model.trendItems == null
                                      ? EmptyDataBox(
                                          text: "chỉ số Cân nặng",
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, NavigatorName.add_bmi,
                                                arguments: {
                                                  'type': 'input',
                                                });
                                          },
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            color: R.color.white,
                                          ),
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16, right: 16),
                                              child: buildChart(model)),
                                        ),
                                ],
                              )),
                          // buildDescription(model)
                        ]),
                  ),
                );
        }));
  }

  buildChart(TrendWeightModel model) {
    final width = (MediaQuery.of(context).size.width - 200) / 5;
    int length = model.trendItems!.length;
    List<int?> dates = [];
    List<TrendItemWeightModel> trends = model.trendItems!;
    model.trendItems!.forEach((element) {
      dates.add(element.date);
      // List.generate(element.subTrends.length - 1, (index) => dates.add(null));
    });

    double minY = trends.map<double>((e) => e.value ?? 0).reduce(min);
    minY = (minY * (trends.length == 1 ? 0.5 : 0.8)).roundToDouble();
    double maxY = trends.map<double>((e) => e.value ?? 0).reduce(max);
    maxY = (maxY * (trends.length == 1 ? 1.5 : 1.2)).roundToDouble();
    final jumpValue = (maxY - minY) / 4;
    List<int> number =
        List.generate(5, (index) => (jumpValue * index + minY).round())
            .reversed
            .toList();

    return Padding(
      padding: EdgeInsets.only(top: 0, bottom: 0, right: 0, left: 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Container(height: 1, color: R.color.color0xffE5E5E5),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('${R.string.nho_nhat.tr()}:',
                        style: TextStyle(
                            fontSize: 14,
                            color: R.color.black,
                            fontWeight: FontWeight.w400)),
                    SizedBox(
                      width: 4,
                    ),
                    Text('${model.lowest!.toInt()}',
                        style: TextStyle(
                            fontSize: 16,
                            color: R.color.black,
                            fontWeight: FontWeight.w600)),
                    SizedBox(
                      width: 4,
                    ),
                    Text(R.string.cm.tr(),
                        style: TextStyle(
                            fontSize: 14,
                            color: R.color.black,
                            fontWeight: FontWeight.w400)),
                  ],
                ),
                Row(
                  children: [
                    Text('${R.string.lon_nhat.tr()}:',
                        style: TextStyle(
                            fontSize: 14,
                            color: R.color.black,
                            fontWeight: FontWeight.w400)),
                    SizedBox(
                      width: 4,
                    ),
                    Text('${model.highest!.toInt()}',
                        style: TextStyle(
                            fontSize: 16,
                            color: R.color.black,
                            fontWeight: FontWeight.w600)),
                    SizedBox(
                      width: 4,
                    ),
                    Text(R.string.cm.tr(),
                        style: TextStyle(
                            fontSize: 14,
                            color: R.color.black,
                            fontWeight: FontWeight.w400)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 30,
              height: 300,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(number.length, (index) {
                    return Text(number[index].toString(),
                        style: R.style.normalTextStyle);
                  })),
            ),
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
                                        color: R.color.grayComponentBorder,
                                      ),
                                    )))),
                    model.goal == null ||
                            model.goal! < minY ||
                            model.goal! > maxY
                        ? SizedBox()
                        : Container(
                            height: 300,
                            padding:
                                EdgeInsets.only(left: 8, top: 8, bottom: 8),
                            child: Column(
                              children: [
                                SizedBox(
                                    height: 284 -
                                        (284 *
                                            (model.goal! - minY) /
                                            (maxY - minY))),
                                Container(
                                    width: ((length < 5 ? 5 : length) *
                                                (width + 20))
                                            .toDouble() -
                                        36,
                                    height: 0.5,
                                    color: R.color.green),
                              ],
                            ),
                          ),
                    Container(
                        width: ((length < 5 ? 5 : length) * (width + 20))
                            .toDouble(),
                        height: 300,
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: LineChart(
                          LineChartData(
                            lineTouchData: LineTouchData(
                                getTouchLineStart: (barData, index) =>
                                    -double.infinity, // default: from bottom
                                getTouchLineEnd: (barData, index) =>
                                    double.infinity, //to top
                                getTouchedSpotIndicator:
                                    (LineChartBarData barData,
                                        List<int> spotIndexes) {
                                  return spotIndexes.map((index) {
                                    return TouchedSpotIndicatorData(
                                      FlLine(
                                        color: toColor(trends[index].colorCode),
                                        strokeWidth: 0.5,
                                        // dashArray: [1, 2]
                                      ),
                                      FlDotData(
                                        show: true,
                                        getDotPainter:
                                            (spot, percent, barData, index) =>
                                                FlDotCirclePainter(
                                          radius: 6.5,
                                          color: toColor(
                                              trends[touchIndex].colorCode),
                                          strokeWidth: 18,
                                          strokeColor: toColor(
                                                  trends[touchIndex].colorCode)
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                    );
                                  }).toList();
                                },
                                touchTooltipData: LineTouchTooltipData(
                                  showOnTopOfTheChartBoxArea: true,
                                  fitInsideVertically: true,
                                  tooltipBgColor: touchIndex == -1
                                      ? toColor(trends.last.colorCode)
                                          .withOpacity(0.8)
                                      : toColor(trends[touchIndex].colorCode)
                                          .withOpacity(0.8),
                                  tooltipRoundedRadius: 8,
                                  getTooltipItems:
                                      (List<LineBarSpot> lineBarsSpot) {
                                    return lineBarsSpot.map((lineBarSpot) {
                                      return LineTooltipItem(
                                        lineBarSpot.y.round() == lineBarSpot.y
                                            ? lineBarSpot.y.round().toString() +
                                                ' ${R.string.cm.tr()}'
                                            : lineBarSpot.y.toString() +
                                                ' ${R.string.cm.tr()}',
                                        TextStyle(
                                            color: R.color.white,
                                            fontWeight: FontWeight.bold),
                                      );
                                    }).toList();
                                  },
                                ),
                                touchCallback: (FlTouchEvent event,
                                    LineTouchResponse? lineTouch) {
                                  previousDate = 0;
                                  if (lineTouch?.lineBarSpots?.length == 1 &&
                                      event is! FlLongPressEnd &&
                                      event is! FlPanEndEvent) {
                                    final value = lineTouch?.lineBarSpots?[0].x;

                                    if (value != null) {
                                      //   setState(() {
                                      touchIndex = value.toInt();
                                      //   });
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
                                reservedSize: -16,
                                getTextStyles: (context, value) {
                                  return TextStyle(
                                      color: touchIndex == value.toInt()
                                          ? R.color.black
                                          : R.color.color0xffC0C2C5,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal);
                                },
                                getTitles: (double value) {
                                  if (value.toInt() > dates.length - 1) {
                                    return '';
                                  }
                                  final date = dates[value.toInt()];

                                  if (previousDate == date) return '';
                                  previousDate = date;

                                  if (date == null) {
                                    return '';
                                  } else {
                                    final dateTime =
                                        DateTime.fromMillisecondsSinceEpoch(
                                            date * 1000);
                                    if (dateTime.hour > 0 &&
                                        dateTime.hour < 7) {
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
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 16, top: 16),
            child: Row(
              children: [
                model.iconUrl!.isEmpty
                    ? SizedBox()
                    : Image.asset(
                        R.drawable.ic_happy_weight,
                        width: 24,
                        height: 24,
                      ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(model.message!, style: R.style.normalTextStyle),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<LineChartBarData> linesBarData(TrendWeightModel model) {
    List<TrendItemWeightModel> trends = model.trendItems!;

    return trends.length == 0
        ? []
        : [
            LineChartBarData(
              spots: List.generate(trends.length, (index) {
                return FlSpot((index).toDouble(), trends[index].value!);
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
                      radius: 4,
                      color: toColor(trends[index].colorCode),
                      strokeWidth: trends.length - 1 == index ? 18 : 0,
                      strokeColor:
                          toColor(trends.last.colorCode).withOpacity(0.2),
                    );
                  }),
              belowBarData: BarAreaData(show: false),
            )
          ];
  }

  submitTarget(int value) async {
    try {
      BotToast.showLoading();
      await WeightClient().addWaistTarget(value);
      reloadData(periodFilterType);
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
