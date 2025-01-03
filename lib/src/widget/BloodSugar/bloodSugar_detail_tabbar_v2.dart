import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_tracking/activity_list_tracking.dart';
import 'package:medical/src/app_setting/firebase_tracking/kpi_glycemic_tracking.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/components/custom_action_descriptipn.dart';
import 'package:medical/src/widget/glucose_intro/widgets/glucose_lesson_section.dart';
import 'package:medical/src/widget/home/fliter_enum.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail_page.dart';
import 'package:medical/src/widget/tabbar/fillter_bloodSugar_panel.dart';
import 'package:medical/src/widgets/common_page.dart';

import '../../app_setting/app_setting.dart';
import 'widget/bloodSugar_chart.dart';
import 'widget/bloodSugar_compare_chart.dart';
import 'widget/bloodSugar_contain_detail.dart';

class BloodSugarDetailTabbarController extends StatefulWidget {
  final Map<dynamic, dynamic>? data;
  BloodSugarDetailTabbarController({this.data});
  @override
  _BloodSugarDetailTabbarControllerState createState() => _BloodSugarDetailTabbarControllerState();

  static _BloodSugarDetailTabbarControllerState? of(BuildContext context) {
    final _BloodSugarDetailTabbarControllerState? navigator =
        context.findAncestorStateOfType<_BloodSugarDetailTabbarControllerState>();
    return navigator;
  }
}

class _BloodSugarDetailTabbarControllerState extends State<BloodSugarDetailTabbarController>
    with SingleTickerProviderStateMixin, Observer {
  final GlobalKey<CustomActionDescriptionState> customActionDesKey = GlobalKey();

  // GlobalKey<BloodSugarOverviewControllerState> overViewKey = GlobalKey();
  // final GlobalKey<BloodSugarDetailControllerState> detailKey = GlobalKey();

  final GlobalKey<BloodSugarDetailState> sugarDetailKey = GlobalKey();
  final GlobalKey<BloodSugarChartState> sugarChartKey = GlobalKey();
  final GlobalKey<BloodSugarCompareChartState> sugarCompareKey = GlobalKey();

  int periodFilterType = 3;
  late String name = R.string.filter_day.tr(args: ['30']);
  String? glucoseID;

  void _viewDetailListing() {
    Navigator.pushNamed(context, NavigatorName.detail_blood_sugar_listing,
        arguments: {'glucoseID': glucoseID, 'initPeriodFilterType': periodFilterType});
  }

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    KpiGlycemicTracking.firebaseSetup();

    // TODO: KpiGlycemicTracking.clickDetailTab();

    // List<String> filters = await AppSettings.getHomeFilters();
    // name = filters[ScreenList.BLOOD_SUGAR.index];
    // selectedIndex = valueOfSelectedFilter[name]!;
  }

  @override
  void update(Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'glucose_change_data') {
      _doReloadData(periodFilterType);
      // overViewKey.currentState?.reloadData(periodFilterType);
      // detailKey.currentState?.reloadData(periodFilterType);
      // if (map != null && map['index'] != null) {
      //   _tabController!.animateTo(map['index']);
      // }
    }
  }

  @override
  void dispose() async {
    Observable.instance.removeObserver(this);
    AppSettings.syncDataFromHealthApp();
    super.dispose();
  }

  void _doReloadData(int periodFilterType) {
    sugarChartKey.currentState?.reloadData(periodFilterType);
    sugarDetailKey.currentState?.reloadData(periodFilterType);
    sugarCompareKey.currentState?.reloadData(periodFilterType);
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
    // _tabController!.animateTo(index);

    // if (detailKey.currentState != null) {
    //   detailKey.currentState!.loadDataToID(periodFilterType);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4F5),
      body: CommonPage(
        background: R.drawable.bg_glucose,
        title: R.string.duong_huyet.tr(),
        appBarAction: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed(NavigatorName.glucose_intro_2nd_page);
            },
            child: Text(
              R.string.huong_dan.tr(),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: R.color.textDark),
            ),
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 128),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    _sectionFilter(),
                    const SizedBox(height: 24),
                    BloodSugarChart(
                      key: sugarChartKey,
                      periodFilterType: periodFilterType,
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: BloodSugarDetail(
                        key: sugarDetailKey,
                        periodFilterType: periodFilterType,
                        onViewDetail: _viewDetailListing,
                      ),
                    ),

                    // Compare chart will align itself if have data
                    // const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: BloodSugarCompareChart(
                        key: sugarCompareKey,
                        periodFilterType: periodFilterType,
                        onViewDetail: _viewDetailListing,
                      ),
                    ),

                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: GlucoseLessonSection(
                        onLessonTap: (lesson) => _navigateToLessonDetail(lesson.id, lesson.type),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
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
                child: Column(
                  children: [
                    // Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, NavigatorName.schedule_glucose);
                        },
                        child: Container(
                          height: 48,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: R.color.gray_btn,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Text(
                              R.string.blood_sugar_schedule_single_line.tr(),
                              style: TextStyle(
                                color: R.color.dark,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            NavigatorName.add_blood_sugar_new,
                            arguments: {'type': 'input'},
                          );
                        },
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
                  ],
                ),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionFilter() {
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
              onTap: () {
                showActionFilter(context);
              },
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
                        name,
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
          const SizedBox(width: 6),
          InkWell(
            onTap: _viewDetailListing,
            child: SizedBox(
              width: 36,
              height: 36,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: R.color.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: R.color.color0xffE5E5E5),
                ),
                child: Center(child: Icon(Icons.history, color: R.color.textDark, size: 20)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showActionFilter(BuildContext context) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        backgroundColor: R.color.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => FillterGlucosePanel(
            selectedIndex: periodFilterType - 1,
            callback: (value, index) async {
              await AppSettings.setHomeFilters(ScreenList.BLOOD_SUGAR.index, value);
              if (index != null) {
                setState(() {
                  name = value;
                  periodFilterType = index + 1;
                });
                _doReloadData(periodFilterType);
              }
            }));
  }
}
