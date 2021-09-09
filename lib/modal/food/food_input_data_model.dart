import 'package:medical/modal/food/food_input_model.dart';
import 'package:meta/meta.dart';

class FoodInputDataModel {
  final List<MealDayItemModel> inputs;
  final bool hasMore;

  FoodInputDataModel({@required this.inputs, @required this.hasMore});
}
