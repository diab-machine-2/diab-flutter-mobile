import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/firebase_tracking/kpi_blood_pressure_tracking.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodPressure/bloodPressure_detail.dart';
import 'package:medical/src/widget/BloodPressure/overview.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/components/custom_action_descriptipn.dart';
import 'package:medical/src/widget/nipro/health_app/widgets/request_health_connect.dart';
import 'package:medical/src/widget/tabbar/action_list_panel.dart';
import 'package:medical/src/widget/tabbar/fillter_bloodSugar_panel.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  TabController? _tabController;

  GlobalKey<CustomTabbarImageState> customTabbarKey = GlobalKey();
  GlobalKey<CustomActionDescriptionState> customActionDesKey = GlobalKey();

  GlobalKey<BloodPressureOverviewControllerState> overViewKey = GlobalKey();
  GlobalKey<BloodPressureDetailControllerState> detailKey = GlobalKey();

  int periodFilterType = 1;
  String? bloodPressureID;

  ShortGuiModel? des;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
    Observable.instance.addObserver(this);
    // DartNotificationCenter.subscribe(
    //     channel: 'BloodPressure_change_data',
    //     observer: this,
    //     onNotification: (_) {
    //       overViewKey.currentState!.reloadData(periodFilterType);
    //       detailKey.currentState!.reloadData(periodFilterType);
    //     });
    checkShowDes();
    loadDescription();

    _tabController!.addListener(() {
      if (_tabController!.indexIsChanging) {
        if (_tabController!.index == 1) {
          KpiBloodPressureTracking.clickDetailTab();
          print("tracking KpiBloodPressureTracking.clickDetailTab()");
        }
      }
    });
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'BloodPressure_change_data') {
      overViewKey.currentState?.reloadData(periodFilterType);
      detailKey.currentState?.reloadData(periodFilterType);
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

  loadInputWithId(int index, String? id) {
    bloodPressureID = id;
    _tabController!.animateTo(index);

    if (detailKey.currentState != null) {
      detailKey.currentState!.loadDataToID(periodFilterType);
    }
  }

  checkShowDes() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    final showDes = prefs.getBool('show_des_pressure');
    prefs.setBool('show_des_pressure', false);
    if (showDes == null || showDes) {
      customActionDesKey.currentState!.showDes();
      customTabbarKey.currentState!.showDescription();
    }
  }

  loadDescription() async {
    des = await HbA1CClient().fetchShortGuide(2);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: CustomAppBar(
            backgroundColor: R.color.white,
            title: Text(R.string.huyet_ap.tr(),
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
                    builder: (_) => ActionListPanel(selectedIndex: 2),
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
              SizedBox(
                width: 12,
              )
            ],
          ),
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
                BloodPressureOverviewController(key: overViewKey),
                BloodPressureDetailController(key: detailKey)
              ]),
            ),
          ]),
          floatingActionButton: FloatingActionButton(
            backgroundColor: R.color.transparent,
            onPressed: () {
              _showMaterialDialog();
            },
            child:
                Image.asset(R.drawable.ic_button_plus, width: 80, height: 80),
          )),
    );
  }

  _showMaterialDialog() async {
    bool? hasHealthConnection = await AppStorages.getHealthAppPermission();
    if (hasHealthConnection == true) {
      Navigator.pushNamed(context, NavigatorName.add_blood_pressure,
          arguments: {'type': 'input', 'id': null});
    } else {
      String healthIcon = Platform.isIOS
          ? R.drawable.logo_healthkit
          : R.drawable.logo_googleFit;
      String healthTitle =
          Platform.isIOS ? 'Kết nối từ Apple Health' : 'Kết nối từ Google Fit';
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

class CustomTabbarImage extends StatefulWidget {
  CustomTabbarImage(
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

  showDescription() {
    print(showDes);
    showDes = !showDes;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: R.color.white,
      child: Column(
        children: [
          showDes
              ? Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Description(
                      input: false,
                      data: widget.data,
                      titleDetail: R.string.blood_pressure_for_diabetes.tr()),
                )
              : SizedBox(),
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
                    unselectedLabelStyle:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    tabs: [
                      Tab(text: R.string.bieu_do.tr()),
                      Tab(text: R.string.detail.tr())
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

  ActionFilter({this.callback});

  @override
  _ActionFilterState createState() => _ActionFilterState();
}

class _ActionFilterState extends State<ActionFilter> {
  String name = R.string.filter_day.tr(args: ['7']);
  int selectedIndex = 0;

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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        backgroundColor: R.color.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => FillterBloodPanel(
            selectedIndex: selectedIndex,
            callback: (value, index) {
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
