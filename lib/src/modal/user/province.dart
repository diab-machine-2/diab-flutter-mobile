import 'package:meta/meta.dart';

class ProvinceModel {
  final String? id;
  final String? name;

  ProvinceModel({required this.id, required this.name});

  factory ProvinceModel.fromJson(Map<String, dynamic> json) {
    return ProvinceModel(id: json['id'], name: json['name']);
  }

  static List<ProvinceModel> toList(List<dynamic> items) {
    return items.map((item) => ProvinceModel.fromJson(item)).toList();
  }
}
