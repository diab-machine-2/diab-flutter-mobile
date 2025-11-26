import 'dart:async';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/bloodPressure/bloodPressure_bloc.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure_trend.dart';
import 'package:medical/src/repo/blood_pressure/bloodPressure_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodPressure/bloodpressure_result.dto.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/empty_data_box.dart';
import 'package:visibility_detector/visibility_detector.dart';

typedef BloodPressureChartCallback = void Function(
    BloodPressureRangeType rangeType);

class BloodPressureChart extends StatefulWidget {
  BloodPressureChart({
    Key? key,
    required this.initPeriodFilterType,
    required this.bloodPressureChartCallback,
  }) : super(key: key);
  final int initPeriodFilterType;
  final BloodPressureChartCallback bloodPressureChartCallback;
  @override
  BloodPressureChartState createState() => BloodPressureChartState();
}

class BloodPressureChartState extends State<BloodPressureChart>
    with AutomaticKeepAliveClientMixin<BloodPressureChart> {
  final ScrollController _scrollController = ScrollController();
  @override
  bool get wantKeepAlive => true;

  BloodPressureBloc _bloodPressureBloc = BloodPressureBloc();
  StreamSubscription? _subscription;

  int _focusIndex = -1;

  int _periodFilterType = 1;
  late BuildContext currentContext;
  int? previousDate = 0;
  DateTime? _lastTapTime;
  int? _lastTappedIndex;

  // Cached focused node info for mapping across different timelines
  int? _cachedFocusDate; // Timestamp in seconds
  String? _cachedFocusTimeFrame;
  double? _cachedFocusSystolic;
  double? _cachedFocusDiastolic;

  // Tracking variables for scroll logic (similar to HbA1C)
  double _lastViewWidth = 0;
  double _lastEffectivePointWidth = 0;
  int _lastTotalPoints = 0;
  bool _initialScrollApplied = false;
  int? _lastTrendsLength; // Track trends length to detect changes
  int? _lastPeriodFilterType; // Track period filter to detect changes
  bool _shouldScrollToFocus = false; // Flag to force scroll to focused point

  final double _mediumLow = 90;
  final double _mediumHigh = 140;

  @override
  void initState() {
    _periodFilterType = widget.initPeriodFilterType;
    _lastPeriodFilterType = widget.initPeriodFilterType;
    super.initState();
    // Reset flags to ensure first load will focus on latest point and scroll to it
    _initialScrollApplied = false;
    _lastTrendsLength = null;
    _focusIndex = -1;
    _shouldScrollToFocus =
        true; // Set flag to ensure scroll happens on first load
    _registerEmptyNavigation();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _subscription?.cancel();
    _bloodPressureBloc.close();
    super.dispose();
  }

  void _registerEmptyNavigation() {
    _subscription?.cancel();
    _subscription = _bloodPressureBloc.stream.listen((state) {
      if (!mounted) return;
      if (state is BloodPressureTrendLoaded) {
        _subscription?.cancel();
        _subscription = null;

        final trends = _getTrends(state.model);
        if (trends.isEmpty) {
          Future.delayed(Duration(milliseconds: 500)).then((value) {
            if (!mounted) return;
            Navigator.pushReplacementNamed(
                context, NavigatorName.add_blood_pressure,
                arguments: {'type': 'input'});
          });
        }
      }
    });
  }

  void reloadData(int periodFilter, [bool isNew = false]) {
    _registerEmptyNavigation();

    // Check if period filter changed
    final bool periodFilterChanged =
        _lastPeriodFilterType != null && _lastPeriodFilterType != periodFilter;

    if (isNew) {
      // When isNew = true, reset everything to focus on latest point
      _focusIndex = -1;
      _lastTrendsLength = null;
      _initialScrollApplied = false;
      _shouldScrollToFocus = true;
      // Clear cached focus info
      _cacheFocusedNode(null);
    } else if (periodFilterChanged) {
      // When period filter changes, keep focus index if valid but reset scroll flag
      // This ensures the focused point will be scrolled into view
      _initialScrollApplied = false;
      _shouldScrollToFocus = true;
      // Don't reset _lastTrendsLength here - we want to keep it to detect if focus index is still valid
      // The scroll will be triggered by resetting _initialScrollApplied and setting _shouldScrollToFocus
      // Also, we'll detect period filter change in build method to trigger scroll
    }

    _lastPeriodFilterType = periodFilter;
    _periodFilterType = periodFilter;
    _refresh();
  }

  Future<bool> _refresh() async {
    BlocProvider.of<BloodPressureBloc>(currentContext)
        .add(FetchBloodPressureTrend(
      currentDateTime: (DateTime.now().millisecondsSinceEpoch ~/ 1000),
      periodFilterType: _periodFilterType,
    ));
    return true;
  }

  void _viewHistory() {
    Navigator.pushNamed(
        currentContext, NavigatorName.detail_bloodpressure_listing,
        arguments: {
          'initPeriodFilterType': _periodFilterType,
        });
  }

  void _handleTapEvent(FlTapUpEvent event, LineTouchResponse? lineTouch,
      List<SubTrendItemModel> trends) {
    if (lineTouch?.lineBarSpots == null || lineTouch!.lineBarSpots!.isEmpty) {
      return;
    }

    final touchedSpot = lineTouch.lineBarSpots!.first;
    final tappedIndex = touchedSpot.spotIndex;

    if (tappedIndex < 0 || tappedIndex >= trends.length) {
      return;
    }

    final now = DateTime.now();

    // Detect double tap - check if tapping the same dot within 500ms (same as HbA1C)
    if (_lastTappedIndex == tappedIndex &&
        _lastTapTime != null &&
        now.difference(_lastTapTime!).inMilliseconds < 500) {
      // Double tap detected on the same dot - navigate to detail screen
      print('Blood pressure chart Double tap on index: $tappedIndex');
      _openDetailScreen(trends, tappedIndex);
      // Reset tracking after double tap
      _lastTappedIndex = null;
      _lastTapTime = null;
    } else {
      // Single tap - always update focus to the tapped node
      previousDate = 0;
      if (!mounted) return;

      setState(() {
        _focusIndex = tappedIndex;
        // Cache the focused node info for mapping across timelines
        _cacheFocusedNode(trends[_focusIndex]);
      });

      // Update callback with the selected point's range type
      final rangeType =
          BloodPressureRangeType.fromTitle(trends[_focusIndex].type ?? '');
      widget.bloodPressureChartCallback(rangeType);

      // Always scroll to center the selected point when tapped
      if (_lastTotalPoints > 0 &&
          _lastViewWidth > 0 &&
          _lastEffectivePointWidth > 0) {
        _scrollToSelectedPoint(
          totalPoints: _lastTotalPoints,
          viewWidth: _lastViewWidth,
          effectivePointWidth: _lastEffectivePointWidth,
        );
      }

      // Update tracking for next potential double tap
      _lastTappedIndex = tappedIndex;
      _lastTapTime = now;
    }
  }

  void _openDetailScreen(List<SubTrendItemModel> trends, int index) async {
    if (index < 0 || index >= trends.length) return;

    final selectedTrend = trends[index];

    // If id is available, navigate directly
    if (selectedTrend.id != null && selectedTrend.id!.isNotEmpty) {
      Navigator.pushNamed(
        currentContext,
        NavigatorName.add_blood_pressure,
        arguments: {'type': 'update', 'id': selectedTrend.id},
      );
      return;
    }

    // If no id, fetch from listing API to get the id
    if (selectedTrend.date != null && selectedTrend.timeFrameName != null) {
      try {
        final client = BloodPressureClient();
        final dataModel = await client.fetchBloodPressureInput(
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
          _periodFilterType.toString(),
          null, // bloodPressureType
          1, // page
          size: '100', // Get more items to find the matching one
        );

        // Find matching item by date, timeFrameName, and values (systolic/diastolic)
        BloodPressureModel? matchingItem;
        try {
          matchingItem = dataModel.inputs.firstWhere(
            (item) {
              // Compare dates (same timestamp or same day)
              final trendDate = DateTime.fromMillisecondsSinceEpoch(
                selectedTrend.date! * 1000,
                isUtc: true,
              );
              final itemDate = DateTime.fromMillisecondsSinceEpoch(
                item.date! * 1000,
                isUtc: true,
              );

              // First try exact timestamp match (within 1 minute tolerance)
              final timeDiff = (trendDate.millisecondsSinceEpoch -
                      itemDate.millisecondsSinceEpoch)
                  .abs();
              final exactTimeMatch = timeDiff < 60000; // 1 minute tolerance

              // Fallback to same day if exact time doesn't match
              final sameDay = trendDate.year == itemDate.year &&
                  trendDate.month == itemDate.month &&
                  trendDate.day == itemDate.day;

              // Compare timeFrameName
              final sameTimeFrame =
                  item.timeFrame == selectedTrend.timeFrameName;

              // Compare systolic and diastolic values (exact match)
              final sameSystolic = item.systolic != null &&
                  selectedTrend.systolic != null &&
                  (item.systolic!.round() == selectedTrend.systolic!.round());

              final sameDiastolic = item.diastolic != null &&
                  selectedTrend.diastolic != null &&
                  (item.diastolic!.round() == selectedTrend.diastolic!.round());

              // Match if: (exact time OR same day) AND same timeFrame AND same values
              return (exactTimeMatch || sameDay) &&
                  sameTimeFrame &&
                  sameSystolic &&
                  sameDiastolic;
            },
          );
        } catch (e) {
          // Item not found, try without value matching
          try {
            matchingItem = dataModel.inputs.firstWhere(
              (item) {
                final trendDate = DateTime.fromMillisecondsSinceEpoch(
                  selectedTrend.date! * 1000,
                  isUtc: true,
                );
                final itemDate = DateTime.fromMillisecondsSinceEpoch(
                  item.date! * 1000,
                  isUtc: true,
                );

                final sameDay = trendDate.year == itemDate.year &&
                    trendDate.month == itemDate.month &&
                    trendDate.day == itemDate.day;

                final sameTimeFrame =
                    item.timeFrame == selectedTrend.timeFrameName;

                return sameDay && sameTimeFrame;
              },
            );
          } catch (e2) {
            // Item not found, will fallback to listing screen
            matchingItem = null;
          }
        }

        if (matchingItem != null &&
            matchingItem.id != null &&
            matchingItem.id!.isNotEmpty) {
          Navigator.pushNamed(
            currentContext,
            NavigatorName.add_blood_pressure,
            arguments: {'type': 'update', 'id': matchingItem.id},
          );
          return;
        }
      } catch (e) {
        // If error, fallback to listing screen
        print('Error fetching blood pressure id: $e');
      }
    }

    // Fallback: navigate to listing screen
    Navigator.pushNamed(
      currentContext,
      NavigatorName.detail_bloodpressure_listing,
      arguments: {
        'initPeriodFilterType': _periodFilterType,
      },
    );
  }

  List<SubTrendItemModel> _getTrends(BloodPressureTrendModel model) {
    // Get the trends list from the current state
    List<SubTrendItemModel> trends = [];
    model.trendItems.items.forEach((element) {
      trends.addAll(element.subTrendItems);
    });

    // sort the trends by date
    trends.sort((a, b) {
      if (a.date == null || b.date == null) return 0;
      return a.date!.compareTo(b.date!);
    });

    return trends;
  }

  /// Cache the currently focused node information
  void _cacheFocusedNode(SubTrendItemModel? node) {
    if (node == null) {
      _cachedFocusDate = null;
      _cachedFocusTimeFrame = null;
      _cachedFocusSystolic = null;
      _cachedFocusDiastolic = null;
      return;
    }
    _cachedFocusDate = node.date;
    _cachedFocusTimeFrame = node.timeFrameName;
    _cachedFocusSystolic = node.systolic;
    _cachedFocusDiastolic = node.diastolic;
  }

  /// Find the index of a node matching the cached focus info in the new trends list
  /// Returns -1 if not found
  int _findMatchingNodeIndex(List<SubTrendItemModel> trends) {
    if (_cachedFocusDate == null || _cachedFocusTimeFrame == null) {
      return -1;
    }

    // First, try exact match: same date, timeFrame, and values
    for (int i = 0; i < trends.length; i++) {
      final trend = trends[i];
      if (trend.date == _cachedFocusDate &&
          trend.timeFrameName == _cachedFocusTimeFrame) {
        // Check if values match (with tolerance for floating point)
        final systolicMatch = _cachedFocusSystolic != null &&
            trend.systolic != null &&
            (_cachedFocusSystolic!.round() == trend.systolic!.round());
        final diastolicMatch = _cachedFocusDiastolic != null &&
            trend.diastolic != null &&
            (_cachedFocusDiastolic!.round() == trend.diastolic!.round());

        if (systolicMatch && diastolicMatch) {
          return i;
        }
      }
    }

    // If exact match not found, try matching by date and timeFrame only
    for (int i = 0; i < trends.length; i++) {
      final trend = trends[i];
      if (trend.date == _cachedFocusDate &&
          trend.timeFrameName == _cachedFocusTimeFrame) {
        return i;
      }
    }

    // If still not found, try to find the closest node by date
    int? closestIndex;
    int? minTimeDiff;
    final cachedDateTime = DateTime.fromMillisecondsSinceEpoch(
      _cachedFocusDate! * 1000,
      isUtc: true,
    );

    for (int i = 0; i < trends.length; i++) {
      final trend = trends[i];
      if (trend.date == null) continue;

      final trendDateTime = DateTime.fromMillisecondsSinceEpoch(
        trend.date! * 1000,
        isUtc: true,
      );

      final timeDiff = (cachedDateTime.millisecondsSinceEpoch -
              trendDateTime.millisecondsSinceEpoch)
          .abs();

      if (minTimeDiff == null || timeDiff < minTimeDiff) {
        minTimeDiff = timeDiff;
        closestIndex = i;
      }
    }

    // If we found a close match (within 1 hour), use it
    if (closestIndex != null && minTimeDiff != null && minTimeDiff < 3600000) {
      return closestIndex;
    }

    return -1;
  }

  void _ensureSelectedPointVisible({
    required List<SubTrendItemModel> trends,
    required int totalPoints,
    required double viewWidth,
    required double effectivePointWidth,
    int retry = 0,
  }) {
    // Basic validation
    if (totalPoints <= 0) return;
    if (!viewWidth.isFinite || viewWidth <= 0) return;

    // If scroll already applied and we don't need to force scroll, skip
    if (_initialScrollApplied && !_shouldScrollToFocus) {
      return;
    }

    // Maximum retry count to avoid infinite loops
    if (retry > 20) {
      _initialScrollApplied = true;
      _shouldScrollToFocus = false; // Reset flag even on max retry
      return;
    }

    // Don't set _initialScrollApplied here - set it after successful scroll
    // This allows retry if scroll controller is not ready

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Check if scroll controller is ready with proper dimensions
      // If not ready, retry after a delay
      if (!_scrollController.hasClients ||
          !_scrollController.position.hasContentDimensions) {
        _initialScrollApplied = false; // Reset to allow retry
        // Retry after a short delay
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            _ensureSelectedPointVisible(
              trends: trends,
              totalPoints: totalPoints,
              viewWidth: viewWidth,
              effectivePointWidth: effectivePointWidth,
              retry: retry + 1,
            );
          }
        });
        return;
      }

      // Determine selected index: use _focusIndex if valid, otherwise default to last point (latest data)
      final int selectedIndex = _focusIndex >= 0 && _focusIndex < trends.length
          ? _focusIndex
          : (trends.length > 0 ? trends.length - 1 : 0);

      // Calculate the target position to center the selected point
      final double targetCenter =
          selectedIndex * effectivePointWidth + (effectivePointWidth / 2);
      final double rawOffset = targetCenter - (viewWidth / 2);

      // Get maxScrollExtent AFTER ensuring hasContentDimensions
      final double maxScrollExtent = _scrollController.position.maxScrollExtent;
      final double desiredOffset =
          rawOffset.clamp(0.0, maxScrollExtent).toDouble();

      // Check if the point is at the beginning (first few points visible)
      if (desiredOffset <= 0.0 || selectedIndex < 3) {
        // Point is at the beginning, just jump to start without animation
        _scrollController.jumpTo(0.0);
        // Set flag after successful scroll
        _initialScrollApplied = true;
        _shouldScrollToFocus = false;
      } else {
        // Point is not at the beginning, animate smoothly to center it
        _scrollController
            .animateTo(
          desiredOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        )
            .then((_) {
          // Set flag after animation completes
          if (mounted) {
            _initialScrollApplied = true;
            _shouldScrollToFocus = false;
          }
        });
      }
    });
  }

  void _scrollToSelectedPoint({
    required int totalPoints,
    required double viewWidth,
    required double effectivePointWidth,
    int retry = 0,
  }) {
    if (!_scrollController.hasClients) return;
    if (totalPoints <= 0) return;
    if (!viewWidth.isFinite || viewWidth <= 0) return;

    // Maximum retry count to avoid infinite loops
    if (retry > 20) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      // Check if scroll controller is ready with proper dimensions
      if (!_scrollController.position.hasContentDimensions) {
        // Retry after a short delay
        Future.delayed(const Duration(milliseconds: 50), () {
          _scrollToSelectedPoint(
            totalPoints: totalPoints,
            viewWidth: viewWidth,
            effectivePointWidth: effectivePointWidth,
            retry: retry + 1,
          );
        });
        return;
      }

      final int selectedIndex = _focusIndex >= 0 && _focusIndex < totalPoints
          ? _focusIndex
          : (totalPoints > 0 ? totalPoints - 1 : 0);

      // Calculate position to center the selected point
      final double targetCenter =
          selectedIndex * effectivePointWidth + (effectivePointWidth / 2);
      final double rawOffset = targetCenter - (viewWidth / 2);

      // Get maxScrollExtent AFTER ensuring hasContentDimensions
      final double maxScrollExtent = _scrollController.position.maxScrollExtent;
      final double desiredOffset =
          rawOffset.clamp(0.0, maxScrollExtent).toDouble();

      // Animate to the desired position
      _scrollController.animateTo(
        desiredOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<BloodPressureBloc>.value(
      value: _bloodPressureBloc,
      child: BlocBuilder<BloodPressureBloc, BloodPressureState>(
        builder: (BuildContext context, BloodPressureState state) {
          currentContext = context;
          BloodPressureTrendModel? model;

          if (state is BloodPressureInitial) {
            BlocProvider.of<BloodPressureBloc>(context)
                .add(FetchBloodPressureTrend(
              currentDateTime: (DateTime.now().millisecondsSinceEpoch ~/ 1000),
              periodFilterType: _periodFilterType,
            ));
          }
          if (state is BloodPressureError) {
            Message.showToastMessage(context, state.message);
          }

          List<SubTrendItemModel> trends = [];
          if (state is BloodPressureTrendLoaded) {
            model = state.model;

            if (model.trendItems.items.isNotEmpty) {
              trends = _getTrends(model);
            }

            if (trends.isNotEmpty) {
              // Check if trends length changed (new data loaded) or first time loading
              final bool isFirstLoad = _lastTrendsLength == null;
              final bool trendsChanged = _lastTrendsLength != null &&
                  _lastTrendsLength != trends.length;

              // Determine focus index:
              // - If focus index is invalid or first load, focus on latest point
              // - When period filter changes, try to find matching node in new timeline
              // - If no match found, focus on latest point
              bool focusIndexChanged = false;
              BloodPressureRangeType? rangeTypeToCallback;

              if (_focusIndex == -1 ||
                  _focusIndex >= trends.length ||
                  isFirstLoad) {
                // Set focus to latest point (last index) - this is the newest data point
                final int latestIndex = trends.length - 1;
                if (latestIndex >= 0 && latestIndex < trends.length) {
                  final int oldFocusIndex = _focusIndex;
                  _focusIndex = latestIndex;
                  focusIndexChanged = oldFocusIndex != _focusIndex;
                  // Cache the focused node info
                  _cacheFocusedNode(trends[_focusIndex]);
                  rangeTypeToCallback = BloodPressureRangeType.fromTitle(
                      trends[_focusIndex].type ?? '');
                }
              } else if (_shouldScrollToFocus && _cachedFocusDate != null) {
                // Period filter changed - try to find matching node in new timeline
                final int matchingIndex = _findMatchingNodeIndex(trends);
                if (matchingIndex >= 0 && matchingIndex < trends.length) {
                  // Found matching node - use it
                  final int oldFocusIndex = _focusIndex;
                  _focusIndex = matchingIndex;
                  focusIndexChanged = oldFocusIndex != _focusIndex;
                  // Update cache with the matched node
                  _cacheFocusedNode(trends[_focusIndex]);
                  rangeTypeToCallback = BloodPressureRangeType.fromTitle(
                      trends[_focusIndex].type ?? '');
                } else {
                  // No matching node found - focus on latest point
                  final int latestIndex = trends.length - 1;
                  if (latestIndex >= 0 && latestIndex < trends.length) {
                    final int oldFocusIndex = _focusIndex;
                    _focusIndex = latestIndex;
                    focusIndexChanged = oldFocusIndex != _focusIndex;
                    // Cache the new focused node
                    _cacheFocusedNode(trends[_focusIndex]);
                    rangeTypeToCallback = BloodPressureRangeType.fromTitle(
                        trends[_focusIndex].type ?? '');
                  }
                }
              } else {
                // Focus index is valid and no period filter change - ensure callback is called
                if (_focusIndex >= 0 && _focusIndex < trends.length) {
                  rangeTypeToCallback = BloodPressureRangeType.fromTitle(
                      trends[_focusIndex].type ?? '');
                  // When _shouldScrollToFocus is true, we need to scroll to the focused point
                  if (_shouldScrollToFocus) {
                    focusIndexChanged = true;
                  }
                }
              }

              // Call callback after build completes to avoid setState during build
              if (rangeTypeToCallback != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    widget.bloodPressureChartCallback(rangeTypeToCallback!);
                  }
                });
              }

              // Always reset scroll flag when we need to scroll
              // This includes: first load, trends changed, explicit flag set, or focus index changed
              if (isFirstLoad ||
                  trendsChanged ||
                  _shouldScrollToFocus ||
                  focusIndexChanged) {
                _initialScrollApplied = false;
                // Keep _shouldScrollToFocus true until scroll is actually applied
                // Don't reset it here - it will be reset in _ensureSelectedPointVisible after scroll completes
                if (isFirstLoad || trendsChanged) {
                  _lastTrendsLength = trends.length;
                }
              }
            } else {
              // Reset focus index when trends is empty
              _focusIndex = -1;
              _lastTrendsLength = 0;
              _initialScrollApplied =
                  false; // Reset scroll flag for empty trends
              // Clear cached focus info
              _cacheFocusedNode(null);
            }
          }

          if (model == null) {
            return Container(
              height: 240,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return VisibilityDetector(
            key: Key('blood_pressure_chart'),
            onVisibilityChanged: (visibilityInfo) {
              var visiblePercentage = visibilityInfo.visibleFraction * 100;
              if (visiblePercentage == 0) {
                previousDate = 0;
              }
            },
            child: Container(
              color: R.color.transparent,
              padding: EdgeInsets.only(left: 12, right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 14),
                  if (model.trendItems.items.length == 0)
                    EmptyDataBox(
                      text: 'chỉ số huyết áp',
                      onTap: () {
                        Navigator.pushNamed(
                            context, NavigatorName.add_blood_pressure,
                            arguments: {'type': 'input', 'id': null});
                      },
                    )
                  else ...[
                    _buildNavigatorIndex(trends),
                    SizedBox(height: 24),
                    _buildChart(model, trends),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  double _customYTransform(double y) {
    if (y <= 90) {
      // Map 0–90 to 0–30
      return (y / 90) * 30;
    } else if (y <= 140) {
      // Map 90–140 to 30–70
      return 30 + ((y - 90) / 50) * 40;
    } else {
      // Map 140–180+ to 70–100 (you can clamp or allow more)
      return 70 + ((y - 140) / 40) * 30;
    }
  }

  Widget _buildNavigatorIndex(List<SubTrendItemModel> trends) {
    String selectedDate = '';
    String selectedDateTime = '';
    String selectedType = '';
    String selectedTimeFrame = 'Thức dậy';
    String selectedDiastolic = '166';
    String selectedSystolic = '110';
    String selectedColor = '';

    if (_focusIndex != -1 && _focusIndex < trends.length) {
      final selectedTrend = trends[_focusIndex];
      final date = DateTime.fromMillisecondsSinceEpoch(
          (selectedTrend.date ?? 0) * 1000,
          isUtc: true);
      selectedDate = DateFormat('dd/MM').format(date);
      selectedDateTime = DateFormat('HH:mm').format(date);
      selectedType = selectedTrend.type ?? '';
      selectedTimeFrame = selectedTrend.timeFrameName ?? '';
      selectedDiastolic = selectedTrend.diastolic?.toInt().toString() ?? '';
      selectedSystolic = selectedTrend.systolic?.toInt().toString() ?? '';
      selectedColor = selectedTrend.color ?? '';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Row: Stadium with white background (include time -> date) and icon history, center align
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 138,
                  height: 38,
                  decoration: BoxDecoration(
                    color: R.color.white,
                    borderRadius: BorderRadius.circular(19),
                    border:
                        Border.all(color: R.color.color0xffE5E5E5, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        selectedDateTime,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          fontFamily: R.font.sfpro,
                          color: Color(0xFF636A6B),
                          letterSpacing: 0.4,
                        ),
                      ),
                      Container(
                        width: 4,
                        height: 4,
                        margin: EdgeInsets.only(left: 4, right: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFBFC6C6),
                        ),
                      ),
                      Text(
                        selectedDate,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          fontFamily: R.font.sfpro,
                          color: Color(0xFF636A6B),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 12),
                InkWell(
                  onTap: _focusIndex > 0
                      ? () {
                          // Move to previous node
                          setState(() {
                            _focusIndex = max(0, _focusIndex - 1);
                            // Cache the focused node info for mapping across timelines
                            _cacheFocusedNode(trends[_focusIndex]);
                          });

                          // Update callback with the selected point's range type
                          final rangeType = BloodPressureRangeType.fromTitle(
                              trends[_focusIndex].type ?? '');
                          widget.bloodPressureChartCallback(rangeType);

                          // Always scroll to center the selected point when using prev button
                          if (_lastTotalPoints > 0 &&
                              _lastViewWidth > 0 &&
                              _lastEffectivePointWidth > 0) {
                            _scrollToSelectedPoint(
                              totalPoints: _lastTotalPoints,
                              viewWidth: _lastViewWidth,
                              effectivePointWidth: _lastEffectivePointWidth,
                            );
                          }
                        }
                      : null,
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
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _focusIndex != -1 && _focusIndex < trends.length
                      ? () => _openDetailScreen(trends, _focusIndex)
                      : null,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 200),
                    child: Text(
                      selectedType,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: R.font.sfpro,
                        color: selectedColor.isNotEmpty
                            ? Color(int.parse(
                                '0xff${selectedColor.split('#').join()}'))
                            : R.color.color0xff111515,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: _focusIndex < trends.length - 1
                      ? () {
                          // Move to next node
                          setState(() {
                            _focusIndex =
                                min(trends.length - 1, _focusIndex + 1);
                            // Cache the focused node info for mapping across timelines
                            _cacheFocusedNode(trends[_focusIndex]);
                          });

                          // Update callback with the selected point's range type
                          final rangeType = BloodPressureRangeType.fromTitle(
                              trends[_focusIndex].type ?? '');
                          widget.bloodPressureChartCallback(rangeType);

                          // Always scroll to center the selected point when using next button
                          if (_lastTotalPoints > 0 &&
                              _lastViewWidth > 0 &&
                              _lastEffectivePointWidth > 0) {
                            _scrollToSelectedPoint(
                              totalPoints: _lastTotalPoints,
                              viewWidth: _lastViewWidth,
                              effectivePointWidth: _lastEffectivePointWidth,
                            );
                          }
                        }
                      : null,
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
                const SizedBox(width: 12),
              ],
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: _focusIndex != -1 && _focusIndex < trends.length
                  ? () => _openDetailScreen(trends, _focusIndex)
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    selectedTimeFrame,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: R.font.sfpro,
                      color: Color(0xFF636A6B),
                    ),
                  ),
                  Container(
                    width: 4,
                    height: 4,
                    margin: EdgeInsets.only(left: 4, right: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFBFC6C6),
                    ),
                  ),
                  Text(
                    '$selectedSystolic/$selectedDiastolic mmHg',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      fontFamily: R.font.sfpro,
                      color: Color(0xFF111515),
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChart(
      BloodPressureTrendModel model, List<SubTrendItemModel> trends) {
    const int maxVisiblePoints =
        11; // Maximum points to show without scrolling (changed from 12)
    const double scrollVisiblePointCount =
        5.5; // Points visible when scrolling (half of 11)
    const double chartHeight = 120;
    double leftTitleWidth = 50;
    double leftTitleMargin = 2;

    // Fixed minY and maxY for consistent chart display
    double minY = 0;
    double maxY = 100;
    final int totalPoints = trends.length;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: leftTitleWidth,
              height: chartHeight,
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child: Column(
                children: [
                  Spacer(flex: 1),
                  Text(
                    _mediumHigh.round().toString(),
                    style: TextStyle(
                      color: R.color.color0xff111515,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      fontFamily: R.font.sfpro,
                    ),
                  ),
                  Spacer(flex: 1),
                  Text(
                    _mediumLow.round().toString(),
                    style: TextStyle(
                      color: R.color.color0xff111515,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      fontFamily: R.font.sfpro,
                    ),
                  ),
                  Spacer(flex: 2),
                  Image.asset(R.drawable.ic_bloodpressure_pulse,
                      width: 20, height: 20),
                ],
              ),
            ),
            SizedBox(width: leftTitleMargin),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double viewWidth = constraints.maxWidth;
                  if (!viewWidth.isFinite || viewWidth <= 0) {
                    return const SizedBox.shrink();
                  }

                  // If totalPoints <= 11: show all points without scroll
                  // If totalPoints > 11: show 5.5 points visible and enable scroll
                  final bool enableScroll = totalPoints > maxVisiblePoints;

                  final double chartWidth = enableScroll
                      ? (viewWidth / scrollVisiblePointCount) * totalPoints
                      : viewWidth;
                  final double effectivePointWidth =
                      totalPoints == 0 ? 0 : chartWidth / totalPoints;

                  // Save values for use in scroll functions
                  _lastViewWidth = viewWidth;
                  _lastEffectivePointWidth = effectivePointWidth;
                  _lastTotalPoints = totalPoints;

                  if (enableScroll) {
                    // Ensure focus index is set correctly before scrolling
                    // This is important for first load when entering dashboard
                    if ((_focusIndex == -1 || _focusIndex >= trends.length) &&
                        trends.isNotEmpty) {
                      _focusIndex = trends.length - 1;
                      // Update callback with latest point when setting focus
                      // Use post frame callback to avoid setState during build
                      if (_focusIndex >= 0 && _focusIndex < trends.length) {
                        final rangeType = BloodPressureRangeType.fromTitle(
                            trends[_focusIndex].type ?? '');
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            widget.bloodPressureChartCallback(rangeType);
                          }
                        });
                      }
                      // Reset scroll flags to ensure scroll happens
                      _initialScrollApplied = false;
                      _shouldScrollToFocus = true;
                    }

                    // Always try to ensure selected point is visible and centered
                    // This will scroll to focused point on first load and when period filter changes
                    // Call if we haven't applied scroll yet OR if we need to force scroll
                    // Also check if focus index is valid before scrolling
                    if ((!_initialScrollApplied || _shouldScrollToFocus) &&
                        _focusIndex >= 0 &&
                        _focusIndex < trends.length) {
                      // Use post frame callback to ensure chart is fully built before scrolling
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted &&
                            (_shouldScrollToFocus || !_initialScrollApplied) &&
                            _focusIndex >= 0 &&
                            _focusIndex < trends.length) {
                          _ensureSelectedPointVisible(
                            trends: trends,
                            totalPoints: totalPoints,
                            viewWidth: viewWidth,
                            effectivePointWidth: effectivePointWidth,
                          );
                        }
                      });
                    }
                  } else {
                    // When scroll is not needed, ensure we're at the start
                    if (_scrollController.hasClients &&
                        _scrollController.position.pixels != 0.0) {
                      _scrollController.jumpTo(0.0);
                    }
                    _initialScrollApplied = true;
                    _shouldScrollToFocus =
                        false; // Reset flag when scroll not needed
                  }

                  return SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: enableScroll
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    child: SizedBox(
                      width: enableScroll ? chartWidth : viewWidth,
                      child: Container(
                        height: chartHeight,
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: LineChart(
                          LineChartData(
                            lineTouchData: LineTouchData(
                                getTouchLineStart: (barData, index) =>
                                    -double.infinity,
                                getTouchLineEnd: (barData, index) =>
                                    double.infinity,
                                getTouchedSpotIndicator:
                                    (LineChartBarData barData,
                                        List<int> spotIndexes) {
                                  return spotIndexes.map((index) {
                                    // Get the color of the touched point
                                    Color dotColor = R.color.black;
                                    if (index >= 0 && index < trends.length) {
                                      final trend = trends[index];
                                      if (trend.color != null &&
                                          trend.color!.isNotEmpty) {
                                        dotColor = toColor(trend.color);
                                      }
                                    }

                                    return TouchedSpotIndicatorData(
                                      FlLine(
                                        color: dotColor,
                                        strokeWidth: 0.5,
                                      ),
                                      FlDotData(
                                        show: true,
                                        getDotPainter:
                                            (spot, percent, barData, index) =>
                                                FlDotCirclePainter(
                                          radius: 3,
                                          color: dotColor,
                                          strokeWidth: 6,
                                          strokeColor:
                                              dotColor.withOpacity(0.3),
                                        ),
                                      ),
                                    );
                                  }).toList();
                                },
                                touchTooltipData: LineTouchTooltipData(
                                  showOnTopOfTheChartBoxArea: true,
                                  fitInsideVertically: true,
                                  fitInsideHorizontally: true,
                                  tooltipBgColor: Colors.transparent,
                                  tooltipRoundedRadius: 8,
                                  getTooltipItems:
                                      (List<LineBarSpot> lineBarsSpot) {
                                    return lineBarsSpot.map((lineBarSpot) {
                                      if (lineBarSpot.barIndex == 0) {
                                        if (lineBarSpot.spotIndex < 0 ||
                                            lineBarSpot.spotIndex >=
                                                trends.length ||
                                            trends[lineBarSpot.spotIndex]
                                                    .systolic ==
                                                null ||
                                            trends[lineBarSpot.spotIndex]
                                                    .diastolic ==
                                                null) {
                                          return LineTooltipItem(
                                            '0/0',
                                            TextStyle(
                                              color:
                                                  toColor(model.colors!.first),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              fontFamily: R.font.sfpro,
                                            ),
                                          );
                                        }
                                        final trend =
                                            trends[lineBarSpot.spotIndex];
                                        return LineTooltipItem(
                                          trend.systolic!.round().toString() +
                                              '/' +
                                              trend.diastolic!
                                                  .round()
                                                  .toString(),
                                          TextStyle(
                                            color: toColor(trend.color),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            fontFamily: R.font.sfpro,
                                          ),
                                        );
                                      }
                                      return null;
                                    }).toList();
                                  },
                                ),
                                touchCallback: (FlTouchEvent event,
                                    LineTouchResponse? lineTouch) {
                                  if (event is FlTapUpEvent) {
                                    _handleTapEvent(event, lineTouch, trends);
                                  } else if (event is! FlLongPressEnd &&
                                      event is! FlPanEndEvent) {
                                    // Pan/hover event - update focus but don't reset double-tap tracking
                                    previousDate = 0;
                                    final value = lineTouch?.lineBarSpots?[0].x;
                                    if (value != null) {
                                      final panIndex = value.toInt();
                                      if (panIndex >= 0 &&
                                          panIndex < trends.length) {
                                        setState(() {
                                          _focusIndex = panIndex;
                                          // Cache the focused node info for mapping across timelines
                                          _cacheFocusedNode(
                                              trends[_focusIndex]);
                                        });
                                        final rangeType =
                                            BloodPressureRangeType.fromTitle(
                                                trends[_focusIndex].type ?? '');
                                        widget.bloodPressureChartCallback(
                                            rangeType);
                                      }
                                    }
                                  } else {
                                    // Long press end or pan end - reset focus but keep double-tap tracking
                                    previousDate = 0;
                                    _focusIndex = -1;
                                    // Clear cached focus info
                                    _cacheFocusedNode(null);
                                  }
                                }),
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(
                              rightTitles: SideTitles(showTitles: false),
                              topTitles: SideTitles(showTitles: false),
                              bottomTitles: SideTitles(
                                showTitles: true,
                                margin: 16,
                                reservedSize: 16,
                                interval: 1,
                                getTextStyles: (context, value) {
                                  return TextStyle(
                                      color: _focusIndex == value.toInt()
                                          ? R.color.color0xff111515
                                          : R.color.color0xff636A6B,
                                      fontSize: 12,
                                      fontWeight: _focusIndex == value.toInt()
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                      fontFamily: R.font.sfpro,
                                      height: 1.5);
                                },
                                getTitles: (double value) {
                                  // padding left
                                  if (value <= -0.5 ||
                                      value >= (trends.length - 0.5)) return '';
                                  int index = value.toInt();
                                  if (index < 0 ||
                                      index >= trends.length ||
                                      trends[index].pulseRate == null ||
                                      trends[index].pulseRate == 0) {
                                    return '--';
                                  }
                                  // return heart rate value
                                  return trends[index]
                                      .pulseRate!
                                      .round()
                                      .toString();
                                },
                              ),
                              leftTitles: SideTitles(
                                showTitles: false,
                                reservedSize: 50,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            minX: -0.5,
                            maxX: trends.length.toDouble() - 0.5,
                            maxY: maxY,
                            minY: minY,
                            lineBarsData: _linesBarData(trends),
                            extraLinesData: ExtraLinesData(
                              horizontalLines: [
                                HorizontalLine(
                                  y: _customYTransform(_mediumLow),
                                  color: R.color.color0xff636A6B,
                                  dashArray: [8, 4],
                                  strokeWidth: 1,
                                ),
                                HorizontalLine(
                                  y: _customYTransform(_mediumHigh),
                                  color: R.color.color0xff636A6B,
                                  dashArray: [8, 4],
                                  strokeWidth: 1,
                                ),
                              ],
                            ),
                          ),
                          swapAnimationDuration: Duration(milliseconds: 250),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
        SizedBox(height: 12),
        // guide line
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 23,
              height: 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                color: Color(0xFF008479),
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Tâm thu',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                fontFamily: 'Nunito',
                color: R.color.color0xff111515,
                height: 1.29,
              ),
            ),
            SizedBox(width: 48),
            Container(
              width: 23,
              height: 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                color: Color(0xFF95682E),
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Tâm trương',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                fontFamily: 'Nunito',
                color: R.color.color0xff111515,
                height: 1.29,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<LineChartBarData> _linesBarData(List<SubTrendItemModel> trends) {
    if (trends.length == 0) {
      return [];
    }

    return [
      LineChartBarData(
        spots: List.generate(trends.length, (index) {
          double value =
              trends[index].systolic! > 180 ? 180 : trends[index].systolic!;
          return FlSpot((index).toDouble(), _customYTransform(value));
        }),
        isCurved: false,
        colors: [Color(0xFF008479)],
        barWidth: 1,
        isStrokeCapRound: true,
        dotData: FlDotData(
            show: true,
            checkToShowDot: (spot, barData) => true,
            getDotPainter: (spot, percent, barData, index) {
              final color = toColor(trends[index].color);
              final bool isSelected = _focusIndex == index;
              return FlDotCirclePainter(
                radius: 3,
                color: color,
                strokeWidth: isSelected ? 6 : 0,
                strokeColor: isSelected ? color.withOpacity(0.3) : null,
              );
            }),
        belowBarData: BarAreaData(show: false),
      ),
      LineChartBarData(
        spots: List.generate(trends.length, (index) {
          double value =
              trends[index].diastolic! > 180 ? 180 : trends[index].diastolic!;
          return FlSpot((index).toDouble(), _customYTransform(value));
        }),
        isCurved: false,
        colors: [Color(0xFF95682E)],
        barWidth: 1,
        isStrokeCapRound: true,
        dotData: FlDotData(
            show: true,
            checkToShowDot: (spot, barData) => true,
            getDotPainter: (spot, percent, barData, index) {
              final color = toColor(trends[index].color);
              final bool isSelected = _focusIndex == index;
              return FlDotCirclePainter(
                radius: 3,
                color: color,
                strokeWidth: isSelected ? 6 : 0,
                strokeColor: isSelected ? color.withOpacity(0.3) : null,
              );
            }),
        belowBarData: BarAreaData(show: false),
      ),
    ];
  }
}
