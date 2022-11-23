import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/Food/food_detail.dart';
import 'package:medical/src/widget/Food/overview.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/components/custom_action_descriptipn.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/notification/notification_controller.dart';
import 'package:medical/src/widget/notification/notification_read_controller.dart';

import 'notification_unread_controller.dart';

class NotificationTabbarController extends StatefulWidget {
  @override
  _NotificationTabbarControllerState createState() =>
      _NotificationTabbarControllerState();

  static _NotificationTabbarControllerState? of(BuildContext context) {
    final _NotificationTabbarControllerState? navigator =
        context.findAncestorStateOfType<_NotificationTabbarControllerState>();
    return navigator;
  }
}

class _NotificationTabbarControllerState
    extends State<NotificationTabbarController>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  GlobalKey<CustomActionDescriptionState> customActionDesKey = GlobalKey();

  GlobalKey<FoodOverviewControllerState> overviewKey = GlobalKey();
  GlobalKey<FoodDetailControllerState> detailKey = GlobalKey();

  bool isClicked = false;

  int periodFilterType = 1;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
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
        color: R.color.color0xfff5f5f5,
        child: Column(children: [
          CustomAppBar(
            backgroundColor: R.color.transparent,
            title: Text(R.string.notification,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: R.color.textDark)).tr(),
            leadingIcon: IconButton(
                splashColor: R.color.transparent,
                highlightColor: R.color.transparent,
                icon: Icon(Icons.arrow_back, color: R.color.textDark),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ),
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
              labelPadding: const EdgeInsets.all(0),
              tabs: [
                SizedBox(width: width / 3, child: Tab(text: R.string.all.tr())),
                SizedBox(
                    width: width / 3,
                    child: Tab(text: R.string.not_read_yet.tr())),
                SizedBox(
                    width: width / 3, child: Tab(text: R.string.read.tr())),
              ],
              controller: _tabController,
              indicatorColor: R.color.mainColor,
              indicatorWeight: 3),
          Expanded(
              child: TabBarView(controller: _tabController, children: const [
            NotificationController(isRemovealbe: null),
            NotificationUnreadController(isRemovealbe: false),
            NotificationReadController(isRemovealbe: true)
          ])),
        ]),
      ),
    );
  }
}
