import 'package:meta/meta.dart';
@immutable
class IconModel {
  final String? id;
  final String? url;

  const IconModel({
    required this.id,
    required this.url,
  });
  @override
  factory IconModel.fromJson(Map<String, dynamic> json) {
    return IconModel(
      id: json['id'],
      url: json['url'],
    );
  }
}
