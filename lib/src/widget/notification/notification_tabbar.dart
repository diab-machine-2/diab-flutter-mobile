import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/Food/food_description.dart';
import 'package:medical/src/widget/Food/food_detail.dart';
import 'package:medical/src/widget/Food/overview.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/components/custom_action_descriptipn.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/notification/notification.dart';
import 'package:medical/src/widget/tabbar/action_panel.dart';
import 'package:medical/src/widget/tabbar/fillter_bloodSugar_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationTabbarController extends StatefulWidget {
  @override
  _NotificationTabbarControllerState createState() =>
      _NotificationTabbarControllerState();

  static _NotificationTabbarControllerState of(BuildContext context) {
    final _NotificationTabbarControllerState navigator =
        context.findAncestorStateOfType<_NotificationTabbarControllerState>();
    return navigator;
  }
}

class _NotificationTabbarControllerState
    extends State<NotificationTabbarController>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  GlobalKey<CustomActionDescriptionState> customActionDesKey = GlobalKey();

  GlobalKey<FoodOverviewControllerState> overviewKey = GlobalKey();
  GlobalKey<FoodDetailControllerState> detailKey = GlobalKey();

  bool isClicked = false;

  int periodFilterType = 1;
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 3);
    TrackingManager.analytics.setCurrentScreen(screenName: 'Notification');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        color: Color(0xfff5f5f5),
        child: Column(children: [
          CustomAppBar(
            backgroundColor: Colors.transparent,
            title: Text('Thông báo',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textDark)),
            leadingIcon: IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: Icon(Icons.arrow_back, color: textDark),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ),
          TabBar(
              isScrollable: true,
              labelColor: mainColor,
              labelStyle: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: mainColor),
              unselectedLabelColor: captionColorGray,
              unselectedLabelStyle:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              labelPadding: EdgeInsets.all(0),
              tabs: [
                SizedBox(width: width / 3, child: Tab(text: 'Tất cả')),
                SizedBox(width: width / 3, child: Tab(text: 'Chưa đọc')),
                SizedBox(width: width / 3, child: Tab(text: 'Đã đọc')),
              ],
              controller: _tabController,
              indicatorColor: mainColor,
              indicatorWeight: 3),
          Expanded(
              child: TabBarView(controller: _tabController, children: [
            NotificationController(isRead: null),
            NotificationController(isRead: false),
            NotificationController(isRead: true)
          ])),
        ]),
      ),
    );
  }
}
