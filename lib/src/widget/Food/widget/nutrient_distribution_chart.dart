import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/Food/daily_nutrition/daily_nutrition.dart';
import 'package:medical/src/widget/Food/food_detail_tabbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/empty_data_box.dart';

class NutrientDistributionChart extends StatefulWidget {
  final Map<String, int>? nutritionPercent;
  final Map<String, String>? nutritionColors;

  NutrientDistributionChart(
      {Key? key, this.nutritionPercent, this.nutritionColors})
      : super(key: key);
  @override
  NutrientDistributionChartState createState() =>
      NutrientDistributionChartState();
}

class NutrientDistributionChartState extends State<NutrientDistributionChart>
    with AutomaticKeepAliveClientMixin<NutrientDistributionChart> {
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
    BlocProvider.of<FoodBloc>(currentContext).add(FetchNutrientDistribution(
      currentDateTime:
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      periodFilterType: periodFilterType.toString(),
    ));
    return true;
  }

  /// Lấy màu sắc dựa trên phần trăm
  Color _getColorByPercent(double percent, String? colorCode) {
    if (colorCode != null && colorCode.isNotEmpty) {
      return toColor(colorCode);
    }
    if (percent <= 50) {
      return const Color(0xFF81C784);
    } else if (percent <= 80) {
      return const Color(0xFF4CAF50);
    } else if (percent <= 100) {
      return const Color(0xFFFFD233);
    } else {
      return const Color(0xFFEF5350);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // If MealScore data is available (from AI analysis), show it directly
    if (widget.nutritionPercent != null) {
      return _buildMealScoreChart();
    }

    // Otherwise, fetch food inputs and compute nutrient percentages
    return BlocProvider<FoodBloc>(
        create: (context) => FoodBloc(),
        child: BlocBuilder<FoodBloc, FoodState>(
            builder: (BuildContext context, FoodState state) {
          currentContext = context;
          Map<String, double>? nutrientData;
          if (state is FoodInitial) {
            BlocProvider.of<FoodBloc>(context).add(FetchNutrientDistribution(
              currentDateTime:
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
              periodFilterType: periodFilterType.toString(),
            ));
          }
          if (state is FoodError) {
            Message.showToastMessage(context, state.message);
          }

          if (state is FoodNutrientDistributionLoaded) {
            nutrientData = state.nutrientPercent;
          }

          if (nutrientData == null) {
            return Container(
                height: 300,
                child: Center(child: CircularProgressIndicator()));
          }

          // Check if all values are 0 (no food data)
          final allZero = nutrientData.values.every((v) => v == 0);
          if (allZero) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: 16, left: 16, right: 16, top: 8),
              child: EmptyDataBox(
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
              ),
            );
          }

          return _buildNutrientBars(nutrientData);
        }));
  }

  /// Hiển thị chart từ nutrient data — cùng style với AI MealScore chart
  Widget _buildNutrientBars(Map<String, double> data) {
    final displayItems = [
      {'label': 'Tinh bột', 'key': 'carb'},
      {'label': 'Chất đạm', 'key': 'protein'},
      {'label': 'Chất béo', 'key': 'fat'},
      {'label': 'Rau củ', 'key': 'vegetable'},
      {'label': 'Hoa quả', 'key': 'fruit'},
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 8),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF7DD3FC),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Phân bổ dinh dưỡng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: R.color.black,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: R.color.primaryGreyColor,
                  size: 24,
                ),
              ],
            ),
            SizedBox(height: 16),
            ...displayItems.map((item) {
              final key = item['key'] as String;
              final percent = data[key] ?? 0;
              return _buildNutrientRow(
                item['label'] as String,
                percent,
                _getColorByPercent(percent, null),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String name, double percent, Color color) {
    final double displayPercent = percent > 100 ? 100 : percent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: R.color.black,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: displayPercent / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 50,
            child: Text(
              '${percent.round()}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: percent > 100 ? Color(0xFFEF5350) : R.color.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealScoreChart() {
    final np = widget.nutritionPercent!;
    final nc = widget.nutritionColors;

    final items = [
      {'label': 'Tinh bột', 'key': 'carb'},
      {'label': 'Chất đạm', 'key': 'protein'},
      {'label': 'Chất béo', 'key': 'fat'},
      {'label': 'Rau củ', 'key': 'vegetable'},
      {'label': 'Hoa quả', 'key': 'fruit'},
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 8),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF7DD3FC),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Phân bổ dinh dưỡng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: R.color.black,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: R.color.primaryGreyColor,
                  size: 24,
                ),
              ],
            ),
            SizedBox(height: 16),
            ...items.map((item) {
              final key = item['key'] as String;
              final percent = (np[key] ?? 0).toDouble();
              final colorCode = nc?[key];
              return _buildNutrientRow(
                item['label'] as String,
                percent,
                _getColorByPercent(percent, colorCode),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
