import 'package:json_annotation/json_annotation.dart';

part 'revise_weight_record_request.g.dart';

@JsonSerializable()
class ReviseWeightRecordRequest {
  @JsonKey(name: "id")
  final String id;
  @JsonKey(name: "images")
  final List<String>? images;
  @JsonKey(name: "date")
  final int date;
  @JsonKey(name: "weight")
  final double weight;
  @JsonKey(name: "waist")
  final double? waist;
  @JsonKey(name: "height")
  final double? height;
  @JsonKey(name: "note")
  final String? note;
  @JsonKey(name: "timeFrameId")
  final String? timeFrameId;
  @JsonKey(name: "removalImageIds")
  final List<String>? removalImageIds;
  @JsonKey(name: "thresholdType")
  final int? thresholdType;

  ReviseWeightRecordRequest({
    required this.id,
    this.images,
    required this.date,
    required this.weight,
    this.waist,
    this.height,
    this.note,
    this.timeFrameId,
    this.removalImageIds,
    this.thresholdType,
  });

  ReviseWeightRecordRequest copyWith({
    String? id,
    List<String>? images,
    int? date,
    double? weight,
    double? waist,
    double? height,
    String? note,
    String? timeFrameId,
    List<String>? removalImageIds,
    int? thresholdType,
  }) =>
      ReviseWeightRecordRequest(
        id: id ?? this.id,
        images: images ?? this.images,
        date: date ?? this.date,
        weight: weight ?? this.weight,
        waist: waist ?? this.waist,
        height: height ?? this.height,
        note: note ?? this.note,
        timeFrameId: timeFrameId ?? this.timeFrameId,
        removalImageIds: removalImageIds ?? this.removalImageIds,
        thresholdType: thresholdType ?? this.thresholdType,
      );

  factory ReviseWeightRecordRequest.create({
    required String id,
    List<String>? images,
    required int date,
    required double weight,
    double? waist,
    double? height,
    String? note,
    List<String>? removalImageIds,
  }) =>
      ReviseWeightRecordRequest(
        id: id,
        date: date,
        weight: weight,
        height: height,
        images: images,
        waist: waist,
        note: note,
        removalImageIds: removalImageIds,
      );

  factory ReviseWeightRecordRequest.fromJson(Map<String, dynamic> json) =>
      _$ReviseWeightRecordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ReviseWeightRecordRequestToJson(this);
}
