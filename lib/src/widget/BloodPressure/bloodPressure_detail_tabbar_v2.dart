import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/firebase_tracking/activity_list_tracking.dart';
import 'package:medical/src/app_setting/firebase_tracking/kpi_blood_pressure_tracking.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodPressure/bloodPressure_detail_listing.dart';
import 'package:medical/src/widget/BloodPressure/overview.dart';
import 'package:medical/src/widget/BloodSugar/widget/ai_loading_text_widget.dart';
import 'package:medical/src/widget/home/fliter_enum.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail.dart';
import 'package:medical/src/widget/nipro/health_app/widgets/request_health_connect.dart';
import 'package:medical/src/widget/tabbar/fillter_bloodSugar_panel.dart';
import 'package:medical/src/widgets/button_widget.dart';

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
    final _BloodPressureDetailTabbarControllerState? navigator =
        context.findAncestorStateOfType<_BloodPressureDetailTabbarControllerState>();
    return navigator;
  }
}

class _BloodPressureDetailTabbarControllerState extends State<BloodPressureDetailTabbarController>
    with SingleTickerProviderStateMixin, Observer {
  // TabController? _tabController;

  final GlobalKey<BloodPressureDistributionChartState> _bloodPressureDistributionChartKey =
      GlobalKey();
  final GlobalKey<BloodPressureChartState> _bloodPressureTrendKey = GlobalKey();

  final GlobalKey<BloodPressureOverviewControllerState> _overViewKey = GlobalKey();
  final GlobalKey<BloodPressureDetailListingControllerState> _detailKey = GlobalKey();

  int _periodFilterType = 1;

  @override
  void initState() {
    super.initState();
    // _tabController = new TabController(vsync: this, length: 2);
    Observable.instance.addObserver(this);
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
  }

  @override
  void update(Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'BloodPressure_change_data') {
      _overViewKey.currentState?.reloadData(_periodFilterType);
      _detailKey.currentState?.reloadData(_periodFilterType);
    }
  }

  static bool _isDisposing = false;

  @override
  void dispose() async {
    if (_isDisposing) {
      return; // Already disposing, do nothing
    }
    _isDisposing = true;
    try {
      Observable.instance.removeObserver(this);
      // Add your await statement, it won't be executed concurrently
      await AppSettings.syncDataFromHealthApp();
    } finally {
      _isDisposing = false;
      super.dispose();
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

  void _showActionFilter(BuildContext context) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      backgroundColor: R.color.white,
      context: context,
      isScrollControlled: true,
      builder: (context) => FillterBloodPanel(
        selectedIndex: _periodFilterType,
        callback: (value, index) async {
          await AppSettings.setHomeFilters(ScreenList.BLOOD_PRESSURE.index, value);
          if (index != null) {
            setState(() {
              _periodFilterType = index + 1;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.glucose_bg_color,
      appBar: AppBar(
        // backgroundColor: R.color.glucose_bg_color,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: R.color.textDark),
        ),
        title: Text(
          R.string.huyet_ap.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: R.color.textDark,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(NavigatorName.blood_pressure_intro_2nd_page);
              },
              child: Text(
                R.string.huong_dan.tr(),
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: R.color.textDark),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main Content
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildFilter(),
                  const SizedBox(height: 12),
                  _buildTrendingChart(),
                  const SizedBox(height: 12),
                  _sectionAIHelp(null, null),
                  const SizedBox(height: 12),
                  _buildFrequencyChart(),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _buildSuggestLessons(),
                  ),
                ],
              ),
            ),
          ),

          // Sticky bottom button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: 8 + MediaQuery.of(context).padding.bottom / 2,
                left: 16,
                right: 16,
                top: 12,
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  onTap: _doInputBloodPressure,
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: R.color.accentColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        R.string.enter_blood_pressure.tr(),
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilter() {
    return Container(
      height: 36,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 42),
          SizedBox(
            width: 165,
            child: InkWell(
              onTap: () => _showActionFilter(context),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: R.color.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: R.color.color0xffE5E5E5),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '30 ngày',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: R.color.textDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: R.color.textDark,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingChart() {
    return BloodPressureChart(
      key: _bloodPressureTrendKey,
      initPeriodFilterType: _periodFilterType,
    );
  }

  Widget _buildFrequencyChart() {
    return BloodPressureDistributionChart(
      key: _bloodPressureDistributionChartKey,
      periodFilterType: _periodFilterType,
      onViewMore: () {},
      onViewDetail: (p0) => {},
    );
  }

  Widget _buildSuggestLessons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gợi ý khoá học',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: R.color.color0xff111515,
          ),
        ),
        const SizedBox(height: 12),
        BloodPressureLessonSection(
          onLessonTap: (lesson) => _navigateToLessonDetail(lesson.id, lesson.type),
        ),
      ],
    );
  }

  Widget _sectionAIHelp(String? aiSuggestion, BloodPressureRangeType? rangeType) {
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
              'Có lỗi xảy ra',
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

  void _showMaterialDialog() async {
    bool? hasHealthConnection = await AppStorages.getHealthAppPermission();
    if (hasHealthConnection == true) {
      Navigator.pushNamed(context, NavigatorName.add_blood_pressure,
          arguments: {'type': 'input', 'id': null});
    } else {
      String healthIcon =
          Platform.isIOS ? R.drawable.logo_healthkit : R.drawable.logo_healthConnect;
      String healthTitle = Platform.isIOS
          ? R.string.connect_from_Apple_Health.tr()
          : R.string.connect_from_Health_Connect.tr();
      showModalBottomSheet(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        backgroundColor: R.color.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) => Container(
          height: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          margin: EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                alignment: Alignment.center,
                decoration:
                    BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xffF2F2F2)))),
                child: Text(
                  R.string.choose_how_to_enter.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    color: R.color.textDark,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    ButtonWidget(
                      isIconSvg: false,
                      icon: healthIcon,
                      backgroundColor: Color(0xFFE4FCF3),
                      textColor: Color(0xff249B92),
                      title: healthTitle,
                      onPressed: () => RequestHealthConnect.showModal(context,
                          callback: () => Navigator.pop(context)),
                    ),
                    SizedBox(height: 15),
                    ButtonWidget(
                      icon: R.icons.ic_tap,
                      backgroundColor: Color(0xFFE4FCF3),
                      textColor: Color(0xff249B92),
                      title: 'Nhập thủ công',
                      onPressed: () => Navigator.pushNamed(
                          context, NavigatorName.add_blood_pressure,
                          arguments: {'type': 'input', 'id': null}),
                    ),
                    SizedBox(height: 15),
                    ButtonWidget(
                      backgroundColor: Color(0xFFF4F4F4),
                      textColor: Color(0xff172823),
                      title: 'Đóng',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }
  }
}

typedef ActionFilterCallback = Function(int);

class ActionFilter extends StatefulWidget {
  final ActionFilterCallback? callback;

  ActionFilter({this.callback});

  @override
  _ActionFilterState createState() => _ActionFilterState();
}

class _ActionFilterState extends State<ActionFilter> {
  String name = R.string.filter_day.tr(args: ['30']);
  int selectedIndex = 2;
  @override
  void initState() {
    loadFilter();
    super.initState();
  }

  void loadFilter() async {
    List<String> filters = await AppSettings.getHomeFilters();
    name = filters[ScreenList.BLOOD_PRESSURE.index];
    selectedIndex = valueOfSelectedFilter[name]!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showActionFilter(context);
      },
      child: Container(
        color: R.color.transparent,
        padding: EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 16),
        child: Row(
          children: [
            Image.asset(R.drawable.ic_filter, width: 24, height: 24),
            SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(name,
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500, color: R.color.textDark)),
            ),
          ],
        ),
      ),
    );
  }

  showActionFilter(BuildContext context) {
    showModalBottomSheet(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        backgroundColor: R.color.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => FillterBloodPanel(
            selectedIndex: selectedIndex,
            callback: (value, index) async {
              await AppSettings.setHomeFilters(ScreenList.BLOOD_PRESSURE.index, value);
              if (index != null) {
                setState(() {
                  name = value;
                  selectedIndex = index;
                });
                widget.callback!(index + 1);
              }
            }));
  }
}
