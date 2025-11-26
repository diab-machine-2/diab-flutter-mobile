import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/firebase_tracking/activity_list_tracking.dart';
import 'package:medical/src/repo/blood_pressure/bloodPressure_client.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/widget/BloodPressure/widget/horizontal_selector.dart';
import 'package:medical/src/widget/BloodSugar/widget/ai_loading_text_widget.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail.dart';
import 'package:medical/src/widgets/background_page.dart';

import 'bloodpressure_result.dto.dart';
import 'intro/widgets/bloodpresure_lesson_section.dart';
import 'widget/aihelp_button.dart';
import 'widget/bloodPressure_chart.dart';
import 'widget/bloodpressure_distribution_chart_v2.dart';

class BloodPressureDetailTabbarController extends StatefulWidget {
  @override
  _BloodPressureDetailTabbarControllerState createState() =>
      _BloodPressureDetailTabbarControllerState();

  static _BloodPressureDetailTabbarControllerState? of(BuildContext context) {
    final _BloodPressureDetailTabbarControllerState? navigator = context
        .findAncestorStateOfType<_BloodPressureDetailTabbarControllerState>();
    return navigator;
  }
}

class _BloodPressureDetailTabbarControllerState
    extends State<BloodPressureDetailTabbarController>
    with SingleTickerProviderStateMixin, Observer {
  // TabController? _tabController;

  final GlobalKey<BloodPressureDistributionChartState>
      _bloodPressureDistributionChartKey = GlobalKey();
  final GlobalKey<BloodPressureChartState> _bloodPressureTrendKey = GlobalKey();

  int _periodFilterType = 3;
  String? _aiSuggestion;
  bool _isDetailViewed =
      false; // Track if user has viewed Blood Pressure detail page
  bool _isFirstLoad =
      true; // Track if this is the first load when entering dashboard

  BloodPressureRangeType _rangeType = BloodPressureRangeType.normal;

  @override
  void initState() {
    super.initState();
    // _tabController = new TabController(vsync: this, length: 2);
    Observable.instance.addObserver(this);
    _loadDetailViewedState();
    // Pass isNew = true on first load to ensure chart focuses on latest point
    _reload(true);
  }

  Future<void> _loadDetailViewedState() async {
    _isDetailViewed = await AppStorages.isBloodPressureDetailViewed();
    if (mounted) {
      setState(() {});
    }
  }

  // DartNotificationCenter.subscribe(
  //     channel: 'BloodPressure_change_data',
  //     observer: this,
  //     onNotification: (_) {
  //       overViewKey.currentState!.reloadData(periodFilterType);
  //       detailKey.currentState!.reloadData(periodFilterType);
  //     });

  // _tabController!.addListener(() {
  //   if (_tabController!.indexIsChanging) {
  //     if (_tabController!.index == 1) {
  //       KpiBloodPressureTracking.clickDetailTab();
  //       print("tracking KpiBloodPressureTracking.clickDetailTab()");
  //     }
  //   }
  // });

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'BloodPressure_change_data') {
      bool isForce = map?['isNew'] == true;
      _reload(isForce);
    }
  }

  static bool _isDisposing = false;

  @override
  void dispose() {
    if (_isDisposing) {
      // Already disposing, ensure super.dispose() is still called
      super.dispose();
      return;
    }
    _isDisposing = true;
    try {
      Observable.instance.removeObserver(this);
      // Fire-and-forget async operation - don't await in dispose()
      AppSettings.syncDataFromHealthApp().catchError((error) {
        // Silently handle errors in background operation
      });
    } catch (e) {
      // Handle any synchronous errors
    } finally {
      _isDisposing = false;
      super.dispose();
    }
  }

  void _viewListing() async {
    // Đánh dấu đã xem chi tiết
    await AppStorages.setBloodPressureDetailViewed();
    setState(() {
      _isDetailViewed = true;
    });

    Navigator.pushNamed(context, NavigatorName.detail_bloodpressure_listing,
        arguments: {'initPeriodFilterType': _periodFilterType});
  }

  void _viewFilteredListing(
      BloodPressureRangeType rangeType, String? bloodPressureID) {
    Navigator.pushNamed(context, NavigatorName.detail_bloodpressure_listing,
        arguments: {
          'initBloodPressureID': bloodPressureID,
          'initBloodPressureRangeType': rangeType.value,
          'initPeriodFilterType': _periodFilterType,
        });
  }

  Future<void> _loadAITrend() async {
    final bloodPressureInputAIAnalysis = await BloodPressureClient()
        .fetchBloodPressureAlltimeAnalysis(_periodFilterType);
    if (bloodPressureInputAIAnalysis != null) {
      _aiSuggestion = bloodPressureInputAIAnalysis;
    }
  }

  void _reload([bool isNew = false]) async {
    // On first load, always pass isNew = true to ensure chart focuses on latest point
    final bool shouldReset = isNew || _isFirstLoad;
    if (_isFirstLoad) {
      _isFirstLoad = false;
    }

    _bloodPressureTrendKey.currentState
        ?.reloadData(_periodFilterType, shouldReset);
    _bloodPressureDistributionChartKey.currentState
        ?.reloadData(_periodFilterType);
    await _loadAITrend();
    if (mounted) {
      setState(() {});
    }
  }

  void _navigateToLessonDetail(String id, int type) async {
    ActivityListTracking.clickLessonItem(
      objectId: id,
      objectIndex: null,
      objectTitle: null,
    );

    await NavigationUtil.navigatePage(
      context,
      LessonDetailPage(
        lessonType: type,
        lessonId: id,
        onComplete: (_, __) {},
      ),
    );
  }

  void _doInputBloodPressure() {
    Navigator.pushNamed(context, NavigatorName.add_blood_pressure,
        arguments: {'type': 'input', 'id': null});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.glucose_bg_color,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: R.color.greenGradientBottom,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: R.color.white),
        ),
        leadingWidth: 30,
        centerTitle: false,
        title: Text(
          R.string.huyet_ap.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: R.font.sfpro,
            color: R.color.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(NavigatorName.blood_pressure_intro_2nd_page);
              },
              child: Text(
                R.string.huong_dan.tr(),
                style: TextStyle(
                    fontSize: 15,
                    color: R.color.white,
                    fontFamily: R.font.sfpro),
              ),
            ),
          ),
        ],
      ),
      body: BackgroundPage(
        background: R.drawable.bg_bloodpressure,
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
                    _buildTrendingChart(),
                    const SizedBox(height: 12),
                    _sectionAIHelp(_aiSuggestion),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: _buildFrequencyChart(),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _buildSuggestLessons(),
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
                      width: 60,
                      height: 44,
                      child: Stack(
                        children: [
                          InkWell(
                            onTap: _viewListing,
                            child: Container(
                              width: 60,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Color(0xffDCFFFC),
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Image.asset(
                                    R.drawable.ic_view_detail,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Show dot indicator if detail hasn't been viewed
                          if (!_isDetailViewed)
                            Positioned(
                              left: 44,
                              top: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Color(0xFFAF0000),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                  ),
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
                        onTap: _doInputBloodPressure,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                R.color.greenGradientTop,
                                R.color.greenGradientBottom,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              "Nhập huyết áp",
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
      ),
    );
  }

  Widget _buildFilter() {
    final List<String> labels = [
      R.string.filter_day.tr(args: ['7']),
      R.string.filter_day.tr(args: ['14']),
      R.string.filter_day.tr(args: ['30']),
      R.string.filter_day.tr(args: ['90']),
    ];
    final List<int> values = [0, 1, 2, 3];
    final int selectedIndex = _periodFilterType - 1;
    return HorizontalSelector(
      onSelected: (value) {
        _periodFilterType = value + 1;
        // When period filter changes, pass isNew = false to keep focus index if valid
        // The chart will handle scrolling to the focused point
        _reload(false);
      },
      initialValue: selectedIndex,
      values: values,
      labels: labels,
    );
  }

  Widget _buildTrendingChart() {
    return BloodPressureChart(
      key: _bloodPressureTrendKey,
      initPeriodFilterType: _periodFilterType,
      bloodPressureChartCallback: (rangeType) {
        if (!mounted) return;
        if (rangeType == _rangeType) return;
        setState(() {
          _rangeType = rangeType;
        });
      },
    );
  }

  Widget _buildFrequencyChart() {
    return BloodPressureDistributionChart(
      key: _bloodPressureDistributionChartKey,
      periodFilterType: _periodFilterType,
      onViewMore: _viewListing,
      onViewDetail: (rangeType) => {
        _viewFilteredListing(
          rangeType,
          null,
        ),
      },
    );
  }

  Widget _buildSuggestLessons() {
    return BloodPressureLessonSection(
      onLessonTap: (lesson) => _navigateToLessonDetail(lesson.id, lesson.type),
    );
  }

  Widget _sectionAIHelp(String? aiSuggestion) {
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: R.color.textDark,
                ),
              ),
              const SizedBox(width: 6),
              Image.asset(R.drawable.ic_info, width: 18, height: 18),
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
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFFC82221),
              ),
            )
          else ...[
            Text(
              aiSuggestion,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: R.color.primaryGreyColor,
                height: 1.46,
              ),
            ),
            const SizedBox(height: 16),
            AIHelpButton(rangeType: _rangeType),
          ],
        ],
      ),
    );
  }
}
