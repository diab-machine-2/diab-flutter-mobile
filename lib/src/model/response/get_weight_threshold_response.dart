import 'package:json_annotation/json_annotation.dart';
import 'package:medical/src/model/response/base/response.dart';

part 'get_weight_threshold_response.g.dart';

@JsonSerializable()
class GetWeightThresholdResponse {
    @JsonKey(name: "meta")
    final Meta? meta;
    @JsonKey(name: "data")
    final List<WeightThreshold>? data;

    GetWeightThresholdResponse({
        this.meta,
        this.data,
    });

    GetWeightThresholdResponse copyWith({
        Meta? meta,
        List<WeightThreshold>? data,
    }) => 
        GetWeightThresholdResponse(
            meta: meta ?? this.meta,
            data: data ?? this.data,
        );

    factory GetWeightThresholdResponse.fromJson(Map<String, dynamic> json) => _$GetWeightThresholdResponseFromJson(json);

    Map<String, dynamic> toJson() => _$GetWeightThresholdResponseToJson(this);
}

@JsonSerializable()
class WeightThreshold {
    @JsonKey(name: "weight")
    final double? weight;
    @JsonKey(name: "colorCode")
    final String? colorCode;
    @JsonKey(name: "backgroundColorCode")
    final String? backgroundColorCode;
    @JsonKey(name: "name")
    final String? name;

    WeightThreshold({
        this.weight,
        this.colorCode,
        this.backgroundColorCode,
        this.name,
    });

    WeightThreshold copyWith({
        double? weight,
        String? colorCode,
        String? backgroundColorCode,
        String? name,
    }) => 
        WeightThreshold(
            weight: weight ?? this.weight,
            colorCode: colorCode ?? this.colorCode,
            backgroundColorCode: backgroundColorCode ?? this.backgroundColorCode,
            name: name ?? this.name,
        );

    factory WeightThreshold.fromJson(Map<String, dynamic> json) => _$WeightThresholdFromJson(json);

    Map<String, dynamic> toJson() => _$WeightThresholdToJson(this);
}