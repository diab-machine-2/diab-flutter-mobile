import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/modal/food/food_statistic_distribute_model.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/Food/daily_nutrition/daily_nutrition.dart';
import 'package:medical/src/widget/Food/food_detail_tabbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/empty_data_box.dart';

class FoodDistributionChart extends StatefulWidget {
  FoodDistributionChart({Key? key}) : super(key: key);
  @override
  FoodDistributionChartState createState() => FoodDistributionChartState();
}

class FoodDistributionChartState extends State<FoodDistributionChart>
    with AutomaticKeepAliveClientMixin<FoodDistributionChart> {
  @override
  bool get wantKeepAlive => true;
  int periodFilterType = 1;
  int? touchIndex;

  @override
  void initState() {
    periodFilterType = FoodDetailTabbarController.of(context)!.periodFilterType;
    super.initState();
  }

  reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<FoodBloc, FoodState>(
        builder: (BuildContext context, FoodState state) {
          FoodDistributeModel? model;
          double total = 0;
          if (state is FoodError) {
            Message.showToastMessage(context, state.message);
          }

          if (state is FoodNutritionOverviewLoaded) {
            model = state.distributeModel;
            for (final element in state.distributeModel.energyChart) {
              total += element.percentValue!;
            }
          } else if (state is FoodStatisticDistributeLoaded) {
            model = state.model;
            if (model != null) {
              for (final element in model.energyChart) {
                total += element.percentValue!;
              }
            }
          }
          return model == null
              ? Container(
                  height: 491.5,
                  child: Center(child: CircularProgressIndicator()))
              : Padding(
                  padding:
                      EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      total == 0
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
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromRGBO(1, 105, 97, 0.08),
                                      offset: const Offset(1, 2),
                                      blurRadius: 8,
                                    ),
                                  ]),
                              child: Column(
                                children: [
                                  // Header with title and arrow
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        R.string.nang_luong_phan_bo.tr(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: R.color.black,
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: R.color.black,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 24),
                                  // Donut chart and legend
                                  Builder(builder: (context) {
                                    // Count only meals with actual data
                                    int actualMealCount = model!.energyChart
                                        .where((item) => (item.value ?? 0) > 0)
                                        .length;

                                    return Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                PieChart(
                                                  PieChartData(
                                                    startDegreeOffset: 270,
                                                    borderData: FlBorderData(
                                                      show: false,
                                                    ),
                                                    sectionsSpace: 0,
                                                    centerSpaceRadius: 44, // 2*(44+40) = 168px (Figma size)
                                                    sections: List.generate(
                                                        model.energyChart
                                                            .length, (i) {
                                                      final double radius = 40;
                                                      final item =
                                                          model!.energyChart[i];
                                                      final percent =
                                                          (item.percentValue ??
                                                                  0)
                                                              .round();

                                                      return PieChartSectionData(
                                                        color: toColor(
                                                            item.colorCode),
                                                        value:
                                                            item.percentValue,
                                                        title: percent > 0
                                                            ? '$percent%'
                                                            : '',
                                                        titleStyle: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Colors.white,
                                                        ),
                                                        radius: radius,
                                                      );
                                                    }),
                                                  ),
                                                ),
                                                // Center content - meal count only
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '$actualMealCount',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Color(0xFF111515),
                                                        letterSpacing: 0.04,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Bữa ăn',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Color(0xFF111515),
                                                        letterSpacing: 0.4,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 32),
                                        // Legend
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: List.generate(
                                              model.energyChart.length, (i) {
                                            final item = model!.energyChart[i];
                                            return Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 12),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 12,
                                                    height: 12,
                                                    decoration: BoxDecoration(
                                                      color: toColor(
                                                          item.colorCode),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    item.text ?? '',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: R.color.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ),
                                        SizedBox(width: 16),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                    ],
                  ),
                );
        });
  }
}
