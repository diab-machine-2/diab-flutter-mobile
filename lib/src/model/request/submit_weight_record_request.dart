import 'package:json_annotation/json_annotation.dart';

part 'submit_weight_record_request.g.dart';

@JsonSerializable()
class SubmitWeightRecordRequest {
    @JsonKey(name: "images")
    final List<String>? images;
    @JsonKey(name: "date")
    final int? date;
    @JsonKey(name: "weight")
    final int? weight;
    @JsonKey(name: "waist")
    final int? waist;
    @JsonKey(name: "height")
    final int? height;
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
        this.date,
        this.weight,
        this.waist,
        this.height,
        this.note,
        this.timeFrameValue,
        this.timeFrameId,
        this.thresholdType,
    });

    SubmitWeightRecordRequest copyWith({
        List<String>? images,
        int? date,
        int? weight,
        int? waist,
        int? height,
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

    factory SubmitWeightRecordRequest.fromJson(Map<String, dynamic> json) => _$SubmitWeightRecordRequestFromJson(json);

    Map<String, dynamic> toJson() => _$SubmitWeightRecordRequestToJson(this);
}
