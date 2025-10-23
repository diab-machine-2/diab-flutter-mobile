import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

import 'package:medical/src/model/response/base/response.dart';

part 'bmi_get_weight_detail_response.g.dart';

@JsonSerializable()
class BmiGetWeightDetailResponse {
    @JsonKey(name: "meta")
    final Meta? meta;
    @JsonKey(name: "data")
    final BmiGetWeightDetail? data;

    BmiGetWeightDetailResponse({
        this.meta,
        this.data,
    });

    BmiGetWeightDetailResponse copyWith({
        Meta? meta,
        BmiGetWeightDetail? data,
    }) => 
        BmiGetWeightDetailResponse(
            meta: meta ?? this.meta,
            data: data ?? this.data,
        );

    factory BmiGetWeightDetailResponse.fromJson(Map<String, dynamic> json) => _$BmiGetWeightDetailResponseFromJson(json);

    Map<String, dynamic> toJson() => _$BmiGetWeightDetailResponseToJson(this);
}

@JsonSerializable()
class BmiGetWeightDetail {
    @JsonKey(name: "id")
    final String? id;
    @JsonKey(name: "images")
    final List<Image>? images;
    @JsonKey(name: "date")
    final int? date;
    @JsonKey(name: "weight")
    final int? weight;
    @JsonKey(name: "waist")
    final int? waist;
    @JsonKey(name: "height")
    final int? height;
    @JsonKey(name: "bmi")
    final int? bmi;
    @JsonKey(name: "note")
    final String? note;
    @JsonKey(name: "timeFrameId")
    final String? timeFrameId;
    @JsonKey(name: "timeFrameText")
    final String? timeFrameText;
    @JsonKey(name: "bmiId")
    final String? bmiId;
    @JsonKey(name: "bmiText")
    final String? bmiText;
    @JsonKey(name: "waistId")
    final String? waistId;
    @JsonKey(name: "bmiColorCode")
    final String? bmiColorCode;
    @JsonKey(name: "bmiBackgroundColorCode")
    final String? bmiBackgroundColorCode;
    @JsonKey(name: "bmiTextColorCode")
    final String? bmiTextColorCode;
    @JsonKey(name: "waistColorCode")
    final String? waistColorCode;
    @JsonKey(name: "isPregnancy")
    final bool? isPregnancy;

    BmiGetWeightDetail({
        this.id,
        this.images,
        this.date,
        this.weight,
        this.waist,
        this.height,
        this.bmi,
        this.note,
        this.timeFrameId,
        this.timeFrameText,
        this.bmiId,
        this.bmiText,
        this.waistId,
        this.bmiColorCode,
        this.bmiBackgroundColorCode,
        this.bmiTextColorCode,
        this.waistColorCode,
        this.isPregnancy,
    });

    BmiGetWeightDetail copyWith({
        String? id,
        List<Image>? images,
        int? date,
        int? weight,
        int? waist,
        int? height,
        int? bmi,
        String? note,
        String? timeFrameId,
        String? timeFrameText,
        String? bmiId,
        String? bmiText,
        String? waistId,
        String? bmiColorCode,
        String? bmiBackgroundColorCode,
        String? bmiTextColorCode,
        String? waistColorCode,
        bool? isPregnancy,
    }) => 
        BmiGetWeightDetail(
            id: id ?? this.id,
            images: images ?? this.images,
            date: date ?? this.date,
            weight: weight ?? this.weight,
            waist: waist ?? this.waist,
            height: height ?? this.height,
            bmi: bmi ?? this.bmi,
            note: note ?? this.note,
            timeFrameId: timeFrameId ?? this.timeFrameId,
            timeFrameText: timeFrameText ?? this.timeFrameText,
            bmiId: bmiId ?? this.bmiId,
            bmiText: bmiText ?? this.bmiText,
            waistId: waistId ?? this.waistId,
            bmiColorCode: bmiColorCode ?? this.bmiColorCode,
            bmiBackgroundColorCode: bmiBackgroundColorCode ?? this.bmiBackgroundColorCode,
            bmiTextColorCode: bmiTextColorCode ?? this.bmiTextColorCode,
            waistColorCode: waistColorCode ?? this.waistColorCode,
            isPregnancy: isPregnancy ?? this.isPregnancy,
        );

    factory BmiGetWeightDetail.fromJson(Map<String, dynamic> json) => _$BmiGetWeightDetailFromJson(json);

    Map<String, dynamic> toJson() => _$BmiGetWeightDetailToJson(this);
}

@JsonSerializable()
class Image {
    @JsonKey(name: "id")
    final String? id;
    @JsonKey(name: "url")
    final String? url;

    Image({
        this.id,
        this.url,
    });

    Image copyWith({
        String? id,
        String? url,
    }) => 
        Image(
            id: id ?? this.id,
            url: url ?? this.url,
        );

    factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);

    Map<String, dynamic> toJson() => _$ImageToJson(this);
}
