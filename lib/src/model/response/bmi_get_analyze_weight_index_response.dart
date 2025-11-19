import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

import 'package:medical/src/model/response/base/response.dart';

part 'bmi_get_analyze_weight_index_response.g.dart';

@JsonSerializable()
class BmiGetAnalyzeWeightIndexResponse {
    @JsonKey(name: "meta")
    final Meta? meta;
    @JsonKey(name: "data")
    final String? data;

    BmiGetAnalyzeWeightIndexResponse({
        this.meta,
        this.data,
    });

    BmiGetAnalyzeWeightIndexResponse copyWith({
        Meta? meta,
        String? data,
    }) => 
        BmiGetAnalyzeWeightIndexResponse(
            meta: meta ?? this.meta,
            data: data ?? this.data,
        );

    factory BmiGetAnalyzeWeightIndexResponse.fromJson(Map<String, dynamic> json) => _$BmiGetAnalyzeWeightIndexResponseFromJson(json);

    Map<String, dynamic> toJson() => _$BmiGetAnalyzeWeightIndexResponseToJson(this);
}
