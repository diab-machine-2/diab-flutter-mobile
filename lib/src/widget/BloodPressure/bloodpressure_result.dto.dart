import 'package:flutter/widgets.dart';

class BloodPressureResultDto {
  final String id;
  final DateTime dateTime;
  final String timeFrame;
  final List<int> rangeValue;
  final int indexRange;
  final Color rangeColor;
  final String rangeLabel;
  final double glucose;
  final String glucoseUnit;
  final String? note;
  final List<dynamic>? files;
  final String? aiResult;
  final BloodPressureRangeType? rangeType;
  final bool? isFetchAnalysis;
  final String? healthRecommendation;

  BloodPressureResultDto({
    required this.id,
    required this.dateTime,
    required this.timeFrame,
    required this.rangeValue,
    required this.indexRange,
    required this.rangeColor,
    required this.rangeLabel,
    required this.glucose,
    required this.glucoseUnit,
    this.note,
    this.files,
    this.aiResult,
    this.rangeType,
    this.isFetchAnalysis,
    this.healthRecommendation,
  });
}

enum BloodPressureRangeType {
  very_low(1),
  low(2),
  normal(3),
  high(4),
  very_high(5),
  ;

  final int value;
  const BloodPressureRangeType(this.value);
}

extension BloodPressureRangeTypeExtension on BloodPressureRangeType {
  String get title => this.toString().split('.').last;
}
