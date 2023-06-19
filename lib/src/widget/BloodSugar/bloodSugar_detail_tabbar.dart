import 'dart:io' show Platform;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:medical/src/app_setting/firebase_tracking/kpi_glycemic_tracking.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodSugar/bloodSugar_detail.dart';
import 'package:medical/src/widget/BloodSugar/overview.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/components/custom_action_descriptipn.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/nipro/health_app/widgets/request_health_connect.dart';
import 'package:medical/src/widget/nipro/roche_connection/roche_connection_view.dart';
import 'package:medical/src/widget/tabbar/action_list_panel.dart';
import 'package:medical/src/widget/tabbar/fillter_bloodSugar_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_setting/app_setting.dart';
import '../../widgets/button_widget.dart';
import '../blood_sugar_survey_screens/blood_sugar_start_survey/blood_sugar_start_survey.dart';

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
  TabController? _tabController;

  GlobalKey<CustomTabbarImageState> customTabbarKey = GlobalKey();
  GlobalKey<CustomActionDescriptionState> customActionDesKey = GlobalKey();

  GlobalKey<BloodSugarOverviewControllerState> overViewKey = GlobalKey();
  GlobalKey<BloodSugarDetailControllerState> detailKey = GlobalKey();

  int periodFilterType = 1;
  String? glucoseID;

  ShortGuiModel? des;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        initialIndex: (widget.data != null && widget.data!['index'] != null
            ? widget.data!['index']
            : 0),
        vsync: this,
        length: 2);
    Observable.instance.addObserver(this);
    checkShowDes();
    loadDescription();
    KpiGlycemicTracking.firebaseSetup();
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'glucose_change_data') {
      overViewKey.currentState?.reloadData(periodFilterType);
      detailKey.currentState?.reloadData(periodFilterType);
      if (map != null && map['index'] != null) {
        _tabController!.animateTo(map['index']);
      }
    }
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  loadInputWithId(int index, String? id) {
    glucoseID = id;
    _tabController!.animateTo(index);

    if (detailKey.currentState != null) {
      detailKey.currentState!.loadDataToID(periodFilterType);
    }
  }

  checkShowDes() async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    final showDes = prefs.getBool('show_des_glucose');
    prefs.setBool('show_des_glucose', false);
    if (showDes == null || showDes) {
      customActionDesKey.currentState!.showDes();
      customTabbarKey.currentState!.showDescription();
    }
  }

  loadDescription() async {
    des = await HbA1CClient().fetchShortGuide(1);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(
          backgroundColor: R.color.white,
          title: Text(R.string.duong_huyet.tr(),
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: R.color.textDark)),
          leadingIcon: GestureDetector(
              onTap: () async {
                await TrackingManager.analytics
                    .logEvent(name: 'cta_button_clicked', parameters: {
                  "screen_name": 'kpi_glycemic',
                  'cta_button_name': 'cta_add_glycemic_3',
                });
                showDialog(
                  barrierColor: R.color.color0xff003F38.withOpacity(0.3),
                  useSafeArea: false,
                  context: context,
                  builder: (_) => ActionListPanel(selectedIndex: 1),
                );
              },
              child: Icon(Icons.format_list_bulleted, color: R.color.textDark)),
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
            const SizedBox(width: 12),
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
              BloodSugarOverviewController(key: overViewKey),
              BloodSugarDetailController(key: detailKey)
            ]),
          ),
        ]),
        floatingActionButton: FloatingActionButton(
          backgroundColor: R.color.transparent,
          onPressed: () {
            _showMaterialDialog();
          },
          child: Image.asset(R.drawable.ic_button_plus, width: 80, height: 80),
        ));
  }

  _showMaterialDialog() async {
    String healthIcon =
        Platform.isIOS ? R.drawable.logo_healthkit : R.drawable.logo_googleFit;
    String healthTitle =
        Platform.isIOS ? 'Kết nối từ Apple Health' : 'Kết nối từ Google Fit';
    bool? hasHealthConnection = await AppStorages.getHealthAppPermission();
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
                  border: Border(bottom: BorderSide(color: Color(0xffF2F2F2)))),
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
                    icon: R.icons.ic_bluetooth,
                    backgroundColor: Color(0xFFE4FCF3),
                    textColor: Color(0xff249B92),
                    title: 'Kết nối từ thiết bị',
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                RocheConnectionView())),
                  ),
                  SizedBox(height: 15),
                  ButtonWidget(
                    icon: R.icons.ic_tap,
                    backgroundColor: Color(0xFFE4FCF3),
                    textColor: Color(0xff249B92),
                    title: 'Nhập thủ công',
                    onPressed: () => Navigator.pushNamed(
                        context, NavigatorName.add_blood_sugar,
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

class CustomTabbarImage extends StatefulWidget {
  const CustomTabbarImage(
      {Key? key,
      required this.tabController,
      this.callback,
      required this.data})
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
          if (showDes)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Description(
                  input: false,
                  data: widget.data,
                  titleDetail: R.string.blood_sugar_for_diabetes.tr()),
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
                    context,
                    const BloodSugarStartSurveyPage(
                        comeFromBloodSugarScreen: true));
              }),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            TabBar(
                isScrollable: true,
                labelColor: R.color.mainColor,
                labelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: R.color.mainColor),
                unselectedLabelColor: R.color.captionColorGray,
                unselectedLabelStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                tabs: [
                  Tab(text: R.string.bieu_do.tr()),
                  GestureDetector(
                    onTap: () {
                      KpiGlycemicTracking.clickDetailTab();
                    },
                    child: Tab(text: R.string.detail.tr()),
                  ),
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
                style: TextStyle(
                    color: R.color.mainColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
