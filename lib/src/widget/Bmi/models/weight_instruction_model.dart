import 'package:json_annotation/json_annotation.dart';

part 'weight_instruction_model.g.dart';

@JsonSerializable()
class WeightInstructionModel {
    @JsonKey(name: "id")
    final String? id;
    @JsonKey(name: "name")
    final String? name;
    @JsonKey(name: "image")
    final String? image;
    @JsonKey(name: "type")
    final int? type;

    WeightInstructionModel({
        this.id,
        this.name,
        this.image,
        this.type,
    });

    factory WeightInstructionModel.fromJson(Map<String, dynamic> json) => _$WeightInstructionModelFromJson(json);

    Map<String, dynamic> toJson() => _$WeightInstructionModelToJson(this);
}
