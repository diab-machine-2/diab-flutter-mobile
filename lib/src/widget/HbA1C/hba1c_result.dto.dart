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
    for (int i = 0; i < ranges.length - 1; i++) {
      if (number >= ranges[i] && number < ranges[i + 1]) {
        return i;
      }
    }
    return ranges.length - 1;
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
