import 'package:medical/src/modal/food/food_model.dart';

class FoodDataModel {
  final List<FoodModel> foods;
  final bool? hasMore;

  FoodDataModel({required this.foods, required this.hasMore});
}

class FoodCategoryDataModel {
  final List<FoodModel> foods;
  final bool? hasMore;

  FoodCategoryDataModel({required this.foods, required this.hasMore});
}
