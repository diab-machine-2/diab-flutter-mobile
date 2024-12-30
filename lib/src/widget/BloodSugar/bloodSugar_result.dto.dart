import 'package:flutter/widgets.dart';

class BloodSugarResultDto {
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

  BloodSugarResultDto({
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
  });
}
