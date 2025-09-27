// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bmi_statistical_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BmiStatisticalResponse _$BmiStatisticalResponseFromJson(
        Map<String, dynamic> json) =>
    BmiStatisticalResponse(
      meta: json['meta'] == null
          ? null
          : Meta.fromJson(json['meta'] as Map<String, dynamic>),
      data: json['data'] == null
          ? null
          : BmiStatistical.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BmiStatisticalResponseToJson(
        BmiStatisticalResponse instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'data': instance.data,
    };

BmiStatistical _$BmiStatisticalFromJson(Map<String, dynamic> json) =>
    BmiStatistical(
      value: (json['value'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      currentLedend: json['currentLedend'] == null
          ? null
          : End.fromJson(json['currentLedend'] as Map<String, dynamic>),
      legends: (json['legends'] as List<dynamic>?)
          ?.map((e) => End.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BmiStatisticalToJson(BmiStatistical instance) =>
    <String, dynamic>{
      'value': instance.value,
      'weight': instance.weight,
      'height': instance.height,
      'currentLedend': instance.currentLedend,
      'legends': instance.legends,
    };

End _$EndFromJson(Map<String, dynamic> json) => End(
      text: json['text'] as String?,
      colorCode: json['colorCode'] as String?,
      backgroundColorCode: json['backgroundColorCode'] as String?,
      textcolorCode: json['textcolorCode'] as String?,
    );

Map<String, dynamic> _$EndToJson(End instance) => <String, dynamic>{
      'text': instance.text,
      'colorCode': instance.colorCode,
      'backgroundColorCode': instance.backgroundColorCode,
      'textcolorCode': instance.textcolorCode,
    };
