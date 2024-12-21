import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/bloc/glucose/glucose_bloc.dart';
import 'package:medical/src/modal/glucose/glucose_data_trend.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodSugar/bloodSugar_detail_tabbar.dart';
import 'package:medical/src/widget/BloodSugar/widget/action_list_filter_trend.dart';
import 'package:medical/src/widget/HbA1C/hba1c_tabble.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/modal/glucose/glucose_trend.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widgets/empty_data_box.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../blood_sugar_functions.dart';

class BloodSugarChart extends StatefulWidget {
  BloodSugarChart({Key? key, required this.periodFilterType}) : super(key: key);

  final int periodFilterType;

  @override
  BloodSugarChartState createState() => BloodSugarChartState();
}

class BloodSugarChartState extends State<BloodSugarChart>
    with AutomaticKeepAliveClientMixin<BloodSugarChart> {
  @override
  bool get wantKeepAlive => true;

  final _bloc = GlucoseBloc();

  StreamSubscription? _subscription;

  late BuildContext currentContext;
  int value = 0;
  int touchIndex = -1;
  String? trendType = R.string.all.tr();
  int trendTypeIndex = 1;
  int periodFilterType = 3;
  int? previousDate = 0;

  int minXIndex = 0;
  int maxXIndex = 0;

  String? _aiSuggestion;

  @override
  void initState() {
    super.initState();
    periodFilterType =
        BloodSugarDetailTabbarController.of(context)?.periodFilterType ?? widget.periodFilterType;
    _loadAISuggestion();
    _subscription = _bloc.stream.listen((state) async {
      if (state is GlucoseTrendLoaded) {
        _subscription?.cancel();
        _subscription = null;

        // Navigate to input if no data
        List<TrendModel> trends = [];
        state.trend.trendItems.items.forEach((item) {
          trends.addAll(item.subTrends);
        });
        if (trends.isEmpty) {
          await Future.delayed(Duration(milliseconds: 500));
          Navigator.pushNamed(context, NavigatorName.add_blood_sugar_new,
              arguments: {'type': 'input'});
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _loadAISuggestion() async {
    try {
      // TODO: Not working
      final res = await GlucoseClient().fetchGlucoseAlltimeAnalysis();
      if (res != null) {
        _aiSuggestion = res.message;
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // final width = MediaQuery.of(context).size.width;
    // final height = 37.0;
    return BlocProvider<GlucoseBloc>.value(
      value: _bloc,
      child: BlocBuilder<GlucoseBloc, GlucoseState>(
        builder: (BuildContext context, GlucoseState state) {
          currentContext = context;
          TrendDataModel? model;

          if (state is GlucoseInitial) {
            BlocProvider.of<GlucoseBloc>(context).add(FetchTrendGlucose(
                trendType: trendTypeIndex.toString(),
                currentDateTime: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
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
              ? Container(height: 450, child: Center(child: CircularProgressIndicator()))
              : VisibilityDetector(
                  key: Key('blood_sugar_chart'),
                  onVisibilityChanged: (visibilityInfo) {
                    var visiblePercentage = visibilityInfo.visibleFraction * 100;
                    if (visiblePercentage == 0) {
                      previousDate = 0;
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _sectionTrending(model),
                      const SizedBox(height: 16),
                      if (_aiSuggestion?.isNotEmpty == true) _sectionAIHelp(),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _sectionTrending(TrendDataModel model) {
    DateTime highestGlucoseDate = DateTime.now();
    String highestGlucoseType = '';
    double highestGlucose = 0;
    int maxGlucoseTrendIndex = -1;
    int maxGlucoseTrendItemIndex = -1;
    String highestGlucoseColor = '';
    for (int i = 0; i < model.trendItems.items.length; i++) {
      for (int j = 0; j < model.trendItems.items[i].subTrends.length; j++) {
        if (model.trendItems.items[i].subTrends[j].glucose != null &&
            model.trendItems.items[i].subTrends[j].glucose! > highestGlucose) {
          maxGlucoseTrendIndex = i;
          maxGlucoseTrendItemIndex = j;
          highestGlucose = model.trendItems.items[i].subTrends[j].glucose!;
        }
      }
    }
    if (maxGlucoseTrendIndex > -1) {
      int dateMilli =
          model.trendItems.items[maxGlucoseTrendIndex].subTrends[maxGlucoseTrendItemIndex].date!;
      highestGlucoseDate = DateTime.fromMillisecondsSinceEpoch(dateMilli * 1000);
      highestGlucoseType =
          model.trendItems.items[maxGlucoseTrendIndex].subTrends[maxGlucoseTrendItemIndex].type!;
      highestGlucose =
          model.trendItems.items[maxGlucoseTrendIndex].subTrends[maxGlucoseTrendItemIndex].glucose!;
      highestGlucoseColor =
          model.trendItems.items[maxGlucoseTrendIndex].subTrends[maxGlucoseTrendItemIndex].color!;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              // '16:45 - 21/08/2024',
              DateFormat('HH:mm - dd/MM/yyyy').format(highestGlucoseDate),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: R.color.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              highestGlucoseType,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: highestGlucoseColor.isNotEmpty
                    ? Color(int.parse('0xff${highestGlucoseColor.split('#').join()}'))
                    : null,
                height: 36 / 24,
              ),
            ),
            Text(
              '${highestGlucose.toStringAsFixed(0)} mmol/L',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: R.color.textDark,
              ),
            ),
          ],
        ),
        Container(
          height: 100,
          child: model.trendItems.items.length == 0 ? SizedBox.shrink() : _buildChart(model),
        ),
      ],
    );
  }

  Widget _sectionAIHelp() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI result
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                R.string.ai_suggestion_glucose.tr(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: R.color.textDark,
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () {},
                child: Image.asset(R.drawable.ic_speak_text, width: 24, height: 24),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _aiSuggestion ?? '',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: R.color.primaryGreyColor,
              height: 16 / 12,
            ),
          ),

          const SizedBox(height: 16),
          // elevated button, ic_zalo and text, full width
          ElevatedButton(
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(R.drawable.ic_social_zalo, width: 24, height: 24),
                const SizedBox(width: 4),
                Text(
                  'Chat Zalo OA DiaB',
                  style: TextStyle(
                    color: R.color.mainColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: R.color.color0xffE1FAF8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget build1(BuildContext context) {
    super.build(context);
    // final width = MediaQuery.of(context).size.width;
    // final height = 37.0;
    return BlocProvider<GlucoseBloc>(
        create: (context) => GlucoseBloc(),
        child: BlocBuilder<GlucoseBloc, GlucoseState>(
            builder: (BuildContext context, GlucoseState state) {
          currentContext = context;
          TrendDataModel? model;

          if (state is GlucoseInitial) {
            BlocProvider.of<GlucoseBloc>(context).add(FetchTrendGlucose(
                trendType: trendTypeIndex.toString(),
                currentDateTime: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
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
              ? Container(height: 100, child: Center(child: CircularProgressIndicator()))
              : VisibilityDetector(
                  key: Key('blood_sugar_chart'),
                  onVisibilityChanged: (visibilityInfo) {
                    var visiblePercentage = visibilityInfo.visibleFraction * 100;
                    if (visiblePercentage == 0) {
                      previousDate = 0;
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(R.string.blood_sugar_trend.tr(),
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
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
                                            top: 4, bottom: 4, left: 12, right: 8),
                                        child: Row(
                                          children: [
                                            Text(
                                                trendType != null ? trendType! : R.string.all.tr()),
                                            SizedBox(width: 4),
                                            Image.asset(R.drawable.ic_chevron_down,
                                                width: 24, height: 24)
                                          ],
                                        ),
                                      )),
                                )),
                          ],
                        ),
                        SizedBox(height: 23),
                        model.trendItems.items.length == 0
                            ? EmptyDataBox(
                                text: "chỉ số đường huyết",
                                onTap: () async {
                                  await TrackingManager.analytics
                                      .logEvent(name: 'cta_button_clicked', parameters: {
                                    "screen_name": 'kpi_glycemic',
                                    'cta_button_name': 'cta_add_glycemic_1',
                                  });
                                  if (AppSettings.isUS) {
                                    Navigator.pushNamed(context, NavigatorName.add_blood_sugar_new,
                                        arguments: {'type': 'input'});
                                  } else {
                                    BloodSugarFunctions.showModalAddData(context);
                                  }
                                  // Navigator.pushNamed(
                                  //     context, NavigatorName.add_blood_sugar,
                                  //     arguments: {'type': 'input', 'id': null});
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
                                      offset: Offset(0, 2), // changes position of shadow
                                    ),
                                  ],
                                ),
                                //padding: EdgeInsets.all(16),
                                child: Column(children: [
                                  //SizedBox(height: 32),
                                  _buildChart(model),

                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, NavigatorName.blood_sugar_table,
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
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(R.string.xem_chi_tiet.tr(),
                                                style: TextStyle(color: R.color.mainColor)),
                                            Image.asset(R.drawable.ic_arrow_right,
                                                width: 20, height: 20)
                                          ]),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  )
                                ])),
                      ],
                    ),
                  ),
                );
        }));
  }

  Widget _buildChart(TrendDataModel model) {
    int length = 0;
    List<TrendModel> trends = [];
    model.trendItems.items.forEach((element) {
      length += element.subTrends.length;
      trends.addAll(element.subTrends);
    });

    double minY = trends.map<double>((e) => e.glucose ?? 0).reduce(min);
    minY = (minY * (trends.length == 1 ? 0.5 : 0.8)).roundToDouble();
    double maxY = trends.map<double>((e) => e.glucose ?? 0).reduce(max);
    maxY = (maxY * (trends.length == 1 ? 1.5 : 1.2)).roundToDouble();
    // find min and max index
    minXIndex = -1;
    maxXIndex = -1;
    for (int i = 0; i < trends.length; i++) {
      if (trends[i].glucose != null) {
        if (minXIndex == -1 || trends[i].glucose! < trends[minXIndex].glucose!) {
          minXIndex = i;
        }
        if (maxXIndex == -1 || trends[i].glucose! > trends[maxXIndex].glucose!) {
          maxXIndex = i;
        }
      }
    }

    minY = max(0, minY - 10);
    maxY = maxY + 10;

    return Padding(
      padding: EdgeInsets.only(top: 32),
      child: SingleChildScrollView(
        reverse: length > 1,
        scrollDirection: Axis.horizontal,
        child: Stack(
          children: [
            Container(
              // width: ((length < 5 ? 5 : length) * (width + 20)).toDouble(),
              width: MediaQuery.of(context).size.width - 56,
              height: 100,
              padding: EdgeInsets.only(top: 8, bottom: 8),
              alignment: Alignment.center,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                      // getTouchLineStart: (barData, index) =>
                      //     -double.infinity, // default: from bottom
                      // getTouchLineEnd: (barData, index) => double.infinity, //to top
                      getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                        return spotIndexes.map((index) {
                          return TouchedSpotIndicatorData(
                            FlLine(color: toColor(trends[index].color), strokeWidth: 0.5),
                            FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                radius: 6.5,
                                color: toColor(trends[index].color),
                                strokeWidth: 18,
                                strokeColor: toColor(trends[index].color).withOpacity(0.3),
                              ),
                            ),
                          );
                        }).toList();
                      },
                      touchTooltipData: LineTouchTooltipData(
                        showOnTopOfTheChartBoxArea: true,
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        tooltipBgColor: R.color.transparent,
                        tooltipRoundedRadius: 8,
                        getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                          return lineBarsSpot.map((lineBarSpot) {
                            return LineTooltipItem(
                              lineBarSpot.y.round() == lineBarSpot.y
                                  ? lineBarSpot.y.round().toString()
                                  : lineBarSpot.y.toString(),
                              TextStyle(
                                  color: toColor(trends[lineBarSpot.spotIndex].color),
                                  fontWeight: FontWeight.bold),
                            );
                          }).toList();
                        },
                        // TODO: Check position tooltip
                        tooltipPadding: EdgeInsets.only(bottom: 50),
                      ),
                      touchCallback: (FlTouchEvent event, LineTouchResponse? lineTouch) {
                        previousDate = 0;
                        if (lineTouch?.lineBarSpots?.length == 1 &&
                            event is! FlLongPressEnd &&
                            event is! FlPanEndEvent) {
                          final value = lineTouch?.lineBarSpots?[0].x;
                          if (value != null) {
                            //    setState(() {
                            touchIndex = value.toInt();
                            //    });
                          }
                        } else {
                          touchIndex = -1;
                        }
                      }),
                  gridData: FlGridData(show: false),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: 180,
                        color: Color(0xFFC82221),
                        dashArray: [4, 4],
                      ),
                    ],
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: SideTitles(showTitles: false),
                    topTitles: SideTitles(showTitles: false),
                    bottomTitles: SideTitles(showTitles: false),
                    leftTitles: SideTitles(showTitles: false),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: length.toDouble(),
                  maxY: maxY,
                  minY: minY,
                  lineBarsData: _linesBarData(model),
                ),
                swapAnimationDuration: Duration(milliseconds: 250),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<LineChartBarData> _linesBarData(TrendDataModel model) {
    List<TrendModel> trends = [];
    model.trendItems.items.forEach((item) {
      trends.addAll(item.subTrends);
    });

    return trends.length == 0
        ? []
        : [
            LineChartBarData(
              spots: List.generate(trends.length, (index) {
                return FlSpot((index).toDouble(), trends[index].glucose!);
              }),
              isCurved: false,
              colors: [Color(0xFF008479)],
              barWidth: 1,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, barData) => spot.x == minXIndex || spot.x == maxXIndex,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: index == maxXIndex ? Color(0xFFC82221) : Color(0xFFF9C239),
                    strokeWidth: 6,
                    strokeColor: index == maxXIndex
                        ? Color(0xFFC82221).withOpacity(0.3)
                        : Color(0xFFF9C239).withOpacity(0.3),
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                colors: [
                  // TODO: change color
                  Colors.green.withOpacity(0.7),
                  Colors.green.withOpacity(0.2),
                  Colors.green.withOpacity(0.01),
                  // Color(0xFFFFFDFD), Color(0xFFE1FAF8),
                ],
                gradientFrom: Offset(0.5, 0),
                gradientTo: Offset(0.5, 1),
                // gradientColorStops: [0, 0.3],
              ),
            ),
          ];
  }

  void showDialog(BuildContext context) {
    //Navigator.pushNamed(context, NavigatorName.hba1c_tabble);
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false, pageBuilder: (BuildContext context, _, __) => HbA1CTable()));
  }

  void showActionTrendFilter(BuildContext context) {
    // setState(() {
    //   this.isChoose = !isChoose;
    // });
    showModalBottomSheet(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
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

  void reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    BlocProvider.of<GlucoseBloc>(currentContext).add(FetchTrendGlucose(
        trendType: trendTypeIndex.toString(),
        currentDateTime: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        periodFilterType: periodFilterType.toString(),
        page: '1'));
  }
}
