import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class BmiThresholdModel {
  final String thresholdName;
  final String description;
  final Color thresholdColor;
  final Color textColor;

  BmiThresholdModel({
    required this.thresholdName,
    required this.description,
    required this.thresholdColor,
    required this.textColor,
  });
}

class BmiThresholds {
  BmiThresholds._();

  static final thresholds = [
    BmiThresholdModel(
      thresholdName: R.string.under_weight,
      description: "< 18.5",
      thresholdColor: Color(0xFFFFCD57),
      textColor: Color(0xFF95682E),
    ),
    BmiThresholdModel(
      thresholdName: R.string.normal_weight,
      description: "18.5 - 22.9",
      thresholdColor: Color(0xFF23C559),
      textColor: Color(0xFFFFFFFF),
    ),
    BmiThresholdModel(
      thresholdName: R.string.over_weight,
      description: "23 - 24.9",
      thresholdColor: Color(0xFFF86F6F),
      textColor: Color(0xFFFFFFFF),
    ),
    BmiThresholdModel(
      thresholdName: R.string.class_1_obesity,
      description: "25 - 29.9",
      thresholdColor: Color(0xFFD02424),
      textColor: Color(0xFFFFFFFF),
    ),
    BmiThresholdModel(
      thresholdName: R.string.class_2_obesity,
      description: "≥ 30",
      thresholdColor: Color(0xFFAF0000),
      textColor: Color(0xFFFFFFFF),
    ),
  ];
}
