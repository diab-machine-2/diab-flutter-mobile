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
      yield FoodStatisticDistributeLoaded(
          model: await client.fetchStatisticDistribute(
              currentDateTime, periodFilterType));
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

  // Handler cho phân bổ dinh dưỡng (tính từ food input, style MealScore)
  Stream<FoodState> fetchNutrientDistribution(
      String? currentDateTime, String? periodFilterType) async* {
    try {
      periodFilterType =
          await AppSettings.getPeriodByScreen(ScreenList.FOOD.index);
      final client = FoodClient();
      yield FoodLoading();

      // Fetch food inputs cho period hiện tại
      final inputData = await client.fetchInput(
          currentDateTime ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
          periodFilterType ?? '1',
          1);

      double totalCarbs = 0;
      double totalProtein = 0;
      double totalFat = 0;

      // Aggregate từ tất cả food items
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

      // Số ngày trong period
      int days = 7;
      final pf = int.tryParse(periodFilterType ?? '1') ?? 1;
      if (pf == 2) days = 14;
      if (pf == 3) days = 30;

      // RDA per day (recommended daily intake)
      const double rdaCarbsPerDay = 130;
      const double rdaProteinPerDay = 50;
      const double rdaFatPerDay = 70;

      // Tính % trung bình so với RDA
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

  // Handler cho biểu đồ calo từng bữa ăn riêng biệt
  Stream<FoodState> fetchFoodCalorieTrend(
      String? currentDateTime, String? periodFilterType) async* {
    try {
      periodFilterType =
          await AppSettings.getPeriodByScreen(ScreenList.FOOD.index);
      final client = FoodClient();

      // Lấy energy goal — explicit toDouble() để tránh lỗi int/null
      double energyGoal = (AppSettings.userInfo?.energyGoal ?? 2000).toDouble();
      double perMealThreshold = energyGoal / 3.0;

      // Fetch tất cả food input trong period
      final inputData = await client.fetchInput(
          currentDateTime ??
              (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
          periodFilterType ?? '1',
          1);

      // Flatten: mỗi FoodInputModel (= 1 lần nhập bữa ăn) → 1 điểm trên chart
      final List<FoodCalorieTrendItem> items = [];

      for (final dayItem in inputData.inputs) {
        for (final mealItem in dayItem.mealItems) {
          for (final foodInput in mealItem.inputs) {
            // Tính tổng calorie cho food input này
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
            // Nếu foodInput có calorie riêng, dùng nó
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

            String status = MealScoreCalculator.getBalanceStatus(score);
            String type = status;
            String colorCode;
            String fontColor;

            if (status == 'Cân bằng') {
              colorCode = '#008479';
              fontColor = '#008479';
            } else if (status == 'Khá cân bằng') {
              colorCode = '#008479';
              fontColor = '#008479';
            } else {
              colorCode = '#FDB913';
              fontColor = '#FDB913';
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
            // Determine balance status and colors from API range
            String savedType;
            String savedColorCode;
            String savedFontColor;
            switch (savedRange) {
              case 'excellent':
                savedType = 'Cân bằng';
                savedColorCode = '#008479';
                savedFontColor = '#008479';
                break;
              case 'good':
                savedType = 'Khá cân bằng';
                savedColorCode = '#008479';
                savedFontColor = '#008479';
                break;
              default:
                savedType = 'Chưa cân bằng';
                savedColorCode = '#F39C12';
                savedFontColor = '#F39C12';
            }
            final lastItem = items.last;
            items[items.length - 1] = FoodCalorieTrendItem(
              id: lastItem.id,
              date: lastItem.date,
              value: lastItem.value,
              score: savedScore,
              colorCode: savedColorCode,
              fontColor: savedFontColor,
              mealText: lastItem.mealText,
              type: savedType,
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
