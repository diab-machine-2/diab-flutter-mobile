import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

part 'submit_weight_record_request.g.dart';

@JsonSerializable()
class SubmitWeightRecordRequest {
  @JsonKey(name: "images")
  final List<String>? images;
  @JsonKey(name: "date")
  final int date;
  @JsonKey(name: "weight")
  final double weight;
  @JsonKey(name: "waist")
  final double? waist;
  @JsonKey(name: "height")
  final double height;
  @JsonKey(name: "note")
  final String? note;
  @JsonKey(name: "timeFrameValue")
  final int? timeFrameValue;
  @JsonKey(name: "timeFrameId")
  final String? timeFrameId;
  @JsonKey(name: "thresholdType")
  final int? thresholdType;

  SubmitWeightRecordRequest({
    this.images,
    required this.date,
    required this.weight,
    this.waist,
    required this.height,
    this.note,
    this.timeFrameValue,
    this.timeFrameId,
    this.thresholdType,
  });

  SubmitWeightRecordRequest copyWith({
    List<String>? images,
    int? date,
    double? weight,
    double? waist,
    double? height,
    String? note,
    int? timeFrameValue,
    String? timeFrameId,
    int? thresholdType,
  }) =>
      SubmitWeightRecordRequest(
        images: images ?? this.images,
        date: date ?? this.date,
        weight: weight ?? this.weight,
        waist: waist ?? this.waist,
        height: height ?? this.height,
        note: note ?? this.note,
        timeFrameValue: timeFrameValue ?? this.timeFrameValue,
        timeFrameId: timeFrameId ?? this.timeFrameId,
        thresholdType: thresholdType ?? this.thresholdType,
      );

  factory SubmitWeightRecordRequest.create({
    List<String>? images,
    required int date,
    required double weight,
    double? waist,
    required double height,
    String? note,
  }) =>
      SubmitWeightRecordRequest(
        date: date,
        weight: weight,
        height: height,
        images: images,
        waist: waist,
        note: note,
      );

  factory SubmitWeightRecordRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitWeightRecordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitWeightRecordRequestToJson(this);
}
