import 'package:json_annotation/json_annotation.dart';
import 'package:medical/src/model/response/base/response.dart';

part 'delete_weight_record_response.g.dart';

@JsonSerializable()
class DeleteWeightRecordResponse {
    @JsonKey(name: "meta")
    final Meta? meta;
    @JsonKey(name: "data")
    final bool? data;

    DeleteWeightRecordResponse({
        this.meta,
        this.data,
    });

    factory DeleteWeightRecordResponse.fromJson(Map<String, dynamic> json) => _$DeleteWeightRecordResponseFromJson(json);

    Map<String, dynamic> toJson() => _$DeleteWeightRecordResponseToJson(this);
}