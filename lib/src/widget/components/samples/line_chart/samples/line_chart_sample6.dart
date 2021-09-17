import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

// ignore: must_be_immutable
class LineChartSample6 extends StatelessWidget {
  final spots = [
    FlSpot(0, 1),
    FlSpot(2, 5),
    FlSpot(4, 3),
    FlSpot(6, 5),
  ];

  final spots2 = [
    FlSpot(0, 3),
    FlSpot(2, 1),
    FlSpot(4, 2),
    FlSpot(6, 1),
  ];

  double minSpotX, maxSpotX;
  double minSpotY, maxSpotY;

  LineChartSample6() {
    minSpotX = spots.first.x;
    maxSpotX = spots.first.x;
    minSpotY = spots.first.y;
    maxSpotY = spots.first.y;

    for (FlSpot spot in spots) {
      if (spot.x > maxSpotX) {
        maxSpotX = spot.x;
      }

      if (spot.x < minSpotX) {
        minSpotX = spot.x;
      }

      if (spot.y > maxSpotY) {
        maxSpotY = spot.y;
      }

      if (spot.y < minSpotY) {
        minSpotY = spot.y;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: R.color.black,
              blurRadius: 10,
              spreadRadius: 0,
            )
          ]),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(colors: [
            R.color.yellowAccent,
            R.color.yellowAccent.withOpacity(0.1),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 22.0, bottom: 20),
          child: SizedBox(
            width: 300,
            height: 200,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    colors: [
                      R.color.deepOrangeAccent,
                      R.color.orangeAccent,
                    ],
                    spots: reverseSpots(spots, minSpotY, maxSpotY),
                    isCurved: true,
                    isStrokeCapRound: true,
                    barWidth: 10,
                    belowBarData: BarAreaData(
                      show: false,
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(radius: 12, color: R.color.deepOrange.withOpacity(0.5)),
                    ),
                  ),
                  LineChartBarData(
                    colors: [
                      R.color.lightBlueAccent,
                      R.color.blue,
                    ],
                    spots: reverseSpots(spots2, minSpotY, maxSpotY),
                    isCurved: true,
                    isStrokeCapRound: true,
                    barWidth: 10,
                    belowBarData: BarAreaData(
                      show: false,
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(radius: 12, color: R.color.blue.withOpacity(0.5)),
                    ),
                  ),
                ],
                minY: 0,
                maxY: maxSpotY + minSpotY,
                titlesData: FlTitlesData(
                  leftTitles: SideTitles(
                    showTitles: true,
                    getTitles: (double value) {
                      final intValue = reverseY(value, minSpotY, maxSpotY).toInt();

                      if (intValue == (maxSpotY + minSpotY)) {
                        return '';
                      }

                      return intValue.toString();
                    },
                    getTextStyles: (context, value) => TextStyle(
                        color: R.color.deepOrange, fontWeight: FontWeight.bold, fontSize: 18),
                    margin: 16,
                  ),
                  rightTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 0,
                    getTitles: (double value) {
                      final intValue = reverseY(value, minSpotY, maxSpotY).toInt();

                      if (intValue == (maxSpotY + minSpotY)) {
                        return '';
                      }

                      return intValue.toString();
                    },
                    getTextStyles: (context, value) => TextStyle(
                        color: R.color.blue, fontWeight: FontWeight.bold, fontSize: 18),
                    margin: 16,
                  ),
                  bottomTitles: SideTitles(showTitles: false),
                  topTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    margin: 8,
                    getTextStyles: (context, value) =>
                        TextStyle(fontWeight: FontWeight.bold, color: R.color.black),
                    getTitles: (double value) {
                      return value.toInt().toString();
                    },
                  ),
                ),
                gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    checkToShowHorizontalLine: (value) {
                      final intValue = reverseY(value, minSpotY, maxSpotY).toInt();

                      if (intValue.toInt() == (maxSpotY + minSpotY).toInt()) {
                        return false;
                      }

                      return true;
                    }),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: R.color.black),
                    top: BorderSide(color: R.color.black),
                    bottom: BorderSide(color: R.color.transparent),
                    right: BorderSide(color: R.color.transparent),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double reverseY(double y, double minX, double maxX) {
    return (maxX + minX) - y;
  }

  List<FlSpot> reverseSpots(List<FlSpot> inputSpots, double minY, double maxY) {
    return inputSpots.map((spot) {
      return spot.copyWith(y: (maxY + minY) - spot.y);
    }).toList();
  }
}
