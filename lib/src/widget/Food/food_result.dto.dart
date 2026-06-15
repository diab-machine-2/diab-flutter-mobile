import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/base/images.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/model/ai_recommendation_result.dart';

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
  final List<AiReference>? references;
  final int? score; // Điểm đánh giá từ 0-10
  final String? balanceStatus; // "Cân bằng" hoặc "Chưa cân bằng"
  final Map<String, int>?
      nutritionPercent; // {carb, protein, vegetable, fruit, fat}
  final Map<String, String>? nutritionColors; // {carb: "#F86F6F", ...}

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
    this.references,
    this.score,
    this.balanceStatus,
    this.nutritionPercent,
    this.nutritionColors,
  });

  /// True when the meal is considered balanced (mirrors the same logic in food_detail.dart).
  bool get isBalanced {
    final raw = balanceStatus?.toLowerCase() ?? '';
    if (raw == 'cân bằng' || raw == 'balanced') return true;
    if (raw == 'chưa cân bằng' || raw == 'unbalanced') return false;
    // Fall back to score if raw status is absent.
    return (score ?? 0) >= 6;
  }

  /// Localized display string for balanceStatus.
  String get localizedBalanceStatus =>
      isBalanced ? R.string.can_bang.tr() : R.string.chua_can_bang.tr();
}
