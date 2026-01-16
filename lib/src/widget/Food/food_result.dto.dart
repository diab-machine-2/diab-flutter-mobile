import 'package:medical/src/modal/base/images.dart';
import 'package:medical/src/modal/food/food_model.dart';

class FoodResultDto {
  final String id;
  final DateTime dateTime;
  final String timeFrame;
  final String timeFrameId;
  final double totalCalories;
  final double goalCalories;
  final double? carbs;
  final double? protein;
  final double? fat;
  final double? vegetables;
  final double? fruits;
  final List<FoodModel> foods;
  final String? note;
  final List<ImagesModel> images;
  final String? healthRecommendation;
  final bool? isFetchAnalysis;
  final int? score; // Điểm đánh giá từ 0-10
  final String? balanceStatus; // "Cân bằng" hoặc "Chưa cân bằng"

  FoodResultDto({
    required this.id,
    required this.dateTime,
    required this.timeFrame,
    required this.timeFrameId,
    required this.totalCalories,
    required this.goalCalories,
    this.carbs,
    this.protein,
    this.fat,
    this.vegetables,
    this.fruits,
    required this.foods,
    this.note,
    required this.images,
    this.healthRecommendation,
    this.isFetchAnalysis,
    this.score,
    this.balanceStatus,
  });
}
