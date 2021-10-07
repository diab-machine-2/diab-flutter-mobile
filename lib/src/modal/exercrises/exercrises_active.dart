import 'package:meta/meta.dart';

class ExercriseActiveModel {
  final String? id;
  final String? name;
  final double? mets;
  final double? defaultMets;
  final String? intensityId;
  final String? intensityName;

  ExercriseActiveModel({
    required this.id,
    required this.name,
    required this.mets,
    required this.defaultMets,
    required this.intensityId,
    required this.intensityName,
  });
  @override
  factory ExercriseActiveModel.fromJson(Map<String, dynamic> json) {
    return ExercriseActiveModel(
      id: json['id'],
      name: json['name'],
      mets: json['mets'],
      defaultMets: json['defaultMets'],
      intensityId: json['intensityId'],
      intensityName: json['intensityName'],
    );
  }

  static List<ExercriseActiveModel> toList(List<dynamic> items) {
    return items.map((item) => ExercriseActiveModel.fromJson(item)).toList();
  }
}
