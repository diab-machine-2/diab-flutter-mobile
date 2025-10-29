import 'package:flutter/material.dart';

class HbA1CResultDto {
  final String id;
  final double hba1c;
  final DateTime dateTime;
  final String note;
  final List<dynamic>? files;
  final List<double> rangeValue;
  final int indexRange;
  final HbA1CRangeType rangeType;
  final bool isNew;
  final String? healthRecommendation;
  final bool? isFetchAnalysis;

  HbA1CResultDto({
    required this.id,
    required this.hba1c,
    required this.dateTime,
    required this.note,
    this.files,
    required this.rangeValue,
    required this.indexRange,
    required this.rangeType,
    this.isNew = false,
    this.healthRecommendation,
    this.isFetchAnalysis,
  });

  factory HbA1CResultDto.fromData({
    required String id,
    required double hba1c,
    required DateTime dateTime,
    required String note,
    List<dynamic>? files,
    required List<double> rangeValue,
    required List<String> rangeLabels,
    required List<Color> colorList,
    bool isNew = false,
    String? healthRecommendation,
    bool? isFetchAnalysis,
  }) {
    int indexRange = _findIndexInRanges(
        hba1c * 10, rangeValue.map((e) => (e * 10).toInt()).toList());

    return HbA1CResultDto(
      id: id,
      hba1c: hba1c,
      dateTime: dateTime,
      note: note,
      files: files,
      rangeValue: rangeValue,
      indexRange: indexRange,
      rangeType: HbA1CRangeType(
        title: rangeLabels[indexRange],
        color: colorList[indexRange],
      ),
      isNew: isNew,
      healthRecommendation: healthRecommendation,
      isFetchAnalysis: isFetchAnalysis,
    );
  }

  static int _findIndexInRanges(double number, List<int> ranges) {
    // Handle boundary values to match visual display:
    // number is already multiplied by 10 (e.g., 65 for 6.5%)
    // ranges = [0, 65, 70, 80] representing [0%, 6.5%, 7.0%, 8.0%]
    // ≤ 65 (≤ 6.5%): Lý tưởng (index 0)
    // > 65 và ≤ 70 (> 6.5% và ≤ 7.0%): Tốt (index 1)
    // > 70 và ≤ 80 (> 7.0% và ≤ 8.0%): Cao (index 2)
    // > 80 (> 8.0%): Rất cao (index 3)

    if (number <= 65) return 0; // Lý tưởng
    if (number <= 70) return 1; // Tốt
    if (number <= 80) return 2; // Cao
    return 3; // Rất cao
  }
}

class HbA1CRangeType {
  final String title;
  final Color color;

  HbA1CRangeType({
    required this.title,
    required this.color,
  });
}
