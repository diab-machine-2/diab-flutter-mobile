// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bmi_get_analyze_weight_trend_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BmiGetAnalyzeWeightTrendResponse _$BmiGetAnalyzeWeightTrendResponseFromJson(
        Map<String, dynamic> json) =>
    BmiGetAnalyzeWeightTrendResponse(
      meta: json['meta'] == null
          ? null
          : Meta.fromJson(json['meta'] as Map<String, dynamic>),
      data: json['data'] as String?,
    );

Map<String, dynamic> _$BmiGetAnalyzeWeightTrendResponseToJson(
        BmiGetAnalyzeWeightTrendResponse instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'data': instance.data,
    };
