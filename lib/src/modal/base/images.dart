import 'package:meta/meta.dart';
@immutable
class ImagesModel {
  final String? id;
  final String? url;

  const ImagesModel({
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["id"] = id;
    data["url"] = url;
    return data;
  }

  static List<ImagesModel> toList(List<dynamic> items) {
    return items.map((item) => ImagesModel.fromJson(item)).toList();
  }
}
