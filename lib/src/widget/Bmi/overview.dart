import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/Bmi/widget/bmi_hiptrend_chart.dart';
import 'package:medical/src/widget/Bmi/widget/bmi_scale_chart.dart';
import 'package:medical/src/widget/Bmi/widget/bmi_trend_chart.dart';
import 'package:medical/src/widget/HbA1C/widget/course_suggest.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

class BmiOverviewController extends StatefulWidget {
  BmiOverviewController({Key? key}) : super(key: key);
  @override
  BmiOverviewControllerState createState() => BmiOverviewControllerState();
}

class BmiOverviewControllerState extends State<BmiOverviewController>
    with AutomaticKeepAliveClientMixin<BmiOverviewController> {
  ScrollController _scrollController = ScrollController();
  GlobalKey<BmiTrendChartState> bmiTrendChartKey = GlobalKey();
  GlobalKey<BmiHipTrendChartState> bmiTrendHipChartKey = GlobalKey();
  GlobalKey<BmiScaleChartState> bmiChartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
        screenName: "kpi_body_weight", screenClass: "BmiOverviewController");
  }

  reloadData(int periodFilterType) {
    _scrollController.jumpTo(0);
    if (bmiTrendChartKey.currentState != null) {
      bmiTrendChartKey.currentState!.reloadData(periodFilterType);
    }
    if (bmiTrendHipChartKey.currentState != null) {
      bmiTrendHipChartKey.currentState!.reloadData(periodFilterType);
    }
    if (bmiChartKey.currentState != null) {
      bmiChartKey.currentState!.reloadData(periodFilterType);
    }
  }

  @override
  bool get wantKeepAlive => true;
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
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
              end: Alignment.bottomLeft,
              stops: [0.0, 0.3, 0.8, 1.0])),
      child: ListView(
          controller: _scrollController,
          physics: ClampingScrollPhysics(),
          children: [
            BmiTrendChart(key: bmiTrendChartKey),
            BmiScaleChart(key: bmiChartKey),
            BmiHipTrendChart(key: bmiTrendHipChartKey),

            // BmiTrendCaloChart(key: exercrisesTrendCaloChartKey),
            // BmiRankingChart(),
            CourseSuggest(position: 4),
            SizedBox(height: 36)
          ]),
    ));
  }
}
