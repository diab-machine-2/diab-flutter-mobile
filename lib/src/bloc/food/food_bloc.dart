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
import 'package:medical/src/modal/food/food_statistic_diet_model.dart';
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
      periodFilterType =
          await AppSettings.getPeriodByScreen(ScreenList.FOOD.index);
      final client = FoodClient();
      final FoodState currenState = state;
      var model =
          await client.fetchInput(currentDateTime, periodFilterType, page);

      if (currenState is FoodInputLoaded) {
        if (page != 1) {
          model.inputs.insertAll(0, currenState.inputs);
        }
      }
      yield FoodInputLoaded(inputs: model.inputs, hasMore: model.hasMore);
    } catch (e, _) {
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
      periodFilterType =
          await AppSettings.getPeriodByScreen(ScreenList.FOOD.index);
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
      periodFilterType =
          await AppSettings.getPeriodByScreen(ScreenList.FOOD.index);
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
      periodFilterType =
          await AppSettings.getPeriodByScreen(ScreenList.FOOD.index);
      final client = FoodClient();
      yield FoodLoading();

      int balancedCount = 0;
      int totalMealCount = 0;

      // Try new Summary API first for meal distribution
      try {
        final int range = int.tryParse(periodFilterType ?? '1') ?? 1;
        final summary = await client.fetchNutritionSummary(range);
        if (summary.mealDistribution != null) {
          balancedCount = summary.mealDistribution!.balanced;
          totalMealCount = summary.mealDistribution!.total;
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

                if (score >= 8) {
                  balancedCount++;
                }
              }
            }
          }
        } catch (_) {
          // Silently fallback if input counting fails
        }
      }

      yield FoodStatisticDistributeLoaded(
        model: await client.fetchStatisticDistribute(
            currentDateTime, periodFilterType),
        balancedCount: balancedCount,
        totalMealCount: totalMealCount,
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
      periodFilterType =
          await AppSettings.getPeriodByScreen(ScreenList.FOOD.index);
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
      periodFilterType =
          await AppSettings.getPeriodByScreen(ScreenList.FOOD.index);
      final client = FoodClient();
      yield FoodLoading();

      // Try new Summary API first
      try {
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

  // Handler cho biểu đồ calo từng bữa ăn riêng biệt
  Stream<FoodState> fetchFoodCalorieTrend(
      String? currentDateTime, String? periodFilterType) async* {
    try {
      periodFilterType =
          await AppSettings.getPeriodByScreen(ScreenList.FOOD.index);
      final client = FoodClient();

      double energyGoal = (AppSettings.userInfo?.energyGoal ?? 2000).toDouble();
      double perMealThreshold = energyGoal / 3.0;

      // Fetch tất cả food input trong period
      final inputData = await client.fetchInput(
          currentDateTime ??
              (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
          periodFilterType ?? '1',
          1,
          size: 100);

      // Flatten: mỗi FoodInputModel (= 1 lần nhập bữa ăn) → 1 điểm trên chart
      final List<FoodCalorieTrendItem> items = [];

      int days = 7;
      final pf = int.tryParse(periodFilterType ?? '1') ?? 1;
      if (pf == 2) days = 14;
      if (pf == 3) days = 30;
      if (pf == 4) days = 90;

      final now = DateTime.now();
      final currentRef = currentDateTime != null 
          ? DateTime.fromMillisecondsSinceEpoch(int.parse(currentDateTime) * 1000) 
          : now;
      // Start of the day, minus (days - 1)
      final startRef = DateTime(currentRef.year, currentRef.month, currentRef.day).subtract(Duration(days: days - 1));
      final startTimestamp = startRef.millisecondsSinceEpoch ~/ 1000;
      final endTimestamp = currentRef.millisecondsSinceEpoch ~/ 1000;

      for (final dayItem in inputData.inputs) {
        for (final mealItem in dayItem.mealItems) {
          for (final foodInput in mealItem.inputs) {
            // Apply period filter locally
            if (foodInput.date != null && (foodInput.date! < startTimestamp || foodInput.date! > endTimestamp)) {
              continue;
            }

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

            // Prefer API-provided totalMealScore; fallback to local calculation
            int score;
            String type;
            String colorCode;
            String fontColor;

            if (foodInput.totalMealScore != null && foodInput.scoreRange != null) {
              // New API: use server-provided score and range
              score = foodInput.totalMealScore!;
              final display = _scoreRangeToDisplay(foodInput.scoreRange);
              type = display['type']!;
              colorCode = display['color']!;
              fontColor = display['color']!;
            } else {
              // Fallback: local MealScore calculation
              score = MealScoreCalculator.calculateScore(
                totalCalories: totalCalorie,
                goalCalories: perMealThreshold,
                carbs: totalCarbs,
                protein: totalProtein,
                fat: totalFat,
              );

              String status = MealScoreCalculator.getBalanceStatus(score);
              type = status;
              if (status == 'Cân bằng' || status == 'Khá cân bằng') {
                colorCode = '#008479';
                fontColor = '#008479';
              } else {
                colorCode = '#FFCD57';
                fontColor = '#FFCD57';
              }
            }

            items.add(FoodCalorieTrendItem(
              id: foodInput.id,
              date: foodInput.date,
              value: totalCalorie,
              score: score,
              colorCode: colorCode,
              fontColor: fontColor,
              mealText: mealItem.text ?? foodInput.mealText ?? '',
              type: type,
            ));
          }
        }
      }

      // Sort theo date (cũ → mới)
      items.sort((a, b) => (a.date ?? 0).compareTo(b.date ?? 0));

      // Override latest meal's score/status with saved MealScore API data
      if (items.isNotEmpty) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final savedScore = prefs.getInt('latest_meal_score');
          final savedRange = prefs.getString('latest_meal_range');
          if (savedScore != null && savedRange != null) {
            final display = _scoreRangeToDisplay(savedRange);
            final lastItem = items.last;
            items[items.length - 1] = FoodCalorieTrendItem(
              id: lastItem.id,
              date: lastItem.date,
              value: lastItem.value,
              score: savedScore,
              colorCode: display['color']!,
              fontColor: display['color']!,
              mealText: lastItem.mealText,
              type: display['type']!,
            );
          }
        } catch (_) {
          // Silently ignore - use local calculation as fallback
        }
      }

      yield FoodCalorieTrendLoaded(
        items: items,
        energyGoal: energyGoal,
        perMealThreshold: perMealThreshold,
      );
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }
}
