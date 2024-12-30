import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/BloodSugar/widget/bloodSugar_chart.dart';
import 'package:medical/src/widget/BloodSugar/widget/bloodSugar_compare_chart.dart';
import 'package:medical/src/widget/BloodSugar/widget/bloodSugar_table.dart';
import 'package:medical/src/widget/HbA1C/widget/course_suggest.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widgets/spacing_row.dart';
import 'widget/bloodSugar_contain_detail.dart';
import 'widget/blood_glucose_item.dart';

class BloodSugarOverviewController extends StatefulWidget {
  BloodSugarOverviewController({Key? key}) : super(key: key);
  @override
  BloodSugarOverviewControllerState createState() =>
      BloodSugarOverviewControllerState();
}

class BloodSugarOverviewControllerState
    extends State<BloodSugarOverviewController>
    with AutomaticKeepAliveClientMixin<BloodSugarOverviewController>, Observer {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<BloodSugarDetailState> sugarDetailKey = GlobalKey();
  final GlobalKey<BloodSugarChartState> sugarChartKey = GlobalKey();
  final GlobalKey<BloodGlucoseItemState> latestDataKey = GlobalKey();
  final GlobalKey<BloodSugarCompareChartState> sugarCompareKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
        screenName: "kpi_glycemic",
        screenClass: "BloodSugarOverviewController");
    AppSettings.currentScreenName = 'kpi_glycemic';
  }

  // TODO: reload this
  void reloadData(int periodFilterType) {
    _scrollController.jumpTo(0);
    if (sugarDetailKey.currentState != null) {
      sugarDetailKey.currentState!.reloadData(periodFilterType);
    }
    if (sugarChartKey.currentState != null) {
      sugarChartKey.currentState!.reloadData(periodFilterType);
    }
    if (latestDataKey.currentState != null) {
      latestDataKey.currentState!.reloadData(periodFilterType);
    }
    if (sugarCompareKey.currentState != null) {
      sugarCompareKey.currentState!.reloadData(periodFilterType);
    }
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'glucose_change_data') {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
  Widget build(BuildContext context) {
    bool isGestationalDiabetes = Utils.isGestationalDiabetes();
    super.build(context);
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(R.drawable.bg_hba1c_high), fit: BoxFit.cover)),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              physics: ClampingScrollPhysics(),
              children: [
                BloodGlucoseItem(key: latestDataKey),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BloodSugarDetail(key: sugarDetailKey, periodFilterType: periodFilterType),
                ),
                BloodSugarChart(key: sugarChartKey, periodFilterType: periodFilterType),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BloodSugarCompareChart(key: sugarCompareKey, periodFilterType: periodFilterType),
                ),
                CourseSuggest(position: 2),
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
