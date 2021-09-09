import 'package:meta/meta.dart';

class IconModel {
  final String id;
  final String url;

  IconModel({
    @required this.id,
    @required this.url,
  });
  @override
  factory IconModel.fromJson(Map<String, dynamic> json) {
    return IconModel(
      id: json['id'],
      url: json['url'],
    );
  }
}
