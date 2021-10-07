import 'package:meta/meta.dart';

class ImagesModel {
  final String? id;
  final String? url;

  ImagesModel({
    required this.id,
    required this.url,
  });
  @override
  factory ImagesModel.fromJson(Map<String, dynamic> json) {
    return ImagesModel(
      id: json['id'],
      url: json['url'],
    );
  }
  static List<ImagesModel> toList(List<dynamic> items) {
    return items.map((item) => ImagesModel.fromJson(item)).toList();
  }
}
