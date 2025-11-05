import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:medical/res/R.dart';

class HbA1cDataPoint {
  final DateTime date;
  final double value;
  final String level;
  final Color color;
  final String timeOfDay;
  final String? id; // ID from API for editing (String to match InputHbA1CModel)

  HbA1cDataPoint({
    required this.date,
    required this.value,
    required this.level,
    required this.color,
    required this.timeOfDay,
    this.id,
  });
}

class HbA1cTrendChart extends StatefulWidget {
  final List<List<HbA1cDataPoint>> groupedPoints;
  final List<HbA1cDataPoint> dataPoints;
  final int focusIndex;
  final int focusSubIndex;
  final Function(int) onPointSelected;
  final Function(int)? onPointDoubleTapped; // Optional callback for double tap

  const HbA1cTrendChart({
    Key? key,
    required this.groupedPoints,
    required this.dataPoints,
    required this.focusIndex,
    required this.focusSubIndex,
    required this.onPointSelected,
    this.onPointDoubleTapped,
  }) : super(key: key);

  @override
  State<HbA1cTrendChart> createState() => _HbA1cTrendChartState();
}

class _HbA1cTrendChartState extends State<HbA1cTrendChart> {
  int? _lastTappedIndex;
  DateTime? _lastTapTime;
  ScrollController? _scrollController;
  bool _initialScrollApplied = false;
  double _lastViewWidth = 0;
  double _lastEffectivePointWidth = 0;
  int _lastTotalPoints = 0;
  HbA1cDataPoint?
      _cachedSelectedPoint; // Cache selected point before range changes

  // Custom Y transform để đặt đường kẻ 6.5% ở giữa chart
  // Tương tự như BloodPressure chart với đường kẻ 90 và 140
  double _customYTransform(double y) {
    // Chia chart thành 3 vùng với 6.5 ở giữa:
    // 0-5.5: map to 0-40
    // 5.5-7.5: map to 40-60 (6.5 sẽ nằm ở 50, chính giữa)
    // 7.5-15: map to 60-100
    if (y <= 5.5) {
      // Map 0–5.5 to 0–40
      return (y / 5.5) * 40;
    } else if (y <= 7.5) {
      // Map 5.5–7.5 to 40–60 (6.5 will be at 50, center)
      return 40 + ((y - 5.5) / 2.0) * 20;
    } else {
      // Map 7.5–15+ to 60–100
      return 60 + ((y - 7.5) / 7.5) * 40;
    }
  }

  int _calculateTotalPoints(List<List<HbA1cDataPoint>> groups) {
    int total = 0;
    for (final group in groups) {
      total += group.length;
    }
    return total;
  }

  void _updateCachedSelectedPoint() {
    // Update cached selected point from current groupedPoints
    if (widget.focusIndex >= 0 &&
        widget.focusIndex < widget.groupedPoints.length) {
      final group = widget.groupedPoints[widget.focusIndex];
      if (widget.focusSubIndex >= 0 && widget.focusSubIndex < group.length) {
        _cachedSelectedPoint = group[widget.focusSubIndex];
      }
    }
  }

  int? _getSelectedFlatIndex() {
    // Use cached selected point if available (for range changes)
    // Otherwise get from current groupedPoints (for same range)
    HbA1cDataPoint? selectedPoint = _cachedSelectedPoint;

    if (selectedPoint == null) {
      // No cached point, get from current groupedPoints
      if (widget.focusIndex >= 0 &&
          widget.focusIndex < widget.groupedPoints.length) {
        final group = widget.groupedPoints[widget.focusIndex];
        if (widget.focusSubIndex >= 0 && widget.focusSubIndex < group.length) {
          selectedPoint = group[widget.focusSubIndex];
        }
      }
    }

    if (selectedPoint == null) return null;

    // Now find this point in the flattened list by comparing ID (or date+timeOfDay+value)
    final flattenedPoints = _getFlattenedDataPoints();
    for (int i = 0; i < flattenedPoints.length; i++) {
      final point = flattenedPoints[i];

      // Priority 1: Match by ID if both have ID
      if (selectedPoint.id != null &&
          selectedPoint.id!.isNotEmpty &&
          point.id != null &&
          point.id!.isNotEmpty) {
        if (selectedPoint.id == point.id) {
          return i;
        }
        continue; // If both have ID but don't match, skip to next
      }

      // Priority 2: Match by date+time, timeOfDay, and value
      // This ensures we find the exact same measurement
      final isSameDateTime = point.date.year == selectedPoint.date.year &&
          point.date.month == selectedPoint.date.month &&
          point.date.day == selectedPoint.date.day &&
          point.date.hour == selectedPoint.date.hour &&
          point.date.minute == selectedPoint.date.minute;
      final isSameTimeOfDay = point.timeOfDay == selectedPoint.timeOfDay;
      final isSameValue = (point.value - selectedPoint.value).abs() < 0.01;

      if (isSameDateTime && isSameTimeOfDay && isSameValue) {
        return i;
      }
    }

    return null; // Point not found in current range
  }

  void _ensureSelectedPointVisible({
    required int totalPoints,
    required double viewWidth,
    required double effectivePointWidth,
    int retry = 0,
  }) {
    if (_scrollController == null || _initialScrollApplied || totalPoints <= 0)
      return;
    if (!viewWidth.isFinite || viewWidth <= 0) return;

    // Maximum retry count to avoid infinite loops
    if (retry > 20) {
      _initialScrollApplied = true;
      return;
    }

    _initialScrollApplied = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Check if scroll controller is ready with proper dimensions
      if (!_scrollController!.hasClients ||
          !_scrollController!.position.hasContentDimensions) {
        _initialScrollApplied = false;
        // Retry after a short delay
        Future.delayed(const Duration(milliseconds: 50), () {
          _ensureSelectedPointVisible(
            totalPoints: totalPoints,
            viewWidth: viewWidth,
            effectivePointWidth: effectivePointWidth,
            retry: retry + 1,
          );
        });
        return;
      }

      final int? selectedFlatIndex = _getSelectedFlatIndex();

      // If selected point not found in current range, scroll to end (latest point)
      if (selectedFlatIndex == null) {
        _cachedSelectedPoint = null;
        final double maxScrollExtent =
            _scrollController!.position.maxScrollExtent;

        // First jump to start, then animate to end
        _scrollController!.jumpTo(0.0);

        Future.delayed(const Duration(milliseconds: 50), () {
          if (!mounted || !_scrollController!.hasClients) return;

          _scrollController!.animateTo(
            maxScrollExtent,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
          );
        });
        return;
      }

      // Selected point found - always center it (regardless of whether it's already visible)
      // Calculate the target position to center the selected point
      final double targetCenter =
          selectedFlatIndex * effectivePointWidth + (effectivePointWidth / 2);
      final double rawOffset = targetCenter - (viewWidth / 2);

      // Get maxScrollExtent AFTER ensuring hasContentDimensions
      final double maxScrollExtent =
          _scrollController!.position.maxScrollExtent;
      final double desiredOffset =
          rawOffset.clamp(0.0, maxScrollExtent).toDouble();

      // Animate to the selected point (centered)
      // First jump to start (position 0), then animate to the selected point
      _scrollController!.jumpTo(0.0);

      // Small delay to ensure the jump is complete before animation
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!mounted || !_scrollController!.hasClients) return;

        _scrollController!.animateTo(
          desiredOffset,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      });
    });
  }

  void _scrollToSelectedPoint({
    required int totalPoints,
    required double viewWidth,
    required double effectivePointWidth,
    int retry = 0,
  }) {
    if (_scrollController == null || !_scrollController!.hasClients) return;
    if (totalPoints <= 0) return;
    if (!viewWidth.isFinite || viewWidth <= 0) return;

    // Maximum retry count to avoid infinite loops
    if (retry > 20) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController!.hasClients) return;

      // Check if scroll controller is ready with proper dimensions
      if (!_scrollController!.position.hasContentDimensions) {
        // Retry after a short delay
        Future.delayed(const Duration(milliseconds: 50), () {
          _scrollToSelectedPoint(
            totalPoints: totalPoints,
            viewWidth: viewWidth,
            effectivePointWidth: effectivePointWidth,
            retry: retry + 1,
          );
        });
        return;
      }

      final int? selectedFlatIndex = _getSelectedFlatIndex();
      final int targetIndex = selectedFlatIndex ?? (totalPoints - 1);
      if (targetIndex < 0) {
        return;
      }

      // Calculate position to center the selected point
      final double targetCenter =
          targetIndex * effectivePointWidth + (effectivePointWidth / 2);
      final double rawOffset = targetCenter - (viewWidth / 2);

      // Get maxScrollExtent AFTER ensuring hasContentDimensions
      final double maxScrollExtent =
          _scrollController!.position.maxScrollExtent;
      final double desiredOffset =
          rawOffset.clamp(0.0, maxScrollExtent).toDouble();

      // Animate to the desired position
      _scrollController!.animateTo(
        desiredOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _updateCachedSelectedPoint(); // Cache initial selected point
  }

  @override
  void didUpdateWidget(covariant HbA1cTrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int newCount = _calculateTotalPoints(widget.groupedPoints);
    final int oldCount = _calculateTotalPoints(oldWidget.groupedPoints);

    final bool rangeChanged = newCount != oldCount;
    final bool focusChanged = widget.focusIndex != oldWidget.focusIndex ||
        widget.focusSubIndex != oldWidget.focusSubIndex;

    if (rangeChanged) {
      // Range changed - cache the selected point from OLD widget
      // This ensures we have the CORRECT point to search for in the new range
      if (oldWidget.focusIndex >= 0 &&
          oldWidget.focusIndex < oldWidget.groupedPoints.length) {
        final group = oldWidget.groupedPoints[oldWidget.focusIndex];
        if (oldWidget.focusSubIndex >= 0 &&
            oldWidget.focusSubIndex < group.length) {
          _cachedSelectedPoint = group[oldWidget.focusSubIndex];
        }
      }

      // Reset scroll position so it will animate to the cached point (centered) in new range
      _initialScrollApplied = false;
    } else if (focusChanged) {
      // Same range, but user selected a different point
      // Clear old cache and update with the new selection
      _cachedSelectedPoint = null;
      _updateCachedSelectedPoint();

      // Scroll to center the new selection
      if (_lastTotalPoints > 0 && _lastViewWidth > 0) {
        _scrollToSelectedPoint(
          totalPoints: _lastTotalPoints,
          viewWidth: _lastViewWidth,
          effectivePointWidth: _lastEffectivePointWidth,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flattenedPoints = _getFlattenedDataPoints();
    if (flattenedPoints.isEmpty) return SizedBox(height: 120);

    final List<LineChartBarData> lineBarsData =
        _generateMultipleHbA1cLines(flattenedPoints);

    const int visiblePointCount = 6;
    const double chartHeight = 140;

    // Fixed minY and maxY for consistent chart display
    double minY = 0;
    double maxY = 100;
    final int totalPoints = flattenedPoints.length;

    return SizedBox(
      height: chartHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Y-axis labels
            Container(
              width: 30,
              height: 140,
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Spacer(flex: 1),
                  Text(
                    '6.5%',
                    style: TextStyle(
                      color: R.color.black,
                      fontSize: 12,
                      fontFamily: R.font.sfpro,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(flex: 1),
                ],
              ),
            ),
            SizedBox(width: 4),
            // Chart area
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double viewWidth = constraints.maxWidth;
                  if (!viewWidth.isFinite || viewWidth <= 0) {
                    return const SizedBox.shrink();
                  }

                  final bool enableScroll = totalPoints > visiblePointCount;
                  final double chartWidth = enableScroll
                      ? (viewWidth / visiblePointCount) * totalPoints
                      : viewWidth;
                  final double effectivePointWidth =
                      totalPoints == 0 ? 0 : chartWidth / totalPoints;

                  // Save values for use in didUpdateWidget
                  _lastViewWidth = viewWidth;
                  _lastEffectivePointWidth = effectivePointWidth;
                  _lastTotalPoints = totalPoints;

                  if (enableScroll) {
                    _ensureSelectedPointVisible(
                      totalPoints: totalPoints,
                      viewWidth: viewWidth,
                      effectivePointWidth: effectivePointWidth,
                    );
                  } else {
                    if (_scrollController != null &&
                        _scrollController!.hasClients &&
                        _scrollController!.position.pixels != 0.0) {
                      _scrollController!.jumpTo(0.0);
                    }
                    _initialScrollApplied = true;
                  }

                  return SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: enableScroll
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    child: SizedBox(
                      width: enableScroll ? chartWidth : viewWidth,
                      child: Container(
                        height: chartHeight,
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: LineChart(
                          LineChartData(
                            lineTouchData: LineTouchData(
                              enabled: true,
                              getTouchLineStart: (barData, index) =>
                                  -double.infinity,
                              getTouchLineEnd: (barData, index) =>
                                  double.infinity,
                              touchCallback: (FlTouchEvent event,
                                  LineTouchResponse? touchResponse) {
                                if (event is FlTapUpEvent) {
                                  final spot =
                                      touchResponse?.lineBarSpots?.isNotEmpty ==
                                              true
                                          ? touchResponse!.lineBarSpots!.first
                                          : null;
                                  if (spot != null) {
                                    final touchedFlatIndex = spot.x.toInt();
                                    if (touchedFlatIndex >= 0 &&
                                        touchedFlatIndex <
                                            flattenedPoints.length) {
                                      final now = DateTime.now();
                                      if (_lastTappedIndex ==
                                              touchedFlatIndex &&
                                          _lastTapTime != null &&
                                          now
                                                  .difference(_lastTapTime!)
                                                  .inMilliseconds <
                                              500) {
                                        if (widget.onPointDoubleTapped !=
                                            null) {
                                          widget.onPointDoubleTapped!(
                                              touchedFlatIndex);
                                        }
                                        _lastTappedIndex = null;
                                        _lastTapTime = null;
                                      } else {
                                        widget
                                            .onPointSelected(touchedFlatIndex);
                                        _lastTappedIndex = touchedFlatIndex;
                                        _lastTapTime = now;
                                      }
                                    }
                                  }
                                } else if (event is! FlLongPressEnd &&
                                    event is! FlPanEndEvent) {
                                  final spot =
                                      touchResponse?.lineBarSpots?.isNotEmpty ==
                                              true
                                          ? touchResponse!.lineBarSpots!.first
                                          : null;
                                  if (spot != null) {
                                    final touchedFlatIndex = spot.x.toInt();
                                    if (touchedFlatIndex >= 0 &&
                                        touchedFlatIndex <
                                            flattenedPoints.length) {
                                      // Update selection for hover/pan interactions.
                                      widget.onPointSelected(touchedFlatIndex);
                                    }
                                  }
                                }
                              },
                              getTouchedSpotIndicator:
                                  (LineChartBarData barData,
                                      List<int> spotIndexes) {
                                return spotIndexes.map((index) {
                                  // Get the color of the touched point
                                  Color dotColor = R.color.black;
                                  if (index >= 0 &&
                                      index < flattenedPoints.length) {
                                    dotColor = flattenedPoints[index].color;
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
                                        radius: 6.5,
                                        color: dotColor,
                                        strokeWidth: 18,
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
                                tooltipBgColor:
                                    Colors.grey.shade800.withOpacity(0.9),
                                tooltipRoundedRadius: 8,
                                getTooltipItems:
                                    (List<LineBarSpot> lineBarsSpot) {
                                  return lineBarsSpot.map((lineBarSpot) {
                                    final int flatIndex = lineBarSpot.x.toInt();
                                    if (flatIndex >= 0 &&
                                        flatIndex < flattenedPoints.length) {
                                      final dataPoint =
                                          flattenedPoints[flatIndex];
                                      return LineTooltipItem(
                                        '${dataPoint.value.toStringAsFixed(1)}%',
                                        TextStyle(
                                          color: Colors.white,
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
                            ),
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(
                              rightTitles: SideTitles(showTitles: false),
                              topTitles: SideTitles(showTitles: false),
                              leftTitles: SideTitles(showTitles: false),
                              bottomTitles: SideTitles(showTitles: false),
                            ),
                            borderData: FlBorderData(show: false),
                            minX: -0.5,
                            maxX: totalPoints > 0
                                ? (totalPoints - 0.5).toDouble()
                                : 0,
                            maxY: maxY,
                            minY: minY,
                            lineBarsData: lineBarsData,
                            extraLinesData: ExtraLinesData(
                              horizontalLines: [
                                // Dashed line at 6.5% reference point (at center)
                                HorizontalLine(
                                  y: _customYTransform(6.5),
                                  color: const Color(0xFF636A6B),
                                  dashArray: [8, 4],
                                  strokeWidth: 1,
                                ),
                              ],
                            ),
                          ),
                          swapAnimationDuration:
                              const Duration(milliseconds: 250),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<LineChartBarData> _generateMultipleHbA1cLines(
      List<HbA1cDataPoint> flattenedPoints) {
    if (flattenedPoints.isEmpty) return [];
    final int? selectedFlatIndex = _getSelectedFlatIndex();

    // Generate spots for the single line connecting all points
    // Apply custom Y transform to position values correctly
    List<FlSpot> spots = [];
    for (int i = 0; i < flattenedPoints.length; i++) {
      double transformedValue = _customYTransform(flattenedPoints[i].value);
      spots.add(FlSpot(i.toDouble(), transformedValue));
    }

    return [
      LineChartBarData(
        spots: spots,
        isCurved: false,
        colors: [Color(0xFF23C559)], // Main line color - green #23C559
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            if (index >= flattenedPoints.length) {
              return FlDotCirclePainter(radius: 0);
            }

            final dp = flattenedPoints[index];
            final bool isSelected =
                selectedFlatIndex != null && selectedFlatIndex == index;

            // Determine dot color based on HbA1C value range
            Color dotColor = _getHbA1cRangeColor(dp.value);

            return FlDotCirclePainter(
              radius: 3,
              color: dotColor,
              strokeWidth: isSelected ? 6 : 0,
              strokeColor: isSelected ? dotColor.withOpacity(0.3) : null,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          // Gradient colors from top to bottom
          // Reversed: green at top -> white/transparent at bottom
          colors: [
            Color(0xFFC7F6D7).withOpacity(1), // Darker green at top
            Color(0xFFC7F6D7).withOpacity(0.7), // Light green in middle
            Color(0xFFFDFDFD)
                .withOpacity(0.4), // Almost transparent white at bottom
          ],
          gradientColorStops: [0.0, 0.5, 1.0], // Distribute colors evenly
          gradientFrom: Offset(0, 0), // Start from line
          gradientTo: Offset(0, 1), // End at bottom
          // Ensure gradient always fills to a minimum depth for visibility
          applyCutOffY: false, // Don't apply cutoff, fill to chart bottom
        ),
      ),
    ];
  }

  List<HbA1cDataPoint> _getFlattenedDataPoints() {
    List<HbA1cDataPoint> flattenedPoints = [];
    for (int dayIndex = 0; dayIndex < widget.groupedPoints.length; dayIndex++) {
      final group = widget.groupedPoints[dayIndex];
      for (int subIndex = 0; subIndex < group.length; subIndex++) {
        flattenedPoints.add(group[subIndex]);
      }
    }
    return flattenedPoints;
  }

  // Get color based on HbA1C value ranges with new color scheme
  Color _getHbA1cRangeColor(double value) {
    // Updated color scheme for 4 ranges:
    // ≤ 6.5: Lý tưởng, > 6.5 và ≤ 7.0: Tốt, > 7.0 và ≤ 8.0: Cao, > 8.0: Rất cao
    if (value <= 6.5) {
      // Lý tưởng - Light Green
      return Color(0xFF64E18E); // #64E18E
    } else if (value <= 7.0) {
      // Tốt - Green
      return Color(0xFF23C559); // #23C559
    } else if (value <= 8.0) {
      // Cao - Light Red
      return Color(0xFFF86F6F); // #F86F6F
    } else {
      // Rất cao - Dark Red
      return Color(0xFFD02424); // #D02424
    }
  }
}
