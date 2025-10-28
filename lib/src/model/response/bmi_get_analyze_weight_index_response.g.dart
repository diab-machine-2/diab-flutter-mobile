// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bmi_get_analyze_weight_index_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BmiGetAnalyzeWeightIndexResponse _$BmiGetAnalyzeWeightIndexResponseFromJson(
        Map<String, dynamic> json) =>
    BmiGetAnalyzeWeightIndexResponse(
      meta: json['meta'] == null
          ? null
          : Meta.fromJson(json['meta'] as Map<String, dynamic>),
      data: json['data'] as String?,
    );

Map<String, dynamic> _$BmiGetAnalyzeWeightIndexResponseToJson(
        BmiGetAnalyzeWeightIndexResponse instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'data': instance.data,
    };
