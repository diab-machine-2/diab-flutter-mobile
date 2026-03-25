import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/widget/Food/food_detail_tabbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Saved nutrition data from SharedPreferences
  Map<String, int>? _savedNutritionPercent;
  Map<String, String>? _savedNutritionColors;
  bool _loadedSavedData = false;
  bool _forceReload = false;

  @override
  void initState() {
    periodFilterType = FoodDetailTabbarController.of(context)!.periodFilterType;
    super.initState();
    // Load saved nutrition data from SharedPreferences if no widget data
    if (widget.nutritionPercent == null) {
      _loadSavedNutritionData();
    }
  }

  void _loadSavedNutritionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final npJson = prefs.getString('latest_nutrition_percent');
      final ncJson = prefs.getString('latest_nutrition_colors');

      if (npJson != null && npJson.isNotEmpty) {
        final decoded = jsonDecode(npJson) as Map<String, dynamic>;
        _savedNutritionPercent = decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
      } else {
        _savedNutritionPercent = null;
      }
      if (ncJson != null && ncJson.isNotEmpty) {
        final decoded = jsonDecode(ncJson) as Map<String, dynamic>;
        _savedNutritionColors = decoded.map((k, v) => MapEntry(k, v.toString()));
      } else {
        _savedNutritionColors = null;
      }
    } catch (e) {
      _savedNutritionPercent = null;
      _savedNutritionColors = null;
    }
    _loadedSavedData = true;
    if (mounted) setState(() {});
  }

  reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    _forceReload = true;
    // Clear in-memory data immediately to avoid stale display during async load
    _savedNutritionPercent = null;
    _savedNutritionColors = null;
    _loadedSavedData = false;
    setState(() {});
    _loadSavedNutritionData();
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

    // ALWAYS verify food data exists via API first
    // SharedPreferences/navigation data only shown if API confirms food exists
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

          // Check if all values are 0 (no food data) → hide chart completely
          final allZero = nutrientData.values.every((v) => v == 0);
          if (allZero) {
            return SizedBox.shrink();
          }

          // Food exists! Prefer AI-analyzed data over API-calculated data
          // 1. From navigation args (just analyzed a meal)
          if (widget.nutritionPercent != null && !_forceReload) {
            return _buildMealScoreChart();
          }
          // 2. From SharedPreferences (persisted AI analysis)
          if (_loadedSavedData && _savedNutritionPercent != null) {
            return _buildSavedNutritionChart();
          }
          // 3. Fallback to API-calculated nutrient data
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
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: displayPercent / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(13),
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

  /// Build chart from saved SharedPreferences data
  Widget _buildSavedNutritionChart() {
    final np = _savedNutritionPercent!;
    final nc = _savedNutritionColors;

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
