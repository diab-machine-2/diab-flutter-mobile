// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_instruction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightInstructionModel _$WeightInstructionModelFromJson(
        Map<String, dynamic> json) =>
    WeightInstructionModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      image: json['image'] as String?,
      type: (json['type'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WeightInstructionModelToJson(
        WeightInstructionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'type': instance.type,
    };
