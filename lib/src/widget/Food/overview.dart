import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/app_setting/firebase_tracking/kpi_nutrition_tracking.dart';
import 'package:medical/src/widget/Food/food_detail_tabbar.dart';
import 'package:medical/src/widget/Food/widget/food_calorie_trend_chart.dart';

import 'package:medical/src/widget/Food/widget/food_distribution_chart.dart';
import 'package:medical/src/widget/Food/widget/food_ai_suggestion.dart';
import 'package:medical/src/widget/Food/widget/food_action_popup.dart';
import 'package:medical/src/widget/Food/widget/meal_distribution_widget.dart';
import 'package:medical/src/widget/Food/widget/nutrient_distribution_chart.dart';
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

  late final FoodBloc _overviewFoodBloc = FoodBloc();
  bool _overviewFetchSeeded = false;

  GlobalKey<FoodCalorieTrendChartState> calorieTrendKey = GlobalKey();
  GlobalKey<StarchChartState> starchKey = GlobalKey();
  GlobalKey<FoodDistributionChartState> distributionKey = GlobalKey();
  GlobalKey<MealDistributionWidgetState> mealDistributionKey = GlobalKey();
  GlobalKey<NutrientDistributionChartState> nutrientDistributionKey = GlobalKey();

  GlobalKey<FoodAISuggestionState> aiSuggestionKey = GlobalKey();

  bool _hasVisitedDetailTab = false;
  final ValueNotifier<bool> _hasFoodData = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    KpiNutritionTracking.firebaseSetup();
    _checkDetailTabVisitStatus();
  }

  @override
  void dispose() {
    _overviewFoodBloc.close();
    _hasFoodData.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_overviewFetchSeeded) {
      _overviewFetchSeeded = true;
      final p = FoodDetailTabbarController.of(context)?.periodFilterType ?? 1;
      _overviewFoodBloc.add(FetchNutritionOverview(
        periodFilterType: p.toString(),
      ));
    }
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
    // Drop "has data" UI from the previous range while the new Summary loads.
    _hasFoodData.value = false;
    _overviewFoodBloc.add(FetchNutritionOverview(
      periodFilterType: periodFilterType.toString(),
    ));
    calorieTrendKey.currentState?.reloadData(periodFilterType);
    aiSuggestionKey.currentState?.reloadData(periodFilterType);
    starchKey.currentState?.reloadData(periodFilterType);
    distributionKey.currentState?.reloadData(periodFilterType);
    mealDistributionKey.currentState?.reloadData(periodFilterType);
    nutrientDistributionKey.currentState?.reloadData(periodFilterType);
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
              color: R.color.backgroundColorNew,
            ),
            child: BlocProvider<FoodBloc>.value(
              value: _overviewFoodBloc,
              child: ListView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(bottom: 100), // Space for fixed button
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0, left: 16, right: 16),
                    child: Column(
                      children: [
                        FoodCalorieTrendChart(
                          key: calorieTrendKey,
                          periodFilterType:
                              FoodDetailTabbarController.of(context)
                                      ?.periodFilterType ??
                                  1,
                          onDataLoaded: (hasData) =>
                              _hasFoodData.value = hasData,
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: _hasFoodData,
                          builder: (context, hasData, _) {
                            if (!hasData) return SizedBox.shrink();
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: FoodAISuggestion(
                                key: aiSuggestionKey,
                                initialPeriodFilterType:
                                    FoodDetailTabbarController.of(context)
                                            ?.periodFilterType ??
                                        1,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _hasFoodData,
                    builder: (context, hasData, _) {
                      if (!hasData) return SizedBox.shrink();
                      return Column(children: [
                        NutrientDistributionChart(
                          key: nutrientDistributionKey,
                          nutritionPercent:
                              FoodDetailTabbarController.of(context)
                                  ?.widget
                                  .nutritionPercent,
                          nutritionColors:
                              FoodDetailTabbarController.of(context)
                                  ?.widget
                                  .nutritionColors,
                        ),
                        FoodDistributionChart(key: distributionKey),
                        MealDistributionWidget(key: mealDistributionKey),
                      ]);
                    },
                  ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: NutritionKnowledgeSection(),
                ),
                SizedBox(height: 36)
              ],
            ),
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
                    color: const Color.fromRGBO(1, 105, 97, 0.08),
                    blurRadius: 8,
                    offset: const Offset(2, -4),
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
                                color: const Color(0xFFAF0000),
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
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0DAB9C), Color(0xFF01847A)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          FoodActionPopup.show(context, fromDashboard: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                        ),
                        child: Text(
                          'Nhập bữa ăn',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
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
