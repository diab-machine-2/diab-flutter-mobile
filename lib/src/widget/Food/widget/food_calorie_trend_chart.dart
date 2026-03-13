import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/modal/food/food_statistic_trend_model.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/Food/daily_nutrition/daily_nutrition.dart';
import 'package:medical/src/widget/Food/food_detail_tabbar.dart';
import 'package:medical/src/widget/Exercrises/widget/dash_line_horizontal.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';

class FoodCalorieTrendChart extends StatefulWidget {
  FoodCalorieTrendChart({
    Key? key,
    required this.periodFilterType,
  }) : super(key: key);

  final int periodFilterType;

  @override
  FoodCalorieTrendChartState createState() => FoodCalorieTrendChartState();
}

class FoodCalorieTrendChartState extends State<FoodCalorieTrendChart>
    with AutomaticKeepAliveClientMixin<FoodCalorieTrendChart> {
  @override
  bool get wantKeepAlive => true;

  late BuildContext currentContext;
  int periodFilterType = 1;
  int? previousDate = 0;

  final int _breakingTypeNumber = 12;

  // focus index
  int _focusIndex = -1;

  DateTime? _lastTapTime;

  List<EnergyTrendItemModel> trends = [];
  List<EnergyTrendItemModel> _previousTrends = [];

  int? _selectedDateTimestamp;

  bool _isChartReady = false;
  bool _shouldAutoScroll = true;

  final ScrollController _scrollController = ScrollController();

  void _scrollToSelected({bool animated = true, int retry = 0}) {
    if (!_shouldAutoScroll || !mounted) return;

    if (retry > 20) {
      _shouldAutoScroll = false;
      return;
    }

    final bool shouldScroll = trends.length >= _breakingTypeNumber;
    const double maxSpacing = 60.0;
    const double minSpacing = 25.0;
    final screenWidth = MediaQuery.of(context).size.width - 32;
    double pointSpacing = shouldScroll
        ? max(minSpacing,
            maxSpacing - (trends.length - _breakingTypeNumber) * 2.5)
        : screenWidth / max(1, (trends.length - 1));

    if (_scrollController.hasClients &&
        _scrollController.position.hasContentDimensions &&
        _focusIndex >= 0 &&
        _focusIndex < trends.length) {
      _shouldAutoScroll = false;
      final double scrollPosition = (_focusIndex * pointSpacing) - 100;

      if (animated) {
        _scrollController.animateTo(
          scrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController.jumpTo(
          scrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
        );
      }
    } else {
      Future.delayed(const Duration(milliseconds: 50), () {
        _scrollToSelected(animated: animated, retry: retry + 1);
      });
    }
  }

  void _updateFocusIndexWithFallback(List<EnergyTrendItemModel> newTrends) {
    _previousTrends.map((e) => e.date).toSet();
    trends = newTrends;

    if (trends.isEmpty) {
      _focusIndex = -1;
      _selectedDateTimestamp = null;
      _previousTrends = [];
      return;
    }

    int? matchedIndex = -1;

    // If previously focused item was the last one and a new tail item appears,
    // auto-focus the new last item
    final bool wasLastPreviously =
        _previousTrends.isNotEmpty && _focusIndex == _previousTrends.length - 1;
    final bool hasNewTail = _previousTrends.isNotEmpty &&
        trends.isNotEmpty &&
        (_previousTrends.last.date != trends.last.date);
    if (wasLastPreviously && hasNewTail) {
      matchedIndex = trends.length - 1;
    }

    // Try to keep the same timestamp
    if (matchedIndex == -1 &&
        _selectedDateTimestamp != null) {
      final duplicateIndexes = <int>[];
      for (int i = 0; i < trends.length; i++) {
        if (trends[i].date == _selectedDateTimestamp) duplicateIndexes.add(i);
      }
      if (duplicateIndexes.isNotEmpty) {
        matchedIndex = duplicateIndexes.reduce((a, b) =>
            (a - _focusIndex).abs() <= (b - _focusIndex).abs() ? a : b);
      }
    }

    // Default to latest data point
    if (matchedIndex == -1) {
      matchedIndex = trends.length - 1;
    }

    _focusIndex = matchedIndex;
    _selectedDateTimestamp = trends[_focusIndex].date;

    _previousTrends = List.from(trends);
    if (mounted) {
      setState(() {
        _shouldAutoScroll = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    periodFilterType =
        FoodDetailTabbarController.of(context)?.periodFilterType ??
            widget.periodFilterType;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<FoodBloc>(
      create: (context) => FoodBloc(),
      child: BlocBuilder<FoodBloc, FoodState>(
        builder: (BuildContext context, FoodState state) {
          currentContext = context;
          FoodTrendModel? model;

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

            if (model != null) {
              final newTrends = model.energyChart.items;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _updateFocusIndexWithFallback(newTrends);
                }
              });
            }
          }

          if (model == null) {
            return Container(
                height: 300, child: Center(child: CircularProgressIndicator()));
          }

          return VisibilityDetector(
            key: Key('food_calorie_trend_chart'),
            onVisibilityChanged: (visibilityInfo) {
              var visiblePercentage = visibilityInfo.visibleFraction * 100;
              if (visiblePercentage == 0) {
                previousDate = 0;
              } else if (visiblePercentage > 0 && mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _scrollToSelected();
                  }
                });
              }
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    R.color.white,
                    R.color.white.withAlpha(0),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.6, 1.0],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  _sectionTrending(model),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTrending(FoodTrendModel model) {
    final items = model.energyChart.items;
    if (items.isEmpty) {
      return _buildEmptyState();
    }
    return _sectionTrendingLess(items);
  }

  Widget _buildEmptyState() {
    double energyGoal = AppSettings.userInfo?.energyGoal ?? 2000;
    String thresholdLabel = '${energyGoal.round()}';
    String selectedUnit = 'kcal';

    return Container(
      height: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Chưa có dữ liệu dinh dưỡng trong ${getLabel()}',
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
    return labels[0];
  }

  Widget _sectionTrendingLess(List<EnergyTrendItemModel> trends) {
    if (_focusIndex == -1) {
      if (trends.length > 1) {
        _focusIndex = (trends.length - 1) ~/ 2;
      } else {
        _focusIndex = 0;
      }
    }

    String selectedDate = '';
    String selectedDateTime = '';
    String selectedValue = '';
    String selectedColor = '';
    String selectedUnit = 'kcal';

    if (_focusIndex != -1 && _focusIndex < trends.length) {
      final selectedTrend = trends[_focusIndex];
      selectedDate = DateFormat('dd/MM').format(
          DateTime.fromMillisecondsSinceEpoch(selectedTrend.date! * 1000,
              isUtc: true));
      selectedDateTime = DateFormat('HH:mm').format(
          DateTime.fromMillisecondsSinceEpoch(selectedTrend.date! * 1000,
              isUtc: true));
      selectedValue = formatNumber(selectedTrend.value ?? 0);
      selectedColor = selectedTrend.colorCode ?? '#008479';
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
              ],
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 16),
                InkWell(
                  onTap: () {
                    _goPreviousNode();
                  },
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
                      '$selectedValue $selectedUnit',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: selectedColor.isNotEmpty
                            ? Color(int.parse(
                                '0xff${selectedColor.replaceAll('#', '')}'))
                            : R.color.greenGradientBottom,
                        height: 36 / 24,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    _goNextNode(trends.length);
                  },
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

  void _goNextNode(int length) {
    if (_focusIndex < length - 1) {
      setState(() {
        _focusIndex = min(length - 1, _focusIndex + 1);
        _selectedDateTimestamp = trends[_focusIndex].date;
        _shouldAutoScroll = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelected();
      });
    }
  }

  void _goPreviousNode() {
    if (_focusIndex > 0) {
      setState(() {
        _focusIndex = max(0, _focusIndex - 1);
        _selectedDateTimestamp = trends[_focusIndex].date;
        _shouldAutoScroll = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelected();
      });
    }
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

  Widget _buildChart(List<EnergyTrendItemModel> trends, {double padding = 0}) {
    if (trends.isEmpty) {
      return SizedBox.shrink();
    }
    double minY = trends.map<double>((e) => e.value ?? 0).reduce(min);
    minY = (minY * (trends.length == 1 ? 0.5 : 0.8)).roundToDouble();
    double maxY = trends.map<double>((e) => e.value ?? 0).reduce(max);
    maxY = (maxY * (trends.length == 1 ? 1.5 : 1.2)).roundToDouble();

    // Threshold = user energy goal (TDEE)
    double energyGoal = AppSettings.userInfo?.energyGoal ?? 2000;
    String thresholdLabel = '${energyGoal.round()}';
    String selectedUnit = 'kcal';

    // Adjust minY and maxY to ensure threshold is within the chart
    minY = max(0, min(minY, energyGoal - 100));
    maxY = max(maxY, energyGoal + 100);

    const double chartPaddingTop = 8.0;
    const double chartPaddingBottom = 8.0;

    final screenWidth = MediaQuery.of(context).size.width - padding;

    final bool shouldScroll = trends.length >= _breakingTypeNumber;

    const double maxSpacing = 60.0;
    const double minSpacing = 25.0;

    double pointSpacing = shouldScroll
        ? max(minSpacing,
            maxSpacing - (trends.length - _breakingTypeNumber) * 2.5)
        : screenWidth / max(1, (trends.length - 1));

    double chartWidth =
        shouldScroll ? pointSpacing * (trends.length - 1) : screenWidth;

    double minX = trends.length == 1 ? -1 : 0;
    double maxX = trends.length == 1 ? 1 : trends.length.toDouble() - 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartHeight = constraints.maxHeight - chartPaddingTop;
        final usableHeight = chartHeight - chartPaddingBottom;
        final targetPixel = chartPaddingTop +
            (maxY - energyGoal) / (maxY - minY) * usableHeight;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isChartReady && mounted) {
            setState(() {
              _isChartReady = true;
            });

            if (_focusIndex >= 0 &&
                _focusIndex < trends.length &&
                _shouldAutoScroll) {
              _scrollToSelected();
            }
          }
        });

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 55,
              height: constraints.maxHeight,
              child: Stack(
                children: [
                  Positioned(
                    top: targetPixel - 8,
                    left: 0,
                    right: 0,
                    child: Text(
                      '$thresholdLabel\n$selectedUnit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: R.color.color0xff111515,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: shouldScroll
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      child: Container(
                        width: chartWidth,
                        height: constraints.maxHeight,
                        padding: const EdgeInsets.only(
                          top: chartPaddingTop,
                          left: 8,
                          right: 8,
                          bottom: chartPaddingBottom,
                        ),
                        alignment: Alignment.center,
                        child: _buildLineChart(
                            trends, minX, maxX, minY, maxY, energyGoal),
                      ),
                    )
                  : Container(
                      width: chartWidth,
                      height: constraints.maxHeight,
                      padding: const EdgeInsets.only(
                        top: chartPaddingTop,
                        left: 8,
                        right: 8,
                        bottom: chartPaddingBottom,
                      ),
                      alignment: Alignment.center,
                      child: _buildLineChart(
                          trends, minX, maxX, minY, maxY, energyGoal),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLineChart(List<EnergyTrendItemModel> trends, double minX,
      double maxX, double minY, double maxY, double thresholdLine) {
    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        lineBarsData: _linesBarData(trends),
        titlesData: FlTitlesData(show: false),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        extraLinesData: ExtraLinesData(
          extraLinesOnTop: true,
          horizontalLines: [
            HorizontalLine(
              y: thresholdLine,
              color: R.color.color0xff636A6B,
              strokeWidth: 1,
              dashArray: [8, 4],
            ),
          ],
        ),
        lineTouchData: LineTouchData(
          getTouchLineStart: (barData, index) => -double.infinity,
          getTouchLineEnd: (barData, index) => double.infinity,
          getTouchedSpotIndicator: (barData, indexes) => indexes.map((index) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: toColor(trends[index].colorCode),
                strokeWidth: 0.5,
              ),
              FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 6.5,
                  color: toColor(trends[index].colorCode),
                  strokeWidth: 18,
                  strokeColor:
                      toColor(trends[index].colorCode).withValues(alpha: 0.3),
                ),
              ),
            );
          }).toList(),
          touchTooltipData: LineTouchTooltipData(
            showOnTopOfTheChartBoxArea: true,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (LineBarSpot touchedSpot) => R.color.transparent,
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.only(bottom: 50),
            getTooltipItems: (lineBarsSpot) {
              return lineBarsSpot.map((spot) {
                return LineTooltipItem(
                  formatNumber(spot.y),
                  TextStyle(
                    color: toColor(trends[spot.spotIndex].colorCode),
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
          touchCallback: (event, response) {
            if (event is FlTapUpEvent) {
              _touchCallback(event, response, trends);
            }
          },
        ),
      ),
      duration: const Duration(milliseconds: 250),
    );
  }

  void _touchCallback(
    FlTapUpEvent event,
    LineTouchResponse? lineTouch,
    List<EnergyTrendItemModel> trends,
  ) {
    final now = DateTime.now();

    // detect double press
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 300)) {
      // Double press → navigate to input
      if (lineTouch?.lineBarSpots != null &&
          lineTouch!.lineBarSpots!.isNotEmpty) {
        final touchedSpot = lineTouch.lineBarSpots!.first;
        if (touchedSpot.spotIndex == _focusIndex) {
          NavigationUtil.navigatePage(
            context,
            DailyNutritionPage(type: 'input', id: null),
          );
        }
      }
    } else {
      // Single press
      previousDate = 0;
      if (lineTouch?.lineBarSpots?.length == 1) {
        final value = lineTouch?.lineBarSpots?[0].x;
        if (value != null) {
          final touchIndex = value.toInt();
          if (touchIndex != _focusIndex) {
            if (!mounted) return;
            setState(() {
              _focusIndex = touchIndex;
              _selectedDateTimestamp = trends[_focusIndex].date;
              _shouldAutoScroll = true;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToSelected();
            });
          }
        }
      }
    }
    _lastTapTime = now;
  }

  List<LineChartBarData> _linesBarData(List<EnergyTrendItemModel> trends) {
    if (trends.length == 0) return [];
    return [
      LineChartBarData(
        spots: List.generate(trends.length, (index) {
          return FlSpot((index).toDouble(), trends[index].value ?? 0);
        }),
        isCurved: false,
        color: Color(0xFF008479),
        barWidth: 1.5,
        isStrokeCapRound: false,
        dotData: FlDotData(
          show: true,
          checkToShowDot: (spot, barData) => true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 3,
              color: toColor(trends[index].colorCode),
              strokeWidth: index == _focusIndex ? 6 : 0,
              strokeColor: index == _focusIndex
                  ? toColor(trends[index].colorCode).withValues(alpha: 0.3)
                  : Colors.transparent,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              R.color.greenGradientMid.withValues(alpha: 0.2),
              R.color.greenGradientMid.withValues(alpha: 0.0),
            ],
            stops: const [0.5, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    ];
  }

  void reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    BlocProvider.of<FoodBloc>(currentContext).add(FetchStatisticTrend(
      currentDateTime:
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      periodFilterType: periodFilterType.toString(),
    ));
  }
}
