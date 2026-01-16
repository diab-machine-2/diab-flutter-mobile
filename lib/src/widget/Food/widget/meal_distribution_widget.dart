import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/modal/food/food_statistic_distribute_model.dart';
import 'package:medical/src/widget/Food/food_detail_tabbar.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MealDistributionWidget extends StatefulWidget {
  MealDistributionWidget({Key? key}) : super(key: key);
  @override
  MealDistributionWidgetState createState() => MealDistributionWidgetState();
}

class MealDistributionWidgetState extends State<MealDistributionWidget>
    with AutomaticKeepAliveClientMixin<MealDistributionWidget>, Observer {
  @override
  bool get wantKeepAlive => true;
  late BuildContext currentContext;
  int periodFilterType = 1;
  bool _hasVisitedMealInput = false;

  @override
  void initState() {
    periodFilterType = FoodDetailTabbarController.of(context)!.periodFilterType;
    super.initState();
    Observable.instance.addObserver(this);
    _checkMealInputVisitStatus();
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'food_change_data') {
      _refresh();
    }
  }

  void _checkMealInputVisitStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _hasVisitedMealInput = prefs.getBool('has_visited_meal_input') ?? false;
    if (mounted) {
      setState(() {});
    }
  }

  void _markMealInputAsVisited() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_visited_meal_input', true);
    _hasVisitedMealInput = true;
    if (mounted) {
      setState(() {});
    }
  }

  reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    _refresh();
  }

  Future<bool> _refresh() async {
    BlocProvider.of<FoodBloc>(currentContext).add(FetchFoodGroupDistribute(
      currentDateTime:
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      periodFilterType: periodFilterType.toString(),
    ));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<FoodBloc>(
        create: (context) => FoodBloc(),
        child: BlocBuilder<FoodBloc, FoodState>(
            builder: (BuildContext context, FoodState state) {
          currentContext = context;
          FoodDistributeModel? model;
          double totalEnergy = 0;
          int mealCount = 0;

          if (state is FoodInitial) {
            BlocProvider.of<FoodBloc>(context).add(FetchFoodGroupDistribute(
              currentDateTime:
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
              periodFilterType: periodFilterType.toString(),
            ));
          }
          if (state is FoodError) {
            Message.showToastMessage(context, state.message);
          }

          if (state is FoodGroupDistributeLoaded) {
            model = state.model;
            final data = model!.energyChart;
            mealCount = data.length;

            // Calculate total energy - update
            data.forEach((element) {
              totalEnergy += element.value ?? 0;
            });
          }

          return model == null
              ? Container(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()))
              : Padding(
                  padding:
                      EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      mealCount == 0
                          ? SizedBox.shrink()
                          : Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Color(0xFFF5F5F5)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Phân bổ bữa ăn',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: R.color.black,
                                        ),
                                      ),
                                      Text(
                                        '$mealCount bữa ăn',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: R.color.primaryGreyColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  // Horizontal bar chart
                                  Builder(builder: (context) {
                                    final data = model!.energyChart;
                                    int balancedCount = 0;
                                    int unbalancedCount = 0;
                                    int actualMealCount = 0;

                                    data.forEach((element) {
                                      // Only count meals with actual data
                                      if ((element.value ?? 0) > 0) {
                                        actualMealCount++;
                                        if ((element.percentValue ?? 0) >= 15) {
                                          balancedCount++;
                                        } else {
                                          unbalancedCount++;
                                        }
                                      }
                                    });

                                    int balancedPercent = actualMealCount > 0
                                        ? ((balancedCount / actualMealCount) *
                                                100)
                                            .round()
                                        : 0;
                                    int unbalancedPercent =
                                        100 - balancedPercent;

                                    // Debug log
                                    print('🍽️ Meal Distribution Debug:');
                                    print('  Total meals: ${data.length}');
                                    print(
                                        '  Actual meals (value > 0): $actualMealCount');
                                    print(
                                        '  Balanced (>= 15%): $balancedCount');
                                    print(
                                        '  Unbalanced (< 15%): $unbalancedCount');
                                    print('  Balanced %: $balancedPercent');
                                    print('  Unbalanced %: $unbalancedPercent');
                                    data.forEach((e) {
                                      print(
                                          '    - ${e.text}: ${e.value} Kcal, ${e.percentValue}%');
                                    });

                                    return Container(
                                      height: 40,
                                      child: Row(
                                        children: [
                                          // Unbalanced portion - Yellow (bad)
                                          if (unbalancedPercent > 0)
                                            Expanded(
                                              flex: unbalancedPercent,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color(
                                                      0xFFFDB913), // Yellow - chưa cân bằng
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '$unbalancedPercent%',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          // Balanced portion - Green (good)
                                          if (balancedPercent > 0)
                                            Expanded(
                                              flex: balancedPercent,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color(
                                                      0xFF4CAF50), // Green - cân bằng
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '$balancedPercent%',
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
                                    );
                                  }),
                                  SizedBox(height: 16),
                                  // Legend
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFFDB913),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Chưa cân bằng',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: R.color.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF4CAF50),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Cân bằng',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: R.color.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Divider(height: 1, color: Colors.grey[300]),
                                  SizedBox(height: 16),
                                  // Target Kcal with border
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Mục tiêu Kcal',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: R.color.primaryGreyColor,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '${totalEnergy.toInt()} Kcal',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: R.color.mainColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  // Sample Menu Button
                                  GestureDetector(
                                    onTap: () {
                                      // TODO: Navigate to sample menu
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                      ),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            R.drawable.im_food_intro,
                                            width: 48,
                                            height: 48,
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Thực đơn mẫu',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                color: R.color.black,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: R.color.black,
                                            size: 24,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // SizedBox(height: 12),
                                  // // Input Meal Section (icon + button) - Hidden because of fixed bottom button
                                  // Row(
                                  //   crossAxisAlignment:
                                  //       CrossAxisAlignment.center,
                                  //   children: [
                                  //     // Icon with notification badge
                                  //     Stack(
                                  //       clipBehavior: Clip.none,
                                  //       children: [
                                  //         Container(
                                  //           width: 48,
                                  //           height: 48,
                                  //           decoration: BoxDecoration(
                                  //             color: R.color.mainColor
                                  //                 .withOpacity(0.1),
                                  //             borderRadius:
                                  //                 BorderRadius.circular(12),
                                  //           ),
                                  //           child: Center(
                                  //             child: Image.asset(
                                  //               R.drawable.ic_view_detail,
                                  //               width: 24,
                                  //               height: 24,
                                  //               color: R.color.mainColor,
                                  //             ),
                                  //           ),
                                  //         ),
                                  //         // Red notification dot
                                  //         if (!_hasVisitedMealInput)
                                  //           Positioned(
                                  //             top: -2,
                                  //             right: -2,
                                  //             child: Container(
                                  //               width: 12,
                                  //               height: 12,
                                  //               decoration: BoxDecoration(
                                  //                 color: Colors.red,
                                  //                 shape: BoxShape.circle,
                                  //                 border: Border.all(
                                  //                   color: Colors.white,
                                  //                   width: 2,
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //           ),
                                  //       ],
                                  //     ),
                                  //     SizedBox(width: 12),
                                  //     // Large Button
                                  //     Expanded(
                                  //       child: ElevatedButton(
                                  //         onPressed: () {
                                  //           _markMealInputAsVisited();
                                  //           // TODO: Navigate to add meal
                                  //         },
                                  //         style: ElevatedButton.styleFrom(
                                  //           backgroundColor: R.color.mainColor,
                                  //           shape: RoundedRectangleBorder(
                                  //             borderRadius:
                                  //                 BorderRadius.circular(100),
                                  //           ),
                                  //           padding: EdgeInsets.symmetric(
                                  //               vertical: 18),
                                  //           elevation: 0,
                                  //         ),
                                  //         child: Text(
                                  //           'Nhập bữa ăn',
                                  //           style: TextStyle(
                                  //             fontSize: 16,
                                  //             fontWeight: FontWeight.w700,
                                  //             color: Colors.white,
                                  //           ),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                    ],
                  ),
                );
        }));
  }
}
