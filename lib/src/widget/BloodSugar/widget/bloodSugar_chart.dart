import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/bloc/glucose/glucose_bloc.dart';
import 'package:medical/src/modal/glucose/glucose_data_trend.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodSugar/bloodSugar_detail_tabbar.dart';
import 'package:medical/src/widget/BloodSugar/constant/bloodSugar_rangetype.dart';
import 'package:medical/src/widget/BloodSugar/widget/action_list_filter_trend.dart';
import 'package:medical/src/widget/Exercrises/widget/dash_line_horizontal.dart';
import 'package:medical/src/widget/HbA1C/hba1c_tabble.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/modal/glucose/glucose_trend.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:medical/src/utils/debouncer.dart';

import 'ai_loading_text_widget.dart';
import 'aihelp_butotn.dart';

typedef BloodSugarChartCallback = void Function(
    BloodSugarRangeType? rangeType, String? aiSuggestion);

class BloodSugarChart extends StatefulWidget {
  BloodSugarChart({
    Key? key,
    required this.periodFilterType,
    required this.onFilterChanged,
    required this.onViewListing,
    required this.filterName,
    this.bloodSugarChartCallback,
  }) : super(key: key);

  final int periodFilterType;
  final Function(int selectedIndex) onFilterChanged;
  final Function() onViewListing;
  final String filterName;
  final BloodSugarChartCallback? bloodSugarChartCallback;

  @override
  BloodSugarChartState createState() => BloodSugarChartState();
}

class BloodSugarChartState extends State<BloodSugarChart>
    with AutomaticKeepAliveClientMixin<BloodSugarChart> {
  @override
  bool get wantKeepAlive => true;

  final _bloc = GlucoseBloc();

  StreamSubscription? _subscription;

  late BuildContext currentContext;
  int value = 0;
  int touchIndex = -1;
  String? trendType = R.string.all.tr();
  int trendTypeIndex = 1;
  int periodFilterType = 3;
  int? previousDate = 0;

  int minXIndex = 0;
  int maxXIndex = 0;

  final int _breakingTypeNumber = 12;

  // less than [_breakingTypeNumber] focus
  int _focusIndex = -1;

  DateTime? _lastTapTime;

  List<TrendModel> trends = [];
  List<TrendModel> _previousTrends = [];

  int? _selectedDateTimestamp; // lưu timestamp của dot được chọn
  String? _selectedId; // id của dot được chọn để phân biệt khi trùng timestamp

  bool _isChartReady = false;

  bool _shouldAutoScroll = true; // Mặc định scroll 1 lần khi có data mới

  final ScrollController _scrollController = ScrollController();

  void _scrollToSelected({bool animated = true, int retry = 0}) {
    if (!_shouldAutoScroll || !mounted) return;

    // Chỉ thử lại tối đa 20 lần
    if (retry > 20) {
      _shouldAutoScroll = false;
      return;
    }

    final bool shouldScroll = trends.length >= _breakingTypeNumber;
    const double maxSpacing = 60.0;
    const double minSpacing = 25.0;
    final screenWidth = MediaQuery.of(context).size.width - 32; // padding 16*2
    double pointSpacing = shouldScroll
        ? max(minSpacing,
            maxSpacing - (trends.length - _breakingTypeNumber) * 2.5)
        : screenWidth / max(1, (trends.length - 1));

    if (_scrollController.hasClients &&
        _scrollController.position.hasContentDimensions &&
        _focusIndex >= 0 &&
        _focusIndex < trends.length) {
      _shouldAutoScroll = false; // Chỉ tắt khi scroll thành công
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
        _scrollToSelected(animated: animated, retry: retry + 1);
      });
    }
  }

  void _updateFocusIndexWithFallback(List<TrendModel> newTrends) {
    // Store old timestamps for comparison
    final oldTimestamps = _previousTrends.map((e) => e.date).toSet();
    trends = newTrends;

    if (trends.isEmpty) {
      _focusIndex = -1;
      _selectedDateTimestamp = null;
      _previousTrends = [];
      return;
    }

    int? matchedIndex;
    // Check for new data by comparing timestamps
    final newData =
        trends.where((item) => !oldTimestamps.contains(item.date)).toList();

    if (newData.isNotEmpty) {
      // If new data exists, select the most recent new data point based on timestamp
      final latestNewData = newData.reduce((a, b) => a.date! > b.date! ? a : b);
      matchedIndex =
          trends.indexWhere((item) => item.date == latestNewData.date);
      _selectedDateTimestamp = latestNewData.date;
      _selectedId = trends[matchedIndex].id;
    } else if (_selectedId != null) {
      // First priority: keep exact same id if possible
      matchedIndex = trends.indexWhere((item) => item.id == _selectedId);
      if (matchedIndex == -1 && _selectedDateTimestamp != null) {
        // Fall back to timestamp but try to pick the closest index to previous focus
        final duplicateIndexes = <int>[];
        for (int i = 0; i < trends.length; i++) {
          if (trends[i].date == _selectedDateTimestamp) duplicateIndexes.add(i);
        }
        if (duplicateIndexes.isNotEmpty) {
          matchedIndex = duplicateIndexes.reduce((a, b) =>
              (a - _focusIndex).abs() <= (b - _focusIndex).abs() ? a : b);
        }
      }
      if (matchedIndex == -1) {
        // As a last resort, select latest
        matchedIndex = trends.length - 1;
      }
    } else if (_selectedDateTimestamp != null) {
      // If no new data but a previous selection exists, try to maintain it
      // If there are duplicates with same timestamp, prefer the index closest to previous focus
      final duplicateIndexes = <int>[];
      for (int i = 0; i < trends.length; i++) {
        if (trends[i].date == _selectedDateTimestamp) duplicateIndexes.add(i);
      }
      if (duplicateIndexes.isNotEmpty) {
        matchedIndex = duplicateIndexes.reduce((a, b) =>
            (a - _focusIndex).abs() <= (b - _focusIndex).abs() ? a : b);
      } else {
        // If previous selection is not found, select the latest data point
        matchedIndex = trends.length - 1;
        _selectedDateTimestamp = trends.last.date;
      }
    } else {
      // No new data and no previous selection, default to the latest data point
      matchedIndex = trends.length - 1;
      _selectedDateTimestamp = trends.last.date;
    }

    _focusIndex = matchedIndex;
    _selectedId = trends[_focusIndex].id;
    _previousTrends =
        List.from(trends); // Update previous trends for next comparison
    if (mounted) {
      setState(() {
        _shouldAutoScroll = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    periodFilterType =
        BloodSugarDetailTabbarController.of(context)?.periodFilterType ??
            widget.periodFilterType;
    _subscription?.cancel();
    _subscription = _bloc.stream.listen((state) async {
      if (state is GlucoseTrendLoaded) {
        _subscription?.cancel();
        _subscription = null;

        // Navigate to input if no data
        // List<TrendModel> trends = [];
        state.trend.trendItems.items.forEach((item) {
          trends.addAll(item.subTrends);
        });
        // if (trends.isEmpty) {
        //   await Future.delayed(Duration(milliseconds: 500));
        //   Navigator.pushReplacementNamed(
        //       context, NavigatorName.add_blood_sugar_new,
        //       arguments: {'type': 'input'});
        // }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<GlucoseBloc>.value(
      value: _bloc,
      child: BlocBuilder<GlucoseBloc, GlucoseState>(
        builder: (BuildContext context, GlucoseState state) {
          currentContext = context;
          TrendDataModel? model;

          if (state is GlucoseInitial) {
            BlocProvider.of<GlucoseBloc>(context).add(FetchTrendGlucose(
                trendType: trendTypeIndex.toString(),
                currentDateTime:
                    (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
                periodFilterType: periodFilterType.toString(),
                page: '1'));
          }
          if (state is GlucoseError) {
            Message.showToastMessage(context, state.message);
          }
          String? aiSuggestion;
          String? mostAppearType;
          String? mostAppearTypeColor;
          BloodSugarRangeType? rangeType;
          if (state is GlucoseTrendLoaded) {
            model = state.trend;
            aiSuggestion = state.glucoseInputAIAnalysis;
            mostAppearType = state.mostAppearType;
            mostAppearTypeColor = state.mostAppearTypeColor;
            rangeType = state.rangeType;

            // Call the callback to pass data back to parent
            if (widget.bloodSugarChartCallback != null) {
              Future.delayed(Duration(milliseconds: 100), () {
                widget.bloodSugarChartCallback!(rangeType, aiSuggestion);
              });
            }

            final newTrends = <TrendModel>[];
            state.trend.trendItems.items.forEach((item) {
              newTrends.addAll(item.subTrends);
            });

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _updateFocusIndexWithFallback(newTrends);
              }
            });
          }

          if (model == null)
            return Container(
                height: 450, child: Center(child: CircularProgressIndicator()));

          return VisibilityDetector(
            key: Key('blood_sugar_chart'),
            onVisibilityChanged: (visibilityInfo) {
              var visiblePercentage = visibilityInfo.visibleFraction * 100;
              if (visiblePercentage == 0) {
                previousDate = 0;
              } else if (visiblePercentage > 0 && mounted) {
                // Khi tab quay lại, scroll tới dot đang chọn
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _scrollToSelected();
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
                  const SizedBox(height: 16),
                  _sectionTrending(model, mostAppearType, mostAppearTypeColor),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTrending(TrendDataModel model, String? mostAppearType,
      String? mostAppearTypeColor) {
    if (model.trendItems.items.isEmpty) {
      return _buildEmptyState();
    }
    List<TrendModel> trends = [];
    model.trendItems.items.forEach((element) {
      trends.addAll(element.subTrends);
    });

    return _sectionTrendingLess(trends);
  }

  Widget _buildEmptyState() {
    // Define threshold based on unit
    double thresholdValue = AppSettings.userInfo!.glucoseUnit == 1 ? 180 : 10;
    String thresholdLabel =
        AppSettings.userInfo!.glucoseUnit == 1 ? '180' : '10';
    String selectedUnit =
        AppSettings.userInfo!.glucoseUnit == 1 ? 'mg/dL' : 'mmol/L';

    return Container(
      height: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            R.string.no_data_blood_sugar_trend_chart.tr(args: [getLabel()]),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: R.color.textDark,
            ),
          ),
          GapH(36),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '$thresholdLabel\n$selectedUnit',
                  style: TextStyle(
                    color: R.color.color0xffBFC6C6,
                    fontSize: 12,
                  ),
                ),
                GapW(8),
                Expanded(
                  child: CustomPaint(
                    size: Size(double.infinity, 1),
                    painter: DashLinePainter(
                      color: R.color.color0xffBFC6C6,
                      strokeWidth: 1,
                      dashWidth: 8,
                      dashSpace: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getLabel() {
    final labels = [
      R.string.filter_day.tr(args: ['7']),
      R.string.filter_day.tr(args: ['14']),
      R.string.filter_day.tr(args: ['30']),
      R.string.filter_day.tr(args: ['90']),
    ];

    int index = periodFilterType - 1;
    if (index >= 0 && index < labels.length) {
      return labels[index];
    }
    return labels[0]; // Default to first label if index is out of bounds
  }

  Widget _sectionTrendingLess(List<TrendModel> trends) {
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
    String selectedDateTime = '';
    String selectedType = '';
    String selectedTimeFrame = '';
    String selectedGlucose = '';
    String selectedColor = '';
    String selectedUnit = '';

    if (_focusIndex != -1 && _focusIndex < trends.length) {
      final selectedTrend = trends[_focusIndex];
      selectedDate = DateFormat('dd/MM').format(
          DateTime.fromMillisecondsSinceEpoch(selectedTrend.date! * 1000,
              isUtc: true));
      selectedDateTime = DateFormat('HH:mm').format(
          DateTime.fromMillisecondsSinceEpoch(selectedTrend.date! * 1000,
              isUtc: true));
      selectedType = selectedTrend.type!;
      selectedTimeFrame = selectedTrend.timeFrameName!;
      selectedGlucose = roundNumber(selectedTrend.glucose!);
      selectedColor = selectedTrend.color!;
      selectedUnit =
          AppSettings.userInfo!.glucoseUnit == 1 ? 'mg/dL' : 'mmol/L';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: R.color.white,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$selectedDateTime',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: R.color.textDark,
                        ),
                      ),
                      _dotWidget(),
                      Text(
                        '$selectedDate',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: R.color.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                    child: InkWell(
                      onTap: () {
                        final selectedTrend = trends[_focusIndex];
                        print(
                            'Blood sugar chart Tap on trends: ${selectedTrend.glucose}');
                        Navigator.pushNamed(
                            context, NavigatorName.add_blood_sugar_new,
                            arguments: {
                              'type': 'update',
                              'id': selectedTrend.id
                            });
                      },
                      child: Text(
                        selectedType,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: selectedColor.isNotEmpty
                              ? Color(int.parse(
                                  '0xff${selectedColor.split('#').join()}'))
                              : null,
                          height: 36 / 24,
                        ),
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
            InkWell(
              onTap: () {
                final selectedTrend = trends[_focusIndex];
                print(
                    'Blood sugar chart Tap on trends: ${selectedTrend.glucose} ');
                Navigator.pushNamed(context, NavigatorName.add_blood_sugar_new,
                    arguments: {'type': 'update', 'id': selectedTrend.id});
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$selectedTimeFrame',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: R.color.color0xff5E6566,
                    ),
                  ),
                  _dotWidget(),
                  Text(
                    '$selectedGlucose $selectedUnit',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: R.color.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 88,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildChart(trends, padding: 16 * 2),
          ),
        ),
      ],
    );
  }

  void _goNextNode(int length) {
    if (_focusIndex < length - 1) {
      setState(() {
        _focusIndex = min(length - 1, _focusIndex + 1);
        _selectedDateTimestamp = trends[_focusIndex].date;
        _selectedId = trends[_focusIndex].id;
        _shouldAutoScroll = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelected();
      });
    }
  }

  void _goPreviousNode() {
    if (_focusIndex > 0) {
      setState(() {
        _focusIndex = max(0, _focusIndex - 1);
        _selectedDateTimestamp = trends[_focusIndex].date;
        _selectedId = trends[_focusIndex].id;
        _shouldAutoScroll = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelected();
      });
    }
  }

  Widget _dotWidget() {
    return Container(
      width: 4,
      height: 4,
      margin: EdgeInsets.only(left: 4, right: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFBFC6C6),
      ),
    );
  }

  Widget _sectionAIHelp(String? aiSuggestion, BloodSugarRangeType? rangeType) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI result
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                R.string.ai_suggestion_glucose.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: R.color.textDark,
                  height: 21 / 15,
                ),
              ),
              const SizedBox(width: 6),
              Image.asset(R.drawable.ic_info, width: 18, height: 18),
              // InkWell(
              //   onTap: () {},
              //   child: Image.asset(R.drawable.ic_speak_text, width: 24, height: 24),
              // ),
            ],
          ),
          const SizedBox(height: 8),
          if (aiSuggestion == null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: const AILoadingTextWidget(),
            )
          else if (aiSuggestion.isEmpty)
            Text(
              'CÃ³ lá»—i xáº£y ra',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFFC82221),
              ),
            )
          else ...[
            Text(
              aiSuggestion,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: R.color.primaryGreyColor,
                height: 16 / 12,
              ),
            ),
            const SizedBox(height: 16),
            AIHelpButton(rangeType: rangeType),
          ],
        ],
      ),
    );
  }

  Widget _buildChart(List<TrendModel> trends, {double padding = 0}) {
    if (trends.isEmpty) {
      return SizedBox.shrink();
    }
    double minY = trends.map<double>((e) => e.glucose ?? 0).reduce(min);
    minY = (minY * (trends.length == 1 ? 0.5 : 0.8)).roundToDouble();
    double maxY = trends.map<double>((e) => e.glucose ?? 0).reduce(max);
    maxY = (maxY * (trends.length == 1 ? 1.5 : 1.2)).roundToDouble();

    // Define threshold based on unit
    double scaleYMaxLine = AppSettings.userInfo!.glucoseUnit == 1 ? 180 : 10;
    String thresholdLabel =
        AppSettings.userInfo!.glucoseUnit == 1 ? '180' : '10';
    String selectedUnit =
        AppSettings.userInfo!.glucoseUnit == 1 ? 'mg/dL' : 'mmol/L';

    // Adjust minY and maxY to ensure scaleYMaxLine is within the chart
    minY = max(0, min(minY, scaleYMaxLine - 10));
    maxY = max(maxY, scaleYMaxLine + 10);

    // find min and max index
    minXIndex = -1;
    maxXIndex = -1;
    for (int i = 0; i < trends.length; i++) {
      if (trends[i].glucose != null) {
        if (minXIndex == -1 ||
            trends[i].glucose! < trends[minXIndex].glucose!) {
          minXIndex = i;
        }
        if (maxXIndex == -1 ||
            trends[i].glucose! > trends[maxXIndex].glucose!) {
          maxXIndex = i;
        }
      }
    }

    const double chartPaddingTop = 8.0;
    const double chartPaddingBottom = 8.0;

    final screenWidth = MediaQuery.of(context).size.width - padding;

    final bool shouldScroll = trends.length >= _breakingTypeNumber;

    const double maxSpacing = 60.0;
    const double minSpacing = 25.0;

    double pointSpacing = shouldScroll
        ? max(minSpacing,
            maxSpacing - (trends.length - _breakingTypeNumber) * 2.5)
        : screenWidth / max(1, (trends.length - 1));

    double chartWidth =
        shouldScroll ? pointSpacing * (trends.length - 1) : screenWidth;

    double minX = trends.length == 1 ? -1 : 0;
    double maxX = trends.length == 1 ? 1 : trends.length.toDouble() - 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartHeight = constraints.maxHeight - chartPaddingTop;
        final usableHeight = chartHeight - chartPaddingBottom;
        final targetPixel = chartPaddingTop +
            (maxY - scaleYMaxLine) / (maxY - minY) * usableHeight;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isChartReady && mounted) {
            setState(() {
              _isChartReady = true;
            });

            // Nếu có focus index hợp lệ thì scroll luôn
            if (_focusIndex >= 0 &&
                _focusIndex < trends.length &&
                _shouldAutoScroll) {
              _scrollToSelected();
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
                      '$thresholdLabel\n$selectedUnit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: R.color.color0xff111515,
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
                        height: constraints.maxHeight,
                        padding: const EdgeInsets.only(
                          top: chartPaddingTop,
                          left: 8,
                          right: 8,
                          bottom: chartPaddingBottom,
                        ),
                        alignment: Alignment.center,
                        child: _buildLineChart(
                            trends, minX, maxX, minY, maxY, scaleYMaxLine),
                      ),
                    )
                  : Container(
                      width: chartWidth,
                      height: constraints.maxHeight,
                      padding: const EdgeInsets.only(
                        top: chartPaddingTop,
                        left: 8,
                        right: 8,
                        bottom: chartPaddingBottom,
                      ),
                      alignment: Alignment.center,
                      child: _buildLineChart(
                          trends, minX, maxX, minY, maxY, scaleYMaxLine),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLineChart(List<TrendModel> trends, double minX, double maxX,
      double minY, double maxY, double scaleYMaxLine) {
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
              y: scaleYMaxLine,
              color: R.color.color0xff636A6B,
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
                color: toColor(trends[index].color),
                strokeWidth: 0.5,
              ),
              FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 6.5,
                  color: toColor(trends[index].color),
                  strokeWidth: 18,
                  strokeColor: toColor(trends[index].color).withOpacity(0.3),
                ),
              ),
            );
          }).toList(),
          touchTooltipData: LineTouchTooltipData(
            showOnTopOfTheChartBoxArea: true,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipBgColor: R.color.transparent,
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.only(bottom: 50),
            getTooltipItems: (lineBarsSpot) {
              return lineBarsSpot.map((spot) {
                return LineTooltipItem(
                  roundNumber(spot.y),
                  TextStyle(
                    color: toColor(trends[spot.spotIndex].color),
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
          touchCallback: (event, response) {
            if (event is FlTapUpEvent) {
              _touchCallback(event, response, trends);
            }
          },
        ),
      ),
      swapAnimationDuration: const Duration(milliseconds: 250),
    );
  }

  void _touchCallback(
    FlTapUpEvent event,
    LineTouchResponse? lineTouch,
    List<TrendModel> trends,
  ) {
    final now = DateTime.now();

    // detect double press
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 300)) {
      // Double press detected
      if (lineTouch?.lineBarSpots != null &&
          lineTouch!.lineBarSpots!.isNotEmpty) {
        final touchedSpot = lineTouch.lineBarSpots!.first;
        final selectedTrend = trends[touchedSpot.spotIndex];

        // Thực hiện hành động khi double press
        if (touchedSpot.spotIndex == _focusIndex) {
          print(
              'Blood sugar chart Double tap on index: ${touchedSpot.spotIndex}');

          Navigator.pushNamed(context, NavigatorName.add_blood_sugar_new,
              arguments: {'type': 'update', 'id': selectedTrend.id});
        }
      }
    } else {
      // Single press detected
      previousDate = 0;
      if (lineTouch?.lineBarSpots?.length == 1) {
        final value = lineTouch?.lineBarSpots?[0].x;
        if (value != null) {
          touchIndex = value.toInt();
          if (touchIndex != _focusIndex) {
            if (!mounted) return;
            setState(() {
              _focusIndex = touchIndex;
              _selectedDateTimestamp = trends[_focusIndex].date;
              _selectedId = trends[_focusIndex].id;
              _shouldAutoScroll = true; // Cho phép scroll đúng dot sau khi tap
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToSelected();
            });
          }
        }
      } else {
        touchIndex = -1;
      }
    }
    _lastTapTime = now;
  }

  // Update the _linesBarData method to handle the baseline properly
  List<LineChartBarData> _linesBarData(List<TrendModel> trends) {
    if (trends.length == 0) return [];
    return [
      LineChartBarData(
        spots: List.generate(trends.length, (index) {
          return FlSpot((index).toDouble(), trends[index].glucose!);
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
              color: toColor(trends[index].color),
              strokeWidth: index == _focusIndex ? 6 : 0,
              strokeColor: index == _focusIndex
                  ? toColor(trends[index].color).withOpacity(0.3)
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

  void showDialog(BuildContext context) {
    //Navigator.pushNamed(context, NavigatorName.hba1c_tabble);
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => HbA1CTable()));
  }

  void showActionTrendFilter(BuildContext context) {
    // setState(() {
    //   this.isChoose = !isChoose;
    // });
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        backgroundColor: R.color.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => ActionListFilterTrend(
            selectedIndex: trendTypeIndex,
            callback: (value, index) {
              trendType = value;
              trendTypeIndex = index + 1;
              reloadData(periodFilterType);
            }));
  }

  void reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    BlocProvider.of<GlucoseBloc>(currentContext).add(FetchTrendGlucose(
        trendType: trendTypeIndex.toString(),
        currentDateTime:
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        periodFilterType: periodFilterType.toString(),
        page: '1'));
  }
}
