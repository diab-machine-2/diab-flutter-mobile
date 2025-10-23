// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_weight_threshold_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetWeightThresholdResponse _$GetWeightThresholdResponseFromJson(
        Map<String, dynamic> json) =>
    GetWeightThresholdResponse(
      meta: json['meta'] == null
          ? null
          : Meta.fromJson(json['meta'] as Map<String, dynamic>),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => WeightThreshold.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetWeightThresholdResponseToJson(
        GetWeightThresholdResponse instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'data': instance.data,
    };

WeightThreshold _$WeightThresholdFromJson(Map<String, dynamic> json) =>
    WeightThreshold(
      weight: (json['weight'] as num?)?.toDouble(),
      colorCode: json['colorCode'] as String?,
      backgroundColorCode: json['backgroundColorCode'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$WeightThresholdToJson(WeightThreshold instance) =>
    <String, dynamic>{
      'weight': instance.weight,
      'colorCode': instance.colorCode,
      'backgroundColorCode': instance.backgroundColorCode,
      'name': instance.name,
    };
