import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/Food/widget/energy_chart.dart';
import 'package:medical/src/widget/Food/widget/food_chart.dart';
import 'package:medical/src/widget/Food/widget/food_distribution_chart.dart';
import 'package:medical/src/widget/Food/widget/food_trend_chart.dart';
import 'package:medical/src/widget/Food/widget/starch_chart.dart';
import 'package:medical/src/widget/HbA1C/widget/course_%20suggest.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

class FoodOverviewController extends StatefulWidget {
  FoodOverviewController({
    Key? key,
  }) : super(key: key);
  @override
  FoodOverviewControllerState createState() => FoodOverviewControllerState();
}

class FoodOverviewControllerState extends State<FoodOverviewController>
    with AutomaticKeepAliveClientMixin<FoodOverviewController> {
  @override
  bool get wantKeepAlive => true;

  GlobalKey<EnergyChartState> energyKey = GlobalKey();
  GlobalKey<StarchChartState> starchKey = GlobalKey();
  GlobalKey<FoodDistributionChartState> distributionKey = GlobalKey();
  GlobalKey<FoodTrendChartState> trendKey = GlobalKey();
  GlobalKey<FoodChartState> foodKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    TrackingManager.analytics.setCurrentScreen(screenName: 'Diet Dashboard');
  }

  reloadData(int periodFilterType) {
    if (energyKey.currentState != null) {
      energyKey.currentState!.reloadData(periodFilterType);
    }
    if (starchKey.currentState != null) {
      starchKey.currentState!.reloadData(periodFilterType);
    }
    if (distributionKey.currentState != null) {
      distributionKey.currentState!.reloadData(periodFilterType);
    }
    if (trendKey.currentState != null) {
      trendKey.currentState!.reloadData(periodFilterType);
    }
    if (foodKey.currentState != null) {
      foodKey.currentState!.reloadData(periodFilterType);
    }
  }

  @override
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
              end: Alignment.bottomLeft,
              stops: const [0.0, 0.3, 0.8, 1.0])),
      child: ListView(physics: const ClampingScrollPhysics(), children: [
        EnergyChart(key: energyKey),
        StarchChart(key: starchKey),
        FoodChart(key: foodKey),
        FoodTrendChart(key: trendKey),
        FoodDistributionChart(key: distributionKey),
        CourseSuggest(position: 7),
        SizedBox(height: 36)
      ]),
    ));
  }
}
