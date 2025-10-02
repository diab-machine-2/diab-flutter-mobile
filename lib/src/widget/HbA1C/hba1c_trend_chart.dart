import 'dart:math';
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
  @override
  Widget build(BuildContext context) {
    if (widget.dataPoints.isEmpty) return SizedBox(height: 120);

    // Calculate dynamic Y-axis range based on actual data
    final allValues =
        widget.groupedPoints.expand((g) => g.map((e) => e.value)).toList();
    double minValue = allValues.reduce(min);
    double maxValue = allValues.reduce(max);

    double padding = 0.2;
    double minY = (minValue - padding).clamp(0.0, double.infinity);
    double maxY = maxValue + padding;

    // Ensure minimum range for better visualization
    if (maxY - minY < 2.0) {
      double center = (maxY + minY) / 2;
      minY = center - 1.0;
      maxY = center + 1.0;
    }

    List<LineChartBarData> lineBarsData = _generateMultipleHbA1cLines();

    return SizedBox(
      height: 140,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Y-axis labels
            Container(
              width: 30,
              height: 140,
              child: Stack(
                children: [
                  // Max value label
                  Positioned(
                    top: _calculateYPosition(maxY, minY, maxY, 140),
                    right: 0,
                    child: Text(
                      '${maxY.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 10,
                        fontFamily: R.font.sfpro,
                      ),
                    ),
                  ),
                  // Middle value label
                  Positioned(
                    top:
                        _calculateYPosition((maxY + minY) / 2, minY, maxY, 140),
                    right: 0,
                    child: Text(
                      '${((maxY + minY) / 2).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 10,
                        fontFamily: R.font.sfpro,
                      ),
                    ),
                  ),
                  // Min value label
                  Positioned(
                    top: _calculateYPosition(minY, minY, maxY, 140),
                    right: 0,
                    child: Text(
                      '${minY.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 10,
                        fontFamily: R.font.sfpro,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 4),
            // Chart area
            Expanded(
              child: Container(
                height: 140,
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
                              color: Colors.black26,
                              strokeWidth: 0.3,
                              dashArray: [2, 2],
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
                            if (lineBarSpot.spotIndex >= 0 &&
                                lineBarSpot.spotIndex <
                                    widget.dataPoints.length) {
                              final dataPoint =
                                  widget.dataPoints[lineBarSpot.spotIndex];
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
                        // Dashed lines from Y-axis labels to chart area
                        HorizontalLine(
                          y: maxY,
                          color: Colors.black26,
                          dashArray: [2, 2],
                          strokeWidth: 0.3,
                        ),
                        HorizontalLine(
                          y: (maxY + minY) / 2,
                          color: Colors.black26,
                          dashArray: [2, 2],
                          strokeWidth: 0.3,
                        ),
                        HorizontalLine(
                          y: minY,
                          color: Colors.black26,
                          dashArray: [2, 2],
                          strokeWidth: 0.3,
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

    // Flatten all data points
    List<HbA1cDataPoint> flattenedPoints = [];
    for (int dayIndex = 0; dayIndex < widget.groupedPoints.length; dayIndex++) {
      final group = widget.groupedPoints[dayIndex];
      for (int subIndex = 0; subIndex < group.length; subIndex++) {
        flattenedPoints.add(group[subIndex]);
      }
    }

    return [
      LineChartBarData(
        spots: List.generate(flattenedPoints.length, (index) {
          return FlSpot(index.toDouble(), flattenedPoints[index].value);
        }),
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

            // Determine dot color based on HbA1C value range only
            // All points (including first/last) use range-based colors
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
          colors: [
            Color(0xFFC7F6D7),
            Color(0xFFFDFDFD),
          ],
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

  double _calculateYPosition(
      double value, double minY, double maxY, double chartHeight) {
    if (maxY == minY) return 0;

    // Normalize the value to 0-1 range
    double normalizedValue = (value - minY) / (maxY - minY);

    // Chart Y-axis is inverted (high values at top)
    double invertedPosition =
        (1 - normalizedValue) * (chartHeight - 16); // Subtract text height

    return invertedPosition;
  }

  // Get color based on HbA1C value ranges with new color scheme
  Color _getHbA1cRangeColor(double value) {
    // Updated color scheme for 4 ranges:
    if (value < 5.7) {
      // Lý tưởng - Light Green
      return Color(0xFF64E18E);
    } else if (value < 6.5) {
      // Tốt - Green
      return Color(0xFF23C559);
    } else if (value < 9.0) {
      // Cao - Light Red
      return Color(0xFFF86F6F);
    } else {
      // Rất cao - Dark Red
      return Color(0xFFD02424);
    }
  }
}
