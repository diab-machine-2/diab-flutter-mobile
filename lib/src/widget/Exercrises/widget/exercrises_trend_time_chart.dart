import 'dart:async';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/exercrises/exercrises_bloc.dart';
import 'package:medical/src/modal/exercrises/exercrise_trend_time.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodSugar/constant/bloodSugar_rangetype.dart';
import 'package:medical/src/widget/Exercrises/widget/dash_line_horizontal.dart';
import 'package:medical/src/widget/Exercrises/widget/exercrises_ai_suggestion.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ExercrisesTrendTimeChart extends StatefulWidget {
  const ExercrisesTrendTimeChart({
    Key? key,
    required this.periodFilterType,
    required this.onFilterChanged,
    required this.onViewListing,
    required this.filterName,
  }) : super(key: key);

  final int periodFilterType;
  final Function() onFilterChanged;
  final Function() onViewListing;
  final String filterName;

  @override
  State<ExercrisesTrendTimeChart> createState() =>
      ExercrisesTrendTimeChartState();
}

class ExercrisesTrendTimeChartState extends State<ExercrisesTrendTimeChart>
    with AutomaticKeepAliveClientMixin<ExercrisesTrendTimeChart> {
  @override
  bool get wantKeepAlive => true;

  final _bloc = ExercrisesBloc();
  final ScrollController _scrollController = ScrollController();

  StreamSubscription? _subscription;

  late BuildContext currentContext;
  int value = 0;
  String? trendType = R.string.all;
  int trendTypeIndex = 1;
  int periodFilterType = 0;
  int? previousDate = 0;

  int minXIndex = 0;
  int maxXIndex = 0;

  final int _breakingTypeNumber = 12;

  int _focusIndex = -1;

  DateTime? _lastTapTime;

  List<SubTrendItemModel> trends = [];

  @override
  void initState() {
    super.initState();
    periodFilterType = widget.periodFilterType;

    _subscription = _bloc.stream.listen((state) async {
      if (state is ExercriseTrendTimeLoaded) {
        _subscription?.cancel();
        _subscription = null;

        // Cập nhật trends
        trends = state.trend.trendItems.items
            .where((item) => item.duration != null && item.duration! > 0)
            .toList();

        if (trends.isEmpty) {
          await Future.delayed(Duration(milliseconds: 500));
          Message.showToastMessage(context, R.string.no_data.tr());
        }

        // Đặt focus index nếu cần
        if (_focusIndex == -1 && trends.isNotEmpty) {
          setState(() {
            _focusIndex = (trends.length - 1) ~/ 2;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<ExercrisesBloc>.value(
      value: _bloc,
      child: BlocBuilder<ExercrisesBloc, ExercrisesState>(
        builder: (BuildContext context, ExercrisesState state) {
          currentContext = context;
          ExercriseTrendTimeModel? model;

          if (state is ExercrisesInitial) {
            BlocProvider.of<ExercrisesBloc>(context).add(FetchTimeTrend(
                currentDateTime:
                    (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
                periodFilterType: periodFilterType.toString()));
          }
          if (state is ExercrisesError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is TimeTrendTrendLoaded) {
            model = state.model;

            // Cập nhật trends mà không gọi setState()
            trends = model.trendItems.items
                .where((item) => item.duration != null && item.duration! > 0)
                .toList();
          }

          if (model == null) {
            return Container(
                height: 450, child: Center(child: CircularProgressIndicator()));
          }

          if (trends.isEmpty) {
            return Container(
              height: 100,
              child: Center(child: Text('No data available')),
            );
          }

          if (trends.isNotEmpty && _focusIndex == -1) {
            _focusIndex = (trends.length - 1) ~/ 2;
            // Gọi _scrollToSelectd sau khi focus index được thiết lập
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToSelectd();
            });
          }

          return VisibilityDetector(
            key: Key('exercrises-trend-time-chart'),
            onVisibilityChanged: (visibilityInfo) {
              var visiblePercentage = visibilityInfo.visibleFraction * 100;
              if (visiblePercentage == 0) {
                previousDate = 0;
              }
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    R.color.white,
                    R.color.white.withAlpha(0),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.6, 1.0],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _sectionTrending(model, '', ''),
                  const SizedBox(height: 16),
                  ExercrisesAISuggestion(
                    aiSuggestion: trends[_focusIndex].targetDescription,
                    rangeType: BloodSugarRangeType.very_high,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }

  Widget _sectionTrending(ExercriseTrendTimeModel model, String? mostAppearType,
      String? mostAppearTypeColor) {
    if (model.trendItems.items.isEmpty) {
      return Container(height: 100);
    }
    List<SubTrendItemModel> trends = [];
    model.trendItems.items.forEach((item) {
      if (item.duration != null && item.duration! > 0) {
        trends.add(item);
      }
    });
    int totalItems = trends.length;

    if (totalItems < _breakingTypeNumber) {
      return _sectionTrendingLess(model.targetUnit, model.target);
    } else {
      return _sectionTrendingMany(
          DateTime.now().microsecondsSinceEpoch,
          DateTime.now().microsecondsSinceEpoch,
          mostAppearType,
          mostAppearTypeColor,
          model.targetUnit);
    }
  }

  Widget _sectionTrendingLess(String? unit, double? target) {
    if (_focusIndex == -1) {
      // if no focus index
      // set focus index to the middle of the list
      if (trends.length > 1) {
        _focusIndex = (trends.length - 1) ~/ 2;
      } else {
        _focusIndex = 0;
      }
    }

    String selectedDate = '';
    String selectedType = 'selectedType';
    String selectedDuration = 'selectedDuration';
    String selectedColor = '';
    String selectedUnit = unit ?? '';

    if (_focusIndex != -1 && _focusIndex < trends.length) {
      final selectedTrend = trends[_focusIndex];
      if (selectedTrend.duration != null) {
        selectedDuration = roundNumber(selectedTrend.duration!).toString();
      }
      if (selectedTrend.firstDateOfWeek != null &&
          selectedTrend.lastDateOfWeek != null) {
        selectedDate =
            convertToUTC(selectedTrend.firstDateOfWeek!, 'dd' + '-') +
                convertToUTC(selectedTrend.lastDateOfWeek!, 'dd/MM');
      } else {
        selectedDate = convertToSectionTicketDate(selectedTrend.date!, '');
      }
      selectedColor = selectedTrend.targetColor ?? '';
      selectedType = selectedTrend.targetDescription ?? '';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    // Respond to button press
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: R.color.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(200),
                    ),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 0,
                      ),
                      child: Text(selectedDate,
                          style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ))),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    reloadData(periodFilterType);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    margin: const EdgeInsets.all(0),
                    height: 36,
                    decoration: BoxDecoration(
                      color: R.color.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: R.color.color0xffE5E5E5,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.restore,
                        size: 20,
                        color: R.color.textDark,
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 16),
                InkWell(
                  onTap: () {
                    _goPreviousNode();
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: R.color.color0xffE5E5E5,
                        width: 1,
                      ),
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      size: 20,
                      color: _focusIndex > 0
                          ? R.color.textDark
                          : R.color.color0xffE5E5E5,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      selectedType,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: selectedColor.isNotEmpty
                            ? Color(int.parse(
                                '0xff${selectedColor.split('#').join()}'))
                            : null,
                        height: 36 / 24,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    _goNextNode(trends.length);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: R.color.color0xffE5E5E5,
                        width: 1,
                      ),
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: _focusIndex < trends.length - 1
                          ? R.color.textDark
                          : R.color.color0xffE5E5E5,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$selectedDuration $selectedUnit',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: R.color.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 88,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildChart(padding: 16 * 2, target: target),
          ),
        ),
      ],
    );
  }

  Widget _sectionTrendingMany(
    int? fromDateInt,
    int? toDateInt,
    String? mostAppearType,
    String? mostAppearTypeColor,
    String? unit,
  ) {
    double highestDuration = 0;
    double lowestDuration = -1;

    String fromDate = '';
    String toDate = '';
    if (fromDateInt != null) {
      fromDate = DateFormat('dd/MM/yyyy').format(
        DateTime.fromMillisecondsSinceEpoch(fromDateInt * 1000, isUtc: true),
      );
    }
    if (toDateInt != null) {
      toDate = DateFormat('dd/MM/yyyy').format(
        DateTime.fromMillisecondsSinceEpoch(toDateInt * 1000, isUtc: true),
      );
    } else {
      toDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    }

    for (int i = 0; i < trends.length; i++) {
      if (trends[i].duration != null && trends[i].duration! > highestDuration) {
        highestDuration = trends[i].duration!;
      }
      if (lowestDuration == -1 ||
          (trends[i].duration != null &&
              trends[i].duration! < lowestDuration)) {
        lowestDuration = trends[i].duration!;
      }
    }

    final selectedUnit = 'unit'; // Replace with actual unit logic

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              // '01/01/2024 - 31/01/2024',
              '$fromDate - $toDate',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: R.color.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              mostAppearType ?? '--',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: mostAppearTypeColor?.isNotEmpty == true
                    ? Color(int.parse(
                        '0xff${mostAppearTypeColor!.split('#').join()}'))
                    : null,
                height: 36 / 24,
              ),
            ),
            Text(
              '${roundNumber(lowestDuration)} - ${roundNumber(highestDuration)} $selectedUnit',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: R.color.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 88,
          child: _buildChart(),
        ),
      ],
    );
  }

  Widget _buildChart({double padding = 0, double? target = 0}) {
    double minY = trends.map<double>((e) => e.duration ?? 0).reduce(min);
    minY = (minY * (trends.length == 1 ? 0.53 : 0.8)).roundToDouble();
    double maxY = trends.map<double>((e) => e.duration ?? 0).reduce(max);
    maxY = (maxY * (trends.length == 1 ? 1.5 : 1.2)).roundToDouble();

    double avgY = (maxY + minY) / 2;

    // const leftReservedSize = 70.0;
    // khoản cách giữa 2 điểm
    const double pointSpacing = 100.0;
    // chiều rộng = min of [screen width, pointSpacing * trends.length]
    double screenWidth = MediaQuery.of(context).size.width - padding * 2;
    // chiều rộng của biểu đồ tối đa là screen width
    double chartWidth = max(screenWidth, pointSpacing * trends.length);

    return Stack(
      alignment: Alignment.center,
      children: [
        SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Container(
                width: chartWidth,
                height: 140,
                padding: EdgeInsets.only(top: 8, bottom: 8),
                alignment: Alignment.center,
                child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: trends.length.toDouble() - 1,
                      maxY: maxY,
                      minY: minY,
                      lineBarsData: _linesBarData(trends),
                      titlesData: FlTitlesData(
                        show: false,
                        // leftTitles: SideTitles(
                        //     checkToShowTitle: (minValue, maxValue, sideTitles,
                        //             appliedInterval, value) =>
                        //         false,
                        //     showTitles: true,
                        //     reservedSize: leftReservedSize),
                        bottomTitles: SideTitles(showTitles: false),
                        topTitles: SideTitles(showTitles: false),
                        // rightTitles: SideTitles(
                        //     checkToShowTitle: (minValue, maxValue, sideTitles,
                        //             appliedInterval, value) =>
                        //         false,
                        //     showTitles: true,
                        //     reservedSize: leftReservedSize),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      // extraLinesData:
                      //     ExtraLinesData(extraLinesOnTop: true, horizontalLines: [
                      //   HorizontalLine(
                      //     label: HorizontalLineLabel(
                      //       show: true,
                      //       style: TextStyle(
                      //           color: R.color.textDark,
                      //           fontSize: 14,
                      //           fontWeight: FontWeight.w400),
                      //       alignment: Alignment.centerLeft,
                      //       padding: EdgeInsets.only(left: -leftReservedSize),
                      //       labelResolver: (value) {
                      //         return '${value.y.toInt()} ${R.string.minute.tr()}';
                      //       },
                      //     ),
                      //     // Adjusted to align with the chart's data range
                      //     y: target ?? 0,
                      //     color: R.color.color0xffDFE4E4,
                      //     strokeWidth: 1,
                      //     dashArray: [8, 2],
                      //   ),
                      // ]),
                      lineTouchData: LineTouchData(
                        getTouchLineStart: (barData, index) => -double.infinity,
                        getTouchLineEnd: (barData, index) => double.infinity,
                        getTouchedSpotIndicator:
                            (LineChartBarData barData, List<int> spotIndexes) {
                          return spotIndexes.map((index) {
                            return TouchedSpotIndicatorData(
                              FlLine(
                                  color: toColor(trends[index].targetColor),
                                  strokeWidth: 0.5),
                              FlDotData(
                                show: true,
                                getDotPainter:
                                    (spot, percent, barData, index) =>
                                        FlDotCirclePainter(
                                  radius: 6.5,
                                  color: toColor(trends[index].targetColor),
                                  strokeWidth: 18,
                                  strokeColor:
                                      toColor(trends[index].targetColor)
                                          .withOpacity(0.3),
                                ),
                              ),
                            );
                          }).toList();
                        },
                        touchTooltipData: LineTouchTooltipData(
                          showOnTopOfTheChartBoxArea: true,
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          tooltipBgColor: R.color.transparent,
                          tooltipRoundedRadius: 8,
                          getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                            return lineBarsSpot.map((lineBarSpot) {
                              return LineTooltipItem(
                                roundNumber(lineBarSpot.y),
                                TextStyle(
                                    color: toColor(trends[lineBarSpot.spotIndex]
                                        .targetColor),
                                    fontWeight: FontWeight.bold),
                              );
                            }).toList();
                          },
                          tooltipPadding: EdgeInsets.only(bottom: 50),
                        ),
                        touchCallback:
                            (FlTouchEvent event, LineTouchResponse? lineTouch) {
                          if (event is FlTapUpEvent) {
                            _touchCallback(event, lineTouch);
                          }
                        },
                      ),
                    ),
                    swapAnimationDuration: Duration(milliseconds: 250)))),
        // Dòng kẻ ngang để chỉ ra giá trị mục tiêu
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('${target?.toInt()} ${R.string.minute.tr()}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                )),
            const SizedBox(width: 8), // Khoảng cách giữa nhãn và dòng kẻ
            Expanded(
              child: DashLine(
                color: R.color.primaryGreyColor,
                dashWidth: 8.0,
                dashSpace: 4.0,
                height: 1.0,
              ),
            ),
          ],
        )
      ],
    );
  }

  void _touchCallback(FlTapUpEvent event, LineTouchResponse? lineTouch) {
    final now = DateTime.now();
    // detect double press
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 300)) {
      // Double press detected
      if (lineTouch?.lineBarSpots != null &&
          lineTouch!.lineBarSpots!.isNotEmpty) {
        final touchedSpot = lineTouch.lineBarSpots!.first;
        print('Double press on spot: ${touchedSpot.x}, ${touchedSpot.y}');
        // Thực hiện hành động khi double press
        if (touchedSpot.spotIndex == _focusIndex) {
          Navigator.of(context, rootNavigator: true)
              .pushNamed(NavigatorName.exercrise_step_detail_v2, arguments: {
            'type': 'input',
            'periodFilterType': periodFilterType,
          });
        }
      }
    } else {
      // Single press detected
      if (lineTouch?.lineBarSpots != null &&
          lineTouch!.lineBarSpots!.isNotEmpty) {
        final touchedSpot = lineTouch.lineBarSpots!.first;
        print('Single press on spot: ${touchedSpot.x}, ${touchedSpot.y}');
        // Thực hiện hành động khi single press
        if (touchedSpot.spotIndex != _focusIndex) {
          setState(() {
            _focusIndex = touchedSpot.spotIndex;
          });
          _scrollToSelectd();
        }
      }
    }
    _lastTapTime = now;
  }

  void _scrollToSelectd() {
    if (_focusIndex != -1 && trends.isNotEmpty) {
      // Lấy chiều rộng của biểu đồ
      final chartWidth = _scrollController.position.maxScrollExtent +
          _scrollController.position.viewportDimension;

      // Tính khoảng cách giữa các điểm
      final pointSpacing = chartWidth / trends.length;

      // Tính vị trí cuộn
      final scrollPosition = _focusIndex * pointSpacing - (pointSpacing / 2);

      // Cuộn đến vị trí
      _scrollController.animateTo(
        scrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goNextNode(int length) {
    if (_focusIndex < length - 1) {
      setState(() {
        _focusIndex = min(length - 1, _focusIndex + 1);
      });
    }
    _scrollToSelectd();
  }

  void _goPreviousNode() {
    if (_focusIndex > 0) {
      setState(() {
        _focusIndex = max(0, _focusIndex - 1);
      });
    }
    _scrollToSelectd();
  }

  void reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    setState(() {
      _focusIndex = -1;
    });
    BlocProvider.of<ExercrisesBloc>(currentContext).add(FetchTimeTrend(
        currentDateTime:
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        periodFilterType: periodFilterType.toString()));
  }

  List<LineChartBarData> _linesBarData(List<SubTrendItemModel> trends) {
    if (trends.length == 0) return [];
    if (trends.length < _breakingTypeNumber) {
      // can change focus
      return [
        LineChartBarData(
          spots: List.generate(trends.length, (index) {
            return FlSpot((index).toDouble(), trends[index].duration!);
          }),
          isCurved: false,
          colors: [Color(0xFF008479)],
          barWidth: 1.5,
          isStrokeCapRound: false,
          dotData: FlDotData(
            show: true,
            checkToShowDot: (spot, barData) => true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3,
                color: toColor(trends[index].targetColor),
                strokeWidth: index == _focusIndex ? 6 : 0,
                strokeColor: index == _focusIndex
                    ? toColor(trends[index].targetColor).withOpacity(0.3)
                    : null,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            colors: [
              R.color.greenGradientMid.withOpacity(0.2),
              R.color.greenGradientMid.withOpacity(0.0),
            ],
            gradientColorStops: const [0.5, 1.0],
            gradientFrom: const Offset(0.5, 0),
            gradientTo: const Offset(0.5, 1),
          ),
        ),
      ];
    }
    return [
      LineChartBarData(
        spots: List.generate(trends.length, (index) {
          return FlSpot((index).toDouble(), trends[index].duration!);
        }),
        isCurved: true,
        colors: [Color(0xFF008479)],
        barWidth: 1.5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          checkToShowDot: (spot, barData) =>
              spot.x == minXIndex || spot.x == maxXIndex,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 3,
              color: index == maxXIndex ? Color(0xFFC82221) : Color(0xFFF9C239),
              strokeWidth: 6,
              strokeColor: index == maxXIndex
                  ? Color(0xFFC82221).withOpacity(0.3)
                  : Color(0xFFF9C239).withOpacity(0.3),
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          colors: [
            Color(0xFFE7FDFB),
            Color(0xFFFFFFFF),
          ],
          gradientFrom: Offset(0.5, 0),
          gradientTo: Offset(0.5, 1.2),
        ),
      ),
    ];
  }
}
