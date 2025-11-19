import 'package:json_annotation/json_annotation.dart';
import 'package:medical/src/model/response/base/response.dart';

part 'submit_weight_record_response.g.dart';

@JsonSerializable()
class SubmitWeightRecordResponse {
    @JsonKey(name: "meta")
    final Meta? meta;
    @JsonKey(name: "data")
    final String? data;

    SubmitWeightRecordResponse({
        this.meta,
        this.data,
    });

    factory SubmitWeightRecordResponse.fromJson(Map<String, dynamic> json) => _$SubmitWeightRecordResponseFromJson(json);

    Map<String, dynamic> toJson() => _$SubmitWeightRecordResponseToJson(this);
}
