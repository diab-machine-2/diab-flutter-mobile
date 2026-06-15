import 'dart:math';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/HbA1C/intro/widgets/hba1c_knowledge_section.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodPressure/widget/horizontal_selector.dart';
import 'package:medical/src/model/ai_recommendation_result.dart';
import 'package:medical/src/widget/BloodSugar/widget/ai_loading_text_widget.dart';
import 'package:medical/src/widget/components/ai_references_widget.dart';
import 'package:medical/src/bloc/HbA1C/HbA1C_bloc.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_Input.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/HbA1C/hba1c_functions.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/widget/HbA1C/hba1c_trend_chart.dart';

// Re-export HbA1cDataPoint for compatibility
export 'hba1c_trend_chart.dart' show HbA1cDataPoint;

class HbA1cDashboard extends StatefulWidget {
  final double? currentValue;
  final String? currentLevel;
  final Color? currentColor;

  const HbA1cDashboard({
    Key? key,
    this.currentValue,
    this.currentLevel,
    this.currentColor,
  }) : super(key: key);

  @override
  State<HbA1cDashboard> createState() => _HbA1cDashboardState();
}

class _HbA1cDashboardState extends State<HbA1cDashboard> {
  double? currentValue;
  String? currentLevel;
  Color? currentColor;

  int _periodFilterType =
      3; // Default to 3 (24 months, used with takeAll for "Tất cả")
  int _selectedUIIndex =
      0; // Track UI selection separately (default to "Tất cả")
  AiRecommendationResult? _aiSuggestion;
  bool _isLoadingAI = false; // Track if AI is being loaded to prevent loops
  int _focusIndex = -1; // Focused time-group index (x axis group)
  int _focusSubIndex = 0; // Focused item within the time group
  DateTime?
      _selectedPointDate; // Store selected point date to maintain selection across time range changes
  bool _isDetailViewed = false; // Track if user has viewed HbA1c detail page

  // Grouped data by calendar day (UTC)
  // Sorted by day ascending; x index = position in this list
  List<int> _timestamps = [];
  List<List<HbA1cDataPoint>> _groupedPoints = [];
  // Flattened list retained for backward compatibility where convenient
  List<HbA1cDataPoint> _dataPoints = [];

  // Bloc instance
  HbA1CBloc _hbA1CBloc = HbA1CBloc();
  late BuildContext currentContext;

  @override
  void initState() {
    super.initState();
    _firebaseSetup();
    _loadDetailViewedState();
    // Load trend data first, then AI will be loaded after data is available
    _loadTrendData();
  }

  @override
  void dispose() {
    _hbA1CBloc.close();
    super.dispose();
  }

  bool _argsInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsInitialized) return;
    // Get arguments from navigation if available
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    currentValue = args?['currentValue'] ?? widget.currentValue;
    currentLevel = args?['currentLevel'] ?? widget.currentLevel;
    currentColor = args?['currentColor'] ?? widget.currentColor;
    _argsInitialized = true;
  }

  Future<void> _loadDetailViewedState() async {
    _isDetailViewed = await AppStorages.isHbA1CDetailViewed();
  }

  Future<void> _firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
      screenName: "hba1c_dashboard",
      screenClass: "HbA1cDashboard",
    );
  }

  Future<void> _loadAITrend() async {
    // Prevent loading if already in progress
    if (_isLoadingAI) return;

    _isLoadingAI = true;
    if (mounted) {
      setState(() {
        _aiSuggestion = null; // Show loading state
      });
    }

    try {
      // When "Tất cả" (index 0) is selected, use takeAll = true
      bool useTakeAll = _selectedUIIndex == 0;

      print('🔄 Loading AI Trend Analysis from API...');
      print('   Period Filter: $_periodFilterType, TakeAll: $useTakeAll');

      // Gọi API để lấy gợi ý AI từ backend
      final aiResult = await HbA1CClient()
          .fetchHbA1CTrendAnalysis(_periodFilterType, takeAll: useTakeAll);

      if (mounted) {
        setState(() {
          if (aiResult != null && aiResult.recommendation.isNotEmpty) {
            _aiSuggestion = aiResult;
            print('✅ AI Analysis from API loaded successfully');
          } else {
            // Fallback to local analysis if API returns empty
            print('⚠️ API returned empty result, using backup analysis');
            _generateLocalAISuggestion();
          }
          _isLoadingAI = false;
        });
      }
    } catch (e) {
      print('❌ Error loading AI trend: $e');
      print('🔄 Falling back to backup analysis...');
      if (mounted) {
        setState(() {
          _generateLocalAISuggestion();
          _isLoadingAI = false;
        });
      }
    }
  }

  void _generateLocalAISuggestion() {
    // Get the most recent HbA1c value (dataPoints is sorted descending - newest first)
    double? currentHbA1cValue = currentValue;
    DateTime? measurementDate;

    // Check if we have data points available
    if (_dataPoints.isNotEmpty) {
      // _dataPoints.first is the most recent reading (sorted descending by date)
      currentHbA1cValue = _dataPoints.first.value;
      measurementDate = _dataPoints.first.date;

      print('📊 Backup Analysis - Most Recent HbA1C:');
      print('   Value: ${currentHbA1cValue.toStringAsFixed(1)}%');
      print('   Date: ${DateFormat('dd/MM/yyyy').format(measurementDate)}');
    }

    if (currentHbA1cValue != null && measurementDate != null) {
      String level = _getHbA1cLevelFromValue(currentHbA1cValue);
      String advice = "";

      // Format measurement date
      final dateFormat = DateFormat('dd/MM/yyyy');
      final formattedDate = dateFormat.format(measurementDate);

      // Main advice based on current level
      if (currentHbA1cValue <= 6.5) {
        advice =
            "cho thấy kiểm soát đường huyết lý tưởng và không có dấu hiệu tiểu đường. Chỉ số này rất tốt! Hãy tiếp tục duy trì lối sống lành mạnh với chế độ ăn cân bằng và tập thể dục đều đặn.";
      } else if (currentHbA1cValue <= 7.0) {
        advice =
            "cho thấy việc kiểm soát đường huyết đang ở mức tốt, tuy nhiên có nguy cơ tiền tiểu đường thấp. Hãy tiếp tục duy trì chế độ ăn uống lành mạnh và tập luyện thể dục đều đặn.";
      } else if (currentHbA1cValue <= 8.0) {
        advice =
            "cho thấy chỉ số đang ở mức cao, có nguy cơ tiểu đường. Bạn cần cải thiện lối sống và chế độ ăn uống. Hãy tham khảo ý kiến bác sĩ để được hướng dẫn điều chỉnh phù hợp.";
      } else {
        advice =
            "cho thấy chỉ số đang ở mức rất cao, có nguy cơ tiểu đường type 2 nghiêm trọng. Bạn cần được theo dõi và điều trị y tế ngay lập tức. Vui lòng liên hệ với bác sĩ để được tư vấn kịp thời.";
      }

      // Simple message referring to the most recent measurement
      _aiSuggestion = AiRecommendationResult(
        recommendation:
          "Chỉ số HbA1c ${currentHbA1cValue.toStringAsFixed(1)}% ($level) đo ngày $formattedDate $advice",
      );

      print('✅ Backup Analysis Generated Successfully');
    } else {
      _aiSuggestion = AiRecommendationResult(
        recommendation:
          "Chưa có dữ liệu HbA1c để phân tích. Hãy nhập chỉ số HbA1c để nhận được lời khuyên từ AI.",
      );

      print('⚠️ No HbA1C data available for backup analysis');
    }
  }

  void _doInputHbA1c() {
    showHbA1cInputMethodModal(context);
  }

  void _loadTrendData() {
    // When "Tất cả" (index 0) is selected, use takeAll = true
    bool useTakeAll = _selectedUIIndex == 0;
    // Use Input API instead of Trend API to get full data including ID
    _hbA1CBloc.add(FetchInputHbA1C(
      currentDateTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      periodFilterType: _periodFilterType,
      page: 1,
      takeAll: true,
    ));
  }

  void reloadData(int periodFilter) {
    // Store current selected point date before resetting
    if (_focusIndex >= 0 && _focusIndex < _groupedPoints.length) {
      final group = _groupedPoints[_focusIndex];
      if (_focusSubIndex < group.length) {
        _selectedPointDate = group[_focusSubIndex].date;
      }
    }

    setState(() {
      _selectedUIIndex = periodFilter; // Track UI selection
      // Map UI index to API trendType:
      // 0 (Tất cả) -> use takeAll=true with periodFilterType=3 (24 months) + size=1000
      // 1 (6 tháng) -> 1
      // 2 (12 tháng) -> 2
      // 3 (24 tháng) -> 3
      _periodFilterType = periodFilter == 0 ? 3 : periodFilter;
      _focusIndex = -1; // Temporarily reset, will be restored after data loads
      _focusSubIndex = 0;
      _isLoadingAI = false; // Reset flag to allow new AI load
      _aiSuggestion = null; // Reset suggestion to trigger reload
      // Clear data immediately to prevent flash of AI section
      _dataPoints.clear();
      _groupedPoints.clear();
      _timestamps.clear();
    });
    _loadTrendData();
    // AI will be loaded automatically after data is available (in BlocBuilder)
  }

  Future<bool> _refresh() async {
    _loadTrendData();
    return true;
  }

  // Convert InputHbA1CModel data to data points (with ID for editing)
  List<HbA1cDataPoint> _convertInputDataToDataPoints(
      List<InputHbA1CModel> apiData) {
    _dataPoints.clear();
    _timestamps.clear();
    _groupedPoints.clear();

    // Group by calendar day (local time) similar to BloodPressure behavior
    final Map<int, List<HbA1cDataPoint>> byTs = {};
    for (int i = 0; i < apiData.length; i++) {
      final item = apiData[i];
      if (item.hbA1C != null && item.date != null) {
        // Parse timestamp as local time (consistent with other modules)
        final date = DateTime.fromMillisecondsSinceEpoch(item.date! * 1000);
        final value = item.hbA1C!;
        final level = _getHbA1cLevelFromValue(value);
        final color = _getHbA1cColorFromValue(value);

        final timeOfDay = DateFormat('HH:mm').format(date);

        final dp = HbA1cDataPoint(
          date: date,
          value: value,
          level: level,
          color: color,
          timeOfDay: timeOfDay,
          id: item.id, // Keep as String to match InputHbA1CModel
        );
        final dayKey =
            DateTime(date.year, date.month, date.day).millisecondsSinceEpoch ~/
                1000;
        byTs.putIfAbsent(dayKey, () => []).add(dp);
        _dataPoints.add(dp);
      }
    }

    // Sort day keys ascending and normalize group ordering by time-of-day ascending
    final sortedTs = byTs.keys.toList()..sort();
    _timestamps = sortedTs;
    for (final ts in sortedTs) {
      final group = byTs[ts]!;
      group.sort((a, b) => a.date.compareTo(b.date));
      _groupedPoints.add(group);
    }

    _applyTimeRangeFilter();

    // IMPORTANT: Sort _dataPoints by date DESCENDING (newest first) for correct analysis
    _dataPoints.sort((a, b) => b.date.compareTo(a.date));

    // Debug: Print grouped data for verification (commented to reduce log spam)
    // print("HbA1C Grouped Data:");
    // for (int i = 0; i < _groupedPoints.length; i++) {
    //   final group = _groupedPoints[i];
    //   print("Day $i: ${group.length} readings");
    //   for (int j = 0; j < group.length; j++) {
    //     print("  Reading $j: ${group[j].value}% at ${group[j].timeOfDay}");
    //   }
    // }

    // Focus most recent group by default
    if (_groupedPoints.isNotEmpty) {
      _focusIndex = _focusIndex == -1
          ? _groupedPoints.length - 1
          : _focusIndex.clamp(0, _groupedPoints.length - 1);
      _focusSubIndex =
          _focusSubIndex.clamp(0, _groupedPoints[_focusIndex].length - 1);
      if (_selectedPointDate == null) {
        _updateSelectedPointDateFromFocus();
      }
      // Don't load AI here - it's loaded in reloadData() to prevent infinite loops
    } else {
      _focusIndex = -1;
      _focusSubIndex = 0;
    }

    return _dataPoints;
  }

  void _setFocusToLatest() {
    if (_groupedPoints.isEmpty) {
      _focusIndex = -1;
      _focusSubIndex = 0;
      _selectedPointDate = null;
      return;
    }

    _focusIndex = _groupedPoints.length - 1;
    _focusSubIndex = 0;
    _updateSelectedPointDateFromFocus();
  }

  int? _getMonthsForSelectedRange() {
    switch (_selectedUIIndex) {
      case 1:
        return 6;
      case 2:
        return 12;
      case 3:
        return 24;
      default:
        return null;
    }
  }

  DateTime _calculateCutoffUtc(int months) {
    final DateTime nowUtc = DateTime.now().toUtc();
    final int totalMonths = nowUtc.year * 12 + (nowUtc.month - 1) - months;
    final int cutoffYear = totalMonths ~/ 12;
    final int cutoffMonth = totalMonths % 12 + 1;
    final int maxDayOfTargetMonth =
        DateTime.utc(cutoffYear, cutoffMonth + 1, 0).day;
    final int cutoffDay = min(nowUtc.day, maxDayOfTargetMonth);
    return DateTime.utc(cutoffYear, cutoffMonth, cutoffDay);
  }

  void _applyTimeRangeFilter() {
    final months = _getMonthsForSelectedRange();
    if (months == null || _groupedPoints.isEmpty) {
      return;
    }

    final DateTime cutoff = _calculateCutoffUtc(months);

    final List<List<HbA1cDataPoint>> filteredGroups = [];
    final List<int> filteredTimestamps = [];
    for (int i = 0; i < _groupedPoints.length; i++) {
      final group = _groupedPoints[i];
      if (group.isEmpty) continue;
      final DateTime dayDate = group.last.date;
      if (!dayDate.isBefore(cutoff)) {
        filteredGroups.add(group);
        filteredTimestamps.add(_timestamps[i]);
      }
    }

    final List<HbA1cDataPoint> filteredDataPoints =
        _dataPoints.where((dp) => !dp.date.isBefore(cutoff)).toList();

    _groupedPoints
      ..clear()
      ..addAll(filteredGroups);
    _timestamps
      ..clear()
      ..addAll(filteredTimestamps);
    _dataPoints
      ..clear()
      ..addAll(filteredDataPoints);
  }

  void _updateSelectedPointDateFromFocus() {
    if (_focusIndex >= 0 && _focusIndex < _groupedPoints.length) {
      final group = _groupedPoints[_focusIndex];
      if (_focusSubIndex >= 0 && _focusSubIndex < group.length) {
        _selectedPointDate = group[_focusSubIndex].date;
      }
    }
  }

  String _getHbA1cLevelFromValue(double value) {
    // Match the visual range bar display as requested:
    // 6.5 shows in Lý tưởng, 7.0 shows in Tốt, 8.0 shows in Cao
    if (value <= 6.5) return 'Lý tưởng';
    if (value <= 7.0) return 'Tốt';
    if (value <= 8.0) return 'Cao';
    return 'Rất cao';
  }

  Color _getHbA1cColorFromValue(double value) {
    // Match the visual range bar display as requested:
    // 6.5 shows in Lý tưởng, 7.0 shows in Tốt, 8.0 shows in Cao
    if (value <= 6.5) {
      // Lý tưởng - Light Green
      return const Color(0xFF64E18E); // #64E18E
    } else if (value <= 7.0) {
      // Tốt - Green
      return const Color(0xFF23C559); // #23C559
    } else if (value <= 8.0) {
      // Cao - Light Red
      return const Color(0xFFF86F6F); // #F86F6F
    } else {
      // Rất cao - Dark Red
      return const Color(0xFFD02424); // #D02424
    }
  }

  String _getEmptyStateText() {
    switch (_selectedUIIndex) {
      case 0: // Tất cả
        return 'Chưa có dữ liệu HbA1c\nHãy nhập chỉ số để theo dõi';
      case 1: // 6 tháng
        return 'Không có dữ liệu\ntrong 6 tháng gần nhất';
      case 2: // 12 tháng
        return 'Không có dữ liệu\ntrong 12 tháng gần nhất';
      case 3: // 24 tháng
        return 'Không có dữ liệu\ntrong 24 tháng gần nhất';
      default:
        return 'Chưa có dữ liệu HbA1c\nHãy nhập chỉ số để theo dõi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HbA1CBloc>.value(
      value: _hbA1CBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFEAF9F7),
        resizeToAvoidBottomInset: true,
        appBar: _buildAppBar(),
        body: BlocBuilder<HbA1CBloc, HbA1CState>(
          builder: (BuildContext context, HbA1CState state) {
            currentContext = context;

            // Handle different states
            if (state is HbA1CInitial) {
              _loadTrendData();
            }

            if (state is HbA1CError) {
              Message.showToastMessage(context, state.message);
            }

            if (state is HbA1CDetailLoaded) {
              final inputData = state.inputHbA1CModel;
              _convertInputDataToDataPoints(inputData);

              // Try to restore selected point after data conversion
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _restoreSelectedPoint();
                });
              });

              // Load AI suggestion after data is available (only if not already loading)
              if (!_isLoadingAI && _aiSuggestion == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _loadAITrend();
                });
              }
            }

            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFEAF9F7),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildFilter(),
                  const SizedBox(height: 8),
                  // Main Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          _buildCombinedMainSection(state),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: _buildKnowledgeSection(),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),

                  // Sticky bottom buttons
                  Container(
                    padding: EdgeInsets.only(
                      bottom: 16 + MediaQuery.of(context).padding.bottom / 2,
                      left: 12,
                      right: 12,
                      top: 16,
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Row(
                        children: [
                          // Detail button
                          Container(
                            constraints: BoxConstraints(minWidth: 60),
                            child: Stack(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    // Đánh dấu đã xem chi tiết
                                    await AppStorages.setHbA1CDetailViewed();
                                    setState(() {
                                      _isDetailViewed = true;
                                    });

                                    Navigator.pushNamed(context,
                                        NavigatorName.hba1c_detail_page,
                                        arguments: {
                                          'initPeriodFilterType':
                                              _selectedUIIndex,
                                        });
                                  },
                                  child: Container(
                                    height: 48,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Color(0xffDCFFFC),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Image.asset(
                                            R.drawable.im_hba1c_detail,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (_dataPoints.isNotEmpty && !_isDetailViewed)
                                  Positioned(
                                    left: 45,
                                    bottom: 32,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFAF0000),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Input button
                          Expanded(
                            child: InkWell(
                              onTap: _doInputHbA1c,
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      R.color.greenGradientTop,
                                      R.color.greenGradientBottom,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Center(
                                  child: Text(
                                    'Nhập HbA1c',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: R.font.sfpro,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: R.color.greenGradientBottom,
      titleSpacing: 8,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(Icons.arrow_back, color: R.color.white),
      ),
      centerTitle: false,
      title: Text(
        R.string.hba1c.tr(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: R.color.white,
          fontFamily: R.font.sfpro,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, NavigatorName.hba1c_intro_2nd_page);
            },
            child: Text(
              R.string.huong_dan.tr(),
              style: TextStyle(
                  fontSize: 15,
                  color: R.color.white,
                  fontFamily: R.font.sfpro,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilter() {
    final List<String> labels = [
      R.string.all.tr(),
      '6 ${R.string.month.tr()}',
      '12 ${R.string.month.tr()}',
      '24 ${R.string.month.tr()}',
    ];
    final List<int> values = [0, 1, 2, 3];
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 0, bottom: 0),
      child: HorizontalSelector(
        onSelected: (value) {
          reloadData(value);
        },
        initialValue: _selectedUIIndex, // Use tracked UI selection
        values: values,
        labels: labels,
        fontSize: 15,
      ),
    );
  }

  Widget _buildTrendingChart(HbA1CState state) {
    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildChartContent(state),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCombinedMainSection(HbA1CState state) {
    // Don't show AI section when loading or when no data
    final bool shouldShowAI = !(state is HbA1CLoading) &&
        _dataPoints.isNotEmpty &&
        _groupedPoints.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFEAF9F7),
            Color(0xFFFFFFFF),
          ],
          stops: [0.05, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            const SizedBox(height: 0),
            _buildChartContent(state),
            if (shouldShowAI) ...[
              const SizedBox(height: 8),
              Divider(height: 1, color: R.color.color0xffE5E5E5),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _buildAIHelpInner(_aiSuggestion),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChartContent(HbA1CState state) {
    // Show loading indicator while fetching data
    if (state is HbA1CLoading) {
      return Container(
        height: 240,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show empty state when no data
    if (_dataPoints.isEmpty) {
      return _buildEmptyHbA1cState();
    }

    // Resolve focused data point from grouped structure
    HbA1cDataPoint currentDataPoint;
    if (_focusIndex >= 0 && _focusIndex < _groupedPoints.length) {
      final group = _groupedPoints[_focusIndex];
      final sub = _focusSubIndex.clamp(0, group.length - 1);
      currentDataPoint = group[sub];
    } else {
      // Fallback to the latest group first item
      currentDataPoint = _groupedPoints.last.first;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Date and time display with navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              constraints: BoxConstraints(
                minHeight: 38,
              ),
              decoration: BoxDecoration(
                color: R.color.white,
                borderRadius: BorderRadius.circular(19),
                border: Border.all(color: R.color.color0xffE5E5E5, width: 1),
              ),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        currentDataPoint.timeOfDay,
                        style: TextStyle(
                          fontFamily: R.font.sfpro,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF636A6B),
                          height: 1.46,
                          letterSpacing: 0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 3,
                      height: 3,
                      margin: EdgeInsets.only(left: 3, right: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFBFC6C6),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "${currentDataPoint.date.day.toString().padLeft(2, '0')}/${currentDataPoint.date.month.toString().padLeft(2, '0')}",
                        style: TextStyle(
                          fontFamily: R.font.sfpro,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF636A6B),
                          height: 1.46,
                          letterSpacing: 0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Reading counter for multiple readings same day
                    if (_focusIndex >= 0 &&
                        _focusIndex < _groupedPoints.length &&
                        _groupedPoints[_focusIndex].length > 1) ...[
                      Container(
                        width: 3,
                        height: 3,
                        margin: EdgeInsets.only(left: 3, right: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFBFC6C6),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "${_focusSubIndex + 1}/${_groupedPoints[_focusIndex].length}",
                          style: TextStyle(
                            fontFamily: R.font.sfpro,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(
                                0xFF008479), // Highlight color for reading counter
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Navigation controls
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Remove space between buttons
            // const SizedBox(width: 12),
            // Previous button
            InkWell(
              onTap: _focusIndex > 0
                  ? () {
                      setState(() {
                        _focusIndex = max(0, _focusIndex - 1);
                        _focusSubIndex = 0;
                        _updateSelectedPointDateFromFocus();
                      });
                    }
                  : null,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
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
            // HbA1c value and level display (tap to cycle within same timestamp if multiple, or navigate to update if single)
            GestureDetector(
              onTap: () {
                if (_focusIndex >= 0 && _focusIndex < _groupedPoints.length) {
                  final len = _groupedPoints[_focusIndex].length;
                  if (len > 1) {
                    // Multiple points in same timestamp - cycle through them
                    setState(() {
                      _focusSubIndex = (_focusSubIndex + 1) % len;
                      _updateSelectedPointDateFromFocus();
                    });
                  } else {
                    // Single point - navigate to update page
                    if (currentDataPoint.id != null &&
                        currentDataPoint.id!.isNotEmpty) {
                      Navigator.pushNamed(
                        context,
                        NavigatorName.add_hba1c,
                        arguments: {
                          'type': 'update',
                          'id': currentDataPoint.id,
                        },
                      );
                    }
                  }
                }
              },
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: 200),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      currentDataPoint.level,
                      style: TextStyle(
                        fontFamily: R.font.sfpro,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: currentDataPoint.color,
                        height: 36 / 24,
                      ),
                    ),
                    Text(
                      "${currentDataPoint.value.toStringAsFixed(1)}%",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: R.font.sfpro,
                        fontSize: 14,
                        height: 1.46,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.w400,
                        color: R.color.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Next button
            InkWell(
              onTap: _focusIndex < _groupedPoints.length - 1
                  ? () {
                      setState(() {
                        final lastIndex = _groupedPoints.length - 1;
                        _focusIndex = min(lastIndex, _focusIndex + 1);
                        _focusSubIndex = 0;
                        _updateSelectedPointDateFromFocus();
                      });
                    }
                  : null,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: _focusIndex < _groupedPoints.length - 1
                      ? R.color.textDark
                      : R.color.color0xffE5E5E5,
                ),
              ),
            ),
            // Remove space between buttons
            // const SizedBox(width: 12),
          ],
        ),
        const SizedBox(height: 16),
        _buildChart(),
      ],
    );
  }

  Widget _buildChart() {
    return HbA1cTrendChart(
      groupedPoints: _groupedPoints,
      dataPoints: _dataPoints,
      focusIndex: _focusIndex,
      focusSubIndex: _focusSubIndex,
      onPointSelected: (flatIndex) {
        _convertFlatIndexToGroupIndex(flatIndex);
      },
      onPointDoubleTapped: (flatIndex) {
        _handlePointDoubleTap(flatIndex);
      },
    );
  }

  // Convert flat index back to group index and sub index
  void _convertFlatIndexToGroupIndex(int flatIndex) {
    int currentFlatIndex = 0;
    for (int dayIndex = 0; dayIndex < _groupedPoints.length; dayIndex++) {
      final group = _groupedPoints[dayIndex];
      for (int subIndex = 0; subIndex < group.length; subIndex++) {
        if (currentFlatIndex == flatIndex) {
          setState(() {
            _focusIndex = dayIndex;
            _focusSubIndex = subIndex;
            // Update selected point date when user manually selects a point
            _selectedPointDate = group[subIndex].date;
          });
          return;
        }
        currentFlatIndex++;
      }
    }
  }

  // Handle double tap on a point to navigate to edit screen
  void _handlePointDoubleTap(int flatIndex) {
    // Convert flat index to actual data point to get the ID
    int currentFlatIndex = 0;
    for (int dayIndex = 0; dayIndex < _groupedPoints.length; dayIndex++) {
      final group = _groupedPoints[dayIndex];
      for (int subIndex = 0; subIndex < group.length; subIndex++) {
        if (currentFlatIndex == flatIndex) {
          final dataPoint = group[subIndex];

          // Navigate to edit screen with the point's data
          if (dataPoint.id != null) {
            Navigator.pushNamed(
              context,
              NavigatorName.add_hba1c,
              arguments: {
                'type': 'update',
                'id': dataPoint.id,
              },
            );
          }
          return;
        }
        currentFlatIndex++;
      }
    }
  }

  // Restore previously selected point when data is reloaded
  void _restoreSelectedPoint() {
    if (_selectedPointDate == null || _groupedPoints.isEmpty) {
      return;
    }

    // Find the point with matching date in the new data
    for (int dayIndex = 0; dayIndex < _groupedPoints.length; dayIndex++) {
      final group = _groupedPoints[dayIndex];
      for (int subIndex = 0; subIndex < group.length; subIndex++) {
        final point = group[subIndex];
        // Compare dates (ignoring milliseconds for robustness)
        if (point.date.year == _selectedPointDate!.year &&
            point.date.month == _selectedPointDate!.month &&
            point.date.day == _selectedPointDate!.day &&
            point.date.hour == _selectedPointDate!.hour &&
            point.date.minute == _selectedPointDate!.minute) {
          // Found the matching point, restore selection
          _focusIndex = dayIndex;
          _focusSubIndex = subIndex;
          _selectedPointDate = point.date;
          return;
        }
      }
    }

    // If point not found in new data, reset selection
    _selectedPointDate = null;
    _setFocusToLatest();
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontFamily: R.font.sfpro,
          ),
        ),
      ],
    );
  }

  Widget _sectionAIHelp(AiRecommendationResult? aiSuggestion) {
    return _buildAIHelpInner(aiSuggestion);
  }

  Widget _buildAIHelpInner(AiRecommendationResult? aiSuggestion) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // AI result
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            MediaQuery(
              data: MediaQuery.of(context).copyWith(
                  textScaler: MediaQuery.of(context)
                      .textScaler
                      .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3)),
              child: Text(
                R.string.ai_suggestion_glucose.tr(),
                style: TextStyle(
                  fontFamily: R.font.sfpro,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: R.color.textDark,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Image.asset(R.drawable.ic_info, width: 18, height: 18),
          ],
        ),
        const SizedBox(height: 8),
        if (aiSuggestion == null)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: AILoadingTextWidget(),
          )
        else if (aiSuggestion.recommendation.isEmpty)
          Text(
            'Có lỗi xảy ra',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color(0xFFC82221),
              fontFamily: R.font.sfpro,
            ),
          )
        else ...[
          Text(
            textAlign: TextAlign.justify,
            aiSuggestion.recommendation,
            style: TextStyle(
              fontFamily: R.font.sfpro,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: R.color.primaryGreyColor,
              height: 1.46,
              letterSpacing: 0.2,
            ),
          ),
          AiReferencesWidget(references: aiSuggestion.references),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFFFC),
              borderRadius: BorderRadius.circular(999),
            ),
            child: TextButton(
              onPressed: () {
                // Navigate to AI health assistant
                Navigator.pushNamed(
                    context, NavigatorName.conversation_chatbot_ai);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                backgroundColor: const Color(0xFFDCFFFC),
                foregroundColor: const Color(0xFF008479),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Trò chuyện cùng Trợ lý Sống khỏe",
                    style: TextStyle(
                      fontFamily: R.font.sfpro,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF008479),
                      height: 1.46,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    color: Color(0xFF008479),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildKnowledgeSection() {
    return const HbA1cKnowledgeSection();
  }

  Widget _buildEmptyHbA1cState() {
    return Container(
      height: 240,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Navigation arrows and text section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left arrow
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.chevron_left,
                  size: 20,
                  color: R.color.color0xffE5E5E5,
                ),
              ),
              // Text content
              Expanded(
                child: Text(
                  _getEmptyStateText(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: R.color.textDark,
                    fontFamily: R.font.sfpro,
                    height: 1.46,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              // Right arrow
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: R.color.color0xffE5E5E5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildEmptyChartPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildEmptyChartPlaceholder() {
    return SizedBox(
      height: 97,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 97,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Spacer(),
                  Text(
                    '6.5%',
                    style: TextStyle(
                      color: R.color.black,
                      fontSize: 12,
                      fontFamily: R.font.sfpro,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: 97,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: CustomPaint(
                  painter: _DashedHorizontalLinePainter(
                    lineColor: const Color(0xFF636A6B),
                    dashWidth: 8,
                    dashGap: 4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedHorizontalLinePainter extends CustomPainter {
  final Color lineColor;
  final double dashWidth;
  final double dashGap;

  _DashedHorizontalLinePainter({
    required this.lineColor,
    this.dashWidth = 3,
    this.dashGap = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final double y = size.height / 2;
    double startX = 0;
    while (startX < size.width) {
      final double endX = min(startX + dashWidth, size.width);
      canvas.drawLine(Offset(startX, y), Offset(endX, y), linePaint);
      startX += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
