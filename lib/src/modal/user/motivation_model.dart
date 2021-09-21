import 'package:meta/meta.dart';

class MotivationModel {
  final String? content;
  final String? id;
  final int? createDateTime;

  MotivationModel(
      {required this.content,
      required this.id,
      required this.createDateTime});

  factory MotivationModel.fromJson(Map<String, dynamic> json) {
    return MotivationModel(
        content: json['content'],
        id: json['id'],
        createDateTime: json['createDateTime']);
  }

  static List<MotivationModel> toList(List<dynamic> items) {
    return items.map((item) => MotivationModel.fromJson(item)).toList();
  }
}
