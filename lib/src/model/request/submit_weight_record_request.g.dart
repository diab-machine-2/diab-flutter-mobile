// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_weight_record_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmitWeightRecordRequest _$SubmitWeightRecordRequestFromJson(
        Map<String, dynamic> json) =>
    SubmitWeightRecordRequest(
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      date: (json['date'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      waist: (json['waist'] as num?)?.toDouble(),
      height: (json['height'] as num).toDouble(),
      note: json['note'] as String?,
      timeFrameValue: (json['timeFrameValue'] as num?)?.toInt(),
      timeFrameId: json['timeFrameId'] as String?,
      thresholdType: (json['thresholdType'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SubmitWeightRecordRequestToJson(
        SubmitWeightRecordRequest instance) =>
    <String, dynamic>{
      'images': instance.images,
      'date': instance.date,
      'weight': instance.weight,
      'waist': instance.waist,
      'height': instance.height,
      'note': instance.note,
      'timeFrameValue': instance.timeFrameValue,
      'timeFrameId': instance.timeFrameId,
      'thresholdType': instance.thresholdType,
    };
