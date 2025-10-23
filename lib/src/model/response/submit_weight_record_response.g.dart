// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_weight_record_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmitWeightRecordResponse _$SubmitWeightRecordResponseFromJson(
        Map<String, dynamic> json) =>
    SubmitWeightRecordResponse(
      meta: json['meta'] == null
          ? null
          : Meta.fromJson(json['meta'] as Map<String, dynamic>),
      data: json['data'] as String?,
    );

Map<String, dynamic> _$SubmitWeightRecordResponseToJson(
        SubmitWeightRecordResponse instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'data': instance.data,
    };
