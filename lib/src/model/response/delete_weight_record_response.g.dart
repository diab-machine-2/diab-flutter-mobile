// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_weight_record_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteWeightRecordResponse _$DeleteWeightRecordResponseFromJson(
        Map<String, dynamic> json) =>
    DeleteWeightRecordResponse(
      meta: json['meta'] == null
          ? null
          : Meta.fromJson(json['meta'] as Map<String, dynamic>),
      data: json['data'] as bool?,
    );

Map<String, dynamic> _$DeleteWeightRecordResponseToJson(
        DeleteWeightRecordResponse instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'data': instance.data,
    };
