import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
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
    this.onDataLoaded,
  }) : super(key: key);

  final int periodFilterType;
  final void Function(bool hasData)? onDataLoaded;

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

  int _focusIndex = -1;
  DateTime? _lastTapTime;

  List<FoodCalorieTrendItem> trends = [];
  List<FoodCalorieTrendItem> _previousTrends = [];

  int? _selectedDateTimestamp;
  String? _selectedId;

  bool _isChartReady = false;
  bool _shouldAutoScroll = true;
  bool _didInitPeriod = false;

  final ScrollController _scrollController = ScrollController();

  // ── Scroll ──────────────────────────────────────────────
  void _scrollToSelected({bool animated = true, int retry = 0}) {
    if (!_shouldAutoScroll || !mounted) return;
    if (retry > 20) {
      _shouldAutoScroll = false;
      return;
    }

    final bool shouldScroll = trends.length >= _breakingTypeNumber;
    const double maxSpacing = 12.0;
    const double minSpacing = 12.0;
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
      final double pos = (_focusIndex * pointSpacing) - 100;
      if (animated) {
        _scrollController.animateTo(
            pos.clamp(0.0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      } else {
        _scrollController
            .jumpTo(pos.clamp(0.0, _scrollController.position.maxScrollExtent));
      }
    } else {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) _scrollToSelected(animated: animated, retry: retry + 1);
      });
    }
  }

  // ── Focus state ─────────────────────────────────────────
  void _updateFocusIndexWithFallback(List<FoodCalorieTrendItem> newTrends) {
    if (!mounted) return;
    trends = newTrends;
    if (trends.isEmpty) {
      _focusIndex = -1;
      _selectedDateTimestamp = null;
      _selectedId = null;
      _previousTrends = [];
      return;
    }

    int matchedIndex = -1;

    final bool wasLast =
        _previousTrends.isNotEmpty && _focusIndex == _previousTrends.length - 1;
    final bool hasNewTail = _previousTrends.isNotEmpty &&
        trends.isNotEmpty &&
        (_previousTrends.last.id != trends.last.id ||
            _previousTrends.last.date != trends.last.date);
    if (wasLast && hasNewTail) matchedIndex = trends.length - 1;

    if (matchedIndex == -1 && _selectedId != null) {
      matchedIndex = trends.indexWhere((item) => item.id == _selectedId);
    }

    if (matchedIndex == -1 && _selectedDateTimestamp != null) {
      final dupes = <int>[];
      for (int i = 0; i < trends.length; i++) {
        if (trends[i].date == _selectedDateTimestamp) dupes.add(i);
      }
      if (dupes.isNotEmpty) {
        matchedIndex = dupes.reduce((a, b) =>
            (a - _focusIndex).abs() <= (b - _focusIndex).abs() ? a : b);
      }
    }

    if (matchedIndex == -1) matchedIndex = trends.length - 1;

    _focusIndex = matchedIndex;
    _selectedDateTimestamp = trends[_focusIndex].date;
    _selectedId = trends[_focusIndex].id;
    _previousTrends = List.from(trends);

    if (mounted)
      setState(() {
        _shouldAutoScroll = true;
      });
  }

  // ── Lifecycle ───────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    // Lấy periodFilterType từ widget parameter — KHÔNG truy cập context ở đây
    periodFilterType = widget.periodFilterType;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // An toàn truy cập context ở đây
    if (!_didInitPeriod) {
      _didInitPeriod = true;
      try {
        final tabController = FoodDetailTabbarController.of(context);
        if (tabController != null) {
          periodFilterType = tabController.periodFilterType;
        }
      } catch (_) {
        // Widget tree chưa sẵn sàng → dùng default
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── Build ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<FoodBloc>(
      create: (context) => FoodBloc(),
      child: BlocBuilder<FoodBloc, FoodState>(
        builder: (BuildContext context, FoodState state) {
          if (!mounted) return SizedBox.shrink();
          currentContext = context;

          if (state is FoodInitial) {
            BlocProvider.of<FoodBloc>(context).add(FetchFoodCalorieTrend(
              currentDateTime:
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
              periodFilterType: periodFilterType.toString(),
            ));
          }

          if (state is FoodError) {
            print('[FoodCalorieTrendChart] BLoC error: ${state.message}');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                widget.onDataLoaded?.call(false);
              }
            });
            // Show empty state instead of infinite spinner
            return _buildEmptyState();
          }

          if (state is FoodCalorieTrendLoaded) {
            final newTrends = state.items;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _updateFocusIndexWithFallback(newTrends);
                widget.onDataLoaded?.call(newTrends.isNotEmpty);
              }
            });
          }

          if (state is FoodLoading || state is FoodInitial) {
            return Container(
                height: 300, child: Center(child: CircularProgressIndicator()));
          }

          if (state is! FoodCalorieTrendLoaded) {
            return _buildEmptyState();
          }

          return VisibilityDetector(
            key: Key('food_calorie_trend_chart'),
            onVisibilityChanged: (info) {
              if (!mounted) return;
              if (info.visibleFraction == 0) {
                previousDate = 0;
              } else if (info.visibleFraction > 0) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _scrollToSelected();
                });
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                _sectionTrending(),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Section trending ────────────────────────────────────
  Widget _sectionTrending() {
    if (trends.isEmpty) return _buildEmptyState();
    return _sectionTrendingLess(trends);
  }

  bool get hasData => trends.isNotEmpty;

  Widget _buildEmptyState() {
    String periodText = '';
    switch (periodFilterType) {
      case 1:
        periodText = '7';
        break;
      case 2:
        periodText = '14';
        break;
      case 3:
        periodText = '30';
        break;
      case 4:
        periodText = '90';
        break;
      default:
        periodText = '7';
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Arrows + empty text
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 16),
            _arrowButton(Icons.chevron_left, false, () {}),
            Expanded(
              child: Center(
                child: Text(
                  'Không có dữ liệu\ntrong $periodText ngày gần nhất',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: R.color.textDark,
                  ),
                ),
              ),
            ),
            _arrowButton(Icons.chevron_right, false, () {}),
            const SizedBox(width: 16),
          ],
        ),
        const SizedBox(height: 40),
        // Score label + dashed line — same layout as real chart
        SizedBox(
          height: 30,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Y-axis column — same width as real chart
              SizedBox(
                width: 55 + 16, // 55px column + left padding
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text('8điểm',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: R.color.color0xff111515)),
                ),
              ),
              // Dashed line fills rest
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: DashLine(color: R.color.color0xff636A6B),
                ),
              ),
            ],
          ),
        ),
      ],
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
    return (index >= 0 && index < labels.length) ? labels[index] : labels[0];
  }

  // ── Header + Chart ──────────────────────────────────────
  Widget _sectionTrendingLess(List<FoodCalorieTrendItem> trends) {
    if (_focusIndex == -1) {
      _focusIndex = trends.length > 1 ? (trends.length - 1) ~/ 2 : 0;
    }

    String selectedDate = '';
    String selectedTime = '';
    String selectedValue = '';
    String selectedFontColor = '#008479';
    String selectedMealText = '';
    String selectedType = 'Cân bằng';
    int selectedScore = 0;

    if (_focusIndex >= 0 && _focusIndex < trends.length) {
      final t = trends[_focusIndex];
      if (t.date != null) {
        final dt =
            DateTime.fromMillisecondsSinceEpoch(t.date! * 1000, isUtc: true);
        selectedDate = DateFormat('dd/MM').format(dt);
        selectedTime = DateFormat('HH:mm').format(dt);
      }
      selectedValue = formatNumber(t.value ?? 0);
      selectedFontColor = t.fontColor ?? '#008479';
      selectedMealText = t.mealText ?? '';
      if (selectedMealText.isNotEmpty &&
          !selectedMealText.toLowerCase().startsWith('bữa')) {
        selectedMealText = 'Bữa ${selectedMealText.toLowerCase()}';
      }
      selectedType = t.type ?? 'Cân bằng';
      selectedScore = t.score ?? 0;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Dòng 1: Giờ · Ngày ──
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: R.color.white, borderRadius: BorderRadius.circular(19)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(selectedTime,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: R.color.textDark)),
              _dotWidget(),
              Text(selectedDate,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: R.color.textDark)),
            ]),
          ),
        ]),
        const SizedBox(height: 2),

        // ── Dòng 2: < Cân bằng / Cao / Thấp > ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 16),
            _arrowButton(Icons.chevron_left, _focusIndex > 0, _goPreviousNode),
            Expanded(
              child: Center(
                child: Text(
                  selectedType,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: _parseColor(selectedFontColor),
                    height: 36 / 24,
                  ),
                ),
              ),
            ),
            _arrowButton(Icons.chevron_right, _focusIndex < trends.length - 1,
                () => _goNextNode(trends.length)),
            const SizedBox(width: 16),
          ],
        ),

        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (selectedMealText.isNotEmpty) ...[
              Text(selectedMealText,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: R.color.color0xff5E6566)),
              _dotWidget(),
            ],
            Text('$selectedScore điểm',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: R.color.textDark)),
            _dotWidget(),
            Text('$selectedValue Kcal',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: R.color.textDark)),
          ]),
        ),

        const SizedBox(height: 16),

        // ── Chart ──
        Container(
          height: 88,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildChart(trends, padding: 32, selectedScore: selectedScore),
        ),
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────
  Color _parseColor(String hex) {
    if (hex.isEmpty) return R.color.greenGradientBottom;
    try {
      return Color(int.parse('0xff${hex.replaceAll('#', '')}'));
    } catch (_) {
      return R.color.greenGradientBottom;
    }
  }

  Widget _arrowButton(IconData icon, bool enabled, VoidCallback onTap) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: R.color.color0xffE5E5E5, width: 1),
          color: Colors.white,
        ),
        child: Icon(icon,
            size: 20,
            color: enabled ? R.color.textDark : R.color.color0xffE5E5E5),
      ),
    );
  }

  void _goNextNode(int length) {
    if (_focusIndex < length - 1 && mounted) {
      setState(() {
        _focusIndex = min(length - 1, _focusIndex + 1);
        _selectedDateTimestamp = trends[_focusIndex].date;
        _selectedId = trends[_focusIndex].id;
        _shouldAutoScroll = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToSelected();
      });
    }
  }

  void _goPreviousNode() {
    if (_focusIndex > 0 && mounted) {
      setState(() {
        _focusIndex = max(0, _focusIndex - 1);
        _selectedDateTimestamp = trends[_focusIndex].date;
        _selectedId = trends[_focusIndex].id;
        _shouldAutoScroll = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToSelected();
      });
    }
  }

  Widget _dotWidget() {
    return Container(
      width: 4,
      height: 4,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: Color(0xFFBFC6C6)),
    );
  }

  // ── Chart build ─────────────────────────────────────────
  Widget _buildChart(List<FoodCalorieTrendItem> trends,
      {double padding = 0, int selectedScore = 0}) {
    if (trends.isEmpty) return SizedBox.shrink();

    // Threshold = mức điểm chuẩn
    double threshold = 8.0;

    // Y-axis range (0-10)
    double minY = 0.0;
    double maxY = 10.0;

    final screenWidth = MediaQuery.of(context).size.width - padding;
    final bool shouldScroll = trends.length >= _breakingTypeNumber;
    const double maxSp = 12.0, minSp = 12.0;

    double pointSpacing = shouldScroll
        ? max(minSp, maxSp - (trends.length - _breakingTypeNumber) * 2.5)
        : screenWidth / max(5, (trends.length - 1));

    double chartWidth =
        shouldScroll ? pointSpacing * (trends.length - 1) : screenWidth;
    double minX = 0;
    // ensure at least 5 intervals on screen so lines between points are never too long
    double maxX = shouldScroll
        ? trends.length.toDouble() - 1
        : max(5.0, trends.length.toDouble() - 1);

    return LayoutBuilder(builder: (context, constraints) {
      final chartH = constraints.maxHeight - 16;
      // Position score label aligned with the dashed threshold line
      final targetPx = 8 + (maxY - threshold) / (maxY - minY) * chartH;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isChartReady && mounted) {
          setState(() {
            _isChartReady = true;
          });
          if (_focusIndex >= 0 &&
              _focusIndex < trends.length &&
              _shouldAutoScroll) _scrollToSelected();
        }
      });

      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Y-axis label — show selected score, aligned with data point
        Container(
          width: 55,
          height: constraints.maxHeight,
          child: Stack(children: [
            Positioned(
              top: max(0, min(targetPx - 8, constraints.maxHeight - 20)),
              left: 0,
              right: 0,
              child: Text('Mức tốt\n${threshold.toInt()} điểm',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: R.color.color0xff111515, height: 1.2),
                  textAlign: TextAlign.left),
            ),
          ]),
        ),
        // Chart area
        Expanded(
          child: shouldScroll
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  child: Container(
                    width: chartWidth,
                    height: constraints.maxHeight,
                    padding: const EdgeInsets.all(8),
                    child:
                        _lineChart(trends, minX, maxX, minY, maxY, threshold),
                  ),
                )
              : Container(
                  width: chartWidth,
                  height: constraints.maxHeight,
                  padding: const EdgeInsets.all(8),
                  child: _lineChart(trends, minX, maxX, minY, maxY, threshold),
                ),
        ),
      ]);
    });
  }

  Widget _lineChart(List<FoodCalorieTrendItem> trends, double minX, double maxX,
      double minY, double maxY, double threshold) {
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
        extraLinesData: ExtraLinesData(extraLinesOnTop: true, horizontalLines: [
          HorizontalLine(
              y: threshold,
              color: R.color.color0xff636A6B,
              strokeWidth: 1,
              dashArray: [4, 6]),
        ]),
        lineTouchData: LineTouchData(
          getTouchedSpotIndicator: (barData, indexes) => indexes.map((index) {
            return TouchedSpotIndicatorData(
              FlLine(color: Colors.transparent, strokeWidth: 0),
              FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 6.5,
                  color: R.color.goodGreen,
                  strokeWidth: 18,
                  strokeColor: R.color.goodGreen.withValues(alpha: 0.3),
                ),
              ),
            );
          }).toList(),
          touchTooltipData: LineTouchTooltipData(
            showOnTopOfTheChartBoxArea: true,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (_) => R.color.transparent,
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.only(bottom: 50),
            getTooltipItems: (spots) => spots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toInt()} điểm\n${formatNumber(trends[spot.spotIndex].value ?? 0)} kcal',
                TextStyle(color: toColor(trends[spot.spotIndex].colorCode), fontWeight: FontWeight.bold),
              );
            }).toList(),
          ),
          touchCallback: (event, response) {
            if (event is FlTapUpEvent) _touchCallback(event, response, trends);
          },
        ),
      ),
      duration: const Duration(milliseconds: 250),
    );
  }

  // ── Touch ───────────────────────────────────────────────
  void _touchCallback(FlTapUpEvent event, LineTouchResponse? lineTouch,
      List<FoodCalorieTrendItem> trends) {
    if (!mounted) return;
    final now = DateTime.now();

    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 300)) {
      if (lineTouch?.lineBarSpots != null &&
          lineTouch!.lineBarSpots!.isNotEmpty) {
        final touchedSpot = lineTouch.lineBarSpots!.first;
        if (touchedSpot.spotIndex == _focusIndex) {
          final trendItem = trends[_focusIndex];
          // If the trend item has an id, open in edit mode; otherwise create mode with that date
          if (trendItem.id != null && trendItem.id!.isNotEmpty) {
            NavigationUtil.navigatePage(
                context, DailyNutritionPage(type: 'update', id: trendItem.id));
          } else {
            // Parse the date from the trend item for the new input
            DateTime? dotDate;
            if (trendItem.date != null) {
              dotDate = DateTime.fromMillisecondsSinceEpoch(
                  trendItem.date! * 1000,
                  isUtc: true);
            }
            NavigationUtil.navigatePage(
                context,
                DailyNutritionPage(
                    type: 'input', id: null, initialDate: dotDate));
          }
        }
      }
    } else {
      previousDate = 0;
      if (lineTouch?.lineBarSpots?.length == 1) {
        final value = lineTouch?.lineBarSpots?[0].x;
        if (value != null) {
          final touchIndex = value.toInt();
          if (touchIndex != _focusIndex && mounted) {
            setState(() {
              _focusIndex = touchIndex;
              _selectedDateTimestamp = trends[_focusIndex].date;
              _selectedId = trends[_focusIndex].id;
              _shouldAutoScroll = true;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _scrollToSelected();
            });
          }
        }
      }
    }
    _lastTapTime = now;
  }

  // ── Line bar data ───────────────────────────────────────
  List<LineChartBarData> _linesBarData(List<FoodCalorieTrendItem> trends) {
    if (trends.isEmpty) return [];
    return [
      LineChartBarData(
        spots: List.generate(trends.length,
            (i) => FlSpot(i.toDouble(), (trends[i].score ?? 0).toDouble())),
        isCurved: false,
        color: R.color.goodGreen,
        barWidth: 2.5,
        isStrokeCapRound: false,
        dotData: FlDotData(
          show: true,
          checkToShowDot: (_, __) => true,
          getDotPainter: (spot, percent, barData, index) {
            final isSelected = index == _focusIndex;
            // Green for balanced, yellow for unbalanced
            final dotColor = (trends[index].colorCode == '#008479')
                ? R.color.goodGreen
                : R.color.warningYellow;
            return FlDotCirclePainter(
              radius: isSelected ? 5 : 3.5,
              color: dotColor,
              strokeWidth: isSelected ? 8 : 0,
              strokeColor: isSelected
                  ? dotColor.withValues(alpha: 0.3)
                  : Colors.transparent,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              R.color.goodGreen.withValues(alpha: 0.2),
              R.color.goodGreen.withValues(alpha: 0.0),
            ],
            stops: const [0.5, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    ];
  }

  // ── Reload ──────────────────────────────────────────────
  void reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    if (!mounted) return;
    BlocProvider.of<FoodBloc>(currentContext).add(FetchFoodCalorieTrend(
      currentDateTime:
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      periodFilterType: periodFilterType.toString(),
    ));
  }
}
