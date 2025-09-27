import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:medical/src/model/response/base/response.dart';
import 'package:medical/src/utils/utils.dart';

part 'bmi_statistical_response.g.dart';

@JsonSerializable()
class BmiStatisticalResponse {
  @JsonKey(name: "meta")
  final Meta? meta;
  @JsonKey(name: "data")
  final BmiStatistical? data;

  BmiStatisticalResponse({
    this.meta,
    this.data,
  });

  factory BmiStatisticalResponse.fromJson(Map<String, dynamic> json) =>
      _$BmiStatisticalResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BmiStatisticalResponseToJson(this);
}

@JsonSerializable()
class BmiStatistical {
  @JsonKey(name: "value")
  final double? value;
  @JsonKey(name: "weight")
  final double? weight;
  @JsonKey(name: "height")
  final double? height;
  @JsonKey(name: "currentLedend")
  final End? currentLedend;
  @JsonKey(name: "legends")
  final List<End>? legends;

  BmiStatistical({
    this.value,
    this.weight,
    this.height,
    this.currentLedend,
    this.legends,
  });

  factory BmiStatistical.fromJson(Map<String, dynamic> json) =>
      _$BmiStatisticalFromJson(json);

  Map<String, dynamic> toJson() => _$BmiStatisticalToJson(this);

  String? get bmiEvaluation => currentLedend?.text;

  Color? get color => Utils.parseStringToColor(currentLedend?.colorCode);

  List<Color>? get thresholdColors => legends != null
      ? legends!
          .map((e) => Utils.parseStringToColor(e.colorCode))
          .toList()
      : null;
}

@JsonSerializable()
class End {
  @JsonKey(name: "text")
  final String? text;
  @JsonKey(name: "colorCode")
  final String? colorCode;
  @JsonKey(name: "backgroundColorCode")
  final String? backgroundColorCode;
  @JsonKey(name: "textcolorCode")
  final String? textcolorCode;

  End({
    this.text,
    this.colorCode,
    this.backgroundColorCode,
    this.textcolorCode,
  });

  factory End.fromJson(Map<String, dynamic> json) => _$EndFromJson(json);

  Map<String, dynamic> toJson() => _$EndToJson(this);
}
