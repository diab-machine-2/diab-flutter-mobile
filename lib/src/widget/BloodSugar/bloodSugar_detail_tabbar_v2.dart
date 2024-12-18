import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_tracking/kpi_glycemic_tracking.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description.dart';
import 'package:medical/src/widget/components/custom_action_descriptipn.dart';
import 'package:medical/src/widget/home/fliter_enum.dart';
import 'package:medical/src/widget/tabbar/fillter_bloodSugar_panel.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_setting/app_setting.dart';
import '../blood_sugar_survey_screens/blood_sugar_start_survey/blood_sugar_start_survey.dart';
import 'widget/bloodSugar_chart.dart';
import 'widget/bloodSugar_compare_chart.dart';
import 'widget/bloodSugar_contain_detail.dart';
import 'widget/blood_glucose_item.dart';

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
  final GlobalKey<CustomTabbarImageState> customTabbarKey = GlobalKey();
  final GlobalKey<CustomActionDescriptionState> customActionDesKey = GlobalKey();

  // GlobalKey<BloodSugarOverviewControllerState> overViewKey = GlobalKey();
  // final GlobalKey<BloodSugarDetailControllerState> detailKey = GlobalKey();

  final GlobalKey<BloodSugarDetailState> sugarDetailKey = GlobalKey();
  final GlobalKey<BloodSugarChartState> sugarChartKey = GlobalKey();
  final GlobalKey<BloodGlucoseItemState> latestDataKey = GlobalKey();
  final GlobalKey<BloodSugarCompareChartState> sugarCompareKey = GlobalKey();

  int periodFilterType = 3;
  late String name = R.string.filter_day.tr(args: ['30']);
  String? glucoseID;

  ShortGuiModel? des;

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    checkShowDes();
    loadDescription();
    KpiGlycemicTracking.firebaseSetup();

    // TODO: KpiGlycemicTracking.clickDetailTab();

    // List<String> filters = await AppSettings.getHomeFilters();
    // name = filters[ScreenList.BLOOD_SUGAR.index];
    // selectedIndex = valueOfSelectedFilter[name]!;
  }

  @override
  void update(Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'glucose_change_data') {
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

  void loadInputWithId(int index, String? id) {
    glucoseID = id;
    // _tabController!.animateTo(index);

    // if (detailKey.currentState != null) {
    //   detailKey.currentState!.loadDataToID(periodFilterType);
    // }
  }

  void checkShowDes() async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    final showDes = prefs.getBool('show_des_glucose');
    prefs.setBool('show_des_glucose', false);
    if (showDes == null || showDes) {
      customActionDesKey.currentState!.showDes();
      customTabbarKey.currentState!.showDescription();
    }
  }

  void loadDescription() async {
    des = await HbA1CClient().fetchShortGuide(1);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4F5),
      body: CommonPage(
        background: R.drawable.bg_lesson_detail,
        title: R.string.duong_huyet.tr(),
        appBarAction: GestureDetector(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: () {
                // TODO:
              },
              child: Text(
                R.string.huong_dan.tr(),
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: R.color.textDark),
              ),
            ),
          ),
        ),
        child: SingleChildScrollView(
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
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BloodSugarCompareChart(
                  key: sugarCompareKey,
                  periodFilterType: periodFilterType,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TODO: move outside (parent scope)
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
          SizedBox(
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
              }
            }));
  }
}

class CustomTabbarImage extends StatefulWidget {
  const CustomTabbarImage(
      {Key? key, required this.tabController, this.callback, required this.data})
      : super(key: key);

  final Function(int)? callback;
  final TabController? tabController;
  final ShortGuiModel? data;

  @override
  CustomTabbarImageState createState() => CustomTabbarImageState();
}

class CustomTabbarImageState extends State<CustomTabbarImage> {
  bool showDes = false;

  var userInfo = AppSettings.userInfo!;

  int clickTime = 0;

  showDescription() async {
    List<int> valueOfClickTime = await AppSettings.getValueOfClickShortGuide();
    clickTime = valueOfClickTime[ScreenList.BLOOD_SUGAR.index];
    clickTime += 1;
    await AppSettings.setValueOfClickShortGuideIndex(ScreenList.BLOOD_SUGAR.index, clickTime);
    if (clickTime > 2 && widget.data != null) {
      Description.showTooltip(context,
          data: widget.data!, title: R.string.blood_sugar_for_diabetes.tr());
    }
    showDes = !showDes;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: R.color.white,
      child: Column(
        children: [
          if (showDes || clickTime >= 2)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Description(
                input: false,
                data: widget.data,
                titleDetail: R.string.blood_sugar_for_diabetes.tr(),
                clickTime: clickTime,
              ),
            ),
          _buildButton(
              title: R.string.testing_schedule_suggest.tr(),
              icon: R.drawable.ic_blood_sugar_testing_suggest,
              onTap: () async {
                // if(userInfo.isUserFree) {
                //   NavigationUtil.showUpdateRequirePopup(context: context, title: R.string.testing_schedule_suggest.tr());
                //   return;
                // }
                await NavigationUtil.navigatePage(
                    context, const BloodSugarStartSurveyPage(comeFromBloodSugarScreen: true));
              }),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            TabBar(
                isScrollable: true,
                labelColor: R.color.mainColor,
                labelStyle:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: R.color.mainColor),
                unselectedLabelColor: R.color.captionColorGray,
                unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                tabs: [
                  Tab(text: R.string.bieu_do.tr()),
                  Tab(text: R.string.detail.tr()),
                ],
                controller: widget.tabController,
                indicatorColor: R.color.mainColor,
                indicatorWeight: 3),
            ActionFilter(
              callback: (periodFilter) {
                widget.callback!(periodFilter);
              },
            )
          ]),
        ],
      ),
    );
  }
}

class ActionFilter extends StatefulWidget {
  final Function(int)? callback;
  const ActionFilter({this.callback});
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
    name = filters[ScreenList.BLOOD_SUGAR.index];
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
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 16),
        child: Row(
          children: [
            Image.asset(R.drawable.ic_filter, width: 24, height: 24),
            const SizedBox(width: 6),
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

  void showActionFilter(BuildContext context) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        backgroundColor: R.color.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => FillterBloodPanel(
            selectedIndex: selectedIndex,
            callback: (value, index) async {
              await AppSettings.setHomeFilters(ScreenList.BLOOD_SUGAR.index, value);
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

Widget _buildButton({
  required String title,
  required String icon,
  required VoidCallback onTap,
}) {
  return Row(
    children: [
      InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: R.color.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: R.color.greenGradientBottom.withOpacity(0.08),
                spreadRadius: 2,
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              Image.asset(icon, width: 24, height: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style:
                    TextStyle(color: R.color.mainColor, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
