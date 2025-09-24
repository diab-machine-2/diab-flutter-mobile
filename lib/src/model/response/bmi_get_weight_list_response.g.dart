// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bmi_get_weight_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BmiGetWeightListResponse _$BmiGetWeightListResponseFromJson(
        Map<String, dynamic> json) =>
    BmiGetWeightListResponse(
      meta: json['meta'] == null
          ? null
          : BmiGetWeightListMeta.fromJson(json['meta'] as Map<String, dynamic>),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => BmiGetWeightRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BmiGetWeightListResponseToJson(
        BmiGetWeightListResponse instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'data': instance.data,
    };

BmiGetWeightRecord _$BmiGetWeightRecordFromJson(Map<String, dynamic> json) =>
    BmiGetWeightRecord(
      id: json['id'] as String?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => Image.fromJson(e as Map<String, dynamic>))
          .toList(),
      date: (json['date'] as num?)?.toInt(),
      weight: (json['weight'] as num?)?.toInt(),
      waist: (json['waist'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      bmi: (json['bmi'] as num?)?.toInt(),
      note: json['note'] as String?,
      timeFrameId: json['timeFrameId'] as String?,
      timeFrameText: json['timeFrameText'] as String?,
      bmiId: json['bmiId'] as String?,
      bmiText: json['bmiText'] as String?,
      waistId: json['waistId'] as String?,
      bmiColorCode: json['bmiColorCode'] as String?,
      bmiBackgroundColorCode: json['bmiBackgroundColorCode'] as String?,
      bmiTextColorCode: json['bmiTextColorCode'] as String?,
      waistColorCode: json['waistColorCode'] as String?,
      isPregnancy: json['isPregnancy'] as bool?,
    );

Map<String, dynamic> _$BmiGetWeightRecordToJson(BmiGetWeightRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'images': instance.images,
      'date': instance.date,
      'weight': instance.weight,
      'waist': instance.waist,
      'height': instance.height,
      'bmi': instance.bmi,
      'note': instance.note,
      'timeFrameId': instance.timeFrameId,
      'timeFrameText': instance.timeFrameText,
      'bmiId': instance.bmiId,
      'bmiText': instance.bmiText,
      'waistId': instance.waistId,
      'bmiColorCode': instance.bmiColorCode,
      'bmiBackgroundColorCode': instance.bmiBackgroundColorCode,
      'bmiTextColorCode': instance.bmiTextColorCode,
      'waistColorCode': instance.waistColorCode,
      'isPregnancy': instance.isPregnancy,
    };

Image _$ImageFromJson(Map<String, dynamic> json) => Image(
      id: json['id'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$ImageToJson(Image instance) => <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
    };

BmiGetWeightListMeta _$BmiGetWeightListMetaFromJson(
        Map<String, dynamic> json) =>
    BmiGetWeightListMeta(
      success: json['success'] as bool?,
      total: (json['total'] as num?)?.toInt(),
      pageCount: (json['pageCount'] as num?)?.toInt(),
      page: (json['page'] as num?)?.toInt(),
      size: (json['size'] as num?)?.toInt(),
      canNext: json['canNext'] as bool?,
      canPrev: json['canPrev'] as bool?,
    );

Map<String, dynamic> _$BmiGetWeightListMetaToJson(
        BmiGetWeightListMeta instance) =>
    <String, dynamic>{
      'success': instance.success,
      'total': instance.total,
      'pageCount': instance.pageCount,
      'page': instance.page,
      'size': instance.size,
      'canNext': instance.canNext,
      'canPrev': instance.canPrev,
    };
