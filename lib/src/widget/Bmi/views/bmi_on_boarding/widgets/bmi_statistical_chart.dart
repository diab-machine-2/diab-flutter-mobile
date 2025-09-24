
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/widget/bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/bmi/bloc/bmi_state.dart';

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

                        spots: _bmiBloc.weightStatistical?.trendItems
                            ?.map((e) => FlSpot(
                                  e.date?.toDouble() ?? 0,
                                  e.value?.toDouble() ?? 0,
                                ))
                            .toList(),
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
                  ),
                )),
          );
        });
  }
}
