import 'package:medical/src/modal/food/food_input_model.dart';
import 'package:meta/meta.dart';
@immutable
class FoodInputDataModel {
  final List<MealDayItemModel> inputs;
  final bool? hasMore;

  const FoodInputDataModel({required this.inputs, required this.hasMore});
}
