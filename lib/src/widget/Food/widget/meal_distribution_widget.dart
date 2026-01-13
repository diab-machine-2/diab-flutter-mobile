import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/modal/food/food_statistic_distribute_model.dart';
import 'package:medical/src/widget/Food/food_detail_tabbar.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class MealDistributionWidget extends StatefulWidget {
  MealDistributionWidget({Key? key}) : super(key: key);
  @override
  MealDistributionWidgetState createState() => MealDistributionWidgetState();
}

class MealDistributionWidgetState extends State<MealDistributionWidget>
    with AutomaticKeepAliveClientMixin<MealDistributionWidget> {
  @override
  bool get wantKeepAlive => true;
  late BuildContext currentContext;
  int periodFilterType = 1;

  @override
  void initState() {
    periodFilterType = FoodDetailTabbarController.of(context)!.periodFilterType;
    super.initState();
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

            // Calculate total energy
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

                                    data.forEach((element) {
                                      if ((element.percentValue ?? 0) >= 15) {
                                        balancedCount++;
                                      } else {
                                        unbalancedCount++;
                                      }
                                    });

                                    int balancedPercent = mealCount > 0
                                        ? ((balancedCount / mealCount) * 100)
                                            .round()
                                        : 0;
                                    int unbalancedPercent =
                                        100 - balancedPercent;

                                    return Container(
                                      height: 40,
                                      child: Row(
                                        children: [
                                          // Unbalanced portion
                                          if (unbalancedPercent > 0)
                                            Expanded(
                                              flex: unbalancedPercent,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFFDB913),
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
                                          // Balanced portion
                                          if (balancedPercent > 0)
                                            Expanded(
                                              flex: balancedPercent,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF4CAF50),
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
                                  // Target Kcal
                                  Column(
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
                                ],
                              ),
                            ),
                    ],
                  ),
                );
        }));
  }
}
