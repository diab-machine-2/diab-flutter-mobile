import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/widget/Food/food_detail_tabbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';

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
  int periodFilterType = 1;

  bool _forceReload = false;

  @override
  void initState() {
    periodFilterType = FoodDetailTabbarController.of(context)!.periodFilterType;
    super.initState();
  }

  reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    _forceReload = true;
    setState(() {});
  }

  /// Lấy màu sắc dựa trên phần trăm
  Color _getColorByPercent(double percent, String? colorCode) {
    if (colorCode != null && colorCode.isNotEmpty) {
      return toColor(colorCode);
    }
    if (percent <= 50) {
      return R.color.warningYellow;
    } else if (percent <= 100) {
      return R.color.goodGreen;
    } else {
      return R.color.dangerRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Navigation args: meal just analyzed. Otherwise use API nutrient overview.
    return BlocBuilder<FoodBloc, FoodState>(
        builder: (BuildContext context, FoodState state) {
          Map<String, double>? nutrientData;
          if (state is FoodError) {
            Message.showToastMessage(context, state.message);
          }

          if (state is FoodNutritionOverviewLoaded) {
            nutrientData = state.nutrientPercent;
          } else if (state is FoodNutrientDistributionLoaded) {
            nutrientData = state.nutrientPercent;
          }

          if (widget.nutritionPercent != null && !_forceReload) {
            return _buildMealScoreChart();
          }
          if (nutrientData == null) {
            return Container(
                height: 300,
                child: Center(child: CircularProgressIndicator()));
          }
          // final allZero = nutrientData.values.isEmpty ||
          //     nutrientData.values.every((v) => v == 0);
          // if (allZero) {
          //   return SizedBox.shrink();
          // }
          return _buildNutrientBars(nutrientData);
        });
  }

  /// Hiển thị chart từ nutrient data — cùng style với AI MealScore chart
  Widget _buildNutrientBars(Map<String, double> data) {
    final displayItems = [
      {'label': R.string.tinh_bot.tr(), 'key': 'carb'},
      {'label': R.string.protein_nutrient.tr(), 'key': 'protein'},
      {'label': R.string.fat_nutrient.tr(), 'key': 'fat'},
      {'label': R.string.vegetable_nutrient.tr(), 'key': 'vegetable'},
      {'label': R.string.nhom_hoa_qua.tr(), 'key': 'fruit'},
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 8),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  R.string.phan_bo_dinh_duong.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: R.color.color0xff111515,
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
            width: 100,
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
                color: R.color.neutralBg1,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: displayPercent / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          '${percent.round()}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: percent > 80 ? Colors.white : R.color.black,
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

  Widget _buildMealScoreChart() {
    final np = widget.nutritionPercent!;
    final nc = widget.nutritionColors;

    final items = [
      {'label': R.string.tinh_bot.tr(), 'key': 'carb'},
      {'label': R.string.protein_nutrient.tr(), 'key': 'protein'},
      {'label': R.string.fat_nutrient.tr(), 'key': 'fat'},
      {'label': R.string.vegetable_nutrient.tr(), 'key': 'vegetable'},
      {'label': R.string.nhom_hoa_qua.tr(), 'key': 'fruit'},
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 8),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  R.string.phan_bo_dinh_duong.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: R.color.color0xff111515,
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
