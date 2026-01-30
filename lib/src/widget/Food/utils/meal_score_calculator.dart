import 'dart:math';

/// Helper class to calculate meal score and nutrition balance
/// Similar to glucose range comparison logic
class MealScoreCalculator {
  // Recommended daily intake (RDA) for a typical meal (1/3 of daily)
  static const double recommendedCarbsGrams = 130 / 3; // ~43g per meal
  static const double recommendedProteinGrams = 50 / 3; // ~17g per meal
  static const double recommendedFatGrams = 70 / 3; // ~23g per meal

  /// Calculate meal score (0-10) based on calories and nutrition balance
  static int calculateScore({
    required double totalCalories,
    required double goalCalories,
    required double carbs,
    required double protein,
    required double fat,
  }) {
    // Calculate component scores
    double caloriesScore = _calculateCaloriesScore(totalCalories, goalCalories);
    double balanceScore = _calculateBalanceScore(carbs, protein, fat);

    // Weighted average: 50% calories, 50% balance
    double finalScore = (caloriesScore * 0.5) + (balanceScore * 0.5);

    return min(10, max(0, finalScore.round()));
  }

  /// Calculate calories achievement score (0-5)
  static double _calculateCaloriesScore(double actual, double goal) {
    if (goal == 0) return 3.0;

    double percentage = (actual / goal) * 100;

    // Perfect range: 80-120%
    if (percentage >= 80 && percentage <= 120) return 5.0;
    // Good range: 60-140%
    if (percentage >= 60 && percentage <= 140) return 4.0;
    // Fair range: 40-160%
    if (percentage >= 40 && percentage <= 160) return 3.0;
    // Poor range: 20-180%
    if (percentage >= 20 && percentage <= 180) return 2.0;
    // Very poor
    return 1.0;
  }

  /// Calculate nutrition balance score (0-5)
  static double _calculateBalanceScore(
      double carbs, double protein, double fat) {
    double carbsPercent =
        _calculateNutritionPercent(carbs, recommendedCarbsGrams);
    double proteinPercent =
        _calculateNutritionPercent(protein, recommendedProteinGrams);
    double fatPercent = _calculateNutritionPercent(fat, recommendedFatGrams);

    // Count how many nutrients are in good range (80-120%)
    int goodCount = 0;
    if (carbsPercent >= 80 && carbsPercent <= 120) goodCount++;
    if (proteinPercent >= 80 && proteinPercent <= 120) goodCount++;
    if (fatPercent >= 80 && fatPercent <= 120) goodCount++;

    // Score based on balanced nutrients
    if (goodCount == 3) return 5.0; // All balanced
    if (goodCount == 2) return 4.0; // 2 balanced
    if (goodCount == 1) return 3.0; // 1 balanced
    return 2.0; // None balanced
  }

  /// Calculate nutrition percentage compared to recommended
  static double _calculateNutritionPercent(double actual, double recommended) {
    if (recommended == 0) return 0;
    return (actual / recommended) * 100;
  }

  /// Get balance status label based on score
  static String getBalanceStatus(int score) {
    if (score >= 8) return 'Cân bằng';
    if (score >= 5) return 'Khá cân bằng';
    return 'Chưa cân bằng';
  }

  /// Calculate individual nutrition percentages for display
  static Map<String, double> calculateNutritionPercentages({
    required double carbs,
    required double protein,
    required double fat,
  }) {
    return {
      'carbs': _calculateNutritionPercent(carbs, recommendedCarbsGrams),
      'protein': _calculateNutritionPercent(protein, recommendedProteinGrams),
      'fat': _calculateNutritionPercent(fat, recommendedFatGrams),
      'vegetables':
          0, // TODO: Calculate when food category detection is implemented
      'fruits':
          0, // TODO: Calculate when food category detection is implemented
    };
  }
}
