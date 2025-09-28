// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculate_bmi_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalculateBmiResponse _$CalculateBmiResponseFromJson(
        Map<String, dynamic> json) =>
    CalculateBmiResponse(
      meta: json['meta'] == null
          ? null
          : Meta.fromJson(json['meta'] as Map<String, dynamic>),
      data: json['data'] == null
          ? null
          : CaculateBmiModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CalculateBmiResponseToJson(
        CalculateBmiResponse instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'data': instance.data,
    };

CaculateBmiModel _$CaculateBmiModelFromJson(Map<String, dynamic> json) =>
    CaculateBmiModel(
      bmi: (json['bmi'] as num?)?.toDouble(),
      note: json['note'] as String?,
      colorCode: json['colorCode'] as String?,
    );

Map<String, dynamic> _$CaculateBmiModelToJson(CaculateBmiModel instance) =>
    <String, dynamic>{
      'bmi': instance.bmi,
      'note': instance.note,
      'colorCode': instance.colorCode,
    };
