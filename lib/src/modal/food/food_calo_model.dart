import 'package:medical/src/modal/base/images.dart';
import 'package:meta/meta.dart';

@immutable
class FoodCaloModel {
  final bool? includeBreakfast;
  final bool? includeLunch;
  final bool? includeDinner;
  final double? percent;
  final double? total;
  final double? goal;
  final String? note;
  final String? colorCode;
  final ImagesModel? image;
  final List<MealModel> mealDetails;

  const FoodCaloModel({
    this.includeBreakfast,
    this.includeLunch,
    this.includeDinner,
    required this.percent,
    required this.total,
    required this.goal,
    required this.note,
    required this.colorCode,
    required this.image,
    required this.mealDetails,
  });
  @override
  factory FoodCaloModel.fromJson(Map<String, dynamic> json) {
    return FoodCaloModel(
        includeBreakfast: json['hasBreakfastSnack'],
        includeLunch: json['hasLunchSnack'],
        includeDinner: json['hasDinnerSnack'],
        percent: json['percent'],
        total: json['total'],
        goal: json['goal'],
        note: json['note'],
        colorCode: json['colorCode'],
        image:
            json['image'] == null ? null : ImagesModel.fromJson(json['image']),
        mealDetails: MealModel.toList(json['mealDetails']));
  }

  static List<FoodCaloModel> toList(List<dynamic> items) {
    return items.map((item) => FoodCaloModel.fromJson(item)).toList();
  }
}

class MealModel {
  final String? text;
  final double? value;
  final ImagesModel icon;

  MealModel({required this.text, required this.value, required this.icon});
  @override
  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
        text: json['text'],
        value: json['value'],
        icon: ImagesModel.fromJson(json['icon']));
  }

  static List<MealModel> toList(List<dynamic> items) {
    return items.map((item) => MealModel.fromJson(item)).toList();
  }
}
