import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/firebase_tracking/kpi_motion_tracking.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Exercrises/exercrises_detail.dart';
import 'package:medical/src/widget/Exercrises/overview.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/components/custom_action_descriptipn.dart';
import 'package:medical/src/widget/home/fliter_enum.dart';
import 'package:medical/src/widget/nipro/health_app/widgets/request_health_connect.dart';
import 'package:medical/src/widget/tabbar/action_list_panel.dart';
import 'package:medical/src/widget/tabbar/fillter_bloodSugar_panel.dart';
import 'package:medical/src/widget/tabbar/tabbar_v2.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExercrisesDetailTabbarController extends StatefulWidget {
  @override
  _ExercrisesDetailTabbarControllerState createState() =>
      _ExercrisesDetailTabbarControllerState();
  static _ExercrisesDetailTabbarControllerState? of(BuildContext context) {
    final _ExercrisesDetailTabbarControllerState? navigator = context
        .findAncestorStateOfType<_ExercrisesDetailTabbarControllerState>();
    return navigator;
  }
}

class _ExercrisesDetailTabbarControllerState
    extends State<ExercrisesDetailTabbarController>
    with SingleTickerProviderStateMixin, Observer {
  TabController? _tabController;
  GlobalKey<CustomTabbarImageState> customTabbarKey = GlobalKey();
  GlobalKey<CustomActionDescriptionState> customActionDesKey = GlobalKey();
  GlobalKey<ExercrisesOverviewControllerState> overViewKey = GlobalKey();
  GlobalKey<ExercrisesDetailControllerState> detailKey = GlobalKey();

  int periodFilterType = 1;

  ShortGuiModel? des;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    Observable.instance.addObserver(this);
    checkShowDes();
    loadDescription();
    _tabController!.addListener(() {
      if (_tabController!.indexIsChanging) {
        if (_tabController!.index == 1) {
          KpiMotionTracking.clickDetailTab();
          print("tracking KpiMotionTracking.clickDetailTab()");
        }
      }
    });
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'active_change_data') {
      overViewKey.currentState!.reloadData(periodFilterType);
      if (detailKey.currentState != null) {
        detailKey.currentState!.reloadData(periodFilterType);
      }
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

  changeIndex(int index) {
    _tabController!.animateTo(index);
  }

  checkShowDes() async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    final showDes = prefs.getBool('show_des_exercises');
    prefs.setBool('show_des_exercises', false);
    if (showDes == null || showDes) {
      customActionDesKey.currentState!.showDes();
      customTabbarKey.currentState!.showDescription();
    }
  }

  loadDescription() async {
    des = await HbA1CClient().fetchShortGuide(3);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(
            backgroundColor: R.color.white,
            title: Text(R.string.van_dong.tr(),
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: R.color.textDark)),
            leadingIcon: GestureDetector(
                onTap: () {
                  showDialog(
                    barrierColor: R.color.color0xff003F38.withOpacity(0.3),
                    useSafeArea: false,
                    context: context,
                    builder: (_) => ActionListPanel(selectedIndex: 3),
                  );
                },
                child:
                    Icon(Icons.format_list_bulleted, color: R.color.textDark)),
            actions: [
              CustomActionDescription(
                  key: customActionDesKey,
                  callback: (value) {
                    customTabbarKey.currentState!.showDescription();
                  }),
              IconButton(
                  icon: Icon(Icons.close, color: R.color.black),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              const SizedBox(width: 12)
            ]),
        body: Column(children: [
          CustomTabbarImage(
              key: customTabbarKey,
              tabController: _tabController,
              data: des,
              callback: (periodFilter) {
                periodFilterType = periodFilter;
                overViewKey.currentState!.reloadData(periodFilterType);
                if (detailKey.currentState != null) {
                  detailKey.currentState!.reloadData(periodFilterType);
                }
              }),
          Expanded(
              child: TabBarView(controller: _tabController, children: [
            ExercrisesOverviewController(key: overViewKey),
            ExercrisesDetailController(key: detailKey)
          ])),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showMaterialDialog();
          },
          child: Image.asset(R.drawable.ic_button_plus, width: 80, height: 80),
        ));
  }

  _showMaterialDialog() async {
    if (AppSettings.userInfo!.weight == null ||
        AppSettings.userInfo!.weight == 0) {
      showPopupWeight();
    } else {
      bool? hasHealthConnection = await AppStorages.getHealthAppPermission();
      if (hasHealthConnection == true) {
        Navigator.pushNamed(context, NavigatorName.add_exercrises,
            arguments: {'type': 'input'});
      } else {
        String healthIcon = Platform.isIOS
            ? R.drawable.logo_healthkit
            : R.drawable.logo_googleFit;
        String healthTitle = Platform.isIOS
            ? 'Kết nối từ Apple Health'
            : 'Kết nối từ Google Fit';
        showModalBottomSheet(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
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
                  decoration: BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: Color(0xffF2F2F2)))),
                  child: Text(
                    'Chọn cách nhập',
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
                            context, NavigatorName.add_exercrises,
                            arguments: {'type': 'input'}),
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
    clickTime = valueOfClickTime[ScreenList.EXERCISE.index];
    clickTime += 1;

    await AppSettings.setValueOfClickShortGuideIndex(
        ScreenList.EXERCISE.index, clickTime);
    if (clickTime > 2 && widget.data != null) {
      Description.showTooltip(context,
          data: widget.data!,
          title: R.string.che_do_tap_luyen_doi_voi_benh_tieu_duong.tr());
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
                  titleDetail:
                      R.string.che_do_tap_luyen_doi_voi_benh_tieu_duong.tr(),
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
    name = filters[ScreenList.EXERCISE.index];
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
              await AppSettings.setHomeFilters(
                  ScreenList.EXERCISE.index, value);
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
