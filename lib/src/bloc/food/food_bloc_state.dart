part of 'food_bloc.dart';

@immutable
abstract class FoodState {}

class FoodInitial extends FoodState {}

class FoodError extends FoodState {
  final String? message;

  FoodError({
    required this.message,
  });
}

class FoodLoading extends FoodState {}

class FoodLoaded extends FoodState {
  final FoodDataModel model;
  final FoodDataModel? searchModel;
  FoodLoaded({required this.model, this.searchModel});
}

class FoodSearchLoaded extends FoodState {
  final FoodCategoryDataModel? searchModel;
  FoodSearchLoaded({this.searchModel});
}

class FoodCategoryLoaded extends FoodState {
  final List<FoodCategoryModel> model;
  FoodCategoryLoaded({required this.model});
}

class FoodInputLoaded extends FoodState {
  final List<MealDayItemModel> inputs;
  final bool? hasMore;
  FoodInputLoaded({required this.inputs, required this.hasMore});
}

class FoodStatisticCaloLoaded extends FoodState {
  final FoodCaloModel model;
  FoodStatisticCaloLoaded({required this.model});
}

class FoodStatisticCarbLoaded extends FoodState {
  final FoodCaloModel? model;
  FoodStatisticCarbLoaded({this.model});
}

class FoodStatisticDetailLoaded extends FoodState {
  final FoodDietModel? model;
  FoodStatisticDetailLoaded({this.model});
}

class FoodStatisticTrendLoaded extends FoodState {
  final FoodTrendModel? model;

  FoodStatisticTrendLoaded({this.model});
}

class FoodStatisticDistributeLoaded extends FoodState {
  final FoodDistributeModel? model;

  FoodStatisticDistributeLoaded({this.model});
}

// State cho phân bổ theo nhóm thực phẩm (Admin API)
class FoodGroupDistributeLoaded extends FoodState {
  final FoodDistributeModel? model;

  FoodGroupDistributeLoaded({this.model});
}

// State cho AI Analysis
class FoodDietAnalysisLoaded extends FoodState {
  final String? dietAnalysis;

  FoodDietAnalysisLoaded({this.dietAnalysis});
}

// State cho phân bổ dinh dưỡng (tính từ food input, style MealScore)
class FoodNutrientDistributionLoaded extends FoodState {
  final Map<String, double> nutrientPercent;

  FoodNutrientDistributionLoaded({required this.nutrientPercent});
}

// Model cho từng điểm trên biểu đồ calo (mỗi bữa ăn = 1 điểm)
class FoodCalorieTrendItem {
  final String? id;
  final int? date;
  final double? value; // tổng calorie cho bữa ăn đó
  final int? score; // điểm đánh giá 0-10
  final String? colorCode;
  final String? fontColor;
  final String? mealText; // "Sáng", "Trưa", "Tối"...
  final String? type; // "Cân bằng", "Cao", "Thấp"

  FoodCalorieTrendItem({
    this.id,
    this.date,
    this.value,
    this.score,
    this.colorCode,
    this.fontColor,
    this.mealText,
    this.type,
  });
}

// State cho biểu đồ calo xu hướng (từng bữa ăn riêng biệt)
class FoodCalorieTrendLoaded extends FoodState {
  final List<FoodCalorieTrendItem> items;
  final double energyGoal;
  final double perMealThreshold; // energyGoal / 3

  FoodCalorieTrendLoaded({
    required this.items,
    required this.energyGoal,
    required this.perMealThreshold,
  });
}
