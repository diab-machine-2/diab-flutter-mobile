import 'package:medical/src/modal/base/images.dart';
import 'package:meta/meta.dart';

class SymptomModel {
  final String id;
  final String name;
  final ImagesModel icon;

  SymptomModel({
    @required this.id,
    @required this.name,
    @required this.icon,
  });
  @override
  factory SymptomModel.fromJson(Map<String, dynamic> json) {
    return SymptomModel(
        id: json['id'],
        name: json['name'] ?? json['text'],
        icon: ImagesModel.fromJson(json['icon']));
  }
  static List<SymptomModel> toList(List<dynamic> items) {
    return items.map((item) => SymptomModel.fromJson(item)).toList();
  }
}
