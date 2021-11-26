import 'package:medical/src/modal/base/images.dart';
import 'package:meta/meta.dart';
@immutable
class EmotionStatisticItemModel {
  final String? colorCode;
  final String? id;
  final int? count;
  final String? text;
  final ImagesModel icon;

  const EmotionStatisticItemModel({
    required this.colorCode,
    required this.id,
    required this.count,
    required this.text,
    required this.icon,
  });
  @override
  factory EmotionStatisticItemModel.fromJson(Map<String, dynamic> json) {
    return EmotionStatisticItemModel(
        colorCode: json['colorCode'],
        id: json['id'],
        count: json['count'],
        text: json['text'],
        icon: ImagesModel.fromJson(json['icon']));
  }
  static List<EmotionStatisticItemModel> toList(List<dynamic> items) {
    return items
        .map((item) => EmotionStatisticItemModel.fromJson(item))
        .toList();
  }
}
