import 'package:medical/src/modal/base/images.dart';
import 'package:meta/meta.dart';

class ActivityModel {
  final String id;
  final String name;
  final ImagesModel icon;

  ActivityModel({
    @required this.id,
    @required this.name,
    @required this.icon,
  });
  @override
  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'],
      name: json['name'] ?? json['text'],
      icon: ImagesModel.fromJson(json['icon']),
    );
  }
  static List<ActivityModel> toList(List<dynamic> items) {
    return items.map((item) => ActivityModel.fromJson(item)).toList();
  }
}
