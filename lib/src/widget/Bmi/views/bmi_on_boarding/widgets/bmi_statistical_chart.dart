import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/src/model/response/bmi_get_weight_list_response.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_event.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_state.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/revise_weight_page.dart';

class BmiStatisticalChart extends StatefulWidget {
  const BmiStatisticalChart({
    super.key,
  });

  @override
  State<BmiStatisticalChart> createState() => _BmiStatisticalChartState();
}

class _BmiStatisticalChartState extends State<BmiStatisticalChart> {
  static final double _heightOfChart = 160;
  static final double _widthOfSideBar = 32;
  static final double _marginOfWeight = 10; // Reduced margin to fit more data
  static final double _itemWidth = 40;

  late BmiBloc _bmiBloc;
  ScrollController _scrollController = ScrollController(
    keepScrollOffset: true,
  );

  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _bmiBloc = context.read();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BmiBloc, BmiState>(
        buildWhen: (_, state) =>
            state is BmiGetWeightIndexListState ||
            (state is BmiDataChangedState &&
                state.event == BmiDataChangeEvent.selectedPointChanged),
        builder: (context, state) {
          List<BmiGetWeightRecord> data =
              List.from(_bmiBloc.historicalWeightList);

          data = data.reversed.toList();

          bool enableScroll =
              data.length * _itemWidth > MediaQuery.of(context).size.width;

          double widthChart = enableScroll
              ? data.length * _itemWidth
              : MediaQuery.of(context).size.width - _widthOfSideBar - 24;

          // Calculate min/max from actual data points to ensure all are visible
          double actualMinWeight = double.infinity;
          double actualMaxWeight = double.negativeInfinity;
          if (data.isNotEmpty) {
            for (var record in data) {
              if (record.weight != null) {
                if (record.weight! < actualMinWeight) {
                  actualMinWeight = record.weight!;
                }
                if (record.weight! > actualMaxWeight) {
                  actualMaxWeight = record.weight!;
                }
              }
            }
          }

          // Use actual data range with smaller margin to fit within fixed height
          double _minWeightOnChart;
          double _maxWeightOnChart;

          if (actualMinWeight != double.infinity &&
              actualMaxWeight != double.negativeInfinity) {
            // Use actual data points with margin
            _minWeightOnChart = actualMinWeight - _marginOfWeight;
            _maxWeightOnChart = actualMaxWeight + _marginOfWeight;
          } else {
            // Fallback to statistical data
            _minWeightOnChart = _bmiBloc.getLowestOfChart(_marginOfWeight);
            _maxWeightOnChart = _bmiBloc.getHighestOfChart(_marginOfWeight);
          }

          // Ensure weight goal is included in range if it exists
          if (_bmiBloc.weightGoal != null) {
            if (_bmiBloc.weightGoal! < _minWeightOnChart) {
              _minWeightOnChart = _bmiBloc.weightGoal! - _marginOfWeight;
            }
            if (_bmiBloc.weightGoal! > _maxWeightOnChart) {
              _maxWeightOnChart = _bmiBloc.weightGoal! + _marginOfWeight;
            }
          }

          // Calculate bendmark padding with safety checks
          double _bendmarkPadding = 0.0;
          final weightRange = _maxWeightOnChart - _minWeightOnChart;
          if (weightRange > 0 && _bmiBloc.weightGoal != null) {
            _bendmarkPadding = (_heightOfChart / weightRange) *
                    ((_bmiBloc.weightGoal ?? 60) - _minWeightOnChart) -
                _marginOfWeight +
                6;
            // Clamp padding to valid range (0 to _heightOfChart)
            _bendmarkPadding = _bendmarkPadding.clamp(0.0, _heightOfChart);
          }

          if (enableScroll) _focusToSelectedPoint(totalPoint: data.length);

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
                          "${_bmiBloc.weightGoal!.floor() == _bmiBloc.weightGoal ? _bmiBloc.weightGoal!.floor() : _bmiBloc.weightGoal} kg",
                          style: R.style.smallTextStyle
                              .copyWith(color: AppColors.neutral3),
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
                  clipBehavior: Clip.none,
                  child: Container(
                    width: widthChart,
                    height: _heightOfChart,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    clipBehavior: Clip.none,
                    child: LineChart(
                      LineChartData(
                        minY: _minWeightOnChart,
                        maxY: _maxWeightOnChart,
                        minX: data.length == 1 ? -0.5 : 0,
                        maxX: data.length == 1 ? 0 : data.length - 1,
                        clipData: FlClipData.none(),
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
                            isCurved: false,
                            colors: [Colors.green],
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
                                colors: [
                                  Colors.green.withOpacity(0.2),
                                  Colors.transparent,
                                ],
                                gradientFrom: Offset(0.5, 0),
                                gradientTo: Offset(0.5, 1),
                                gradientColorStops: [0.5, 1]),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                            touchCallback: (event, response) {
                              // Kiểm tra xem có tap vào 1 điểm không
                              if (!event.isInterestedForInteractions ||
                                  response == null ||
                                  response.lineBarSpots == null) {
                                return;
                              } else if (event is FlTapDownEvent) {
                                _touchCallback(event, response, data);
                              }
                            },
                            handleBuiltInTouches: true,
                            touchTooltipData: LineTouchTooltipData(
                              tooltipBgColor: Colors.transparent,
                              fitInsideHorizontally: true,
                              fitInsideVertically: false,
                              tooltipPadding: EdgeInsets.zero,
                              tooltipMargin: 12,
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  bool isInteger =
                                      spot.y.floor().toDouble() == spot.y;
                                  return LineTooltipItem(
                                    '${isInteger ? spot.y.floor() : spot.y.toStringAsFixed(1)}',
                                    TextStyle(
                                        color: data[spot.spotIndex].bmiColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  );
                                }).toList();
                              },
                            ),
                            getTouchLineStart: (barData, index) =>
                                -double.infinity,
                            getTouchLineEnd: (barData, index) =>
                                double.infinity,
                            getTouchedSpotIndicator: (LineChartBarData barData,
                                List<int> spotIndexes) {
                              return spotIndexes.map((index) {
                                return TouchedSpotIndicatorData(
                                  FlLine(
                                    color: data[index]
                                        .bmiColor, // màu line khi chạm
                                    strokeWidth: 0.5,
                                    // dashArray: [4, 2],
                                  ),
                                  FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) =>
                                            FlDotCirclePainter(
                                      radius: 6.5,
                                      color: data[index]
                                          .bmiColor, // màu chấm được chọn
                                      strokeWidth: 18,
                                      strokeColor:
                                          data[index].bmiColor.withOpacity(0.3),
                                    ),
                                  ),
                                );
                              }).toList();
                            }),
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

  void _focusToSelectedPoint({required int totalPoint}) {
    Future.delayed(Durations.short1, () {
      final double viewportCenter =
          MediaQuery.of(context).size.width / 2 - _widthOfSideBar;
      int mirrorIndex =
          (totalPoint - 1) - (_bmiBloc.selectedIndexPointChart ?? 0);

      double targetOffset =
          (mirrorIndex * _itemWidth - viewportCenter + (_itemWidth / 2));

      // Giới hạn offset trong [0, maxScrollExtent]
      targetOffset = targetOffset.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      );

      _scrollController.animateTo(
        targetOffset,
        duration: Durations.medium2,
        curve: Curves.easeInOut,
      );
    });
  }

  void _touchCallback(
    FlTapDownEvent event,
    LineTouchResponse lineTouch,
    List<BmiGetWeightRecord> records,
  ) async {
    final now = DateTime.now();

    // detect double press
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 300)) {
      // Double press detected
      if (lineTouch.lineBarSpots != null &&
          lineTouch.lineBarSpots!.isNotEmpty) {
        final touchedSpot = lineTouch.lineBarSpots!.first;
        final selectedTrend = records[touchedSpot.spotIndex];

        // Thực hiện hành động khi double press
        if (selectedTrend == _bmiBloc.selectedPointChart) {
          final updateResult = await Navigator.pushNamed(
            context,
            NavigatorName.bmiReviseRecordPage,
            arguments: {
              ReviseWeightPage.bmiBlocKey: _bmiBloc,
              ReviseWeightPage.dataKey: selectedTrend,
            },
          );

          if (updateResult == true) {
            _bmiBloc
              ..fetchHistoricalWeight()
              ..refresh();
          }
        }
      }
    } else {
      // Single press detected
      final spot = lineTouch.lineBarSpots!.first;
      debugPrint('Tap vào điểm x=${spot.x}, y=${spot.y}');
      var index = records.length - 1 - spot.spotIndex;
      _bmiBloc.selectPointChart(index);
    }
    _lastTapTime = now;
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
