import 'package:flutter_test/flutter_test.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/nutrition_summary_model.dart';
import 'package:medical/src/widget/Food/nutrient_percent.dart';

void main() {
  group('nutrientLevelColor (legend: < 80 thiếu, 80–100 đủ, > 100 dư)', () {
    test('77% on the dashboard is "thiếu", not "đủ"', () {
      expect(nutrientLevelColor(77), R.color.warningYellow);
    });

    test('0 and 79.9 are "thiếu"', () {
      expect(nutrientLevelColor(0), R.color.warningYellow);
      expect(nutrientLevelColor(79.9), R.color.warningYellow);
    });

    test('80 and 100 are "đủ"', () {
      expect(nutrientLevelColor(80), R.color.goodGreen);
      expect(nutrientLevelColor(100), R.color.goodGreen);
    });

    test('above 100 is "dư"', () {
      expect(nutrientLevelColor(100.5), R.color.dangerRed);
      expect(nutrientLevelColor(150), R.color.dangerRed);
    });
  });

  group('parseNutrientPercent', () {
    test('manual save: nested nutritionPercent (staging 13/11 shape)', () {
      expect(
        parseNutrientPercent({
          'nutritionPercent': {
            'carb': 150,
            'protein': 20,
            'vegetable': 0,
            'fruit': 0,
            'fat': 30,
            'colors': {'carb': '#F86F6F'},
          },
        }),
        {'carb': 150, 'protein': 20, 'fat': 30, 'vegetable': 0, 'fruit': 0},
      );
    });

    test('AI analysis: flat carbPercent… fields', () {
      expect(
        parseNutrientPercent({
          'carbPercent': 70,
          'proteinPercent': 10.4,
          'fatPercent': 20,
          'vegetablePercent': 0,
          'fruitPercent': 0,
        }),
        {'carb': 70, 'protein': 10, 'fat': 20, 'vegetable': 0, 'fruit': 0},
      );
    });

    test('null or missing group stays null (never 0 = "Thiếu")', () {
      final p = parseNutrientPercent({
        'nutritionPercent': {'carb': 60, 'protein': null},
      })!;
      expect(p['carb'], 60);
      expect(p['protein'], isNull);
      expect(p['fat'], isNull);
      expect(p['vegetable'], isNull);
      expect(p['fruit'], isNull);
    });

    test('nested wins, flat fills the gaps', () {
      final p = parseNutrientPercent({
        'carbPercent': 10,
        'fruitPercent': 5,
        'nutritionPercent': {'carb': 90},
      })!;
      expect(p['carb'], 90);
      expect(p['fruit'], 5);
    });

    test('no payload => null', () {
      expect(parseNutrientPercent(null), isNull);
    });
  });

  group('parseNutrientColors', () {
    test('keeps only real colours so the rest use the legend thresholds', () {
      expect(
        parseNutrientColors({
          'nutritionPercent': {
            'colors': {'carb': '#F86F6F', 'protein': '', 'fat': null},
          },
        }),
        {'carb': '#F86F6F'},
      );
    });

    test('no colours => null', () {
      expect(parseNutrientColors({'carbPercent': 10}), isNull);
      expect(
          parseNutrientColors({
            'nutritionPercent': {'colors': {}}
          }),
          isNull);
    });
  });

  group('NutritionPercent (dashboard Summary)', () {
    test('null group stays null through toMap', () {
      final map = NutritionPercent.fromJson(
              {'carb': 77, 'protein': null, 'fat': 16, 'vegetable': 15})
          .toMap();
      expect(map['carb'], 77);
      expect(map['protein'], isNull);
      expect(map['fruit'], isNull);
    });
  });
}
