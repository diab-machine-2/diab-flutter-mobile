// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bmi_weight_statistical_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BmiWeightStatisticalResponse _$BmiWeightStatisticalResponseFromJson(
        Map<String, dynamic> json) =>
    BmiWeightStatisticalResponse(
      meta: json['meta'] == null
          ? null
          : Meta.fromJson(json['meta'] as Map<String, dynamic>),
      data: json['data'] == null
          ? null
          : BmiWeightStatistical.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BmiWeightStatisticalResponseToJson(
        BmiWeightStatisticalResponse instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'data': instance.data,
    };

BmiWeightStatistical _$BmiWeightStatisticalFromJson(
        Map<String, dynamic> json) =>
    BmiWeightStatistical(
      safeWeightFrom: (json['safeWeightFrom'] as num?)?.toInt(),
      safeWeightTo: (json['safeWeightTo'] as num?)?.toInt(),
      weightSafes: (json['weightSafes'] as List<dynamic>?)
          ?.map((e) => WeightSafe.fromJson(e as Map<String, dynamic>))
          .toList(),
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

Map<String, dynamic> _$BmiWeightStatisticalToJson(
        BmiWeightStatistical instance) =>
    <String, dynamic>{
      'safeWeightFrom': instance.safeWeightFrom,
      'safeWeightTo': instance.safeWeightTo,
      'weightSafes': instance.weightSafes,
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

WeightSafe _$WeightSafeFromJson(Map<String, dynamic> json) => WeightSafe(
      safeWeightFrom: (json['safeWeightFrom'] as num?)?.toInt(),
      safeWeightTo: (json['safeWeightTo'] as num?)?.toInt(),
      safeDateFrom: (json['safeDateFrom'] as num?)?.toInt(),
      week: (json['week'] as num?)?.toInt(),
      length: (json['length'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WeightSafeToJson(WeightSafe instance) =>
    <String, dynamic>{
      'safeWeightFrom': instance.safeWeightFrom,
      'safeWeightTo': instance.safeWeightTo,
      'safeDateFrom': instance.safeDateFrom,
      'week': instance.week,
      'length': instance.length,
    };
