import 'package:meta/meta.dart';
@immutable
class HomeMediaModel {
  final String? id;
  final String? mimeType;
  final String? mediaLink;

  HomeMediaModel({
    required this.id,
    required this.mimeType,
    required this.mediaLink,
  });
  @override
  factory HomeMediaModel.fromJson(Map<String, dynamic> json) {
    return HomeMediaModel(
        id: json['id'],
        mimeType: json['mimeType'],
        mediaLink: json['mediaLink']);
  }

  static List<HomeMediaModel> toList(List<dynamic> items) {
    return items.map((item) => HomeMediaModel.fromJson(item)).toList();
  }
}
