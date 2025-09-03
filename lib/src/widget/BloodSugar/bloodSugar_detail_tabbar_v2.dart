import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_tracking/activity_list_tracking.dart';
import 'package:medical/src/app_setting/firebase_tracking/kpi_glycemic_tracking.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/components/custom_action_descriptipn.dart';
import 'package:medical/src/widget/glucose_intro/widgets/glucose_lesson_section.dart';
import 'package:medical/src/widget/home/fliter_enum.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail_page.dart';
import 'package:medical/src/widget/BloodPressure/widget/horizontal_selector.dart'; // Add this import

import '../../app_setting/app_setting.dart';
import 'constant/bloodSugar_rangetype.dart';
import 'widget/bloodSugar_chart.dart';
import 'widget/bloodSugar_compare_chart.dart';
import 'widget/bloodSugar_contain_detail.dart';
import 'widget/ai_loading_text_widget.dart';
import 'widget/aihelp_butotn.dart';

class BloodSugarDetailTabbarController extends StatefulWidget {
  final Map<dynamic, dynamic>? data;
  BloodSugarDetailTabbarController({this.data});
  @override
  _BloodSugarDetailTabbarControllerState createState() =>
      _BloodSugarDetailTabbarControllerState();

  static _BloodSugarDetailTabbarControllerState? of(BuildContext context) {
    final _BloodSugarDetailTabbarControllerState? navigator = context
        .findAncestorStateOfType<_BloodSugarDetailTabbarControllerState>();
    return navigator;
  }
}

class _BloodSugarDetailTabbarControllerState
    extends State<BloodSugarDetailTabbarController>
    with SingleTickerProviderStateMixin, Observer {
  final GlobalKey<CustomActionDescriptionState> customActionDesKey =
      GlobalKey();

  final GlobalKey<BloodSugarDetailState> sugarDetailKey = GlobalKey();
  final GlobalKey<BloodSugarChartState> sugarChartKey = GlobalKey();
  final GlobalKey<BloodSugarCompareChartState> sugarCompareKey = GlobalKey();

  int periodFilterType = 3; // Default to 30 days
  late String name = R.string.filter_day.tr(args: ['30']);
  String? glucoseID;
  String? _aiSuggestion;
  BloodSugarRangeType? _rangeType;

  bool _haveGlucoseScheduler = false;

  @override
  void initState() {
    _checkGlucoseScheduler();
    super.initState();
    // _initPeriodFilterType();
    Observable.instance.addObserver(this);
    KpiGlycemicTracking.firebaseSetup();
    _reload();
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'glucose_change_data' ||
        notifyName == 'glucose_data_refresh') {
      _doReloadData(periodFilterType);
    }
  }

  @override
  void dispose() async {
    Observable.instance.removeObserver(this);
    AppSettings.syncDataFromHealthApp();
    super.dispose();
  }

  _initPeriodFilterType() async {
    final filterList = await AppSettings.getHomeFilters();
    name = filterList.elementAtOrNull(ScreenList.BLOOD_SUGAR.index) ??
        R.string.filter_day.tr(args: ['30']);
    final periodFilterTypeStr =
        await AppSettings.getPeriodByScreen(ScreenList.BLOOD_SUGAR.index);
    periodFilterType = int.tryParse(periodFilterTypeStr) ?? 3;
  }

  void _checkGlucoseScheduler() async {
    _haveGlucoseScheduler =
        await GlucoseClient().checkGlucoseSchedulerExisting();
    if (mounted && _haveGlucoseScheduler) {
      setState(() {});
    }
  }

  void _viewListing() {
    Navigator.pushNamed(context, NavigatorName.detail_blood_sugar_listing,
        arguments: {
          'glucoseID': glucoseID,
          'initPeriodFilterType': periodFilterType
        });
  }

  void _viewFilteredListing(BloodSugarRangeType rangeType) {
    Navigator.pushNamed(context, NavigatorName.detail_blood_sugar_listing,
        arguments: {
          'glucoseID': glucoseID,
          'glucoseDistributionType': rangeType.value,
          'initPeriodFilterType': periodFilterType,
        });
  }

  void _doReloadData(int periodFilterType) {
    sugarChartKey.currentState?.reloadData(periodFilterType);
    sugarDetailKey.currentState?.reloadData(periodFilterType);
    sugarCompareKey.currentState?.reloadData(periodFilterType);
  }

  void _reload([bool isNew = false]) async {
    _doReloadData(periodFilterType);
    await _loadAITrend();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadAITrend() async {
    // Add AI suggestion loading logic here if available
    // This should match the blood pressure implementation
    try {
      // Replace with actual glucose AI analysis call
      // final glucoseInputAIAnalysis = await GlucoseClient().fetchGlucoseAlltimeAnalysis(periodFilterType);
      // if (glucoseInputAIAnalysis != null) {
      //   _aiSuggestion = glucoseInputAIAnalysis;
      // }
    } catch (e) {
      debugPrint('Error loading AI trend: $e');
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

  void loadInputWithId(int index, String? id) {
    glucoseID = id;
  }

  void _doInputGlucose() async {
    Navigator.of(context).pushNamed(NavigatorName.add_blood_sugar_new,
        arguments: {'type': 'input'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.glucose_bg_color,
      appBar: AppBar(
        backgroundColor: R.color.greenGradientBottom,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: R.color.white),
        ),
        leadingWidth: 30,
        centerTitle: false,
        title: Text(
          R.string.duong_huyet.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: R.color.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(NavigatorName.glucose_intro_2nd_page);
              },
              child: Text(
                R.string.huong_dan.tr(),
                style: TextStyle(fontSize: 15, color: R.color.white),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildFilter(),
          const SizedBox(height: 8),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  _buildTrendingChart(),
                  const SizedBox(height: 12),
                  _sectionAIHelp(_aiSuggestion),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildFrequencyChart(),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildCompareChart(),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _buildSuggestLessons(),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _buildCreateScheduleButton(),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Sticky bottom button
          Container(
            padding: EdgeInsets.only(
              bottom: 8 + MediaQuery.of(context).padding.bottom / 2,
              left: 12,
              right: 12,
              top: 8,
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: _doInputGlucose,
                child: Container(
                  height: 48,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: R.color.accentColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      R.string.blood_sugar_input.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
    final int selectedIndex = periodFilterType - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: HorizontalSelector(
        onSelected: (value) {
          setState(() {
            periodFilterType = value + 1;
            final labels = [
              R.string.filter_day.tr(args: ['7']),
              R.string.filter_day.tr(args: ['14']),
              R.string.filter_day.tr(args: ['30']),
              R.string.filter_day.tr(args: ['90']),
            ];
            name = labels[value];
          });
          _reload();
        },
        initialValue: selectedIndex,
        values: values,
        labels: labels,
      ),
    );
  }

  Widget _buildTrendingChart() {
    return BloodSugarChart(
      key: sugarChartKey,
      periodFilterType: periodFilterType,
      filterName: name,
      onFilterChanged: (selectedIndex) {},
      onViewListing: _viewListing,
      bloodSugarChartCallback: (rangeType, aiSuggestion) {
        if (!mounted) return;
        if (rangeType == _rangeType && aiSuggestion == _aiSuggestion) return;
        setState(() {
          _rangeType = rangeType;
          _aiSuggestion = aiSuggestion;
        });
      },
    );
  }

  Widget _buildFrequencyChart() {
    return BloodSugarDetail(
      key: sugarDetailKey,
      periodFilterType: periodFilterType,
      onViewMore: _viewListing,
      onViewDetail: _viewFilteredListing,
    );
  }

  Widget _buildCompareChart() {
    return BloodSugarCompareChart(
      key: sugarCompareKey,
      periodFilterType: periodFilterType,
      onViewDetail: _viewListing,
    );
  }

  Widget _buildSuggestLessons() {
    return GlucoseLessonSection(
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

  Widget _buildCreateScheduleButton() {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(NavigatorName.schedule_glucose);
      },
      child: Container(
        height: 76,
        width: double.infinity,
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: R.color.gray_btn),
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            const SizedBox(width: 17),
            Image.asset(R.drawable.ic_glucose_create_scheduler,
                width: 39, height: 41),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _haveGlucoseScheduler
                    ? 'Lịch đo đường huyết của bạn'
                    : 'Gợi ý lịch đo từ chuyên gia',
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: R.color.primaryGreyColor, size: 20),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
