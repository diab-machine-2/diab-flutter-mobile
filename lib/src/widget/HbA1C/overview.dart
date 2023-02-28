import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/widget/HbA1C/widget/course_suggest.dart';
import 'package:medical/src/widget/HbA1C/widget/hba1c_chart.dart';
import 'package:medical/src/widget/HbA1C/widget/hba1c_contain_detail.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

class HbA1COverviewController extends StatefulWidget {
  HbA1COverviewController({
    Key? key,
  }) : super(key: key);
  @override
  HbA1COverviewControllerState createState() => HbA1COverviewControllerState();
}

class HbA1COverviewControllerState extends State<HbA1COverviewController>
    with AutomaticKeepAliveClientMixin<HbA1COverviewController> {
  @override
  bool get wantKeepAlive => true;

  ScrollController _scrollController = ScrollController();
  GlobalKey<HbA1CDetailState> detailKey = GlobalKey();
  GlobalKey<HbA1CChartState> chartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
      screenName: "kpi_hba1c",
      screenClass: "HbA1COverviewController",
    );
    AppSettings.currentScreenName = 'kpi_hba1c';
  }

  reloadData(int periodFilterType) {
    _scrollController.jumpTo(0);
    if (detailKey.currentState != null) {
      detailKey.currentState!.reloadData(periodFilterType);
    }
    if (chartKey.currentState != null) {
      chartKey.currentState!.reloadData(periodFilterType);
    }
  }

  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        // backgroundColor: backgroundColor,
        body: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                R.color.color0xFFFDC798.withOpacity(0.3),
                R.color.greenbg.withOpacity(0.3),
                R.color.greenbg.withOpacity(0.3),
                R.color.color0xFFFDC798.withOpacity(0.3),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft, //FractionalOffset(1.0, 0.0),
              stops: [0.0, 0.3, 0.8, 1.0])),
      child: ListView(
          controller: _scrollController,
          physics: ClampingScrollPhysics(),
          children: [
            // FilterAction(),
            HbA1CDetail(key: detailKey),
            HbA1CChart(key: chartKey),
            SizedBox(height: 8),
            CourseSuggest(position: 8),
            SizedBox(height: 32)
          ]),
    ));
  }
}
