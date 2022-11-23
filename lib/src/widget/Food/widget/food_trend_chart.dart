import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/modal/food/food_statistic_trend_model.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/Food/daily_nutrition/daily_nutrition.dart';
import 'package:medical/src/widget/Food/food_detail_tabbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/empty_data_box.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'food_trend_chart_tab_bar.dart';
import 'food_trend_chart_tab_view.dart';

class FoodTrendChart extends StatefulWidget {
  FoodTrendChart({Key? key}) : super(key: key);
  @override
  FoodTrendChartState createState() => FoodTrendChartState();
}

class FoodTrendChartState extends State<FoodTrendChart>
    with AutomaticKeepAliveClientMixin<FoodTrendChart> {
  @override
  bool get wantKeepAlive => true;

  late BuildContext currentContext;
  int periodFilterType = 1;
  late PageController pageController;
  bool isEnergy = true;

  @override
  void initState() {
    pageController = PageController(initialPage: 0);
    periodFilterType = FoodDetailTabbarController.of(context)!.periodFilterType;
    super.initState();
  }

  reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    _refresh();
  }

  Future<bool> _refresh() async {
    BlocProvider.of<FoodBloc>(currentContext).add(FetchStatisticTrend(
      currentDateTime:
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      periodFilterType: periodFilterType.toString(),
    ));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final width = MediaQuery.of(context).size.width;
    return BlocProvider<FoodBloc>(
        create: (context) => FoodBloc(),
        child: BlocBuilder<FoodBloc, FoodState>(
            builder: (BuildContext context, FoodState state) {
          currentContext = context;
          FoodTrendModel? model;
          if (state is FoodInitial) {
            BlocProvider.of<FoodBloc>(context).add(FetchStatisticTrend(
              currentDateTime:
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
              periodFilterType: periodFilterType.toString(),
            ));
          }
          if (state is FoodError) {
            Message.showToastMessage(context, state.message);
          }

          if (state is FoodStatisticTrendLoaded) {
            model = state.model;
          }
          return model == null
              ? Container(
                  height: 491.5,
                  child: Center(child: CircularProgressIndicator()))
              : Container(
                  color: R.color.transparent,
                  padding:
                      EdgeInsets.only(left: 18, right: 18, bottom: 18, top: 18),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(R.string.xu_huong_dinh_duong.tr(),
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        SizedBox(height: 23),
                        (model.energyChart.items.length == 0)
                            ? EmptyDataBox(
                                text: "chỉ số Dinh dưỡng",
                                onTap: () {
                                  NavigationUtil.navigatePage(
                                    context,
                                    DailyNutritionPage(
                                      type: 'input',
                                      id: null,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: R.color.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: R.color.grey.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 7,
                                      offset: Offset(
                                          0, 2), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: buildChart(model),
                              ),
                        // SizedBox(height: 26),
                      ]),
                );
        }));
  }

  buildChart(FoodTrendModel foodTrendModel) {
    final width = (MediaQuery.of(context).size.width - 200) / 5;
    return Padding(
      padding: EdgeInsets.only(top: 20, bottom: 0, right: 8, left: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FoodTrendChartTabBar(
            onEnergyTap: () async {
              pageController.jumpToPage(0);
            },
            onCarbTap: () async {
              pageController.jumpToPage(1);
            },
          ),
          SizedBox(height: 36),
          Container(
            height: 350,
            child: PageView(
              controller: pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                FoodTrendChartTabView(
                    model: foodTrendModel.energyChart, width: width, type: 0),
                FoodTrendChartTabView(
                    model: foodTrendModel.carbChart, width: width, type: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
