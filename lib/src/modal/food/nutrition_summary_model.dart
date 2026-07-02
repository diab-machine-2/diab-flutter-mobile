import 'package:medical/src/model/ai_recommendation_result.dart';

/// Model for GET /App/Nutrition/Summary?periodFilterType=X response
class NutritionSummaryModel {
  final NutritionDateRange? dateRange;
  final int? avgScore;
  final String? avgScoreRange;
  final int? avgCalories;
  final NutritionPercent? nutritionPercent;
  final List<EnergyDistributionItem> energyDistribution;
  final MealDistribution? mealDistribution;
  final int? targetKcal;
  final AiRecommendationResult? aiAdvice;
  final List<TrendDataItem> trendData;

  NutritionSummaryModel({
    this.dateRange,
    this.avgScore,
    this.avgScoreRange,
    this.avgCalories,
    this.nutritionPercent,
    this.energyDistribution = const [],
    this.mealDistribution,
    this.targetKcal,
    this.aiAdvice,
    this.trendData = const [],
  });

  factory NutritionSummaryModel.fromJson(Map<String, dynamic> json) {
    AiRecommendationResult? aiAdvice;
    final raw = json['aiAdvice'];
    if (raw != null) {
      if (raw is Map) {
        aiAdvice = AiRecommendationResult.fromJson(raw.cast<String, dynamic>());
      } else {
        final text = raw.toString();
        final rawRefs = json['references'];
        List<AiReference> refs = [];
        if (rawRefs is List) {
          refs = rawRefs
              .map((e) => e is Map<String, dynamic>
                  ? AiReference.fromJson(e)
                  : AiReference.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
        aiAdvice = AiRecommendationResult(recommendation: text, references: refs);
      }
    }

    return NutritionSummaryModel(
      dateRange: json['dateRange'] != null
          ? NutritionDateRange.fromJson(json['dateRange'])
          : null,
      avgScore: (json['avgScore'] as num?)?.toInt(),
      avgScoreRange: json['avgScoreRange'],
      avgCalories: (json['avgCalories'] as num?)?.toInt(),
      nutritionPercent: json['nutritionPercent'] != null
          ? NutritionPercent.fromJson(json['nutritionPercent'])
          : null,
      energyDistribution: json['energyDistribution'] != null
          ? (json['energyDistribution'] as List)
              .map((e) => EnergyDistributionItem.fromJson(e))
              .toList()
          : [],
      mealDistribution: json['mealDistribution'] != null
          ? MealDistribution.fromJson(json['mealDistribution'])
          : null,
      targetKcal: (json['targetKcal'] as num?)?.toInt(),
      aiAdvice: aiAdvice,
      trendData: json['trendData'] != null
          ? (json['trendData'] as List)
              .map((e) => TrendDataItem.fromJson(e))
              .toList()
          : [],
    );
  }
}

class NutritionDateRange {
  final String? from;
  final String? to;
  final String? label;

  NutritionDateRange({this.from, this.to, this.label});

  factory NutritionDateRange.fromJson(Map<String, dynamic> json) {
    return NutritionDateRange(
      from: json['from']?.toString(),
      to: json['to']?.toString(),
      label: json['label']?.toString(),
    );
  }
}

class NutritionPercent {
  final int carb;
  final int protein;
  final int fat;
  final int vegetable;
  final int fruit;

  NutritionPercent({
    this.carb = 0,
    this.protein = 0,
    this.fat = 0,
    this.vegetable = 0,
    this.fruit = 0,
  });

  factory NutritionPercent.fromJson(Map<String, dynamic> json) {
    return NutritionPercent(
      carb: (json['carb'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toInt() ?? 0,
      fat: (json['fat'] as num?)?.toInt() ?? 0,
      vegetable: (json['vegetable'] as num?)?.toInt() ?? 0,
      fruit: (json['fruit'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, double> toMap() => {
        'carb': carb.toDouble(),
        'protein': protein.toDouble(),
        'fat': fat.toDouble(),
        'vegetable': vegetable.toDouble(),
        'fruit': fruit.toDouble(),
      };
}

class EnergyDistributionItem {
  final String? timeFrameId;
  final String? timeFrameName;
  final int? percent;
  final String? color;

  EnergyDistributionItem({
    this.timeFrameId,
    this.timeFrameName,
    this.percent,
    this.color,
  });

  factory EnergyDistributionItem.fromJson(Map<String, dynamic> json) {
    return EnergyDistributionItem(
      timeFrameId: json['timeFrameId'],
      timeFrameName: json['timeFrameName'],
      percent: (json['percent'] as num?)?.toInt(),
      color: json['color'],
    );
  }
}

class MealDistribution {
  final int total;
  final int balanced;
  final int unbalanced;
  final int balancedPercent;

  MealDistribution({
    this.total = 0,
    this.balanced = 0,
    this.unbalanced = 0,
    this.balancedPercent = 0,
  });

  factory MealDistribution.fromJson(Map<String, dynamic> json) {
    return MealDistribution(
      total: (json['total'] as num?)?.toInt() ?? 0,
      balanced: (json['balanced'] as num?)?.toInt() ?? 0,
      unbalanced: (json['unbalanced'] as num?)?.toInt() ?? 0,
      balancedPercent: (json['balancedPercent'] as num?)?.toInt() ?? 0,
    );
  }
}

class TrendDataItem {
  final String? id;
  final String? date;
  final int? avgScore;
  final int? totalCalories;
  final int? mealCount;
  final String? timeFrameId;
  final String? timeFrameName;

  TrendDataItem({
    this.id,
    this.date,
    this.avgScore,
    this.totalCalories,
    this.mealCount,
    this.timeFrameId,
    this.timeFrameName,
  });

  factory TrendDataItem.fromJson(Map<String, dynamic> json) {
    // date có thể là int (unix timestamp) hoặc String (ISO date) tuỳ backend
    String? dateStr;
    if (json['date'] != null) {
      final dynDate = json['date'];
      if (dynDate is int) {
        dateStr = DateTime.fromMillisecondsSinceEpoch(
          dynDate * 1000,
          isUtc: true,
        ).toIso8601String();
      } else {
        final strDate = dynDate.toString();
        // Check if it's a numeric unix timestamp string
        final parsedInt = int.tryParse(strDate);
        if (parsedInt != null) {
          dateStr = DateTime.fromMillisecondsSinceEpoch(
            parsedInt * 1000,
            isUtc: true,
          ).toIso8601String();
        } else {
          dateStr = strDate;
        }
      }
    }

    return TrendDataItem(
      id: json['id']?.toString(),
      date: dateStr,
      avgScore: (json['avgScore'] as num?)?.toInt(),
      totalCalories: (json['totalCalories'] as num?)?.toInt(),
      mealCount: (json['mealCount'] as num?)?.toInt(),
      timeFrameId: json['timeFrameId']?.toString(),
      timeFrameName: json['timeFrameName']?.toString(),
    );
  }
}
