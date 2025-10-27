import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:medical/res/R.dart';

class HbA1cDataPoint {
  final DateTime date;
  final double value;
  final String level;
  final Color color;
  final String timeOfDay;

  HbA1cDataPoint({
    required this.date,
    required this.value,
    required this.level,
    required this.color,
    required this.timeOfDay,
  });
}

class HbA1cTrendChart extends StatefulWidget {
  final List<List<HbA1cDataPoint>> groupedPoints;
  final List<HbA1cDataPoint> dataPoints;
  final int focusIndex;
  final int focusSubIndex;
  final Function(int) onPointSelected;

  const HbA1cTrendChart({
    Key? key,
    required this.groupedPoints,
    required this.dataPoints,
    required this.focusIndex,
    required this.focusSubIndex,
    required this.onPointSelected,
  }) : super(key: key);

  @override
  State<HbA1cTrendChart> createState() => _HbA1cTrendChartState();
}

class _HbA1cTrendChartState extends State<HbA1cTrendChart> {
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

  @override
  Widget build(BuildContext context) {
    if (widget.dataPoints.isEmpty) return SizedBox(height: 120);

    List<LineChartBarData> lineBarsData = _generateMultipleHbA1cLines();

    // Fixed minY and maxY for consistent chart display
    double minY = 0;
    double maxY = 100;

    return SizedBox(
      height: 140,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Y-axis labels
            Container(
              width: 40,
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
                      fontSize: 14,
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
              child: Container(
                height: 140,
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      enabled: true,
                      getTouchLineStart: (barData, index) => -double.infinity,
                      getTouchLineEnd: (barData, index) => double.infinity,
                      touchCallback: (FlTouchEvent event,
                          LineTouchResponse? touchResponse) {
                        if (event is! FlLongPressEnd &&
                            event is! FlPanEndEvent) {
                          final spot =
                              touchResponse?.lineBarSpots?.isNotEmpty == true
                                  ? touchResponse!.lineBarSpots!.first
                                  : null;
                          if (spot != null) {
                            final touchedFlatIndex = spot.x.toInt();
                            widget.onPointSelected(touchedFlatIndex);
                          }
                        }
                      },
                      getTouchedSpotIndicator:
                          (LineChartBarData barData, List<int> spotIndexes) {
                        return spotIndexes.map((index) {
                          return TouchedSpotIndicatorData(
                            FlLine(
                              color: R.color.black,
                              strokeWidth: 0.5,
                            ),
                            FlDotData(show: false),
                          );
                        }).toList();
                      },
                      touchTooltipData: LineTouchTooltipData(
                        showOnTopOfTheChartBoxArea: true,
                        fitInsideVertically: true,
                        fitInsideHorizontally: true,
                        tooltipBgColor: Colors.grey.shade800.withOpacity(0.9),
                        tooltipRoundedRadius: 8,
                        getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                          return lineBarsSpot.map((lineBarSpot) {
                            // Get the flat index from the spot's x position
                            int flatIndex = lineBarSpot.x.toInt();
                            if (flatIndex >= 0 &&
                                flatIndex < _getFlattenedDataPoints().length) {
                              final dataPoint =
                                  _getFlattenedDataPoints()[flatIndex];
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
                    maxX: (widget.groupedPoints.length - 0.5).toDouble(),
                    maxY: maxY,
                    minY: minY,
                    lineBarsData: lineBarsData,
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        // Dashed line at 6.5% reference point (at center)
                        HorizontalLine(
                          y: _customYTransform(6.5),
                          color: Color(0xFF636A6B),
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
          ],
        ),
      ),
    );
  }

  List<LineChartBarData> _generateMultipleHbA1cLines() {
    if (widget.groupedPoints.isEmpty) return [];

    // Flatten all data points - use all data points in order
    List<HbA1cDataPoint> flattenedPoints = [];
    for (int dayIndex = 0; dayIndex < widget.groupedPoints.length; dayIndex++) {
      final group = widget.groupedPoints[dayIndex];
      for (int subIndex = 0; subIndex < group.length; subIndex++) {
        flattenedPoints.add(group[subIndex]);
      }
    }

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
            final bool isSelected = _isPointSelected(index, flattenedPoints);
            final bool isFirst = index == 0;
            final bool isLast = index == flattenedPoints.length - 1;

            // Determine dot color based on HbA1C value range
            Color dotColor = _getHbA1cRangeColor(dp.value);

            return FlDotCirclePainter(
              radius: isFirst || isLast ? 5 : 4,
              color: dotColor,
              strokeWidth: isSelected ? 12 : 0,
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

  bool _isPointSelected(int flatIndex, List<HbA1cDataPoint> flattenedPoints) {
    if (widget.focusIndex < 0 ||
        widget.focusIndex >= widget.groupedPoints.length) return false;
    if (widget.focusSubIndex < 0 ||
        widget.focusSubIndex >= widget.groupedPoints[widget.focusIndex].length)
      return false;

    // Find the corresponding flat index for the selected point
    int currentFlatIndex = 0;
    for (int dayIndex = 0; dayIndex < widget.groupedPoints.length; dayIndex++) {
      final group = widget.groupedPoints[dayIndex];
      for (int subIndex = 0; subIndex < group.length; subIndex++) {
        if (dayIndex == widget.focusIndex && subIndex == widget.focusSubIndex) {
          return currentFlatIndex == flatIndex;
        }
        currentFlatIndex++;
      }
    }
    return false;
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
