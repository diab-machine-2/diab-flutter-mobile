import 'package:meta/meta.dart';

class ExercriseIntensityModel {
  final String id;
  final String name;
  final String note;

  ExercriseIntensityModel({
    @required this.id,
    @required this.name,
    @required this.note,
  });
  @override
  factory ExercriseIntensityModel.fromJson(Map<String, dynamic> json) {
    return ExercriseIntensityModel(
      id: json['id'],
      name: json['name'],
      note: json['note'],
    );
  }

  static List<ExercriseIntensityModel> toList(List<dynamic> items) {
    return items.map((item) => ExercriseIntensityModel.fromJson(item)).toList();
  }
}
