import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/bloc/glucose/glucose_bloc.dart';
import 'package:medical/src/modal/glucose/glucose_data_trend.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodPressure/widget/horizontal_selector.dart';
import 'package:medical/src/widget/BloodSugar/bloodSugar_detail_tabbar.dart';
import 'package:medical/src/widget/BloodSugar/constant/bloodSugar_rangetype.dart';
import 'package:medical/src/widget/BloodSugar/widget/action_list_filter_trend.dart';
import 'package:medical/src/widget/Exercrises/widget/dash_line_horizontal.dart';
import 'package:medical/src/widget/HbA1C/hba1c_tabble.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/modal/glucose/glucose_trend.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'ai_loading_text_widget.dart';
import 'aihelp_butotn.dart';

typedef BloodSugarChartCallback = void Function(
    BloodSugarRangeType? rangeType, String? aiSuggestion);

class BloodSugarChart extends StatefulWidget {
  BloodSugarChart({
    Key? key,
    required this.periodFilterType,
    required this.onFilterChanged,
    required this.onViewListing,
    required this.filterName,
    this.bloodSugarChartCallback,
  }) : super(key: key);

  final int periodFilterType;
  final Function(int selectedIndex) onFilterChanged;
  final Function() onViewListing;
  final String filterName;
  final BloodSugarChartCallback? bloodSugarChartCallback;

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

  final int _breakingTypeNumber = 12;

  // less than [_breakingTypeNumber] focus
  int _focusIndex = -1;

  final double _glucoseThresholdMgDl = 180;
  final double _glucoseThresholdMmol = 10;

  @override
  void initState() {
    super.initState();
    periodFilterType =
        BloodSugarDetailTabbarController.of(context)?.periodFilterType ??
            widget.periodFilterType;
    _subscription?.cancel();
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
          Navigator.pushReplacementNamed(
              context, NavigatorName.add_blood_sugar_new,
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<GlucoseBloc>.value(
      value: _bloc,
      child: BlocBuilder<GlucoseBloc, GlucoseState>(
        builder: (BuildContext context, GlucoseState state) {
          currentContext = context;
          TrendDataModel? model;

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
          String? aiSuggestion;
          String? mostAppearType;
          String? mostAppearTypeColor;
          BloodSugarRangeType? rangeType;
          if (state is GlucoseTrendLoaded) {
            model = state.trend;
            aiSuggestion = state.glucoseInputAIAnalysis;
            mostAppearType = state.mostAppearType;
            mostAppearTypeColor = state.mostAppearTypeColor;
            rangeType = state.rangeType;

            // Call the callback to pass data back to parent
            if (widget.bloodSugarChartCallback != null) {
              Future.delayed(Duration(milliseconds: 100), () {
                widget.bloodSugarChartCallback!(rangeType, aiSuggestion);
              });
            }
          }

          if (model == null)
            return Container(
                height: 450, child: Center(child: CircularProgressIndicator()));

          return VisibilityDetector(
            key: Key('blood_sugar_chart'),
            onVisibilityChanged: (visibilityInfo) {
              var visiblePercentage = visibilityInfo.visibleFraction * 100;
              if (visiblePercentage == 0) {
                previousDate = 0;
              }
            },
            child: DecoratedBox(
              decoration: BoxDecoration(color: R.color.backgroundColorNew),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  _sectionTrending(model, mostAppearType, mostAppearTypeColor),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTrending(TrendDataModel model, String? mostAppearType,
      String? mostAppearTypeColor) {
    if (model.trendItems.items.isEmpty) {
      return _buildEmptyState();
    }
    List<TrendModel> trends = [];
    model.trendItems.items.forEach((element) {
      trends.addAll(element.subTrends);
    });
    int totalItems = trends.length;

    if (totalItems < _breakingTypeNumber) {
      return _sectionTrendingLess(trends);
    } else {
      return _sectionTrendingMany(trends, model.fromDate, model.toDate,
          mostAppearType, mostAppearTypeColor);
    }
  }

  Widget _buildEmptyState() {
    // Define threshold based on unit
    double thresholdValue = AppSettings.userInfo!.glucoseUnit == 1 ? 180 : 10;
    String thresholdLabel =
        AppSettings.userInfo!.glucoseUnit == 1 ? '180' : '10';
    String selectedUnit =
        AppSettings.userInfo!.glucoseUnit == 1 ? 'mg/dL' : 'mmol/L';

    return Container(
      height: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            R.string.no_data_blood_sugar_trend_chart.tr(args: [getLabel()]),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: R.color.textDark,
            ),
          ),
          GapH(36),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '$thresholdLabel\n$selectedUnit',
                  style: TextStyle(
                    color: R.color.color0xffBFC6C6,
                    fontSize: 12,
                  ),
                ),
                GapW(8),
                Expanded(
                  child: CustomPaint(
                    size: Size(double.infinity, 1),
                    painter: DashLinePainter(
                      color: R.color.color0xffBFC6C6,
                      strokeWidth: 1,
                      dashWidth: 8,
                      dashSpace: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getLabel() {
    final labels = [
      R.string.filter_day.tr(args: ['7']),
      R.string.filter_day.tr(args: ['14']),
      R.string.filter_day.tr(args: ['30']),
      R.string.filter_day.tr(args: ['90']),
    ];

    int index = periodFilterType - 1;
    if (index >= 0 && index < labels.length) {
      return labels[index];
    }
    return labels[0]; // Default to first label if index is out of bounds
  }

  Widget _sectionTrendingLess(List<TrendModel> trends) {
    if (_focusIndex == -1) {
      _focusIndex = (trends.length - 1) ~/ 2;
    }
    String selectedDate = '';
    String selectedDateTime = '';
    String selectedType = '';
    String selectedTimeFrame = '';
    String selectedGlucose = '';
    String selectedColor = '';
    String selectedUnit = '';

    if (_focusIndex != -1 && _focusIndex < trends.length) {
      final selectedTrend = trends[_focusIndex];
      selectedDate = DateFormat('dd-MM').format(
          DateTime.fromMillisecondsSinceEpoch(selectedTrend.date! * 1000,
              isUtc: true));
      selectedDateTime = DateFormat('HH:mm').format(
          DateTime.fromMillisecondsSinceEpoch(selectedTrend.date! * 1000,
              isUtc: true));
      selectedType = selectedTrend.type!;
      selectedTimeFrame = selectedTrend.timeFrameName!;
      selectedGlucose = roundNumber(selectedTrend.glucose!);
      selectedColor = selectedTrend.color!;
      selectedUnit =
          AppSettings.userInfo!.glucoseUnit == 1 ? 'mg/dL' : 'mmol/L';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: R.color.white,
                    borderRadius: BorderRadius.circular(19),
                    border:
                        Border.all(color: R.color.color0xffE5E5E5, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$selectedDateTime',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: R.color.textDark,
                        ),
                      ),
                      _dotWidget(),
                      Text(
                        '$selectedDate',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: R.color.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                GapW(8),
                InkWell(
                  onTap: widget.onViewListing,
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: R.color.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: R.color.color0xffE5E5E5),
                      ),
                      child: Center(
                          child: Icon(Icons.history,
                              color: R.color.textDark, size: 20)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 16),
                InkWell(
                  onTap: _focusIndex > 0
                      ? () {
                          setState(() {
                            _focusIndex = max(0, _focusIndex - 1);
                          });
                        }
                      : null,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: R.color.color0xffE5E5E5,
                        width: 1,
                      ),
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      size: 20,
                      color: _focusIndex > 0
                          ? R.color.textDark
                          : R.color.color0xffE5E5E5,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      selectedType,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: selectedColor.isNotEmpty
                            ? Color(int.parse(
                                '0xff${selectedColor.split('#').join()}'))
                            : null,
                        height: 36 / 24,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: _focusIndex < trends.length - 1
                      ? () {
                          setState(() {
                            _focusIndex =
                                min(trends.length - 1, _focusIndex + 1);
                          });
                        }
                      : null,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: R.color.color0xffE5E5E5,
                        width: 1,
                      ),
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: _focusIndex < trends.length - 1
                          ? R.color.textDark
                          : R.color.color0xffE5E5E5,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$selectedTimeFrame',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: R.color.color0xff5E6566,
                  ),
                ),
                _dotWidget(),
                Text(
                  '$selectedGlucose $selectedUnit',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: R.color.textDark,
                  ),
                ),
                _dotWidget(),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 88,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildChart(trends, padding: 16 * 2),
          ),
        ),
      ],
    );
  }

  Widget _dotWidget() {
    return Container(
      width: 4,
      height: 4,
      margin: EdgeInsets.only(left: 4, right: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFBFC6C6),
      ),
    );
  }

  Widget _sectionTrendingMany(
    List<TrendModel> trends,
    int? fromDateInt,
    int? toDateInt,
    String? mostAppearType,
    String? mostAppearTypeColor,
  ) {
    double highestGlucose = 0;
    double lowestGlucose = -1;

    String fromDate = '';
    String toDate = '';
    if (fromDateInt != null) {
      fromDate = DateFormat('dd/MM/yyyy').format(
        DateTime.fromMillisecondsSinceEpoch(fromDateInt * 1000, isUtc: true),
      );
    }
    if (toDateInt != null) {
      toDate = DateFormat('dd/MM/yyyy').format(
        DateTime.fromMillisecondsSinceEpoch(toDateInt * 1000, isUtc: true),
      );
    } else {
      toDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    }

    for (int i = 0; i < trends.length; i++) {
      if (trends[i].glucose != null && trends[i].glucose! > highestGlucose) {
        highestGlucose = trends[i].glucose!;
      }
      if (lowestGlucose == -1 ||
          (trends[i].glucose != null && trends[i].glucose! < lowestGlucose)) {
        lowestGlucose = trends[i].glucose!;
      }
    }

    final selectedUnit =
        AppSettings.userInfo!.glucoseUnit == 1 ? 'mg/dL' : 'mmol/L';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$fromDate - $toDate',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: R.color.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              mostAppearType ?? '--',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: mostAppearTypeColor?.isNotEmpty == true
                    ? Color(int.parse(
                        '0xff${mostAppearTypeColor!.split('#').join()}'))
                    : null,
                height: 36 / 24,
              ),
            ),
            Text(
              '${roundNumber(lowestGlucose)} - ${roundNumber(highestGlucose)} $selectedUnit',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: R.color.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 88,
          child: _buildChart(trends),
        ),
      ],
    );
  }

  Widget _sectionAIHelp(String? aiSuggestion, BloodSugarRangeType? rangeType) {
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
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: R.color.textDark,
                  height: 21 / 15,
                ),
              ),
              const SizedBox(width: 6),
              Image.asset(R.drawable.ic_info, width: 18, height: 18),
              // InkWell(
              //   onTap: () {},
              //   child: Image.asset(R.drawable.ic_speak_text, width: 24, height: 24),
              // ),
            ],
          ),
          const SizedBox(height: 8),
          if (aiSuggestion == null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: const AILoadingTextWidget(),
            )
          else if (aiSuggestion.isEmpty)
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFFC82221),
              ),
            )
          else ...[
            Text(
              aiSuggestion,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: R.color.primaryGreyColor,
                height: 16 / 12,
              ),
            ),
            const SizedBox(height: 16),
            AIHelpButton(rangeType: rangeType),
          ],
        ],
      ),
    );
  }

  Widget _buildChart(List<TrendModel> trends, {double padding = 0}) {
    double minY = trends.map<double>((e) => e.glucose ?? 0).reduce(min);
    minY = (minY * (trends.length == 1 ? 0.5 : 0.8)).roundToDouble();
    double maxY = trends.map<double>((e) => e.glucose ?? 0).reduce(max);
    maxY = (maxY * (trends.length == 1 ? 1.5 : 1.2)).roundToDouble();

    // Define threshold based on unit
    double scaleYMaxLine = AppSettings.userInfo!.glucoseUnit == 1 ? 180 : 10;
    String thresholdLabel =
        AppSettings.userInfo!.glucoseUnit == 1 ? '180' : '10';
    String selectedUnit =
        AppSettings.userInfo!.glucoseUnit == 1 ? 'mg/dL' : 'mmol/L';

    // find min and max index
    minXIndex = -1;
    maxXIndex = -1;
    for (int i = 0; i < trends.length; i++) {
      if (trends[i].glucose != null) {
        if (minXIndex == -1 ||
            trends[i].glucose! < trends[minXIndex].glucose!) {
          minXIndex = i;
        }
        if (maxXIndex == -1 ||
            trends[i].glucose! > trends[maxXIndex].glucose!) {
          maxXIndex = i;
        }
      }
    }

    minY = max(0, minY - 10);
    maxY = maxY + 10;

    return SingleChildScrollView(
      reverse: trends.length > 1,
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // width: ((length < 5 ? 5 : length) * (width + 20)).toDouble(),
            width: MediaQuery.of(context).size.width - padding,
            height: 88,
            padding: EdgeInsets.only(top: 8, bottom: 8),
            alignment: Alignment.center,
            child: trends.length == 1
                ? Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: toColor(trends[0].color).withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: toColor(trends[0].color),
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                          getTouchLineStart: (barData, index) =>
                              -double.infinity,
                          getTouchLineEnd: (barData, index) => double.infinity,
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
                            tooltipBgColor: R.color.transparent,
                            tooltipRoundedRadius: 8,
                            getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                              return lineBarsSpot.map((lineBarSpot) {
                                return LineTooltipItem(
                                  roundNumber(lineBarSpot.y),
                                  TextStyle(
                                      color: toColor(
                                          trends[lineBarSpot.spotIndex].color),
                                      fontWeight: FontWeight.bold),
                                );
                              }).toList();
                            },
                            tooltipPadding: EdgeInsets.only(bottom: 50),
                          ),
                          touchCallback: (FlTouchEvent event,
                              LineTouchResponse? lineTouch) {
                            previousDate = 0;
                            if (lineTouch?.lineBarSpots?.length == 1 &&
                                event is! FlLongPressEnd &&
                                event is! FlPanEndEvent) {
                              final value = lineTouch?.lineBarSpots?[0].x;
                              if (value != null) {
                                touchIndex = value.toInt();
                                setState(() {
                                  _focusIndex = touchIndex;
                                });
                              }
                            } else {
                              touchIndex = -1;
                            }
                          }),
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        rightTitles: SideTitles(showTitles: false),
                        topTitles: SideTitles(showTitles: false),
                        bottomTitles: SideTitles(showTitles: false),
                        leftTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          interval: (maxY - minY) / 10,
                          textAlign: TextAlign.left,
                          getTitles: (double value) {
                            if ((value - scaleYMaxLine).abs() <=
                                (maxY - minY) * 0.05) {
                              return '${thresholdLabel}\n${selectedUnit}';
                            }
                            return '';
                          },
                          getTextStyles: (context, value) => TextStyle(
                            color: R.color.color0xff111515,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: trends.length.toDouble() - 1,
                      maxY: maxY,
                      minY: minY,
                      lineBarsData: _linesBarData(trends),
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: scaleYMaxLine,
                            color: R.color.color0xff636A6B,
                            dashArray: [8, 4],
                            strokeWidth: 1,
                          ),
                        ],
                      ),
                    ),
                    swapAnimationDuration: Duration(milliseconds: 250),
                  ),
          ),
        ],
      ),
    );
  }

// Update the _linesBarData method to handle the baseline properly
  List<LineChartBarData> _linesBarData(List<TrendModel> trends) {
    if (trends.length == 0) return [];
    if (trends.length < _breakingTypeNumber) {
      // can change focus
      return [
        LineChartBarData(
          spots: List.generate(trends.length, (index) {
            return FlSpot((index).toDouble(), trends[index].glucose!);
          }),
          isCurved: false,
          colors: [Color(0xFF008479)],
          barWidth: 1.5,
          isStrokeCapRound: false,
          dotData: FlDotData(
            show: true,
            checkToShowDot: (spot, barData) => true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3,
                color: toColor(trends[index].color),
                strokeWidth: index == _focusIndex ? 6 : 0,
                strokeColor: index == _focusIndex
                    ? toColor(trends[index].color).withOpacity(0.3)
                    : null,
              );
            },
          ),
          belowBarData: BarAreaData(show: false),
        ),
      ];
    }
    return [
      LineChartBarData(
        spots: List.generate(trends.length, (index) {
          return FlSpot((index).toDouble(), trends[index].glucose!);
        }),
        isCurved: true,
        colors: [Color(0xFF008479)],
        barWidth: 1.5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          checkToShowDot: (spot, barData) =>
              spot.x == minXIndex || spot.x == maxXIndex,
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
            Color(0xFFE7FDFB),
            Color(0xFFFFFFFF),
          ],
          gradientFrom: Offset(0.5, 0),
          gradientTo: Offset(0.5, 1.2),
        ),
      ),
    ];
  }

  void showDialog(BuildContext context) {
    //Navigator.pushNamed(context, NavigatorName.hba1c_tabble);
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => HbA1CTable()));
  }

  void showActionTrendFilter(BuildContext context) {
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

  void reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    BlocProvider.of<GlucoseBloc>(currentContext).add(FetchTrendGlucose(
        trendType: trendTypeIndex.toString(),
        currentDateTime:
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        periodFilterType: periodFilterType.toString(),
        page: '1'));
  }
}
