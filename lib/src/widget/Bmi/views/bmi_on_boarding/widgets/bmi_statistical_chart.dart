import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/src/model/response/bmi_get_weight_list_response.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_event.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_state.dart';

class BmiStatisticalChart extends StatelessWidget {
  const BmiStatisticalChart({
    super.key,
  });

  static final double _heightOfChart = 160;
  static final double _widthOfSideBar = 32;
  static final double _marginOfWeight = 15;

  @override
  Widget build(BuildContext context) {
    BmiBloc _bmiBloc = context.read();
    ScrollController _scrollController = ScrollController(
      keepScrollOffset: true,
    );

    return BlocBuilder<BmiBloc, BmiState>(
        buildWhen: (_, state) =>
            state is BmiGetWeightIndexListState ||
            (state is BmiDataChangedState &&
                state.event == BmiDataChangeEvent.selectedPointChanged),
        builder: (context, state) {
          List<BmiGetWeightRecord> data =
              List.from(_bmiBloc.historicalWeightList);

          data = data.reversed.toList();
          double intervalWidth = 48;
          bool enableScroll =
              data.length * intervalWidth > MediaQuery.of(context).size.width;

          double widthChart = enableScroll
              ? data.length * intervalWidth
              : MediaQuery.of(context).size.width - _widthOfSideBar - 24;
          double _minWeightOnChart = _bmiBloc.getLowestOfChart(_marginOfWeight);
          double _maxWeightOnChart = _bmiBloc.getHighestOfChart(_marginOfWeight);
          double _bendmarkPadding =
              (_heightOfChart / (_maxWeightOnChart - _minWeightOnChart)) *
                      (60 - _minWeightOnChart) -
                  _marginOfWeight;

          if (_bmiBloc.isLastSelectedPoint && data.length > 1) {
            Future.delayed(Durations.extralong4, () {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: Durations.medium2,
                curve: Curves.easeInOut,
              );
            });
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: _widthOfSideBar,
                // padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Column(
                  children: [
                    if (_bmiBloc.weightGoal != null)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: _bendmarkPadding >= _heightOfChart
                              ? _heightOfChart / 2
                              : _bendmarkPadding,
                        ),
                        child: Text(
                          "${_bmiBloc.weightGoal} kg",
                          style: R.style.smallTextStyle.copyWith(color: AppColors.neutral3),
                        ),
                      ),
                    Image.asset(
                      "lib/res/drawables/icon_waist.png",
                      width: 18,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  child: Container(
                    width: widthChart,
                    height: _heightOfChart,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: LineChart(
                      LineChartData(
                        minY: _minWeightOnChart,
                        maxY: _maxWeightOnChart,
                        minX: data.length == 1 ? -0.5 : 0,
                        maxX: data.length == 1 ? 0 : data.length - 1,
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
                                if (value < 0) return '';
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
                            colors: data.map((e) => e.bmiColor).toList(),
                            barWidth: 2,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                final isSelected =
                                    data[index] == _bmiBloc.selectedPointChart;

                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: data[index].bmiColor,
                                  strokeWidth: isSelected ? 6 : 0,
                                  strokeColor: isSelected
                                      ? data[index].bmiColor.withOpacity(0.4)
                                      : null,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              colors: data.map((e) => e.bmiColor.withOpacity(0.1)).toList(),
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
                            var index = data.length - 1 - spot.spotIndex;
                            _bmiBloc.selectPointChart(index);
                          },
                        ),
                        extraLinesData: _bmiBloc.weightGoal != null
                            ? ExtraLinesData(horizontalLines: [
                                HorizontalLine(
                                  y: _bmiBloc.weightGoal ?? 0,
                                  color: Colors.grey,
                                  strokeWidth: 1,
                                  dashArray: [5, 5],
                                ),
                              ])
                            : null,
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
