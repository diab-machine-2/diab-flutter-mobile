import 'package:flutter/widgets.dart';

class BloodPressureResultDto {
  final String id;
  final DateTime dateTime;
  final String timeFrame;
  final List<int> rangeValue;
  final int indexRange;
  final double diastolic;
  final double systolic;
  final double? pulse;
  final String? pulseResultText;
  final String? note;
  final List<dynamic>? files;
  final String? aiResult;
  final List<Color> rangeColors;
  final BloodPressureRangeType rangeType;
  final bool? isFetchAnalysis;
  final String? healthRecommendation;

  BloodPressureResultDto({
    required this.id,
    required this.dateTime,
    required this.timeFrame,
    required this.rangeValue,
    required this.indexRange,
    required this.diastolic,
    required this.systolic,
    this.pulse,
    this.pulseResultText,
    required this.rangeColors,
    required this.rangeType,
    this.note,
    this.files,
    this.aiResult,
    this.isFetchAnalysis,
    this.healthRecommendation,
  });
}

enum BloodPressureRangeType {
  low(1),
  normal(2),
  normal_high(3),
  high1(4),
  high2(5),
  very_high(6),
  ;

  final int value;
  const BloodPressureRangeType(this.value);
}

extension BloodPressureRangeTypeExtension on BloodPressureRangeType {
  String get title {
    switch (this) {
      case BloodPressureRangeType.low:
        return 'Thấp';
      case BloodPressureRangeType.normal:
        return 'Bình thường';
      case BloodPressureRangeType.normal_high:
        return 'Bình thường cao';
      case BloodPressureRangeType.high1:
        return 'Tăng huyết áp độ 1';
      case BloodPressureRangeType.high2:
        return 'Tăng huyết áp độ 2';
      case BloodPressureRangeType.very_high:
        return 'Tăng huyết áp độ 3';
    }
  }

  Color get color {
    switch (this) {
      case BloodPressureRangeType.low:
        return Color(0xFFF99D1A);
      case BloodPressureRangeType.normal:
        return Color(0xFF21A567);
      case BloodPressureRangeType.normal_high:
        return Color(0xFF008479);
      case BloodPressureRangeType.high1:
        return Color(0xFFFF3C3C);
      case BloodPressureRangeType.high2:
        return Color(0xFFC82221);
      case BloodPressureRangeType.very_high:
        return Color(0xFF880808);
    }
  }
}
