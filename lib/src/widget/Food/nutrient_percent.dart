import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

/// The five "Phân bổ dinh dưỡng" groups, in display order.
const List<String> nutrientGroupKeys = [
  'carb',
  'protein',
  'fat',
  'vegetable',
  'fruit',
];

/// Per-group % of the meal's need, read from a MealScore / Nutrition Input
/// payload. Accepts the nested `nutritionPercent: {carb, …}` shape (manual
/// save) and the flat `carbPercent`, … shape (AI analysis); nested wins.
///
/// A group the server sends as `null` (or omits) stays `null` = "chưa đủ dữ
/// liệu". It is never turned into 0, which the UI would show as "Thiếu".
Map<String, int?>? parseNutrientPercent(Map<String, dynamic>? data) {
  if (data == null) return null;
  final nested = data['nutritionPercent'];
  return {
    for (final key in nutrientGroupKeys)
      key: _toInt(nested is Map ? nested[key] : null) ??
          _toInt(data['${key}Percent']),
  };
}

/// Server colours per group (`nutritionPercent.colors`). Missing or empty
/// entries are left out so the UI falls back to [nutrientLevelColor].
Map<String, String>? parseNutrientColors(Map<String, dynamic>? data) {
  final nested = data?['nutritionPercent'];
  final colors = nested is Map ? nested['colors'] : null;
  if (colors is! Map) return null;
  final result = <String, String>{
    for (final key in nutrientGroupKeys)
      if ((colors[key]?.toString() ?? '').isNotEmpty)
        key: colors[key].toString(),
  };
  return result.isEmpty ? null : result;
}

/// Bar colour when the server sends none (the dashboard Summary never does).
/// Same levels as the in-app legend: < 80 thiếu, 80–100 đủ, > 100 dư.
Color nutrientLevelColor(double percent) {
  if (percent < 80) return R.color.warningYellow;
  if (percent <= 100) return R.color.goodGreen;
  return R.color.dangerRed;
}

int? _toInt(Object? value) {
  if (value is num) return value.round();
  if (value is String) return num.tryParse(value)?.round();
  return null;
}
