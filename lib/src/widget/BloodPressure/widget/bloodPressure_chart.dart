import 'dart:async';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/bloodPressure/bloodPressure_bloc.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure_trend.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodPressure/bloodpressure_result.dto.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/empty_data_box.dart';
import 'package:visibility_detector/visibility_detector.dart';

typedef BloodPressureChartCallback = void Function(
    BloodPressureRangeType rangeType);

class BloodPressureChart extends StatefulWidget {
  BloodPressureChart({
    Key? key,
    required this.initPeriodFilterType,
    required this.bloodPressureChartCallback,
  }) : super(key: key);
  final int initPeriodFilterType;
  final BloodPressureChartCallback bloodPressureChartCallback;
  @override
  BloodPressureChartState createState() => BloodPressureChartState();
}

class BloodPressureChartState extends State<BloodPressureChart>
    with AutomaticKeepAliveClientMixin<BloodPressureChart> {
  final ScrollController _scrollController = ScrollController();
  @override
  bool get wantKeepAlive => true;

  BloodPressureBloc _bloodPressureBloc = BloodPressureBloc();
  StreamSubscription? _subscription;

  int _focusIndex = -1;

  int _periodFilterType = 1;
  late BuildContext currentContext;
  int? previousDate = 0;

  final double _mediumLow = 90;
  final double _mediumHigh = 140;

  @override
  void initState() {
    _periodFilterType = widget.initPeriodFilterType;
    super.initState();
    _registerEmptyNavigation();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _subscription?.cancel();
    _bloodPressureBloc.close();
    super.dispose();
  }

  void _registerEmptyNavigation() {
    _subscription?.cancel();
    _subscription = _bloodPressureBloc.stream.listen((state) {
      if (!mounted) return;
      if (state is BloodPressureTrendLoaded) {
        _subscription?.cancel();
        _subscription = null;

        final trends = _getTrends(state.model);
        if (trends.isEmpty) {
          Future.delayed(Duration(milliseconds: 500)).then((value) {
            if (!mounted) return;
            Navigator.pushReplacementNamed(
                context, NavigatorName.add_blood_pressure,
                arguments: {'type': 'input'});
          });
        }
      }
    });
  }

  void reloadData(int periodFilter, [bool isNew = false]) {
    _registerEmptyNavigation();
    if (isNew) {
      _focusIndex = -1;
    }
    _periodFilterType = periodFilter;
    _refresh();
  }

  Future<bool> _refresh() async {
    BlocProvider.of<BloodPressureBloc>(currentContext)
        .add(FetchBloodPressureTrend(
      currentDateTime: (DateTime.now().millisecondsSinceEpoch ~/ 1000),
      periodFilterType: _periodFilterType,
    ));
    return true;
  }

  void _viewHistory() {
    Navigator.pushNamed(
        currentContext, NavigatorName.detail_bloodpressure_listing,
        arguments: {
          'initPeriodFilterType': _periodFilterType,
        });
  }

  List<SubTrendItemModel> _getTrends(BloodPressureTrendModel model) {
    // Get the trends list from the current state
    List<SubTrendItemModel> trends = [];
    model.trendItems.items.forEach((element) {
      trends.addAll(element.subTrendItems);
    });

    // sort the trends by date
    trends.sort((a, b) {
      if (a.date == null || b.date == null) return 0;
      return a.date!.compareTo(b.date!);
    });

    return trends;
  }

  void _scrollToFocusIndex() {
    // REF: [_buildChart]
    double paddingOutSideBoth = 12 * 2;
    double leftTitleWidth = 50;
    double leftTitleMargin = 2;
    double chartWidth = MediaQuery.of(context).size.width -
        paddingOutSideBoth -
        leftTitleWidth -
        leftTitleMargin;
    final width = chartWidth / 18;
    final itemWidth = width + 12; // same as used in chart

    // Get the trends list from the current state
    final BloodPressureState state =
        BlocProvider.of<BloodPressureBloc>(currentContext).state;
    List<SubTrendItemModel> trends = [];
    if (state is BloodPressureTrendLoaded) {
      trends = _getTrends(state.model);
    }

    // Handle different scrolling behavior based on whether the list is reversed
    if (trends.length > 1) {
      // Chart is reversed when trends.length > 1
      // When reversed, we need to calculate from the right edge
      final totalWidth = ((trends.length < 5 ? 5 : trends.length) * itemWidth);
      final rightEdgeOffset = totalWidth - (_focusIndex + 1) * itemWidth;
      final targetOffset = rightEdgeOffset + (itemWidth / 2) - (chartWidth / 2);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    } else {
      // Normal left-to-right scrolling
      final targetOffset =
          (_focusIndex * itemWidth) - (chartWidth / 2) + (itemWidth / 2);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<BloodPressureBloc>.value(
      value: _bloodPressureBloc,
      child: BlocBuilder<BloodPressureBloc, BloodPressureState>(
        builder: (BuildContext context, BloodPressureState state) {
          currentContext = context;
          BloodPressureTrendModel? model;

          if (state is BloodPressureInitial) {
            BlocProvider.of<BloodPressureBloc>(context)
                .add(FetchBloodPressureTrend(
              currentDateTime: (DateTime.now().millisecondsSinceEpoch ~/ 1000),
              periodFilterType: _periodFilterType,
            ));
          }
          if (state is BloodPressureError) {
            Message.showToastMessage(context, state.message);
          }

          List<SubTrendItemModel> trends = [];
          if (state is BloodPressureTrendLoaded) {
            model = state.model;

            if (model.trendItems.items.isNotEmpty) {
              trends = _getTrends(model);
            }

            if (trends.isNotEmpty) {
              if (_focusIndex == -1 || _focusIndex >= trends.length) {
                _focusIndex = (trends.length - 1);
                if (_focusIndex >= 0 && _focusIndex < trends.length) {
                  final rangeType = BloodPressureRangeType.fromTitle(
                      trends[_focusIndex].type ?? '');
                  Future.delayed(Duration(milliseconds: 200)).then((value) {
                    widget.bloodPressureChartCallback(rangeType);
                  });
                }
              }
            } else {
              // Reset focus index when trends is empty
              _focusIndex = -1;
            }
          }

          if (model == null) {
            return Container(
              height: 240,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return VisibilityDetector(
            key: Key('blood_pressure_chart'),
            onVisibilityChanged: (visibilityInfo) {
              var visiblePercentage = visibilityInfo.visibleFraction * 100;
              if (visiblePercentage == 0) {
                previousDate = 0;
              }
            },
            child: Container(
              color: R.color.transparent,
              padding: EdgeInsets.only(left: 12, right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 14),
                  if (model.trendItems.items.length == 0)
                    EmptyDataBox(
                      text: 'chỉ số huyết áp',
                      onTap: () {
                        Navigator.pushNamed(
                            context, NavigatorName.add_blood_pressure,
                            arguments: {'type': 'input', 'id': null});
                      },
                    )
                  else ...[
                    _buildNavigatorIndex(trends),
                    SizedBox(height: 24),
                    _buildChart(model, trends),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
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

  Widget _buildNavigatorIndex(List<SubTrendItemModel> trends) {
    String selectedDate = '';
    String selectedDateTime = '';
    String selectedType = '';
    String selectedTimeFrame = 'Thức dậy';
    String selectedDiastolic = '166';
    String selectedSystolic = '110';
    String selectedColor = '';

    if (_focusIndex != -1 && _focusIndex < trends.length) {
      final selectedTrend = trends[_focusIndex];
      final date = DateTime.fromMillisecondsSinceEpoch(
          (selectedTrend.date ?? 0) * 1000,
          isUtc: true);
      selectedDate = DateFormat('dd/MM').format(date);
      selectedDateTime = DateFormat('HH:mm').format(date);
      selectedType = selectedTrend.type ?? '';
      selectedTimeFrame = selectedTrend.timeFrameName ?? '';
      selectedDiastolic = selectedTrend.diastolic?.toInt().toString() ?? '';
      selectedSystolic = selectedTrend.systolic?.toInt().toString() ?? '';
      selectedColor = selectedTrend.color ?? '';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Row: Stadium with white background (include time -> date) and icon history, center align
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 138,
                  height: 38,
                  decoration: BoxDecoration(
                    color: R.color.white,
                    borderRadius: BorderRadius.circular(19),
                    border:
                        Border.all(color: R.color.color0xffE5E5E5, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        selectedDateTime,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          fontFamily: R.font.sfpro,
                          color: Color(0xFF636A6B),
                          letterSpacing: 0.4,
                        ),
                      ),
                      Container(
                        width: 4,
                        height: 4,
                        margin: EdgeInsets.only(left: 4, right: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFBFC6C6),
                        ),
                      ),
                      Text(
                        selectedDate,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          fontFamily: R.font.sfpro,
                          color: Color(0xFF636A6B),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _viewHistory,
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
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 12),
                InkWell(
                  onTap: _focusIndex > 0
                      ? () {
                          setState(() {
                            _focusIndex = max(0, _focusIndex - 1);
                          });
                          final rangeType = BloodPressureRangeType.fromTitle(
                              trends[_focusIndex].type ?? '');
                          widget.bloodPressureChartCallback(rangeType);
                          if (_focusIndex > 0) {
                            _scrollToFocusIndex();
                          }
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
                const SizedBox(width: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 200),
                  child: Text(
                    selectedType,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: R.font.sfpro,
                      color: selectedColor.isNotEmpty
                          ? Color(int.parse(
                              '0xff${selectedColor.split('#').join()}'))
                          : R.color.color0xff111515,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: _focusIndex < trends.length - 1
                      ? () {
                          setState(() {
                            _focusIndex =
                                min(trends.length - 1, _focusIndex + 1);
                          });
                          final rangeType = BloodPressureRangeType.fromTitle(
                              trends[_focusIndex].type ?? '');
                          widget.bloodPressureChartCallback(rangeType);
                          if (_focusIndex < trends.length - 1) {
                            _scrollToFocusIndex();
                          }
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
                const SizedBox(width: 12),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  selectedTimeFrame,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: R.font.sfpro,
                    color: Color(0xFF636A6B),
                  ),
                ),
                Container(
                  width: 4,
                  height: 4,
                  margin: EdgeInsets.only(left: 4, right: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFBFC6C6),
                  ),
                ),
                Text(
                  '$selectedSystolic/$selectedDiastolic mmHg',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    fontFamily: R.font.sfpro,
                    color: Color(0xFF111515),
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChart(
      BloodPressureTrendModel model, List<SubTrendItemModel> trends) {
    double paddingOutSideBoth = 12 * 2;
    double leftTitleWidth = 50;
    double leftTitleMargin = 2;
    double chartWidth = MediaQuery.of(context).size.width -
        paddingOutSideBoth -
        leftTitleWidth -
        leftTitleMargin;
    // Calculate width to show 11 points on the page
    final width = chartWidth / 18;

    // less no.trends need to scale width to fill screen
    final minWidth = chartWidth;
    double calculatedWidth = (trends.length * (width + 12)).toDouble();
    if (calculatedWidth < minWidth) {
      calculatedWidth = minWidth;
    }

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
              width: leftTitleWidth,
              height: 120,
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child: Column(
                children: [
                  Spacer(flex: 1),
                  Text(
                    _mediumHigh.round().toString(),
                    style: TextStyle(
                      color: R.color.color0xff111515,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      fontFamily: R.font.sfpro,
                    ),
                  ),
                  Spacer(flex: 1),
                  Text(
                    _mediumLow.round().toString(),
                    style: TextStyle(
                      color: R.color.color0xff111515,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      fontFamily: R.font.sfpro,
                    ),
                  ),
                  Spacer(flex: 2),
                  // Icon(Icons.heat_pump_rounded, size: 20),
                  Image.asset(R.drawable.ic_bloodpressure_pulse,
                      width: 20, height: 20),
                ],
              ),
            ),
            SizedBox(width: leftTitleMargin),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                reverse: trends.length > 1,
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: calculatedWidth,
                  height: 120,
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                          getTouchLineStart: (barData, index) =>
                              -double.infinity,
                          getTouchLineEnd: (barData, index) => double.infinity,
                          getTouchedSpotIndicator: (LineChartBarData barData,
                              List<int> spotIndexes) {
                            return spotIndexes.map((index) {
                              // Get the color of the touched point
                              Color dotColor = R.color.black;
                              if (index >= 0 && index < trends.length) {
                                final trend = trends[index];
                                if (trend.color != null &&
                                    trend.color!.isNotEmpty) {
                                  dotColor = toColor(trend.color);
                                }
                              }

                              return TouchedSpotIndicatorData(
                                FlLine(
                                  color: dotColor,
                                  strokeWidth: 0.5,
                                ),
                                FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) =>
                                          FlDotCirclePainter(
                                    radius: 3,
                                    color: dotColor,
                                    strokeWidth: 6,
                                    strokeColor: dotColor.withOpacity(0.3),
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          touchTooltipData: LineTouchTooltipData(
                            showOnTopOfTheChartBoxArea: true,
                            fitInsideVertically: true,
                            fitInsideHorizontally: true,
                            tooltipBgColor: Colors.transparent,
                            tooltipRoundedRadius: 8,
                            getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                              return lineBarsSpot.map((lineBarSpot) {
                                if (lineBarSpot.barIndex == 0) {
                                  if (lineBarSpot.spotIndex < 0 ||
                                      lineBarSpot.spotIndex >= trends.length ||
                                      trends[lineBarSpot.spotIndex].systolic ==
                                          null ||
                                      trends[lineBarSpot.spotIndex].diastolic ==
                                          null) {
                                    return LineTooltipItem(
                                      '0/0',
                                      TextStyle(
                                        color: toColor(model.colors!.first),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        fontFamily: R.font.sfpro,
                                      ),
                                    );
                                  }
                                  final trend = trends[lineBarSpot.spotIndex];
                                  return LineTooltipItem(
                                    trend.systolic!.round().toString() +
                                        '/' +
                                        trend.diastolic!.round().toString(),
                                    TextStyle(
                                      color: toColor(trend.color),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      fontFamily: R.font.sfpro,
                                    ),
                                  );
                                }
                                return null;
                              }).toList();
                            },
                          ),
                          touchCallback: (FlTouchEvent event,
                              LineTouchResponse? lineTouch) {
                            previousDate = 0;
                            if (event is! FlLongPressEnd &&
                                event is! FlPanEndEvent) {
                              final value = lineTouch?.lineBarSpots?[0].x;
                              if (value != null) {
                                setState(() {
                                  _focusIndex = value.toInt();
                                });
                                final rangeType =
                                    BloodPressureRangeType.fromTitle(
                                        trends[_focusIndex].type ?? '');
                                widget.bloodPressureChartCallback(rangeType);
                              }
                            } else {
                              _focusIndex = -1;
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
                                color: _focusIndex == value.toInt()
                                    ? R.color.color0xff111515
                                    : R.color.color0xff636A6B,
                                fontSize: 10,
                                fontWeight: _focusIndex == value.toInt()
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                                fontFamily: 'Nunito',
                                height: 1.5);
                          },
                          getTitles: (double value) {
                            // padding left
                            if (value <= -0.5 || value >= (trends.length - 0.5))
                              return '';
                            int index = value.toInt();
                            if (index < 0 ||
                                index >= trends.length ||
                                trends[index].pulseRate == null ||
                                trends[index].pulseRate == 0) {
                              return '--';
                            }
                            // return heart rate value
                            return trends[index].pulseRate!.round().toString();
                          },
                        ),
                        leftTitles: SideTitles(
                          showTitles: false,
                          reservedSize: 50,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: -0.5,
                      maxX: trends.length.toDouble() - 0.5,
                      maxY: maxY,
                      minY: minY,
                      lineBarsData: _linesBarData(trends),
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: _customYTransform(_mediumLow),
                            color: R.color.color0xff636A6B,
                            dashArray: [8, 4],
                            strokeWidth: 1,
                          ),
                          HorizontalLine(
                            y: _customYTransform(_mediumHigh),
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
              ),
            )
          ],
        ),
        SizedBox(height: 12),
        // guide line
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 23,
              height: 1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                color: Color(0xFF008479),
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Tâm thu',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                fontFamily: 'Nunito',
                color: R.color.color0xff111515,
                height: 1.29,
              ),
            ),
            SizedBox(width: 48),
            Container(
              width: 23,
              height: 1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                color: Color(0xFF95682E),
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Tâm trương',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                fontFamily: 'Nunito',
                color: R.color.color0xff111515,
                height: 1.29,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<LineChartBarData> _linesBarData(List<SubTrendItemModel> trends) {
    if (trends.length == 0) {
      return [];
    }

    return [
      LineChartBarData(
        spots: List.generate(trends.length, (index) {
          double value =
              trends[index].systolic! > 180 ? 180 : trends[index].systolic!;
          return FlSpot((index).toDouble(), _customYTransform(value));
        }),
        isCurved: false,
        colors: [Color(0xFF008479)],
        barWidth: 1,
        isStrokeCapRound: true,
        dotData: FlDotData(
            show: true,
            checkToShowDot: (spot, barData) => true,
            getDotPainter: (spot, percent, barData, index) {
              final color = toColor(trends[index].color);
              final bool isSelected = _focusIndex == index;
              return FlDotCirclePainter(
                radius: 3,
                color: color,
                strokeWidth: isSelected ? 6 : 0,
                strokeColor: isSelected ? color.withOpacity(0.3) : null,
              );
            }),
        belowBarData: BarAreaData(show: false),
      ),
      LineChartBarData(
        spots: List.generate(trends.length, (index) {
          double value =
              trends[index].diastolic! > 180 ? 180 : trends[index].diastolic!;
          return FlSpot((index).toDouble(), _customYTransform(value));
        }),
        isCurved: false,
        colors: [Color(0xFF95682E)],
        barWidth: 1,
        isStrokeCapRound: true,
        dotData: FlDotData(
            show: true,
            checkToShowDot: (spot, barData) => true,
            getDotPainter: (spot, percent, barData, index) {
              final color = toColor(trends[index].color);
              final bool isSelected = _focusIndex == index;
              return FlDotCirclePainter(
                radius: 3,
                color: color,
                strokeWidth: isSelected ? 6 : 0,
                strokeColor: isSelected ? color.withOpacity(0.3) : null,
              );
            }),
        belowBarData: BarAreaData(show: false),
      ),
    ];
  }
}
