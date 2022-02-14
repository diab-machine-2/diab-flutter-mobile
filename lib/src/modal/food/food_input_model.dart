import 'package:medical/src/modal/base/images.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:meta/meta.dart';
@immutable
class MealDayItemModel {
  final int? date;
  final List<MealItemModel> mealItems;

  const MealDayItemModel({required this.date, required this.mealItems});
  @override
  factory MealDayItemModel.fromJson(Map<String, dynamic> json) {
    return MealDayItemModel(
        date: json['date'], mealItems: MealItemModel.toList(json['mealItems']));
  }

  static List<MealDayItemModel> toList(List<dynamic> items) {
    return items.map((item) => MealDayItemModel.fromJson(item)).toList();
  }
}

class FoodInputModel {
  final String? id;
  final double? calorie;
  final double? glucose;
  final String? mealId;
  final String? mealText;
  final ImagesModel? mealIcon;
  final int? date;
  final List<ImagesModel> images;
  final List<FoodModel> foods;
  final String? note;

  FoodInputModel({
    required this.id,
    required this.calorie,
    required this.glucose,
    required this.mealId,
    required this.mealText,
    required this.mealIcon,
    required this.date,
    required this.images,
    required this.foods,
    required this.note,
  });
  @override
  factory FoodInputModel.fromJson(Map<String, dynamic> json) {
    return FoodInputModel(
        id: json['id'],
        calorie: json['calorie'],
        glucose: json['glucose'],
        mealId: json['mealId'],
        mealText: json['mealText'],
        mealIcon: json['mealIcon'] == null
            ? null
            : ImagesModel.fromJson(json['mealIcon']),
        date: json['date'],
        images:
            json['images'] == null ? [] : ImagesModel.toList(json['images']),
        foods: FoodModel.toList(json['foods']),
        note: json['note']);
  }

  static List<FoodInputModel> toList(List<dynamic> items) {
    return items.map((item) => FoodInputModel.fromJson(item)).toList();
  }
}

class MealItemModel {
  final String? text;
  final double? caloValue;
  final List<FoodInputModel> inputs;

  MealItemModel(
      {required this.text, required this.caloValue, required this.inputs});
  @override
  factory MealItemModel.fromJson(Map<String, dynamic> json) {
    return MealItemModel(
        text: json['text'],
        caloValue: json['caloValue'],
        inputs: FoodInputModel.toList(json['inputs']));
  }

  static List<MealItemModel> toList(List<dynamic> items) {
    return items.map((item) => MealItemModel.fromJson(item)).toList();
  }
}
