import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/Exercrises/widget/exercrises_contain_detail.dart';
import 'package:medical/src/widget/Exercrises/widget/exercrises_ranking_chart.dart';
import 'package:medical/src/widget/Exercrises/widget/exercrises_trend_calo_chart.dart';
import 'package:medical/src/widget/Exercrises/widget/exercrises_trend_chart.dart';
import 'package:medical/src/widget/HbA1C/widget/course_%20suggest.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

class ExercrisesOverviewController extends StatefulWidget {
  ExercrisesOverviewController({Key key}) : super(key: key);
  @override
  ExercrisesOverviewControllerState createState() =>
      ExercrisesOverviewControllerState();
}

class ExercrisesOverviewControllerState
    extends State<ExercrisesOverviewController>
    with AutomaticKeepAliveClientMixin<ExercrisesOverviewController> {
  ScrollController scrollController = ScrollController();
  GlobalKey<ExercrisesDetailState> excersireKey = GlobalKey();
  GlobalKey<ExercrisesTrendChartState> exercrisesTrendChartKey = GlobalKey();
  GlobalKey<ExercrisesTrendCaloChartState> exercrisesTrendCaloChartKey =
      GlobalKey();
  GlobalKey<ExercrisesRankingChartState> exercrisesRankKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    TrackingManager.analytics
        .setCurrentScreen(screenName: 'Exercise Dashboard');
  }

  reloadData(int periodFilterType) {
    scrollController.jumpTo(0);
    if (excersireKey.currentState != null) {
      excersireKey.currentState.reloadData(periodFilterType);
    }
    if (exercrisesTrendChartKey.currentState != null) {
      exercrisesTrendChartKey.currentState.reloadData(periodFilterType);
    }
    if (exercrisesTrendCaloChartKey.currentState != null) {
      exercrisesTrendCaloChartKey.currentState.reloadData(periodFilterType);
    }
    if (exercrisesRankKey.currentState != null) {
      exercrisesRankKey.currentState.reloadData(periodFilterType);
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
          controller: scrollController,
          physics: ClampingScrollPhysics(),
          children: [
            ExercrisesDetail(key: excersireKey),
            ExercrisesTrendChart(key: exercrisesTrendChartKey),
            ExercrisesTrendCaloChart(key: exercrisesTrendCaloChartKey),
            ExercrisesRankingChart(key: exercrisesRankKey),
            CourseSuggest(position: 6),
            SizedBox(height: 36)
          ]),
    ));
  }
}
