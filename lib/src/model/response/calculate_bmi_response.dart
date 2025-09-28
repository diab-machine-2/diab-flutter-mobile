import 'package:json_annotation/json_annotation.dart';
import 'package:medical/src/model/response/base/response.dart';

part 'calculate_bmi_response.g.dart';

@JsonSerializable()
class CalculateBmiResponse {
  @JsonKey(name: "meta")
  final Meta? meta;
  @JsonKey(name: "data")
  final CaculateBmiModel? data;

  CalculateBmiResponse({
    this.meta,
    this.data,
  });

  factory CalculateBmiResponse.fromJson(Map<String, dynamic> json) =>
      _$CalculateBmiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CalculateBmiResponseToJson(this);
}

@JsonSerializable()
class CaculateBmiModel {
    @JsonKey(name: "bmi")
    final double? bmi;
    @JsonKey(name: "note")
    final String? note;
    @JsonKey(name: "colorCode")
    final String? colorCode;

    CaculateBmiModel({
        this.bmi,
        this.note,
        this.colorCode,
    });

    factory CaculateBmiModel.fromJson(Map<String, dynamic> json) => _$CaculateBmiModelFromJson(json);

    Map<String, dynamic> toJson() => _$CaculateBmiModelToJson(this);
}
