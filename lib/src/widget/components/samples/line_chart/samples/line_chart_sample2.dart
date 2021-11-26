import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class LineChartSample2 extends StatefulWidget {
  @override
  _LineChartSample2State createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  final List<int> showIndexes = const [1, 2, 4];
  final List<FlSpot> allSpots = [
    FlSpot(1, 3),
    FlSpot(3, 2),
    FlSpot(5, 5),
    FlSpot(7, 3.1),
    FlSpot(9, 4),
  ];

  List<Color> gradientColors = [
    const Color(0xff0A2836),
    const Color(0xff0A2836),
  ];

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    final lineBarsData = [
      LineChartBarData(
        spots: allSpots,
        isCurved: false,
        barWidth: 1,
        isStrokeCapRound: true,
        colors: [
          R.color.black,
        ],
        belowBarData: BarAreaData(
          show: true,
          colors: [
            R.color.transparent,
          ],
          spotsLine: BarAreaSpotsLine(
            show: true,
            flLineStyle: FlLine(
              color: R.color.blue,
              strokeWidth: 10,
            ),
            checkToShowSpotLine: (spot) {
              if (spot.x == 0 || spot.x == 4) {
                return false;
              }

              return true;
            },
          ),
        ),
        dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              if (index == 4) {
                return FlDotCirclePainter(
                    radius: 5,
                    color: R.color.red,
                    strokeWidth: 2,
                    strokeColor: R.color.white);
              } else {
                return FlDotCirclePainter(
                  radius: 0,
                  color: R.color.white,
                  strokeWidth: 0,
                  strokeColor: R.color.black,
                );
              }
            },
            checkToShowDot: (spot, barData) {
              return spot.x != 0 && spot.x != 4;
            }),
      ),
    ];
    final LineChartBarData tooltipsOnBar = lineBarsData[0];
    return Container(
      width: 360,
      child: LineChart(
        LineChartData(
          showingTooltipIndicators: showIndexes.map((index) {
            return ShowingTooltipIndicators([
              LineBarSpot(tooltipsOnBar, lineBarsData.indexOf(tooltipsOnBar),
                  tooltipsOnBar.spots[index]),
            ]);
          }).toList(),
          lineTouchData: LineTouchData(
            enabled: true,
            getTouchedSpotIndicator:
                (LineChartBarData barData, List<int> spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: R.color.transparent,
                  ),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                      radius: 5,
                      color: R.color.red,
                      strokeWidth: 1,
                      strokeColor: R.color.white,
                    ),
                  ),
                );
              }).toList();
            },
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: R.color.blue,
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                return lineBarsSpot.map((lineBarSpot) {
                  return LineTooltipItem(
                    lineBarSpot.y.toString(),
                    TextStyle(
                        color: R.color.white, fontWeight: FontWeight.bold),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(),
          lineBarsData: lineBarsData,
          minX: 0,
          maxX: 11,
          minY: 0,
          maxY: 6,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: SideTitles(
              showTitles: true,
              reservedSize: 15,
              getTextStyles: (context, value) =>
                  const TextStyle(color: Color(0xff0A2836), fontSize: 16),
              getTitles: (value) {
                switch (value.toInt()) {
                  case 1:
                    return '12/18';
                  case 3:
                    return '06/19';
                  case 5:
                    return '12/19';
                  case 7:
                    return '6/20';
                  case 9:
                    return '12/20';
                }
                return '';
              },
              margin: 8,
            ),
            leftTitles: SideTitles(
              showTitles: true,
              getTextStyles: (context, value) => const TextStyle(
                color: Color(0xff0A2836),
                fontSize: 14,
              ),
              getTitles: (value) {
                switch (value.toInt()) {
                  case 0:
                    return '0';
                  case 1:
                    return '1';
                  case 2:
                    return '2';
                  case 3:
                    return '3';
                  case 4:
                    return '4';
                  case 5:
                    return '5';
                }
                return '';
              },
              reservedSize: 20,
              margin: 12,
            ),
          ),
          borderData: FlBorderData(
              show: true,
              border: Border(
                // left: BorderSide(width: 1.0, color: Color(0xff0A2836)),
                bottom: BorderSide(width: 1, color: R.color.color0xffE5E5E5),
              )),
        ),
      ),
    );
  }
}

Color? lerpGradient(List<Color> colors, List<double> stops, double t) {
  if (stops == null || stops.length != colors.length) {
    stops = [];

    /// provided gradientColorStops is invalid and we calculate it here
    colors.asMap().forEach((index, color) {
      final percent = 1.0 / colors.length;
      stops.add(percent * index);
    });
  }

  for (var s = 0; s < stops.length - 1; s++) {
    final leftStop = stops[s], rightStop = stops[s + 1];
    final leftColor = colors[s], rightColor = colors[s + 1];
    if (t <= leftStop) {
      return leftColor;
    } else if (t < rightStop) {
      final sectionT = (t - leftStop) / (rightStop - leftStop);
      return Color.lerp(leftColor, rightColor, sectionT);
    }
  }
  return colors.last;
}
