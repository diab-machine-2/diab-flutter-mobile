// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bmi_get_weight_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BmiGetWeightDetailResponse _$BmiGetWeightDetailResponseFromJson(
        Map<String, dynamic> json) =>
    BmiGetWeightDetailResponse(
      meta: json['meta'] == null
          ? null
          : Meta.fromJson(json['meta'] as Map<String, dynamic>),
      data: json['data'] == null
          ? null
          : BmiGetWeightDetail.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BmiGetWeightDetailResponseToJson(
        BmiGetWeightDetailResponse instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'data': instance.data,
    };

BmiGetWeightDetail _$BmiGetWeightDetailFromJson(Map<String, dynamic> json) =>
    BmiGetWeightDetail(
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

Map<String, dynamic> _$BmiGetWeightDetailToJson(BmiGetWeightDetail instance) =>
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
