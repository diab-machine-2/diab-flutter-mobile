import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/widget/BloodSugar/widget/bloodSugar_chart.dart';
import 'package:medical/src/widget/BloodSugar/widget/bloodSugar_compare_chart.dart';
import 'package:medical/src/widget/HbA1C/widget/course_suggest.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'widget/bloodSugar_contain_detail.dart';

class BloodSugarOverviewController extends StatefulWidget {
  BloodSugarOverviewController({Key? key}) : super(key: key);
  @override
  BloodSugarOverviewControllerState createState() =>
      BloodSugarOverviewControllerState();
}

class BloodSugarOverviewControllerState
    extends State<BloodSugarOverviewController>
    with AutomaticKeepAliveClientMixin<BloodSugarOverviewController> {
  ScrollController _scrollController = ScrollController();
  GlobalKey<BloodSugarDetailState> sugarDetailKey = GlobalKey();
  GlobalKey<BloodSugarChartState> sugarChartKey = GlobalKey();
  GlobalKey<BloodSugarCompareChartState> sugarCompareKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
        screenName: "kpi_glycemic",
        screenClass: "BloodSugarOverviewController");
    AppSettings.currentScreenName = 'kpi_glycemic';
  }

  reloadData(int periodFilterType) {
    _scrollController.jumpTo(0);
    if (sugarDetailKey.currentState != null) {
      sugarDetailKey.currentState!.reloadData(periodFilterType);
    }
    if (sugarChartKey.currentState != null) {
      sugarChartKey.currentState!.reloadData(periodFilterType);
    }
    if (sugarCompareKey.currentState != null) {
      sugarCompareKey.currentState!.reloadData(periodFilterType);
    }
  }

  @override
  bool get wantKeepAlive => true;
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
            BloodSugarDetail(key: sugarDetailKey),
            BloodSugarChart(key: sugarChartKey),
            BloodSugarCompareChart(key: sugarCompareKey),
            CourseSuggest(position: 2),
            SizedBox(height: 36)
          ]),
    ));
  }
}

class KeyboardVisibilityObserver extends WidgetsBindingObserver {
  final Function(bool) callback;

  KeyboardVisibilityObserver(this.callback);

  @override
  void didChangeMetrics() {
    final isKeyboardVisible =
        WidgetsBinding.instance.window.viewInsets.bottom > 0;
    callback(isKeyboardVisible);
  }
}
