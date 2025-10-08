import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/model/response/bmi_get_weight_list_response.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_state.dart';

class BmiStatisticalChart extends StatelessWidget {
  const BmiStatisticalChart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BmiBloc _bmiBloc = context.read();
    ScrollController _scrollController = ScrollController(
      keepScrollOffset: true,
    );

    return BlocBuilder<BmiBloc, BmiState>(
        buildWhen: (_, state) => state is BmiGetWeightIndexListState,
        builder: (context, state) {
          List<BmiGetWeightRecord> data =
              List.from(_bmiBloc.historicalWeightList);
          data = data.reversed.toList();
          double intervalWidth = 48;
          bool enableScroll =
              data.length * intervalWidth > MediaQuery.of(context).size.width;

          double widthChart = enableScroll
              ? data.length * intervalWidth
              : MediaQuery.of(context).size.width - 24;

          Future.delayed(Durations.extralong4, () {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Durations.medium2,
              curve: Curves.easeInOut,
            );
          });

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Image.asset(
                  "lib/res/drawables/icon_waist.png",
                  width: 18,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  child: Container(
                    width: widthChart,
                    height: 160,
                    padding: EdgeInsets.symmetric(horizontal: 12),
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
                                if (data[index].waist == 0) return '-';
                                return data[index].waist?.toStringAsFixed(0) ??
                                    '';
                              }
                              return "";
                            },
                            interval: 1,
                            getTextStyles: (context, value) =>
                                R.style.smallTextStyle,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              data.length,
                              (i) => FlSpot(i.toDouble(), data[i].weight ?? 0),
                            ),
                            isCurved: true,
                            colors: [Colors.green],
                            barWidth: 2,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                final isSelected =
                                    data[index] == _bmiBloc.selectedPointChart;
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: isSelected ? Colors.red : Colors.green,
                                  strokeWidth: isSelected ? 6 : 0,
                                  strokeColor: isSelected
                                      ? Colors.red.withOpacity(0.4)
                                      : null,
                                );
                              },
                            ),
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
                            _bmiBloc.selectPointChart(data[spot.spotIndex]);
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
                ),
              ),
            ],
          );
        });
  }

  // List<FlSpot> getSpots(BuildContext context) {
  //   BmiBloc _bmiBloc = context.read();
  //   List<FlSpot> spots = [];
  //   List<WeightStatisticRecord> weightData =
  //       _bmiBloc.weightStatistical?.trendItems ?? [];
  //   List<WaistStatisticRecord> waistData =
  //       _bmiBloc.bmiWaistStatistical?.trendItems ?? [];
  //   int totalRecords = weightData.length;

  //   if (totalRecords == 0) return [];

  //   for (int i = 0; i <= totalRecords; i++) {
  //     spots.add(FlSpot(
  //       // waistData.elementAtOrNull(i)?.value?.toDouble() ?? 0,
  //       weightData.elementAtOrNull(i)?.date?.toDouble() ?? 0,
  //       weightData.elementAtOrNull(i)?.value?.toDouble() ?? 0,
  //     ));
  //   }

  //   return spots;
  // }
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
