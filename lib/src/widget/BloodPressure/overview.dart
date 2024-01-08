import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_tracking/kpi_blood_pressure_tracking.dart';
import 'package:medical/src/widget/BloodPressure/widget/bloodPressure_chart.dart';
import 'package:medical/src/widget/BloodPressure/widget/bloodPressure_distribution_chart.dart';
import 'package:medical/src/widget/BloodPressure/widget/heart_chart.dart';
import 'package:medical/src/widget/HbA1C/widget/course_suggest.dart';
import 'widget/bloodPressure_contain_detail.dart';

class BloodPressureOverviewController extends StatefulWidget {
  BloodPressureOverviewController({Key? key}) : super(key: key);
  @override
  BloodPressureOverviewControllerState createState() =>
      BloodPressureOverviewControllerState();
}

class BloodPressureOverviewControllerState
    extends State<BloodPressureOverviewController>
    with AutomaticKeepAliveClientMixin<BloodPressureOverviewController> {
  ScrollController _scrollController = ScrollController();

  GlobalKey<BloodPressureDetailState> bloodPressureDetailKey = GlobalKey();
  GlobalKey<BloodPressureDistributionChartState>
      bloodPressureDistributionChart = GlobalKey();
  GlobalKey<BloodPressureChartState> bloodPressureTrendKey = GlobalKey();
  GlobalKey<HeartChartState> bloodPressureHeartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    KpiBloodPressureTracking.firebaseSetup();
  }

  reloadData(int periodFilterType) {
    _scrollController.jumpTo(0);
    if (bloodPressureDetailKey.currentState != null) {
      bloodPressureDetailKey.currentState!.reloadData(periodFilterType);
    }
    if (bloodPressureDistributionChart.currentState != null) {
      bloodPressureDistributionChart.currentState!.reloadData(periodFilterType);
    }
    if (bloodPressureTrendKey.currentState != null) {
      bloodPressureTrendKey.currentState!.reloadData(periodFilterType);
    }
    if (bloodPressureHeartKey.currentState != null) {
      bloodPressureHeartKey.currentState!.reloadData(periodFilterType);
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(R.drawable.bg_hba1c_high), fit: BoxFit.cover)),
      child: ListView(
          controller: _scrollController,
          physics: ClampingScrollPhysics(),
          children: [
            BloodPressureDetail(key: bloodPressureDetailKey),
            BloodPressureDistributionChart(key: bloodPressureDistributionChart),
            BloodPressureChart(key: bloodPressureTrendKey),
            HeartChart(key: bloodPressureHeartKey),
            CourseSuggest(position: 3),
            SizedBox(height: 36)
          ]),
    ));
  }
}
