import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/food/food_calo_model.dart';
import 'package:medical/src/modal/food/food_category_model.dart';
import 'package:medical/src/modal/food/food_data_model.dart';
import 'package:medical/src/modal/food/food_input_model.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/modal/food/food_statistic_diet_model.dart' hide EnergyItemModel;
import 'package:medical/src/modal/food/food_statistic_distribute_model.dart';
import 'package:medical/src/modal/food/food_statistic_trend_model.dart';
import 'package:medical/src/modal/food/nutrition_summary_model.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/widget/home/fliter_enum.dart';
import 'package:meta/meta.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widget/Food/utils/meal_score_calculator.dart';

part 'food_bloc_event.dart';
part 'food_bloc_state.dart';

class FoodBloc extends Bloc<FoodEvent, FoodState> {
  FoodBloc() : super(FoodInitial());

  @override
  Stream<FoodState> mapEventToState(FoodEvent event) async* {
    if (event is FetchFoodLatest) {
      yield* fetchFoodLatest(event.page);
    }
    if (event is FetchFoodFavorite) {
      yield* fetchFoodFavorite(event.page);
    }
    if (event is FetchFoodCategory) {
      yield* fetchFoodCategory(event.page);
    }
    if (event is FetchFood) {
      yield* fetchFood(event.page);
    }
    if (event is FetchSearchFood) {
      yield* searchFood(event.keyword, event.page);
    }
    if (event is FetchInputFood) {
      yield* fetchInputFood(
          event.currentDateTime, event.periodFilterType, event.page);
    }
    if (event is LikeFood) {
      yield* likeFood(event.model, event.index);
    }
    if (event is FetchStatisticCalo) {
      yield* fetchStatisticCalo();
    }
    if (event is FetchStatisticCarb) {
      yield* fetchStatisticCarb();
    }
    if (event is FetchStatisticDetail) {
      yield* fetchStatisticDetail(
          event.currentDateTime, event.periodFilterType);
    }
    if (event is FetchStatisticTrend) {
      yield* fetchStatisticTrend(event.currentDateTime, event.periodFilterType);
    }
    if (event is FetchStatisticDistribute) {
      yield* fetchStatisticDistribute(
          event.currentDateTime, event.periodFilterType);
    }
    if (event is FetchFoodGroupDistribute) {
      yield* fetchFoodGroupDistribute(
          event.currentDateTime, event.periodFilterType);
    }
    if (event is FetchDietAnalysis) {
      yield* fetchDietAnalysis(event.currentDateTime, event.periodFilterType);
    }
    if (event is FetchNutrientDistribution) {
      yield* fetchNutrientDistribution(
          event.currentDateTime, event.periodFilterType);
    }
    if (event is FetchFoodCalorieTrend) {
      yield* fetchFoodCalorieTrend(
          event.currentDateTime, event.periodFilterType);
    }
  }

  Stream<FoodState> fetchFoodLatest(int page) async* {
    try {
      final client = FoodClient();
      yield FoodLoading();
      yield FoodLoaded(model: await client.fetchFoodLatest());
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<FoodState> fetchFoodFavorite(int page) async* {
    try {
      final client = FoodClient();
      yield FoodLoading();
      yield FoodLoaded(model: await client.fetchFoodFavorite());
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<FoodState> fetchFoodCategory(int page) async* {
    try {
      final client = FoodClient();
      yield FoodLoading();
      yield FoodCategoryLoaded(model: await client.fetchCategory());
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<FoodState> fetchFood(int page) async* {
    try {
      final client = FoodClient();
      yield FoodLoading();
      yield FoodLoaded(model: await client.fetchFood());
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<FoodState> searchFood(String keyword, int page) async* {
    try {
      if (page == 1) {
        yield FoodLoading();
      }
      final client = FoodClient();
      final FoodState currenState = state;
      var model = await client.fetchFoodCategory(null, keyword, page);

      if (currenState is FoodSearchLoaded) {
        if (currenState.searchModel != null && page != 1) {
          model.foods.insertAll(0, currenState.searchModel!.foods);
        }
      }
      yield FoodSearchLoaded(searchModel: model);
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<FoodState> fetchInputFood(
      String currentDateTime, String periodFilterType, int page) async* {
    try {
      final client = FoodClient();
      final FoodState currenState = state;
      
      print('[FoodDetail] fetchInputFood range=$periodFilterType, page=$page');
      var model =
          await client.fetchInput(currentDateTime, periodFilterType, page);
      
      print('[FoodDetail] fetchInputFood got ${model.inputs.length} day groups');

      if (currenState is FoodInputLoaded) {
        if (page != 1) {
          model.inputs.insertAll(0, currenState.inputs);
        }
      }
      yield FoodInputLoaded(inputs: model.inputs, hasMore: model.hasMore);
    } catch (e, _) {
      print('[FoodDetail] fetchInputFood ERROR: $e');
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<FoodState> likeFood(FoodModel food, int index) async* {
    try {
      final FoodState currenState = state;

      if (currenState is FoodLoaded) {
        FoodDataModel model;
        model = currenState.model;
        model.foods[index] = food;
        yield FoodLoaded(model: model);
      } else if (currenState is FoodSearchLoaded) {
        FoodCategoryDataModel? model;
        model = currenState.searchModel;
        model!.foods[index] = food;
        yield FoodSearchLoaded(searchModel: model);
      }
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<FoodState> fetchStatisticCalo() async* {
    try {
      final client = FoodClient();
      yield FoodLoading();
      yield FoodStatisticCaloLoaded(model: await client.fetchStatisticCalo());
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<FoodState> fetchStatisticCarb() async* {
    try {
      final client = FoodClient();
      yield FoodLoading();
      yield FoodStatisticCarbLoaded(model: await client.fetchStatisticCarb());
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<FoodState> fetchStatisticDetail(
      String? currentDateTime, String? periodFilterType) async* {
    try {
      final client = FoodClient();
      yield FoodLoading();
      yield FoodStatisticDetailLoaded(
          model: await client.fetchStatisticDetail(
              currentDateTime, periodFilterType));
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<FoodState> fetchStatisticTrend(
      String? currentDateTime, String? periodFilterType) async* {
    try {
      final client = FoodClient();
      yield FoodLoading();
      yield FoodStatisticTrendLoaded(
          model: await client.fetchStatisticTrend(
              currentDateTime, periodFilterType));
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  Stream<FoodState> fetchStatisticDistribute(
      String? currentDateTime, String? periodFilterType) async* {
    try {
      final client = FoodClient();
      yield FoodLoading();

      int balancedCount = 0;
      int totalMealCount = 0;

      int targetKcal = (AppSettings.userInfo?.energyGoal ?? 2000).toInt();
      // Try new Summary API first for meal distribution
      try {
        // API range enum: 0=today, 1=7d, 2=14d, 3=30d, 4=90d
        final int range = int.tryParse(periodFilterType ?? '1') ?? 1;
        final summary = await client.fetchNutritionSummary(range);
        if (summary.mealDistribution != null) {
          balancedCount = summary.mealDistribution!.balanced;
          totalMealCount = summary.mealDistribution!.total;
        }
        if (summary.targetKcal != null && summary.targetKcal! > 0) {
          targetKcal = summary.targetKcal!;
        }
      } catch (e) {
        // Fallback to old manual calculation if Summary API not available
        try {
          final inputData = await client.fetchInput(
              currentDateTime ??
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
              periodFilterType ?? '1',
              1,
              size: 100);

          double energyGoal =
              (AppSettings.userInfo?.energyGoal ?? 2000).toDouble();
          targetKcal = energyGoal.toInt();
          double perMealThreshold = energyGoal / 3.0;

          for (final dayItem in inputData.inputs) {
            for (final mealItem in dayItem.mealItems) {
              for (final foodInput in mealItem.inputs) {
                totalMealCount++;

                double totalCalorie = 0.0;
                double totalCarbs = 0.0;
                double totalProtein = 0.0;
                double totalFat = 0.0;
                for (final food in foodInput.foods) {
                  final double portion = (food.portion ?? 1).toDouble();
                  totalCalorie += (food.calorie ?? 0).toDouble() * portion;
                  totalCarbs += (food.glucose ?? 0).toDouble() * portion;
                  totalProtein += (food.protein ?? 0).toDouble() * portion;
                  totalFat += (food.lipid ?? 0).toDouble() * portion;
                }

                final double? inputCal = foodInput.calorie?.toDouble();
                if (inputCal != null && inputCal > 0) {
                  totalCalorie = inputCal;
                }

                int score = MealScoreCalculator.calculateScore(
                  totalCalories: totalCalorie,
                  goalCalories: perMealThreshold,
                  carbs: totalCarbs,
                  protein: totalProtein,
                  fat: totalFat,
                );

                if (score >= 6) {
                  balancedCount++;
                }
              }
            }
          }
        } catch (_) {
          // Silently fallback if input counting fails
        }
      }
      // Build energyChart from Summary API energyDistribution
      List<EnergyItemModel> energyChartItems = [];
      try {
        final int range = int.tryParse(periodFilterType ?? '1') ?? 1;
        final summary = await client.fetchNutritionSummary(range);
        
        // Define Figma colors mapping based on ID or Name
        String ColorMap(String name, String? id) {
          final lower = name.toLowerCase();
          if (lower.contains('sáng') || lower.contains('breakfast') || id == '1' || id == 'Bữa sáng') return '#008479';
          if (lower.contains('trưa') || lower.contains('lunch') || id == '2' || id == 'Bữa trưa') return '#0FB4A5';
          if (lower.contains('tối') || lower.contains('dinner') || id == '3' || id == 'Bữa tối') return '#FF9841';
          if (lower.contains('nhẹ') || lower.contains('snack') || id == '4' || id == 'Bữa phụ') return '#F9BA1A';
          if (lower.contains('khuya') || lower.contains('late') || id == '5') return '#F86F6F';
          return '#008479'; // Fallback to green so it never looks grey/broken
        }

        // Initialize base structure with all 5 meals to match Figma Legend
        Map<String, double> fixedEnergyMap = {
          'Sáng': 0,
          'Trưa': 0,
          'Tối': 0,
          'Nhẹ': 0,
          'Khuya': 0
        };

        if (summary.energyDistribution.isNotEmpty) {
          for (final item in summary.energyDistribution) {
            final name = (item.timeFrameName ?? '').toLowerCase();
            final val = (item.percent ?? 0).toDouble();
            
            if (name.contains('sáng') || name.contains('breakfast') || item.timeFrameId == '1') {
              fixedEnergyMap['Sáng'] = (fixedEnergyMap['Sáng'] ?? 0) + val;
            } else if (name.contains('trưa') || name.contains('lunch') || item.timeFrameId == '2') {
              fixedEnergyMap['Trưa'] = (fixedEnergyMap['Trưa'] ?? 0) + val;
            } else if (name.contains('tối') || name.contains('dinner') || item.timeFrameId == '3') {
              fixedEnergyMap['Tối'] = (fixedEnergyMap['Tối'] ?? 0) + val;
            } else if (name.contains('nhẹ') || name.contains('snack') || item.timeFrameId == '4') {
              fixedEnergyMap['Nhẹ'] = (fixedEnergyMap['Nhẹ'] ?? 0) + val;
            } else if (name.contains('khuya') || name.contains('late') || item.timeFrameId == '5') {
              fixedEnergyMap['Khuya'] = (fixedEnergyMap['Khuya'] ?? 0) + val;
            } else {
              // Fallback to Sáng if unmapped
              fixedEnergyMap['Sáng'] = (fixedEnergyMap['Sáng'] ?? 0) + val;
            }
          }
          
          fixedEnergyMap.forEach((key, val) {
            energyChartItems.add(EnergyItemModel(
              text: key,
              value: val,
              percentValue: val,
              colorCode: ColorMap(key, null),
            ));
          });
        } else {
          // Fallback: manually calculate from inputData if Summary API is missing
          final inputData = await client.fetchInput(
              currentDateTime ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
              periodFilterType ?? '1', 1, size: 100);

          double totalE = 0;

          for (final dayItem in inputData.inputs) {
            for (final mealItem in dayItem.mealItems) {
              String name = mealItem.text ?? 'Sáng';
              double mealE = 0;
              for (final foodInput in mealItem.inputs) {
                double tempCal = 0;
                for (final food in foodInput.foods) {
                  tempCal += (food.calorie ?? 0).toDouble() * (food.portion ?? 1).toDouble();
                }
                if (foodInput.calorie != null && foodInput.calorie! > 0) {
                  tempCal = foodInput.calorie!.toDouble();
                }
                mealE += tempCal;
              }
              
              String matchedKey = 'Sáng';
              final lower = name.toLowerCase();
              if (lower.contains('trưa')) matchedKey = 'Trưa';
              else if (lower.contains('tối')) matchedKey = 'Tối';
              else if (lower.contains('nhẹ')) matchedKey = 'Nhẹ';
              else if (lower.contains('khuya')) matchedKey = 'Khuya';
              
              fixedEnergyMap[matchedKey] = fixedEnergyMap[matchedKey]! + mealE;
              totalE += mealE;
            }
          }

          fixedEnergyMap.forEach((key, val) {
            double pct = totalE > 0 ? (val / totalE * 100.0) : 0;
            energyChartItems.add(EnergyItemModel(
              text: key,
              value: pct,
              percentValue: pct,
              colorCode: ColorMap(key, null),
            ));
          });
        }
      } catch (e) {
        print('[EnergyDistribution] Failed to load: $e');
      }

      yield FoodStatisticDistributeLoaded(
        model: FoodDistributeModel(
          legends: [],
          energyChart: energyChartItems,
          carbChart: [],
        ),
        balancedCount: balancedCount,
        totalMealCount: totalMealCount,
        targetKcal: targetKcal,
      );
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  // Handler cho phân bổ theo nhóm thực phẩm (Admin API)
  Stream<FoodState> fetchFoodGroupDistribute(
      String? currentDateTime, String? periodFilterType) async* {
    try {
      final client = FoodClient();
      yield FoodLoading();
      yield FoodGroupDistributeLoaded(
          model: await client.fetchFoodGroupDistribute(
              currentDateTime, periodFilterType));
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  // Handler cho AI Analysis
  Stream<FoodState> fetchDietAnalysis(
      String currentDateTime, String periodFilterType) async* {
    try {
      final client = FoodClient();
      yield FoodLoading();

      final dietAnalysis = await client.fetchDietAnalysis(
        int.parse(periodFilterType),
      );

      yield FoodDietAnalysisLoaded(dietAnalysis: dietAnalysis ?? '');
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  // Handler cho phân bổ dinh dưỡng — ưu tiên Summary API, fallback manual
  Stream<FoodState> fetchNutrientDistribution(
      String? currentDateTime, String? periodFilterType) async* {
    try {
      final client = FoodClient();
      yield FoodLoading();

      // Try new Summary API first
      try {
        // API range enum: 0=today, 1=7d, 2=14d, 3=30d, 4=90d
        final int range = int.tryParse(periodFilterType ?? '1') ?? 1;
        final summary = await client.fetchNutritionSummary(range);
        if (summary.nutritionPercent != null) {
          yield FoodNutrientDistributionLoaded(
              nutrientPercent: summary.nutritionPercent!.toMap());
          return;
        }
      } catch (_) {
        // Fallback to manual calculation
      }

      // Fallback: manual calculation from food inputs
      final inputData = await client.fetchInput(
          currentDateTime ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
          periodFilterType ?? '1',
          1,
          size: 100);

      double totalCarbs = 0;
      double totalProtein = 0;
      double totalFat = 0;

      for (final dayItem in inputData.inputs) {
        for (final mealItem in dayItem.mealItems) {
          for (final foodInput in mealItem.inputs) {
            for (final food in foodInput.foods) {
              final portion = food.portion ?? 1;
              totalCarbs += (food.glucose ?? 0) * portion;
              totalProtein += (food.protein ?? 0) * portion;
              totalFat += (food.lipid ?? 0) * portion;
            }
          }
        }
      }

      int days = 7;
      final pf = int.tryParse(periodFilterType ?? '1') ?? 1;
      if (pf == 2) days = 14;
      if (pf == 3) days = 30;
      if (pf == 4) days = 90;

      const double rdaCarbsPerDay = 130;
      const double rdaProteinPerDay = 50;
      const double rdaFatPerDay = 70;

      double carbPercent =
          days > 0 ? (totalCarbs / (rdaCarbsPerDay * days)) * 100 : 0;
      double proteinPercent =
          days > 0 ? (totalProtein / (rdaProteinPerDay * days)) * 100 : 0;
      double fatPercent =
          days > 0 ? (totalFat / (rdaFatPerDay * days)) * 100 : 0;

      yield FoodNutrientDistributionLoaded(nutrientPercent: {
        'carb': carbPercent,
        'protein': proteinPercent,
        'fat': fatPercent,
        'vegetable': 0,
        'fruit': 0,
      });
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  /// Helper: map scoreRange string to display status and colors
  static Map<String, String> _scoreRangeToDisplay(String? scoreRange) {
    switch (scoreRange) {
      case 'excellent':
        return {'type': 'Cân bằng', 'color': '#008479'};
      case 'balanced':
        return {'type': 'Cân bằng', 'color': '#008479'};
      case 'good':
        return {'type': 'Khá cân bằng', 'color': '#008479'};
      case 'fair':
        return {'type': 'Trung bình', 'color': '#F39C12'};
      case 'poor':
        return {'type': 'Chưa cân bằng', 'color': '#E74C3C'};
      default:
        return {'type': 'Chưa cân bằng', 'color': '#FDB913'};
    }
  }

  /// Helper: map numeric score to display status and color
  static Map<String, String> _scoreFromValue(int score) {
    if (score >= 8) return {'type': 'Cân bằng', 'color': '#008479'};
    if (score >= 6) return {'type': 'Khá cân bằng', 'color': '#008479'};
    if (score >= 4) return {'type': 'Trung bình', 'color': '#F39C12'};
    return {'type': 'Chưa cân bằng', 'color': '#FDB913'};
  }

  // Handler cho biểu đồ calo từng bữa ăn riêng biệt
  Stream<FoodState> fetchFoodCalorieTrend(
      String? currentDateTime, String? periodFilterType) async* {
    try {
      double energyGoal = (AppSettings.userInfo?.energyGoal ?? 2000).toDouble();
      double perMealThreshold = energyGoal / 3.0;

      // API range enum: 0=today, 1=7d, 2=14d, 3=30d, 4=90d
      final int range = int.tryParse(periodFilterType ?? '1') ?? 1;
      List<FoodCalorieTrendItem> items = [];

      // ── STRATEGY 1: Input API (per-meal dots — like blood sugar chart) ──
      bool inputSuccess = false;
      try {
        print('[FoodCalorieTrend] Trying Input API with range=$range');
        final inputData = await FoodClient().fetchInput(
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
            range.toString(),
            1,
            size: 100);

        print('[FoodCalorieTrend] Input API success, ${inputData.inputs.length} day groups');

        for (final dayItem in inputData.inputs) {
          for (final mealItem in dayItem.mealItems) {
            for (final foodInput in mealItem.inputs) {
              final int score = foodInput.totalMealScore ?? 0;
              final double totalCalorie = foodInput.totalCalories ??
                  foodInput.calorie?.toDouble() ??
                  0;
              final display = (foodInput.scoreRange != null)
                  ? _scoreRangeToDisplay(foodInput.scoreRange)
                  : _scoreFromValue(score);

              items.add(FoodCalorieTrendItem(
                id: foodInput.id,
                date: foodInput.date,
                value: totalCalorie,
                score: score,
                colorCode: display['color']!,
                fontColor: display['color']!,
                mealText: mealItem.text ?? foodInput.mealText ?? '',
                type: display['type']!,
              ));
            }
          }
        }
        inputSuccess = items.isNotEmpty;
      } catch (e) {
        print('[FoodCalorieTrend] Input API failed: $e');
      }

      // ── STRATEGY 2 (fallback): Summary API (per-day) ──
      if (!inputSuccess) {
        try {
          print('[FoodCalorieTrend] Fallback: Trying Summary API with range=$range');
          final summary = await FoodClient().fetchNutritionSummary(range);
          print('[FoodCalorieTrend] Summary API success, trendData=${summary.trendData.length}');

          for (final trend in summary.trendData) {
            if (trend.date == null) continue;
            int? timestamp;
            try {
              final dt = DateTime.parse(trend.date!);
              timestamp = dt.millisecondsSinceEpoch ~/ 1000;
            } catch (_) {
              continue;
            }

            final int score = trend.avgScore ?? 0;
            final double calories = (trend.totalCalories ?? 0).toDouble();
            final display = _scoreFromValue(score);

            items.add(FoodCalorieTrendItem(
              id: trend.date,
              date: timestamp,
              value: calories,
              score: score,
              colorCode: display['color']!,
              fontColor: display['color']!,
              mealText: '${trend.mealCount ?? 0} bữa',
              type: display['type']!,
            ));
          }
        } catch (e) {
          print('[FoodCalorieTrend] Summary API also failed: $e');
        }
      }

      // Sort by date (old → new)
      items.sort((a, b) => (a.date ?? 0).compareTo(b.date ?? 0));
      print('[FoodCalorieTrend] Total items: ${items.length}');

      yield FoodCalorieTrendLoaded(
        items: items,
        energyGoal: energyGoal,
        perMealThreshold: perMealThreshold,
      );
    } catch (e, _) {
      print('[FoodCalorieTrend] Fatal error: $e');
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }
}
