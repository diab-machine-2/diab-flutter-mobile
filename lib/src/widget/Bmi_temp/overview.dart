import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/firebase_tracking/kpi_body_weight_tracking.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/Bmi/widget/bmi_hiptrend_chart.dart';
import 'package:medical/src/widget/Bmi/widget/bmi_scale_chart.dart';
import 'package:medical/src/widget/Bmi/widget/bmi_trend_chart.dart';
import 'package:medical/src/widget/HbA1C/widget/course_suggest.dart';
import 'package:medical/src/widgets/spacing_row.dart';

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
    KpiBodyWeightTracking.firebaseSetup();
  }

  reloadData(int periodFilterType) {
    BotToast.closeAllLoading();
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
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;
  Widget build(BuildContext context) {
    bool isGestationalDiabetes = Utils.isGestationalDiabetes();
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: _scrollController,
                physics: ClampingScrollPhysics(),
                children: [
                  BmiTrendChart(key: bmiTrendChartKey),
                  if (!isGestationalDiabetes) BmiScaleChart(key: bmiChartKey),
                  if (!isGestationalDiabetes)
                    BmiHipTrendChart(key: bmiTrendHipChartKey),

                  // BmiTrendCaloChart(key: exercrisesTrendCaloChartKey),
                  // BmiRankingChart(),
                  CourseSuggest(position: 4),
                  SizedBox(height: 36),
                ],
              ),
            ),
            if (isGestationalDiabetes)
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      offset: Offset(4, 0),
                      blurRadius: 2,
                      color: Colors.black.withOpacity(0.03))
                ]),
                child: SpacingRow(
                  spacing: 15,
                  children: [
                    Image.asset(
                      R.drawable.ic_pregnancy,
                      width: 20,
                    ),
                    Expanded(
                      child: Text(
                          'Chào ${AppSettings.userInfo!.fullName!.split(' ').last}, mừng bạn đang ở tuần ${AppSettings.userInfo!.curentWeekPregnancy ?? 0} của thai kỳ'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
