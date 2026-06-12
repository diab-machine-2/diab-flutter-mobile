import 'dart:async';
import 'package:bloc/bloc.dart';
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
import 'package:meta/meta.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';
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
    if (event is FetchNutritionOverview) {
      yield* fetchNutritionOverview(
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

  static Map<String, double> _emptyNutrientPercentMap() => {
        'carb': 0,
        'protein': 0,
        'fat': 0,
        'vegetable': 0,
        'fruit': 0,
      };

  /// Maps meal slot labels/IDs to chart colors (Figma).
  /// Accepts both UUID timeFrameId strings and numeric ids.
  static String _energySlotColor(String name, String? id) {
    // Match by known UUIDs from food_action_popup.dart
    const breakfastId = 'b770d23f-8444-4a36-9621-58cc24a39906';
    const lunchId = '9a4c53ca-7c5e-4d3c-9452-07fe19fc2aff';
    const dinnerId = '95faf80c-a6cb-4796-8d65-7478eb875833';
    const snackId = '6b0684ea-5e03-45ef-a5be-03c9aa4a9c03';

    if (id == breakfastId ||
        id == 'Bữa sáng' ||
        name.contains('sáng') ||
        name.contains('breakfast')) {
      return '#008479';
    }
    if (id == lunchId ||
        id == 'Bữa trưa' ||
        name.contains('trưa') ||
        name.contains('lunch')) {
      return '#0FB4A5';
    }
    if (id == dinnerId ||
        id == 'Bữa tối' ||
        name.contains('tối') ||
        name.contains('dinner')) {
      return '#FF9841';
    }
    if (id == snackId ||
        id == 'Bữa phụ' ||
        name.contains('nhẹ') ||
        name.contains('phụ') ||
        name.contains('snack')) {
      return '#F9BA1A';
    }
    if (name.contains('khuya') || name.contains('late')) {
      return '#F86F6F';
    }
    return '#008479';
  }

  static List<EnergyItemModel> _energyChartFromSummary(
      NutritionSummaryModel summary) {
    final energyChartItems = <EnergyItemModel>[];
    final _sang = R.string.meal_breakfast.tr();
    final _trua = R.string.meal_lunch.tr();
    final _toi = R.string.meal_dinner.tr();
    final _nhe = R.string.meal_snack.tr();
    final _khuya = R.string.khuya.tr();

    final fixedEnergyMap = <String, double>{
      _sang: 0,
      _trua: 0,
      _toi: 0,
      _nhe: 0,
      _khuya: 0,
    };

    if (summary.energyDistribution.isEmpty) {
      return energyChartItems;
    }

    for (final item in summary.energyDistribution) {
      final name = (item.timeFrameName ?? '').toLowerCase();
      final val = (item.percent ?? 0).toDouble();

      if (name.contains('sáng') ||
          name.contains('breakfast') ||
          item.timeFrameId == '1') {
        fixedEnergyMap[_sang] = (fixedEnergyMap[_sang] ?? 0) + val;
      } else if (name.contains('trưa') ||
          name.contains('lunch') ||
          item.timeFrameId == '2') {
        fixedEnergyMap[_trua] = (fixedEnergyMap[_trua] ?? 0) + val;
      } else if (name.contains('tối') ||
          name.contains('dinner') ||
          item.timeFrameId == '3') {
        fixedEnergyMap[_toi] = (fixedEnergyMap[_toi] ?? 0) + val;
      } else if (name.contains('nhẹ') ||
          name.contains('snack') ||
          item.timeFrameId == '4') {
        fixedEnergyMap[_nhe] = (fixedEnergyMap[_nhe] ?? 0) + val;
      } else if (name.contains('khuya') ||
          name.contains('late') ||
          item.timeFrameId == '5') {
        fixedEnergyMap[_khuya] = (fixedEnergyMap[_khuya] ?? 0) + val;
      } else {
        fixedEnergyMap[_sang] = (fixedEnergyMap[_sang] ?? 0) + val;
      }
    }

    fixedEnergyMap.forEach((key, val) {
      energyChartItems.add(EnergyItemModel(
        text: key,
        value: val,
        percentValue: val,
        colorCode: _energySlotColor(key.toLowerCase(), null),
      ));
    });
    return energyChartItems;
  }

  /// Resolve localized meal name from API timeFrameId (UUID) or timeFrameName.
  /// Maps API's "\u0102n s\u00e1ng" style names → "B\u1eefa s\u00e1ng" localization keys.
  static String localizedMealText(String? timeFrameId, String? timeFrameName) {
    const breakfastId = 'b770d23f-8444-4a36-9621-58cc24a39906';
    const lunchId = '9a4c53ca-7c5e-4d3c-9452-07fe19fc2aff';
    const dinnerId = '95faf80c-a6cb-4796-8d65-7478eb875833';
    const snackId = '6b0684ea-5e03-45ef-a5be-03c9aa4a9c03';

    // Prefer matching by UUID
    if (timeFrameId == breakfastId || timeFrameId == '1') {
      return R.string.meal_breakfast.tr();
    }
    if (timeFrameId == lunchId || timeFrameId == '2') {
      return R.string.meal_lunch.tr();
    }
    if (timeFrameId == dinnerId || timeFrameId == '3') {
      return R.string.meal_dinner.tr();
    }
    if (timeFrameId == snackId || timeFrameId == '4') {
      return R.string.meal_snack.tr();
    }

    // Fallback: match by timeFrameName content (API may return "\u0102n s\u00e1ng", "\u0102n tr\u01b0a", etc.)
    final lower = (timeFrameName ?? '').toLowerCase();
    if (lower.contains('s\u00e1ng') || lower.contains('breakfast')) {
      return R.string.meal_breakfast.tr();
    }
    if (lower.contains('tr\u01b0a') || lower.contains('lunch')) {
      return R.string.meal_lunch.tr();
    }
    if (lower.contains('t\u1ed1i') || lower.contains('dinner')) {
      return R.string.meal_dinner.tr();
    }
    if (lower.contains('ph\u1ee5') || lower.contains('nh\u1eb9') || lower.contains('snack')) {
      return R.string.meal_snack.tr();
    }

    // Last resort: return the raw API name
    return timeFrameName ?? '';
  }

  static List<FoodCalorieTrendItem> _trendItemsFromSummary(
      NutritionSummaryModel summary) {
    final items = <FoodCalorieTrendItem>[];
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
      final mealText = localizedMealText(trend.timeFrameId, trend.timeFrameName);

      items.add(FoodCalorieTrendItem(
        id: trend.date,
        date: timestamp,
        value: calories,
        score: score,
        colorCode: display['color']!,
        fontColor: display['color']!,
        mealText: mealText,
        type: display['type']!,
        timeFrameId: trend.timeFrameId,
        timeFrameName: trend.timeFrameName,
      ));
    }
    items.sort((a, b) => (a.date ?? 0).compareTo(b.date ?? 0));
    return items;
  }

  Stream<FoodState> fetchNutritionOverview(
      String? currentDateTime, String? periodFilterType) async* {
    try {
      yield FoodLoading();
      final client = FoodClient();
      final int range = int.tryParse(periodFilterType ?? '1') ?? 1;
      double energyGoal = (AppSettings.userInfo?.energyGoal ?? 2000).toDouble();
      double perMealThreshold = energyGoal / 3.0;
      int targetKcal = (AppSettings.userInfo?.energyGoal ?? 2000).toInt();

      NutritionSummaryModel summary;
      try {
        summary = await client.fetchNutritionSummary(range);
      } catch (_) {
        yield FoodNutritionOverviewLoaded(
          periodFilterType: range,
          trendItems: const [],
          energyGoal: energyGoal,
          perMealThreshold: perMealThreshold,
          distributeModel: const FoodDistributeModel(
            legends: [],
            energyChart: [],
            carbChart: [],
          ),
          balancedCount: 0,
          totalMealCount: 0,
          targetKcal: targetKcal,
          nutrientPercent: _emptyNutrientPercentMap(),
          aiAdvice: null,
        );
        return;
      }

      // if (summary.targetKcal != null && summary.targetKcal! > 0) {
      //   targetKcal = summary.targetKcal!;
      // }

      int balancedCount = 0;
      int totalMealCount = 0;
      if (summary.mealDistribution != null) {
        balancedCount = summary.mealDistribution!.balanced;
        totalMealCount = summary.mealDistribution!.total;
      }

      final energyChart = _energyChartFromSummary(summary);
      final trendItems = _trendItemsFromSummary(summary);
      final nutrientMap =
          summary.nutritionPercent?.toMap() ?? _emptyNutrientPercentMap();

      yield FoodNutritionOverviewLoaded(
        periodFilterType: range,
        trendItems: trendItems,
        energyGoal: energyGoal,
        perMealThreshold: perMealThreshold,
        distributeModel: FoodDistributeModel(
          legends: [],
          energyChart: energyChart,
          carbChart: [],
        ),
        balancedCount: balancedCount,
        totalMealCount: totalMealCount,
        targetKcal: targetKcal,
        nutrientPercent: nutrientMap,
        aiAdvice: summary.aiAdvice,
      );
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
      List<EnergyItemModel> energyChartItems = [];

      try {
        final int range = int.tryParse(periodFilterType ?? '1') ?? 1;
        final summary = await client.fetchNutritionSummary(range);
        if (summary.mealDistribution != null) {
          balancedCount = summary.mealDistribution!.balanced;
          totalMealCount = summary.mealDistribution!.total;
        }
        // if (summary.targetKcal != null && summary.targetKcal! > 0) {
        //   targetKcal = summary.targetKcal!;
        // }
        energyChartItems = _energyChartFromSummary(summary);
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

  // Handler cho phân bổ dinh dưỡng — chỉ Summary API
  Stream<FoodState> fetchNutrientDistribution(
      String? currentDateTime, String? periodFilterType) async* {
    try {
      final client = FoodClient();
      yield FoodLoading();

      final int range = int.tryParse(periodFilterType ?? '1') ?? 1;
      final summary = await client.fetchNutritionSummary(range);
      yield FoodNutrientDistributionLoaded(
        nutrientPercent:
            summary.nutritionPercent?.toMap() ?? _emptyNutrientPercentMap(),
      );
    } catch (e, _) {
      if (e is Error) {
        yield FoodError(message: e.message);
      } else {
        yield FoodError(message: R.string.error_can_not_connect_to_server.tr());
      }
    }
  }

  /// Helper: map numeric score to display status and color
  static Map<String, String> _scoreFromValue(int score) {
    if (score >= 8)
      return {
        'type': 'Cân bằng',
        'color': '#23C559'
      }; // Sửa màu Cân bằng giống Figma
    // if (score >= 6) return {'type': 'Khá cân bằng', 'color': '#23C559'};
    // if (score >= 4) return {'type': 'Trung bình', 'color': '#F39C12'};
    return {
      'type': 'Chưa cân bằng',
      'color': '#FFCD57'
    }; // Màu Vàng theo design
  }

  // Handler cho biểu đồ calo — dữ liệu theo ngày từ Summary API (trendData)
  Stream<FoodState> fetchFoodCalorieTrend(
      String? currentDateTime, String? periodFilterType) async* {
    try {
      double energyGoal = (AppSettings.userInfo?.energyGoal ?? 2000).toDouble();
      double perMealThreshold = energyGoal / 3.0;

      final int range = int.tryParse(periodFilterType ?? '1') ?? 1;
      List<FoodCalorieTrendItem> items = [];

      try {
        final summary = await FoodClient().fetchNutritionSummary(range);
        items = _trendItemsFromSummary(summary);
      } catch (e) {
        print('[FoodCalorieTrend] Summary API failed: $e');
      }

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
