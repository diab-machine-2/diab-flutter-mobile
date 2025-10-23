import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/response/get_weight_threshold_response.dart';
import 'package:medical/src/utils/utils.dart';

class BmiThresholdModel {
  String thresholdName;
  String description;
  Color thresholdColor;
  Color textColor;

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
      textColor: Color(0xFFFFFFFF),
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

  static List<BmiThresholdModel> applyWith(List<WeightThreshold> t) {
    var defaultThreshold = List<BmiThresholdModel>.from(thresholds);
    defaultThreshold = defaultThreshold.mapIndexed((index, e) {
      return e
        ..thresholdName = t[index].name ?? ""
        ..thresholdColor =
            Utils.parseStringToColor(t[index].backgroundColorCode);
    }).toList();
    return defaultThreshold;
  }
}
