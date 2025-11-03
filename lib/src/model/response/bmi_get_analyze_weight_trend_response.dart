import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

import 'package:medical/src/model/response/base/response.dart';

part 'bmi_get_analyze_weight_trend_response.g.dart';

@JsonSerializable()
class BmiGetAnalyzeWeightTrendResponse {
    @JsonKey(name: "meta")
    final Meta? meta;
    @JsonKey(name: "data")
    final String? data;

    BmiGetAnalyzeWeightTrendResponse({
        this.meta,
        this.data,
    });

    BmiGetAnalyzeWeightTrendResponse copyWith({
        Meta? meta,
        String? data,
    }) => 
        BmiGetAnalyzeWeightTrendResponse(
            meta: meta ?? this.meta,
            data: data ?? this.data,
        );

    factory BmiGetAnalyzeWeightTrendResponse.fromJson(Map<String, dynamic> json) => _$BmiGetAnalyzeWeightTrendResponseFromJson(json);

    Map<String, dynamic> toJson() => _$BmiGetAnalyzeWeightTrendResponseToJson(this);
}
