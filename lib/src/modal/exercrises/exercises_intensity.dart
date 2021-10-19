import 'package:meta/meta.dart';

class ExerciseIntensityModel {
  final String? id;
  final String? name;
  final String? note;
  final double? rate;

  ExerciseIntensityModel({
    required this.id,
    required this.name,
    required this.note,
    required this.rate,
  });
  @override
  factory ExerciseIntensityModel.fromJson(Map<String, dynamic> json) {
    return ExerciseIntensityModel(
      id: json['id'],
      name: json['name'],
      note: json['note'],
      rate: json['rate'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['note'] = note;
    map['rate'] = rate;
    return map;
  }

  static List<ExerciseIntensityModel> toList(List<dynamic> items) {
    return items.map((item) => ExerciseIntensityModel.fromJson(item)).toList();
  }
}
