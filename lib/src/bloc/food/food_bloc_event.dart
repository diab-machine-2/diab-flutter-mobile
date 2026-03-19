part of 'food_bloc.dart';

@immutable
abstract class FoodEvent {}

class FetchFoodFavorite extends FoodEvent {
  final int page;
  FetchFoodFavorite({required this.page});
}

class FetchFoodLatest extends FoodEvent {
  final int page;
  FetchFoodLatest({required this.page});
}

class FetchFoodCategory extends FoodEvent {
  final int page;
  FetchFoodCategory({required this.page});
}

class FetchFood extends FoodEvent {
  final int page;
  FetchFood({required this.page});
}

class FetchSearchFood extends FoodEvent {
  final String keyword;
  final int page;
  FetchSearchFood({required this.keyword, required this.page});
}

class FetchFoodTrend extends FoodEvent {
  final int type;
  FetchFoodTrend({required this.type});
}

class FetchInputFood extends FoodEvent {
  final String currentDateTime;
  final String periodFilterType;
  final int page;

  FetchInputFood(
      {required this.currentDateTime,
      required this.periodFilterType,
      required this.page});
}

class LikeFood extends FoodEvent {
  final FoodModel model;
  final int index;
  LikeFood({required this.model, required this.index});
}

class FetchStatisticCalo extends FoodEvent {
  FetchStatisticCalo();
}

class FetchStatisticCarb extends FoodEvent {
  FetchStatisticCarb();
}

class FetchStatisticDetail extends FoodEvent {
  final String? currentDateTime;
  final String? periodFilterType;

  FetchStatisticDetail({this.currentDateTime, this.periodFilterType});
}

class FetchStatisticTrend extends FoodEvent {
  final String? currentDateTime;
  final String? periodFilterType;

  FetchStatisticTrend({this.currentDateTime, this.periodFilterType});
}

class FetchStatisticDistribute extends FoodEvent {
  final String? currentDateTime;
  final String? periodFilterType;

  FetchStatisticDistribute({this.currentDateTime, this.periodFilterType});
}

// Event cho phân bổ theo nhóm thực phẩm (Tinh bột, Chất đạm, Chất béo, Rau củ, Hoa quả)
class FetchFoodGroupDistribute extends FoodEvent {
  final String? currentDateTime;
  final String? periodFilterType;

  FetchFoodGroupDistribute({this.currentDateTime, this.periodFilterType});
}

// Event cho AI Analysis
class FetchDietAnalysis extends FoodEvent {
  final String currentDateTime;
  final String periodFilterType;

  FetchDietAnalysis({
    required this.currentDateTime,
    required this.periodFilterType,
  });
}

// Event cho phân bổ dinh dưỡng (tính từ food input, style MealScore)
class FetchNutrientDistribution extends FoodEvent {
  final String? currentDateTime;
  final String? periodFilterType;

  FetchNutrientDistribution({this.currentDateTime, this.periodFilterType});
}

// Event cho biểu đồ calo xu hướng (từng bữa ăn riêng biệt)
class FetchFoodCalorieTrend extends FoodEvent {
  final String? currentDateTime;
  final String? periodFilterType;

  FetchFoodCalorieTrend({this.currentDateTime, this.periodFilterType});
}
