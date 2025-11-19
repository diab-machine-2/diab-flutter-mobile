// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revise_weight_record_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviseWeightRecordRequest _$ReviseWeightRecordRequestFromJson(
        Map<String, dynamic> json) =>
    ReviseWeightRecordRequest(
      id: json['id'] as String,
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      date: (json['date'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      waist: (json['waist'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      note: json['note'] as String?,
      timeFrameId: json['timeFrameId'] as String?,
      removalImageIds: (json['removalImageIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      thresholdType: (json['thresholdType'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ReviseWeightRecordRequestToJson(
        ReviseWeightRecordRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'images': instance.images,
      'date': instance.date,
      'weight': instance.weight,
      'waist': instance.waist,
      'height': instance.height,
      'note': instance.note,
      'timeFrameId': instance.timeFrameId,
      'removalImageIds': instance.removalImageIds,
      'thresholdType': instance.thresholdType,
    };
