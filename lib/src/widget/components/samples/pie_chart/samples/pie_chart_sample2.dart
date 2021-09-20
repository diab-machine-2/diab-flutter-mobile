import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:easy_localization/easy_localization.dart';

import 'indicator.dart';

class PieChartSample2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State {
  int touchedIndex;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.4,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: R.color.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2), // changes position of shadow
            ),
          ], borderRadius: BorderRadius.circular(14), color: R.color.white),
          // color: R.color.white,
          child: Row(
            children: <Widget>[
              const SizedBox(
                height: 12,
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: PieChart(
                    PieChartData(
                        pieTouchData:
                            PieTouchData(touchCallback: (event, pieTouchResponse) {
                          setState(() {
                            if (event is FlLongPressEnd ||
                                event is FlPanEndEvent) {
                              touchedIndex = -1;
                            } else {
                              touchedIndex =
                                  pieTouchResponse.touchedSection.touchedSectionIndex;
                            }
                          });
                        }),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        sectionsSpace: 1,
                        centerSpaceRadius: 45,
                        sections: showingSections()),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0, bottom: 8),
                    child: Text(
                      R.string.chu_thich.tr(),
                      style: TextStyle(fontSize: 14, color: R.color.textDark),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Indicator(
                        color: Color(0xffE53935),
                        number: '10%',
                        text: R.string.very_high.tr(),
                        isSquare: true,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Indicator(
                        color: Color(0xfffFF8E8E),
                        text: R.string.high.tr(),
                        number: '10%',
                        isSquare: true,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Indicator(
                        color: R.color.green,
                        text: R.string.good.tr(),
                        number: '10%',
                        isSquare: true,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Indicator(
                        color: Color(0xffFCB276),
                        number: '10%',
                        text: R.string.low.tr(),
                        isSquare: true,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Indicator(
                        color: R.color.color0xffF58220,
                        number: '10%',
                        text: R.string.very_low.tr(),
                        isSquare: true,
                      ),
                      SizedBox(
                        height: 18,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                width: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(5, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 25 : 16;
      // final double radius = isTouched ? 40 : 60;
      final double radius = 40;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color(0xfffFF8E8E),
            value: 20,
            showTitle: false,
            radius: radius,
          );
        case 1:
          return PieChartSectionData(
            color: R.color.green,
            value: 30,
            showTitle: false,
            radius: radius,
          );
        case 2:
          return PieChartSectionData(
            color: R.color.color0xffF58220,
            value: 15,
            showTitle: false,
            radius: radius,
          );
        case 3:
          return PieChartSectionData(
            color: const Color(0xffFCB276),
            value: 15,
            showTitle: false,
            radius: radius,
          );
        case 4:
          return PieChartSectionData(
            color: const Color(0xffE53935),
            value: 20,
            showTitle: false,
            radius: radius,
          );
        default:
          return null;
      }
    });
  }
}
