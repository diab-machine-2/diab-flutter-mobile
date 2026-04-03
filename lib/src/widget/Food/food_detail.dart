import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loadmore/loadmore.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/modal/food/food_input_model.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/Food/food_detail_tabbar.dart';
import 'package:medical/src/widget/components/load_more.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';

import 'daily_nutrition/daily_nutrition.dart';

class FoodDetailController extends StatefulWidget {
  final int? periodFilterType;
  FoodDetailController({Key? key, this.periodFilterType}) : super(key: key);
  @override
  FoodDetailControllerState createState() => FoodDetailControllerState();
}

class FoodDetailControllerState extends State<FoodDetailController>
    with AutomaticKeepAliveClientMixin<FoodDetailController> {
  @override
  bool get wantKeepAlive => true;

  late BuildContext currentContext;

  ScrollController scrollController = ScrollController();

  int periodFilterType = 1;

  int page = 1;
  bool hasMore = false;
  bool isLoading = false;

  @override
  void initState() {
    // Use passed periodFilterType or get from parent controller
    if (widget.periodFilterType != null) {
      periodFilterType = widget.periodFilterType!;
    } else {
      final controller = FoodDetailTabbarController.of(context);
      if (controller != null) {
        periodFilterType = controller.periodFilterType;
      }
    }
    super.initState();
  }

  reloadData(int periodFilter) {
    scrollController.jumpTo(0);
    periodFilterType = periodFilter;
    refresh();
  }

  Future<bool> _loadMore() async {
    if (isLoading || !hasMore) {
      return true;
    } else {
      isLoading = true;
      BlocProvider.of<FoodBloc>(currentContext).add(FetchInputFood(
          currentDateTime:
              (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
          periodFilterType: periodFilterType.toString(),
          page: page));
    }
    return true;
  }

  Future<bool> refresh() async {
    page = 1;
    BlocProvider.of<FoodBloc>(currentContext).add(FetchInputFood(
        currentDateTime:
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        periodFilterType: periodFilterType.toString(),
        page: 1));
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
          List<MealDayItemModel>? model;
          if (state is FoodInitial) {
            BlocProvider.of<FoodBloc>(context).add(FetchInputFood(
                currentDateTime:
                    (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
                periodFilterType: periodFilterType.toString(),
                page: 1));
          }
          if (state is FoodError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is FoodInputLoaded) {
            model = state.inputs;
            hasMore = false;
            if (hasMore) {
              page += 1;
            }
            isLoading = false;
          }
          return RefreshIndicator(
              onRefresh: refresh,
              child: Scaffold(
                backgroundColor: R.color.backgroundColorNew,
                body: model == null
                    ? Center(child: CircularProgressIndicator())
                    : model.isEmpty
                        ? _buildEmptyState()
                        : LoadMore(
                            onLoadMore: _loadMore,
                            isFinish: !hasMore,
                            whenEmptyLoad: false,
                            delegate: CustomLoadMoreDelegate(),
                            textBuilder: DefaultLoadMoreTextBuilder.english,
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: model.length,
                              physics: AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.only(bottom: 100),
                              itemBuilder: (BuildContext context, int index) {
                                final element = model![index];
                                return _buildDayGroup(element);
                              },
                            )),
              ));
        }));
  }

  /// Empty state when no data
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu,
              size: 64, color: R.color.color0xffBFC6C6),
          const SizedBox(height: 16),
          Text(
            'Chưa có dữ liệu dinh dưỡng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: R.color.color0xff636A6B,
            ),
          ),
        ],
      ),
    );
  }

  /// Build one day group (date header + list of meal items)
  Widget _buildDayGroup(MealDayItemModel element) {
    // Flatten all inputs from all meal groups into a single list
    final List<FoodInputModel> allInputs = [];
    for (final mealItem in element.mealItems) {
      allInputs.addAll(mealItem.inputs);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header — Figma: fontSize 20, Bold, #111515
        Padding(
          padding: EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 12),
          child: Row(
            children: [
              Text(
                convertCustomDate(element.date!),
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111515),
                  letterSpacing: 0.04,
                ),
              ),
            ],
          ),
        ),
        // List of individual meal input cards
        ...allInputs
            .map((inputModel) => _buildMealInputCard(inputModel))
            .toList(),
      ],
    );
  }

  /// Build a single meal input card matching the Figma design
  Widget _buildMealInputCard(FoodInputModel inputModel) {
    // Extract data with fallbacks
    final int score = inputModel.totalMealScore ?? 0;
    final double totalKcal = inputModel.totalCalories ??
        inputModel.calorie ??
        0;
    // Đồng bộ: điểm >= 6 được tính là Cân bằng (giống biểu đồ trend)
    final bool isBalanced = inputModel.isBalanced ?? (score >= 6);
    final String balanceText = isBalanced ? 'Cân bằng' : 'Chưa cân bằng';
    // Figma: Cân bằng = #23C559, Chưa cân bằng = #FFCD57
    final Color balanceColor =
        isBalanced ? Color(0xFF23C559) : Color(0xFFFFCD57);

    // Meal type text (Bữa sáng, Bữa trưa, etc.)
    String mealText = inputModel.timeFrameName ?? inputModel.mealText ?? '';
    if (mealText.isNotEmpty && !mealText.toLowerCase().startsWith('bữa')) {
      mealText = 'Bữa ${mealText.toLowerCase()}';
    }

    // Time string
    String timeStr = '';
    if (inputModel.date != null) {
      timeStr = convertToUTC(inputModel.date!, 'HH:mm');
    }

    return GestureDetector(
      onTap: () {
        NavigationUtil.navigatePage(
          context,
          DailyNutritionPage(type: 'update', id: inputModel.id),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0x14016961), // rgba(1,105,97,0.08)
              blurRadius: 8,
              offset: Offset(1, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Row 1: Score · Kcal | Balance status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Score · Kcal
                Row(
                  children: [
                    // Score: number bold + "điểm" regular
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$score',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111515),
                              height: 1.46,
                            ),
                          ),
                          TextSpan(
                            text: ' điểm',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF111515),
                              height: 1.46,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _dotSeparator(),
                    // Kcal: number bold + "Kcal" regular
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${totalKcal.round()}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111515),
                              height: 1.46,
                            ),
                          ),
                          TextSpan(
                            text: ' Kcal',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF111515),
                              height: 1.46,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Right: Balance status
                Text(
                  balanceText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: balanceColor,
                    height: 1.46,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Row 2: Meal type | Time — Figma: fontSize 13, Regular, #5E6566
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mealText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF5E6566),
                    letterSpacing: 0.4,
                    height: 1.5,
                  ),
                ),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF5E6566),
                    letterSpacing: 0.4,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Small dot separator — Figma: 6x6
  Widget _dotSeparator() {
    return Container(
      width: 6,
      height: 6,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFBFC6C6),
      ),
    );
  }
}
