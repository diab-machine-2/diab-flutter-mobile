import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'bmi_get_weight_detail_response.g.dart';

@JsonSerializable()
class BmiGetWeightDetailResponse {
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

    BmiGetWeightDetailResponse({
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

    factory BmiGetWeightDetailResponse.fromJson(Map<String, dynamic> json) => _$BmiGetWeightDetailResponseFromJson(json);

    Map<String, dynamic> toJson() => _$BmiGetWeightDetailResponseToJson(this);
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

    factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);

    Map<String, dynamic> toJson() => _$ImageToJson(this);
}