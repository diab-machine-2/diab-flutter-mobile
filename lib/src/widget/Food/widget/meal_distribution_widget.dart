import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/modal/food/food_statistic_distribute_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/widget/Food/food_detail_tabbar.dart';
import 'package:medical/src/widget/food_menu_screens/food_menu/food_menu_page.dart';
import 'package:medical/src/widget/food_menu_screens/intro_sample_menu/intro_sample_menu_page.dart';
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
    BlocProvider.of<FoodBloc>(currentContext).add(FetchStatisticDistribute(
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
          int balancedMealCount = 0;

          if (state is FoodInitial) {
            BlocProvider.of<FoodBloc>(context).add(FetchStatisticDistribute(
              currentDateTime:
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
              periodFilterType: periodFilterType.toString(),
            ));
          }
          if (state is FoodError) {
            Message.showToastMessage(context, state.message);
          }

          if (state is FoodStatisticDistributeLoaded) {
            model = state.model;
            final data = model!.energyChart;
            mealCount = state.totalMealCount ?? 0;
            balancedMealCount = state.balancedCount ?? 0;

            if (mealCount == 0) {
              // Fallback if raw input count fails
              mealCount = data.where((item) => (item.value ?? 0) > 0).length;
            }

            totalEnergy = 0;
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
                                  color: Colors.white),
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
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '$mealCount',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: R.color.black,
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' bữa ăn',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: R.color.primaryGreyColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  // Horizontal bar chart
                                  Builder(builder: (context) {
                                    int balancedPercent = mealCount > 0
                                        ? ((balancedMealCount / mealCount) * 100).round()
                                        : 0;
                                    int unbalancedPercent = 100 - balancedPercent;

                                    return Container(
                                      height: 36,
                                      child: Row(
                                        children: [
                                          // Unbalanced portion - Yellow
                                          if (unbalancedPercent > 0)
                                            Expanded(
                                              flex: unbalancedPercent,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFFDB913),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                alignment: Alignment.centerLeft,
                                                padding: EdgeInsets.symmetric(horizontal: 14),
                                                child: Text(
                                                  '$unbalancedPercent%',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          if (unbalancedPercent > 0 && balancedPercent > 0)
                                            SizedBox(width: 3),
                                          // Balanced portion - Green
                                          if (balancedPercent > 0)
                                            Expanded(
                                              flex: balancedPercent,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF4CAF50),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                alignment: Alignment.center,
                                                padding: EdgeInsets.symmetric(horizontal: 8),
                                                child: Text(
                                                  '$balancedPercent%',
                                                  style: TextStyle(
                                                    fontSize: 15,
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
                                            width: 24,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFFDB913),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Chưa cân bằng',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF5E6566),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF4CAF50),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Cân bằng',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF5E6566),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                      // Mục tiêu Kcal - separate card
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                            Icon(
                              Icons.edit_outlined,
                              color: Colors.grey[400],
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                      // Thực đơn mẫu - separate card
                      SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final repository = AppRepository();
                          final result =
                              await repository.getCurrentUserInfo();
                          result.when(
                            success: (userInfoResponse) {
                              if (userInfoResponse.data?.hasFoodMenu ==
                                  true) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FoodMenuPage(),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        IntroSampleMenuPage(),
                                  ),
                                );
                              }
                            },
                            failure: (error) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      IntroSampleMenuPage(),
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
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
                    ],
                  ),
                );
        }));
  }
}
