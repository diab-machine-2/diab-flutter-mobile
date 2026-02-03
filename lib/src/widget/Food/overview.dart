import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_tracking/kpi_nutrition_tracking.dart';
import 'package:medical/src/widget/Food/food_detail_tabbar.dart';
import 'package:medical/src/widget/Food/widget/energy_chart.dart';
import 'package:medical/src/widget/Food/widget/food_chart.dart';
import 'package:medical/src/widget/Food/widget/food_distribution_chart.dart';
import 'package:medical/src/widget/Food/widget/food_ai_suggestion.dart';
import 'package:medical/src/widget/Food/widget/food_action_popup.dart';
import 'package:medical/src/widget/Food/widget/meal_distribution_widget.dart';
import 'package:medical/src/widget/Food/widget/nutrient_distribution_chart.dart';
import 'package:medical/src/widget/Food/widget/food_trend_chart.dart';
import 'package:medical/src/widget/Food/widget/starch_chart.dart';
import 'package:medical/src/widget/Food/widget/nutrition_knowledge_section.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  GlobalKey<MealDistributionWidgetState> mealDistributionKey = GlobalKey();
  GlobalKey<NutrientDistributionChartState> nutrientDistributionKey =
      GlobalKey();
  GlobalKey<FoodTrendChartState> trendKey = GlobalKey();
  GlobalKey<FoodChartState> foodKey = GlobalKey();
  GlobalKey<FoodAISuggestionState> aiSuggestionKey = GlobalKey();

  bool _hasVisitedDetailTab = false;

  @override
  void initState() {
    super.initState();
    KpiNutritionTracking.firebaseSetup();
    _checkDetailTabVisitStatus();
  }

  void _checkDetailTabVisitStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _hasVisitedDetailTab =
        prefs.getBool('has_visited_food_detail_tab') ?? false;
    if (mounted) {
      setState(() {});
    }
  }

  void _markDetailTabAsVisited() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_visited_food_detail_tab', true);
    _hasVisitedDetailTab = true;
    if (mounted) {
      setState(() {});
    }
  }

  reloadData(int periodFilterType) {
    if (energyKey.currentState != null) {
      energyKey.currentState!.reloadData(periodFilterType);
    }
    if (aiSuggestionKey.currentState != null) {
      aiSuggestionKey.currentState!.reloadData(periodFilterType);
    }
    if (starchKey.currentState != null) {
      starchKey.currentState!.reloadData(periodFilterType);
    }
    if (distributionKey.currentState != null) {
      distributionKey.currentState!.reloadData(periodFilterType);
    }
    if (mealDistributionKey.currentState != null) {
      mealDistributionKey.currentState!.reloadData(periodFilterType);
    }
    if (trendKey.currentState != null) {
      trendKey.currentState!.reloadData(periodFilterType);
    }
    if (foodKey.currentState != null) {
      foodKey.currentState!.reloadData(periodFilterType);
    }
    if (nutrientDistributionKey.currentState != null) {
      nutrientDistributionKey.currentState!.reloadData(periodFilterType);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Stack(
        children: [
          // Scrollable content
          Container(
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
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(bottom: 100), // Space for fixed button
              children: [
                EnergyChart(key: energyKey),
                FoodAISuggestion(
                    key: aiSuggestionKey, initialPeriodFilterType: 1),
                // StarchChart(key: starchKey), // Hidden per user request
                FoodChart(key: foodKey),
                FoodTrendChart(key: trendKey),
                NutrientDistributionChart(key: nutrientDistributionKey),
                FoodDistributionChart(key: distributionKey),
                MealDistributionWidget(key: mealDistributionKey),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: NutritionKnowledgeSection(),
                ),
                SizedBox(height: 36)
              ],
            ),
          ),
          // Fixed bottom button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon with notification badge
                  InkWell(
                    onTap: () {
                      _markDetailTabAsVisited();
                      // Navigate to Detail tab
                      final tabbarController =
                          FoodDetailTabbarController.of(context);
                      if (tabbarController != null) {
                        tabbarController.switchToTab(1); // Index 1 = Detail tab
                      }
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 60,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(0xffDCFFFC),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Center(
                            child: Image.asset(
                              R.drawable.ic_view_detail,
                              width: 20,
                              height: 20,
                              color: R.color.mainColor,
                            ),
                          ),
                        ),
                        // Red notification dot - only show if not visited
                        if (!_hasVisitedDetailTab)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  // Large Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        FoodActionPopup.show(context, fromDashboard: true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: R.color.mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                      ),
                      child: Text(
                        'Nhập bữa ăn',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
