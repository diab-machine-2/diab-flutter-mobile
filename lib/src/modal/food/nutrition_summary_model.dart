/// Model for GET /App/Nutrition/Summary?range=X response
class NutritionSummaryModel {
  final NutritionDateRange? dateRange;
  final int? avgScore;
  final String? avgScoreRange;
  final int? avgCalories;
  final NutritionPercent? nutritionPercent;
  final List<EnergyDistributionItem> energyDistribution;
  final MealDistribution? mealDistribution;
  final int? targetKcal;
  final String? aiAdvice;
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
    return NutritionSummaryModel(
      dateRange: json['dateRange'] != null
          ? NutritionDateRange.fromJson(json['dateRange'])
          : null,
      avgScore: json['avgScore'],
      avgScoreRange: json['avgScoreRange'],
      avgCalories: json['avgCalories'],
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
      targetKcal: json['targetKcal'],
      aiAdvice: json['aiAdvice'],
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
      from: json['from'],
      to: json['to'],
      label: json['label'],
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
      carb: json['carb'] ?? 0,
      protein: json['protein'] ?? 0,
      fat: json['fat'] ?? 0,
      vegetable: json['vegetable'] ?? 0,
      fruit: json['fruit'] ?? 0,
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
      percent: json['percent'],
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
      total: json['total'] ?? 0,
      balanced: json['balanced'] ?? 0,
      unbalanced: json['unbalanced'] ?? 0,
      balancedPercent: json['balancedPercent'] ?? 0,
    );
  }
}

class TrendDataItem {
  final String? date;
  final int? avgScore;
  final int? totalCalories;
  final int? mealCount;

  TrendDataItem({
    this.date,
    this.avgScore,
    this.totalCalories,
    this.mealCount,
  });

  factory TrendDataItem.fromJson(Map<String, dynamic> json) {
    return TrendDataItem(
      date: json['date'],
      avgScore: json['avgScore'],
      totalCalories: json['totalCalories'],
      mealCount: json['mealCount'],
    );
  }
}
