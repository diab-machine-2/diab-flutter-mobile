import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_tracking/kpi_nutrition_tracking.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Food/nutrition_guide_page.dart';
import 'package:medical/src/widget/Food/food_detail.dart';
import 'package:medical/src/widget/Food/overview.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description.dart';
import 'package:medical/src/widget/components/custom_action_descriptipn.dart';
import 'package:medical/src/widget/home/fliter_enum.dart';
import 'package:medical/src/widget/tabbar/fillter_bloodSugar_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_setting/app_setting.dart';
import '../BloodPressure/widget/horizontal_selector.dart';

class FoodDetailTabbarController extends StatefulWidget {
  final int? initialTabIndex;
  final Map<String, int>? nutritionPercent;
  final Map<String, String>? nutritionColors;

  const FoodDetailTabbarController(
      {Key? key,
      this.initialTabIndex,
      this.nutritionPercent,
      this.nutritionColors})
      : super(key: key);

  @override
  _FoodDetailTabbarControllerState createState() =>
      _FoodDetailTabbarControllerState();

  static _FoodDetailTabbarControllerState? of(BuildContext context) {
    final _FoodDetailTabbarControllerState? navigator =
        context.findAncestorStateOfType<_FoodDetailTabbarControllerState>();
    return navigator;
  }
}

class _FoodDetailTabbarControllerState extends State<FoodDetailTabbarController>
    with SingleTickerProviderStateMixin, Observer {
  TabController? _tabController;
  GlobalKey<CustomTabbarImageState> customTabbarKey = GlobalKey();
  GlobalKey<CustomActionDescriptionState> customActionDesKey = GlobalKey();

  GlobalKey<FoodOverviewControllerState> overviewKey = GlobalKey();
  GlobalKey<FoodDetailControllerState> detailKey = GlobalKey();

  bool isClicked = false;
  var userInfo = AppSettings.userInfo;

  int periodFilterType = 1;

  ShortGuiModel? des;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialTabIndex ?? 0;
    _tabController = TabController(
      vsync: this,
      length: 2,
      initialIndex: initialIndex,
    );
    Observable.instance.addObserver(this);
    checkShowDes();
    loadDescription();
    _tabController!.addListener(() {
      if (_tabController!.indexIsChanging) {
        if (_tabController!.index == 1) {
          KpiNutritionTracking.clickDetailTab();
          print("tracking KpiNutritionTracking.clickDetailTab()");
        }
      }
    });
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'food_change_data') {
      if (overviewKey.currentState != null) {
        overviewKey.currentState!.reloadData(periodFilterType);
      }
      if (detailKey.currentState != null) {
        detailKey.currentState!.reloadData(periodFilterType);
      }
    }
  }

  static bool _isDisposing = false;
  @override
  void dispose() {
    if (_isDisposing) {
      // Already disposing, just call super.dispose() and return
      super.dispose();
      return;
    }
    _isDisposing = true;
    try {
      _tabController?.dispose();
      Observable.instance.removeObserver(this);
      // Run async operation without blocking dispose
      AppSettings.syncDataFromHealthApp().then((_) {
        _isDisposing = false;
      }).catchError((_) {
        _isDisposing = false;
      });
    } finally {
      // Always call super.dispose() even if there's an error
      super.dispose();
    }
  }

  void switchToTab(int index) {
    // Navigate to detail page since TabBar was removed
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              backgroundColor: R.color.greenGradientBottom,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, color: R.color.white),
              ),
              leadingWidth: 30,
              centerTitle: false,
              title: Text(
                'Chi tiết dinh dưỡng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: R.color.white,
                ),
              ),
            ),
            body: FoodDetailController(
              key: detailKey,
              periodFilterType: periodFilterType,
            ),
          ),
        ),
      );
    }
  }

  checkShowDes() async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    final showDes = prefs.getBool('show_des_food');
    prefs.setBool('show_des_food', false);
    if (showDes == null || showDes) {
      customActionDesKey.currentState!.showDes();
      customTabbarKey.currentState!.showDescription();
    }
  }

  loadDescription() async {
    des = await HbA1CClient().fetchShortGuide(4);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: R.color.greenGradientBottom,
        leading: IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.of(context, rootNavigator: true)
                  .pushNamedAndRemoveUntil(
                NavigatorName.tabbar,
                (route) => false,
              );
            }
          },
          icon: Icon(Icons.arrow_back, color: R.color.white),
        ),
        leadingWidth: 30,
        centerTitle: false,
        title: Text(
          R.string.dinh_duong.tr(),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NutritionGuidePage(),
                  ),
                );
              },
              child: Text(
                R.string.huong_dan.tr(),
                style: TextStyle(fontSize: 15, color: R.color.white),
              ),
            ),
          ),
        ],
      ),
      body: Column(children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: HorizontalSelector(
            onSelected: (value) {
              periodFilterType = value + 1;
              overviewKey.currentState!.reloadData(periodFilterType);
              if (detailKey.currentState != null) {
                detailKey.currentState!.reloadData(periodFilterType);
              }
            },
            initialValue: periodFilterType - 1,
            values: [0, 1, 2, 3],
            labels: [
              R.string.filter_day.tr(args: ['7']),
              R.string.filter_day.tr(args: ['14']),
              R.string.filter_day.tr(args: ['30']),
              R.string.filter_day.tr(args: ['90']),
            ],
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: FoodOverviewController(key: overviewKey),
        ),
      ]),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     FoodActionPopup.show(context, fromDashboard: true);
      //     // NavigationUtil.navigatePage(
      //     //     context, DailyNutritionPage(type: 'input', id: null));
      //   },
      //   child: Image.asset(R.drawable.ic_button_plus, width: 80, height: 80),
      // ),
    );
  }
}

class CustomTabbarImage extends StatefulWidget {
  const CustomTabbarImage(
      {Key? key,
      required this.tabController,
      this.callback,
      required this.data})
      : super(key: key);

  final ActionFilterCallback? callback;
  final TabController? tabController;
  final ShortGuiModel? data;

  @override
  CustomTabbarImageState createState() => CustomTabbarImageState();
}

class CustomTabbarImageState extends State<CustomTabbarImage> {
  bool showDes = false;

  int clickTime = 0;

  showDescription() async {
    List<int> valueOfClickTime = await AppSettings.getValueOfClickShortGuide();
    clickTime = valueOfClickTime[ScreenList.FOOD.index];
    clickTime += 1;

    await AppSettings.setValueOfClickShortGuideIndex(
        ScreenList.FOOD.index, clickTime);
    if (clickTime > 2 && widget.data != null) {
      Description.showTooltip(context,
          data: widget.data!,
          title: R.string.che_do_dinh_duong_benh_tieu_duong.tr());
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
                  titleDetail: R.string.che_do_dinh_duong_benh_tieu_duong.tr(),
                  clickTime: clickTime),
            )
          else
            const SizedBox(),
          Row(
              //alignment: Alignment.centerLeft,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TabBar(
                    isScrollable: true,
                    labelColor: R.color.mainColor,
                    labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: R.color.mainColor),
                    unselectedLabelColor: R.color.captionColorGray,
                    unselectedLabelStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w400),
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

typedef ActionFilterCallback = Function(int);

class ActionFilter extends StatefulWidget {
  final ActionFilterCallback? callback;

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
    name = filters[ScreenList.FOOD.index];
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
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: R.color.textDark)),
            ),
          ],
        ),
      ),
    );
  }

  showActionFilter(BuildContext context) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        backgroundColor: R.color.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => FillterBloodPanel(
            selectedIndex: selectedIndex,
            callback: (value, index) async {
              await AppSettings.setHomeFilters(ScreenList.FOOD.index, value);
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
