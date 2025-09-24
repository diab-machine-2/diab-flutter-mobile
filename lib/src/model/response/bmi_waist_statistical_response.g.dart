// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bmi_waist_statistical_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BmiWaistStatisticalResponse _$BmiWaistStatisticalResponseFromJson(
        Map<String, dynamic> json) =>
    BmiWaistStatisticalResponse(
      meta: json['meta'] == null
          ? null
          : Meta.fromJson(json['meta'] as Map<String, dynamic>),
      data: json['data'] == null
          ? null
          : BmiWaistStatistical.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BmiWaistStatisticalResponseToJson(
        BmiWaistStatisticalResponse instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'data': instance.data,
    };

BmiWaistStatistical _$BmiWaistStatisticalFromJson(Map<String, dynamic> json) =>
    BmiWaistStatistical(
      current: (json['current'] as num?)?.toInt(),
      lowest: (json['lowest'] as num?)?.toInt(),
      highest: (json['highest'] as num?)?.toInt(),
      goal: (json['goal'] as num?)?.toInt(),
      message: json['message'] as String?,
      iconUrl: json['iconUrl'] as String?,
      trendItems: (json['trendItems'] as List<dynamic>?)
          ?.map((e) => TrendItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BmiWaistStatisticalToJson(
        BmiWaistStatistical instance) =>
    <String, dynamic>{
      'current': instance.current,
      'lowest': instance.lowest,
      'highest': instance.highest,
      'goal': instance.goal,
      'message': instance.message,
      'iconUrl': instance.iconUrl,
      'trendItems': instance.trendItems,
    };

TrendItem _$TrendItemFromJson(Map<String, dynamic> json) => TrendItem(
      date: (json['date'] as num?)?.toInt(),
      value: (json['value'] as num?)?.toInt(),
      colorCode: json['colorCode'] as String?,
    );

Map<String, dynamic> _$TrendItemToJson(TrendItem instance) => <String, dynamic>{
      'date': instance.date,
      'value': instance.value,
      'colorCode': instance.colorCode,
    };
