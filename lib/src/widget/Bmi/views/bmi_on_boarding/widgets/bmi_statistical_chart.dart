import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/model/response/bmi_waist_statistical_response.dart';
import 'package:medical/src/model/response/bmi_weight_statistical_response.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_state.dart';

class BmiStatisticalChart extends StatelessWidget {
  const BmiStatisticalChart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BmiBloc _bmiBloc = context.read();

    return BlocBuilder<BmiBloc, BmiState>(
        buildWhen: (_, state) =>
            state is BmiGetWeightStatisticalState ||
            state is BmiGetWaistStatisticalState ||
            state is BmiGetBmiStatisticalState,
        builder: (context, state) {
          List<WeightWaistData> data = [];
          _bmiBloc.weightStatistical?.trendItems?.forEach((weight) {
            var waist = _bmiBloc.bmiWaistStatistical?.trendItems
                ?.firstWhereOrNull((waist) => waist.date == weight.date);
            data.add(
              WeightWaistData(
                time: DateTime.fromMillisecondsSinceEpoch(weight.date! * 1000),
                weight: weight.value ?? 0,
                waist: waist?.value,
              ),
            );
          });
          data = data.reversed.toList();
          double intervalWidth = 40;
          bool enableScroll =
              data.length * intervalWidth > MediaQuery.of(context).size.width;

          double widthChart = enableScroll
              ? data.length * intervalWidth
              : MediaQuery.of(context).size.width - 24;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: widthChart,
              height: 160,
              child: LineChart(
                LineChartData(
                  minY: 30,
                  maxY: 100,
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(showTitles: false),
                    rightTitles: SideTitles(showTitles: false),
                    topTitles: SideTitles(showTitles: false),
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTitles: (value) {
                        final int index = value.toInt();
                        if (index >= 0 && index < data.length) {
                          return data[index].waist?.toStringAsFixed(0) ?? '';
                        }
                        return "";
                      },
                      interval: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        data.length,
                        (i) => FlSpot(i.toDouble(), data[i].weight),
                      ),
                      isCurved: false,
                      colors: [Colors.green],
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        colors: [Colors.green.withOpacity(0.1)],
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchCallback: (event, response) {
                      // Kiểm tra xem có tap vào 1 điểm không
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.lineBarSpots == null) {
                        return;
                      }

                      // response.lineBarSpots chứa danh sách điểm được chạm
                      final spot = response.lineBarSpots!.first;
                      debugPrint('Tap vào điểm x=${spot.x}, y=${spot.y}');
                      _bmiBloc.selectPointChart(
                          DateTime.fromMillisecondsSinceEpoch(
                              data[spot.spotIndex]
                                  .time
                                  .millisecondsSinceEpoch));
                    },
                  ),
                  extraLinesData: ExtraLinesData(horizontalLines: [
                    HorizontalLine(
                        y: 60,
                        color: Colors.grey,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                        label: HorizontalLineLabel(
                          show: true,
                          style: R.style.smallBodyStyle.neutral4,
                          labelResolver: (label) =>
                              "${label.y.toStringAsFixed(0)} kg",
                        )),
                  ]),
                ),
              ),
            ),
          );

          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 8,
            ),
            child: SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: SideTitles(showTitles: false),
                        topTitles: SideTitles(showTitles: false),
                        rightTitles: SideTitles(showTitles: false),
                        bottomTitles: SideTitles(
                          showTitles: true,
                          getTitles: (value) => value.toInt().toString(),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          // spots: const [
                          //   FlSpot(0, 82),
                          //   FlSpot(1, 79),
                          //   FlSpot(2, 80),
                          //   FlSpot(3, 80),
                          // ],

                          spots: getSpots(context),
                          isCurved: true,
                          colors: [Colors.green],
                          barWidth: 2,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                      extraLinesData: ExtraLinesData(horizontalLines: [
                        HorizontalLine(
                            y: 60,
                            color: Colors.grey,
                            strokeWidth: 1,
                            dashArray: [5, 5],
                            label: HorizontalLineLabel(show: true)),
                      ]),
                      maxY: 90,
                      minY: 40,
                      lineTouchData: LineTouchData(
                        touchCallback: (event, response) {
                          // Kiểm tra xem có tap vào 1 điểm không
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.lineBarSpots == null) {
                            return;
                          }

                          // response.lineBarSpots chứa danh sách điểm được chạm
                          final spot = response.lineBarSpots!.first;
                          debugPrint('Tap vào điểm x=${spot.x}, y=${spot.y}');
                          _bmiBloc.selectPointChart(
                              DateTime.fromMillisecondsSinceEpoch(
                                  spot.x.toInt() * 1000));
                        },
                      )),
                )),
          );
        });
  }

  List<FlSpot> getSpots(BuildContext context) {
    BmiBloc _bmiBloc = context.read();
    List<FlSpot> spots = [];
    List<WeightStatisticRecord> weightData =
        _bmiBloc.weightStatistical?.trendItems ?? [];
    List<WaistStatisticRecord> waistData =
        _bmiBloc.bmiWaistStatistical?.trendItems ?? [];
    int totalRecords = weightData.length;

    if (totalRecords == 0) return [];

    for (int i = 0; i <= totalRecords; i++) {
      spots.add(FlSpot(
        // waistData.elementAtOrNull(i)?.value?.toDouble() ?? 0,
        weightData.elementAtOrNull(i)?.date?.toDouble() ?? 0,
        weightData.elementAtOrNull(i)?.value?.toDouble() ?? 0,
      ));
    }

    return spots;
  }
}

class WeightWaistData {
  final double weight;
  final double? waist;
  final DateTime time;

  WeightWaistData({
    required this.weight,
    required this.waist,
    required this.time,
  });
}
