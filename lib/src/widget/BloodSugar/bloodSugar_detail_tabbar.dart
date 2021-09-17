import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/BloodSugar/bloodSugar_detail.dart';
import 'package:medical/src/widget/BloodSugar/overview.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/components/HomeButton/main.dart';
import 'package:medical/src/widget/components/custom_action_descriptipn.dart';
import 'package:medical/src/widget/tabbar/action_list_panel.dart';
import 'package:medical/src/widget/tabbar/action_panel.dart';
import 'package:medical/src/widget/tabbar/fillter_bloodSugar_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BloodSugarDetailTabbarController extends StatefulWidget {
  @override
  _BloodSugarDetailTabbarControllerState createState() =>
      _BloodSugarDetailTabbarControllerState();

  static _BloodSugarDetailTabbarControllerState of(BuildContext context) {
    final _BloodSugarDetailTabbarControllerState navigator = context
        .findAncestorStateOfType<_BloodSugarDetailTabbarControllerState>();
    return navigator;
  }
}

class _BloodSugarDetailTabbarControllerState
    extends State<BloodSugarDetailTabbarController>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  GlobalKey<CustomTabbarImageState> customTabbarKey = GlobalKey();
  GlobalKey<CustomActionDescriptionState> customActionDesKey = GlobalKey();

  GlobalKey<BloodSugarOverviewControllerState> overViewKey = GlobalKey();
  GlobalKey<BloodSugarDetailControllerState> detailKey = GlobalKey();

  int periodFilterType = 1;
  String glucoseID;

  ShortGuiModel des;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
    DartNotificationCenter.subscribe(
        channel: 'glucose_change_data',
        observer: this,
        onNotification: (_) {
          overViewKey.currentState.reloadData(periodFilterType);
          detailKey.currentState.reloadData(periodFilterType);
        });

    checkShowDes();
    loadDescription();
  }

  @override
  void dispose() {
    DartNotificationCenter.unsubscribe(
        channel: 'glucose_change_data', observer: this);
    super.dispose();
  }

  loadInputWithId(int index, String id) {
    glucoseID = id;
    _tabController.animateTo(index);

    if (detailKey.currentState != null) {
      detailKey.currentState.loadDataToID(periodFilterType);
    }
  }

  checkShowDes() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    final showDes = prefs.getBool('show_des_glucose');
    prefs.setBool('show_des_glucose', false);
    if (showDes == null || showDes) {
      customActionDesKey.currentState.showDes();
      customTabbarKey.currentState.showDescription();
    }
  }

  loadDescription() async {
    des = await HbA1CClient().fetchShortGuide(1);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: CustomAppBar(
            backgroundColor: Colors.white,
            title: Text('Đường huyết',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: textDark)),
            leadingIcon: GestureDetector(
                onTap: () {
                  showDialog(
                    barrierColor: Color(0xff003F38).withOpacity(0.3),
                    useSafeArea: false,
                    context: context,
                    builder: (_) => ActionListPanel(selectedIndex: 1),
                  );
                },
                child: Icon(Icons.format_list_bulleted, color: textDark)),
            actions: [
              CustomActionDescription(
                  key: customActionDesKey,
                  callback: (value) {
                    customTabbarKey.currentState.showDescription();
                  }),
              IconButton(
                  icon: Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              SizedBox(
                width: 12,
              ),
            ],
            // bottom: PreferredSize(
            //   preferredSize: Size.fromHeight(40),
            //   child: Align(
            //     // alignment: Alignment.centerLeft,
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         TabBar(
            //             isScrollable: true,
            //             labelColor: main,
            //             labelStyle: TextStyle(
            //                 fontSize: 14,
            //                 fontWeight: FontWeight.w600,
            //                 color: main),
            //             unselectedLabelColor: captionColorGray,
            //             unselectedLabelStyle: TextStyle(
            //                 fontSize: 14, fontWeight: FontWeight.w400),
            //             tabs: [
            //               Tab(text: 'Biểu đồ'),
            //               Tab(text: 'Chi tiết'),
            //             ],
            //             controller: _tabController,
            //             indicatorColor: main,
            //             indicatorWeight: 3),
            //         ActionFilter(
            //           callback: (periodFilter) {
            //             periodFilterType = periodFilter;
            //             overViewKey.currentState.reloadData(periodFilterType);
            //             if (detailKey.currentState != null) {
            //               detailKey.currentState.reloadData(periodFilterType);
            //             }
            //           },
            //         )
            //       ],
            //     ),
            //   ),
            // )
          ),
          body: Column(children: [
            CustomTabbarImage(
                key: customTabbarKey,
                tabController: _tabController,
                data: des,
                callback: (periodFilter) {
                  periodFilterType = periodFilter;
                  overViewKey.currentState.reloadData(periodFilterType);
                  if (detailKey.currentState != null) {
                    detailKey.currentState.reloadData(periodFilterType);
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
            backgroundColor: Colors.transparent,
            onPressed: () {
              _showMaterialDialog();
            },
            child: Image.asset('assets/images/button_plus.png',
                width: 80, height: 80),
          )),
    );
  }

  _showMaterialDialog() {
    Navigator.pushNamed(context, '/add_bloodSugar',
        arguments: {'type': 'input'});
    // showDialog(
    //   barrierColor: Color(0xff003F38).withOpacity(0.8),
    //   useSafeArea: false,
    //   context: context,
    //   builder: (_) => FunkyOverlay(),
    // );
  }
}

class CustomTabbarImage extends StatefulWidget {
  CustomTabbarImage(
      {Key key,
      @required this.tabController,
      this.callback,
      @required this.data})
      : super(key: key);

  final ActionFilterCallback callback;
  final TabController tabController;
  final ShortGuiModel data;

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
      color: Colors.white,
      child: Column(
        children: [
          showDes
              ? Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Description(
                      input: false,
                      data: widget.data,
                      titleDetail: 'Chỉ số đường huyết với bệnh tiểu đường'),
                )
              : SizedBox(),
          Row(
              //alignment: Alignment.centerLeft,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TabBar(
                    isScrollable: true,
                    labelColor: mainColor,
                    labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: mainColor),
                    unselectedLabelColor: captionColorGray,
                    unselectedLabelStyle:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    tabs: [
                      Tab(text: 'Biểu đồ'),
                      Tab(text: 'Chi tiết'),
                    ],
                    controller: widget.tabController,
                    indicatorColor: mainColor,
                    indicatorWeight: 3),
                ActionFilter(
                  callback: (periodFilter) {
                    widget.callback(periodFilter);
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
  final ActionFilterCallback callback;
  ActionFilter({this.callback});
  @override
  _ActionFilterState createState() => _ActionFilterState();
}

class _ActionFilterState extends State<ActionFilter> {
  String name = '7 ngày';
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showActionFilter(context);
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 16),
        child: Row(
          children: [
            Image.asset('assets/images/icon_filter.png', width: 24, height: 24),
            SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(name,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textDark)),
            ),
          ],
        ),
      ),
    );
  }

  showActionFilter(BuildContext context) {
    // setState(() {
    //   this.isChoose = !isChoose;
    // });
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => FillterBloodPanel(
            selectedIndex: selectedIndex,
            callback: (value, index) {
              setState(() {
                name = value;
                selectedIndex = index;
              });
              widget.callback(index + 1);
            }));
  }
}
