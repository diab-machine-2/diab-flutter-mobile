import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/Emotion/widget/emotion_activity_chart.dart';
import 'package:medical/src/widget/Emotion/widget/emotion_symptom_chart.dart';
import 'package:medical/src/widget/Emotion/widget/emotion_distribution_chart.dart';
import 'package:medical/src/widget/HbA1C/widget/course_%20suggest.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

class EmotionOverviewController extends StatefulWidget {
  EmotionOverviewController({Key key}) : super(key: key);
  @override
  EmotionOverviewControllerState createState() =>
      EmotionOverviewControllerState();
}

class EmotionOverviewControllerState extends State<EmotionOverviewController>
    with AutomaticKeepAliveClientMixin<EmotionOverviewController> {
  ScrollController scrollController = ScrollController();
  GlobalKey<EmotionDistributionChartState> emotionChartKey = GlobalKey();
  GlobalKey<EmotionSymptomChartState> symptomChartKey = GlobalKey();
  GlobalKey<EmotionActivityChartState> activityChartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    TrackingManager.analytics.setCurrentScreen(screenName: 'Emotion Dashboard');
  }

  reloadData(int periodFilterType) {
    scrollController.jumpTo(0);
    if (emotionChartKey.currentState != null) {
      emotionChartKey.currentState.reloadData(periodFilterType);
    }
    if (symptomChartKey.currentState != null) {
      symptomChartKey.currentState.reloadData(periodFilterType);
    }
    if (activityChartKey.currentState != null) {
      activityChartKey.currentState.reloadData(periodFilterType);
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
            EmotionDistributionChart(key: emotionChartKey),
            EmotionSymptomChart(key: symptomChartKey),
            EmotionActivityChart(key: activityChartKey),
            CourseSuggest(position: 5),
            SizedBox(height: 36)
          ]),
    ));
  }
}
