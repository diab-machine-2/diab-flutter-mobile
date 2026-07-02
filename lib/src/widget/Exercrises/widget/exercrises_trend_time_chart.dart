import 'dart:async';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/exercrises/exercrises_bloc.dart';
import 'package:medical/src/modal/exercrises/exercrise_trend_time.dart';
import 'package:medical/src/utils/debouncer.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Exercrises/widget/exercrises_ai_suggestion.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/app_setting/app_setting.dart';
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

  int? _selectedDateTimestamp; // lưu timestamp của dot được chọn

  bool _isChartReady = false;

  bool _shouldAutoScroll = true; // ✅ Mặc định scroll 1 lần khi có data mới

  void _scrollToSelectd({bool animated = true, int retry = 0}) {
    if (!_shouldAutoScroll || !mounted) return;

    // Chỉ thử lại tối đa 20 lần
    if (retry > 20) {
      _shouldAutoScroll = false;
      return;
    }

    final bool shouldScroll = trends.length >= 11;
    const double maxSpacing = 60.0;
    const double minSpacing = 25.0;
    final screenWidth = MediaQuery.of(context).size.width - 32; // padding 16*2
    double pointSpacing = shouldScroll
        ? max(minSpacing, maxSpacing - (trends.length - 11) * 2.5)
        : screenWidth / max(1, (trends.length - 1));

    if (_scrollController.hasClients &&
        _scrollController.position.hasContentDimensions &&
        _focusIndex >= 0 &&
        _focusIndex < trends.length) {
      _shouldAutoScroll = false; // ✅ Chỉ tắt khi scroll thành công
      final double scrollPosition = (_focusIndex * pointSpacing) - 100;

      if (animated) {
        _scrollController.animateTo(
          scrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController.jumpTo(
          scrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
        );
      }
    } else {
      // Nếu chưa sẵn sàng, thử lại sau 50ms
      Future.delayed(const Duration(milliseconds: 50), () {
        _scrollToSelectd(animated: animated, retry: retry + 1);
      });
    }
  }

  void _updateFocusIndexWithFallback(List<SubTrendItemModel> newTrends) {
    trends = newTrends;

    if (trends.isEmpty) {
      _focusIndex = -1;
      return;
    }

    int? matchedIndex;
    if (_selectedDateTimestamp != null) {
      matchedIndex =
          trends.indexWhere((item) => item.date == _selectedDateTimestamp);
      if (matchedIndex == -1) {
        // Nếu không tìm thấy, chọn dot mới nhất
        matchedIndex = trends.length - 1;
        _selectedDateTimestamp = trends.last.date;
      }
    } else {
      matchedIndex = trends.length - 1;
      _selectedDateTimestamp = trends.last.date;
    }

    _focusIndex = matchedIndex!;
    if (mounted) {
      setState(() {
        _shouldAutoScroll = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<ExercrisesBloc>.value(
      value: _bloc,
      child: BlocBuilder<ExercrisesBloc, ExercrisesState>(
        builder: (BuildContext context, ExercrisesState state) {
          if (!mounted) return const SizedBox.shrink();
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
          if (state is TimeTrendTrendLoaded && mounted) {
            // Only process if mounted
            model = state.model;
            final newTrends = model.trendItems.items
                .where((item) => item.duration != null && item.duration! > 0)
                .toList();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _updateFocusIndexWithFallback(
                    newTrends); // ✅ safe để gọi setState
              }
            });
          }

          if (model == null) {
            return Container(
                height: 450, child: Center(child: CircularProgressIndicator()));
          }

          if (trends.isEmpty) {
            return Container(
              height: 100,
              child: Center(child: Text(R.string.no_data_available.tr())),
            );
          }

          if (trends.isNotEmpty && _focusIndex == -1) {
            _focusIndex = (trends.length - 1) ~/ 2;
            // Gọi _scrollToSelectd sau khi focus index được thiết lập
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToSelectd();
            });
          }

          final selectedTrend = trends[_focusIndex];

          return VisibilityDetector(
            key: Key('exercrises-trend-time-chart'),
            onVisibilityChanged: (visibilityInfo) {
              var visiblePercentage = visibilityInfo.visibleFraction * 100;
              if (visiblePercentage == 0) {
                previousDate = 0;
              } else if (visiblePercentage > 0 && mounted) {
                // Khi tab quay lại, scroll tới dot đang chọn
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _scrollToSelectd();
                  }
                });
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
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _sectionTrending(model, '', ''),
                  const SizedBox(height: 16),
                  ExercrisesAISuggestion(
                    periodFilterType: periodFilterType,
                    date: selectedTrend.date != null
                        ? DateTime.fromMillisecondsSinceEpoch(
                            selectedTrend.date! * 1000)
                        : DateTime.now(),
                    titleButton: R.string.chat_with_AI.tr(),
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

    return _sectionTrendingLess(model.targetUnit, AppSettings.targetDuration);
    // if (totalItems < _breakingTypeNumber) {
    //   return _sectionTrendingLess(model.targetUnit, AppSettings.targetDuration);
    // } else {
    //   return _sectionTrendingMany(
    //       DateTime.now().microsecondsSinceEpoch,
    //       DateTime.now().microsecondsSinceEpoch,
    //       mostAppearType,
    //       mostAppearTypeColor,
    //       model.targetUnit);
    // }
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
      // if (selectedTrend.firstDateOfWeek != null &&
      //     selectedTrend.lastDateOfWeek != null) {
      //   selectedDate =
      //       convertToUTC(selectedTrend.firstDateOfWeek!, 'dd' + '-') +
      //           convertToUTC(selectedTrend.lastDateOfWeek!, 'dd/MM');
      // } else {
      //  selectedDate = convertToSectionTicketDate(selectedTrend.date!, '');
      // }
      selectedDate = convertToSectionTicketDate(selectedTrend.date!, '');
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
                  onPressed: null,
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
                    Navigator.of(context, rootNavigator: true).pushNamed(
                        NavigatorName.exercrise_step_detail_v2,
                        arguments: {
                          'type': 'input',
                          'periodFilterType': periodFilterType,
                        });
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
            child: _buildChart(padding: 16 * 2, target: target ?? 0),
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

  Widget _buildChart({double padding = 0, double target = 0}) {
    const double chartPaddingTop = 8.0;
    const double chartPaddingBottom = 8.0;
    const double chartFixedHeight = 140.0;

    final screenWidth = MediaQuery.of(context).size.width - padding * 2;

    final bool shouldScroll = trends.length >= 11;

    const double maxSpacing = 60.0;
    const double minSpacing = 25.0;

    double pointSpacing = shouldScroll
        ? max(minSpacing, maxSpacing - (trends.length - 11) * 2.5)
        : screenWidth / max(1, (trends.length - 1));

    double chartWidth =
        shouldScroll ? pointSpacing * (trends.length - 1) : screenWidth;

    double minX = trends.length == 1 ? -1 : 0;
    double maxX = trends.length == 1 ? 1 : trends.length.toDouble() - 1;

    final spots = trends.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.duration?.toDouble() ?? 0);
    }).toList();

    /// Tính range để target nằm giữa
    double getSymmetricRange(List<FlSpot> spots, double target) {
      final dataYs = spots.map((e) => e.y).toList();
      final diffs = dataYs.map((y) => (y - target).abs());
      final maxDiff = diffs.isNotEmpty ? diffs.reduce(max) : 5;
      return maxDiff + 5; // cộng thêm margin
    }

    final range = getSymmetricRange(spots, target);
    final double minY = target - range;
    final double maxY = target + range;

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartHeight = constraints.maxHeight - chartPaddingTop;
        final usableHeight = chartHeight - chartPaddingBottom;
        final targetPixel = chartPaddingTop + usableHeight / 2;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isChartReady && mounted) {
            setState(() {
              _isChartReady = true;
            });

            // ✅ Nếu có focus index hợp lệ thì scroll luôn
            if (_focusIndex >= 0 &&
                _focusIndex < trends.length &&
                _shouldAutoScroll) {
              _scrollToSelectd();
            }
          }
        });

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 55,
              height: constraints.maxHeight,
              child: Stack(
                children: [
                  Positioned(
                    top: targetPixel - 8,
                    left: 0,
                    right: 0,
                    child: Text(
                      '${target.toInt()} ${R.string.minute.tr()}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: shouldScroll
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      child: Container(
                        width: chartWidth,
                        height: chartFixedHeight,
                        padding: const EdgeInsets.only(
                          top: chartPaddingTop,
                          left: 8,
                          right: 8,
                          bottom: chartPaddingBottom,
                        ),
                        alignment: Alignment.center,
                        child: _buildLineChart(minX, maxX, minY, maxY, target),
                      ),
                    )
                  : Container(
                      width: chartWidth,
                      height: chartFixedHeight,
                      padding: const EdgeInsets.only(
                        top: chartPaddingTop,
                        left: 8,
                        right: 8,
                        bottom: chartPaddingBottom,
                      ),
                      alignment: Alignment.center,
                      child: _buildLineChart(minX, maxX, minY, maxY, target),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLineChart(
    double minX,
    double maxX,
    double minY,
    double maxY,
    double target,
  ) {
    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        lineBarsData: _linesBarData(trends),
        titlesData: FlTitlesData(show: false),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        extraLinesData: ExtraLinesData(
          extraLinesOnTop: true,
          horizontalLines: [
            HorizontalLine(
              y: target,
              color: R.color.textDark.withOpacity(0.3),
              strokeWidth: 1,
              dashArray: [8, 4],
            ),
          ],
        ),
        lineTouchData: LineTouchData(
          getTouchLineStart: (barData, index) => -double.infinity,
          getTouchLineEnd: (barData, index) => double.infinity,
          getTouchedSpotIndicator: (barData, indexes) => indexes.map((index) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: toColor(trends[index].targetColor),
                strokeWidth: 0.5,
              ),
              FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 6.5,
                  color: toColor(trends[index].targetColor),
                  strokeWidth: 18,
                  strokeColor:
                      toColor(trends[index].targetColor).withOpacity(0.3),
                ),
              ),
            );
          }).toList(),
          touchTooltipData: LineTouchTooltipData(
            showOnTopOfTheChartBoxArea: false,
            fitInsideHorizontally: true,
            fitInsideVertically: false,
            getTooltipColor: (LineBarSpot touchedSpot) => R.color.transparent,
            tooltipRoundedRadius: 8,
            tooltipMargin: 18,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 4),
            getTooltipItems: (lineBarsSpot) {
              return lineBarsSpot.map((spot) {
                return LineTooltipItem(
                  roundNumber(spot.y),
                  TextStyle(
                    color: toColor(trends[spot.spotIndex].targetColor),
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
          touchCallback: (event, response) {
            if (event is FlTapUpEvent) {
              _touchCallback(event, response);
            }
          },
        ),
      ),
      duration: const Duration(milliseconds: 250),
    );
  }

  void _touchCallback(
    FlTapUpEvent event,
    LineTouchResponse? lineTouch,
  ) {
    final now = DateTime.now();
    // detect double press
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 300)) {
      // Double press detected
      if (lineTouch?.lineBarSpots != null &&
          lineTouch!.lineBarSpots!.isNotEmpty) {
        final touchedSpot = lineTouch.lineBarSpots!.first;
        final date = trends[lineTouch.lineBarSpots!.first.spotIndex].date !=
                null
            ? DateTime.fromMillisecondsSinceEpoch(
                trends[lineTouch.lineBarSpots!.first.spotIndex].date! * 1000)
            : DateTime.now();
        // Thực hiện hành động khi double press
        if (touchedSpot.spotIndex == _focusIndex) {
          Navigator.of(context, rootNavigator: true)
              .pushNamed(NavigatorName.exercrise_result, arguments: {
            'date': date,
            'periodFilterType': 1,
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
          if (!mounted) return;
          setState(() {
            _focusIndex = touchedSpot.spotIndex;
            _selectedDateTimestamp = trends[_focusIndex].date;
            _shouldAutoScroll = true; // ✅ Cho phép scroll đúng dot sau khi tap
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToSelectd();
          });
        }
      }
    }
    _lastTapTime = now;
  }

  void _goNextNode(int length) {
    if (_focusIndex < length - 1) {
      setState(() {
        _focusIndex = min(length - 1, _focusIndex + 1);
        _selectedDateTimestamp = trends[_focusIndex].date;
      });
    }
    _scrollToSelectd();
  }

  void _goPreviousNode() {
    if (_focusIndex > 0) {
      setState(() {
        _focusIndex = max(0, _focusIndex - 1);
        _selectedDateTimestamp = trends[_focusIndex].date;
      });
    }
    _scrollToSelectd();
  }

  void reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    BlocProvider.of<ExercrisesBloc>(currentContext).add(FetchTimeTrend(
      currentDateTime:
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      periodFilterType: periodFilterType.toString(),
    ));
  }

  List<LineChartBarData> _linesBarData(List<SubTrendItemModel> trends) {
    if (trends.length == 0) return [];
    return [
      LineChartBarData(
        spots: List.generate(trends.length, (index) {
          return FlSpot((index).toDouble(), trends[index].duration!);
        }),
        isCurved: false,
        color: Color(0xFF008479),
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
                  : Colors.transparent,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              R.color.greenGradientMid.withOpacity(0.2),
              R.color.greenGradientMid.withOpacity(0.0),
            ],
            stops: const [0.5, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    ];
    // if (trends.length < _breakingTypeNumber) {
    //   // can change focus
    //   return [
    //     LineChartBarData(
    //       spots: List.generate(trends.length, (index) {
    //         return FlSpot((index).toDouble(), trends[index].duration!);
    //       }),
    //       isCurved: false,
    //       colors: [Color(0xFF008479)],
    //       barWidth: 1.5,
    //       isStrokeCapRound: false,
    //       dotData: FlDotData(
    //         show: true,
    //         checkToShowDot: (spot, barData) => true,
    //         getDotPainter: (spot, percent, barData, index) {
    //           return FlDotCirclePainter(
    //             radius: 3,
    //             color: toColor(trends[index].targetColor),
    //             strokeWidth: index == _focusIndex ? 6 : 0,
    //             strokeColor: index == _focusIndex
    //                 ? toColor(trends[index].targetColor).withOpacity(0.3)
    //                 : null,
    //           );
    //         },
    //       ),
    //       belowBarData: BarAreaData(
    //         show: true,
    //         colors: [
    //           R.color.greenGradientMid.withOpacity(0.2),
    //           R.color.greenGradientMid.withOpacity(0.0),
    //         ],
    //         gradientColorStops: const [0.5, 1.0],
    //         gradientFrom: const Offset(0.5, 0),
    //         gradientTo: const Offset(0.5, 1),
    //       ),
    //     ),
    //   ];
    // }
    // return [
    //   LineChartBarData(
    //     spots: List.generate(trends.length, (index) {
    //       return FlSpot((index).toDouble(), trends[index].duration!);
    //     }),
    //     isCurved: true,
    //     colors: [Color(0xFF008479)],
    //     barWidth: 1.5,
    //     isStrokeCapRound: true,
    //     dotData: FlDotData(
    //       show: true,
    //       checkToShowDot: (spot, barData) =>
    //           spot.x == minXIndex || spot.x == maxXIndex,
    //       getDotPainter: (spot, percent, barData, index) {
    //         return FlDotCirclePainter(
    //           radius: 3,
    //           color: index == maxXIndex ? Color(0xFFC82221) : Color(0xFFF9C239),
    //           strokeWidth: 6,
    //           strokeColor: index == maxXIndex
    //               ? Color(0xFFC82221).withOpacity(0.3)
    //               : Color(0xFFF9C239).withOpacity(0.3),
    //         );
    //       },
    //     ),
    //     belowBarData: BarAreaData(
    //       show: true,
    //       colors: [
    //         Color(0xFFE7FDFB),
    //         Color(0xFFFFFFFF),
    //       ],
    //       gradientFrom: Offset(0.5, 0),
    //       gradientTo: Offset(0.5, 1.2),
    //     ),
    //   ),
    // ];
  }
}

