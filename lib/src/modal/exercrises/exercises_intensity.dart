import 'package:meta/meta.dart';

class ExerciseIntensityModel {
  final String? id;
  final String? name;
  final String? note;

  ExerciseIntensityModel({
    required this.id,
    required this.name,
    required this.note,
  });
  @override
  factory ExerciseIntensityModel.fromJson(Map<String, dynamic> json) {
    return ExerciseIntensityModel(
      id: json['id'],
      name: json['name'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['note'] = note;
    return map;
  }

  static List<ExerciseIntensityModel> toList(List<dynamic> items) {
    return items.map((item) => ExerciseIntensityModel.fromJson(item)).toList();
  }
}
