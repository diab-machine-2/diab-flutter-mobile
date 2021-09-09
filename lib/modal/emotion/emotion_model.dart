import 'package:meta/meta.dart';

class EmotionModel {
  final String id;
  final String code;
  final String vietnameseName;
  final String englishName;
  final String description;
  final String emotionCategoryId;
  final String coverId;
  final int status;
  final String imageUrl;

  EmotionModel({
    @required this.id,
    @required this.code,
    @required this.vietnameseName,
    @required this.englishName,
    @required this.description,
    @required this.emotionCategoryId,
    @required this.coverId,
    @required this.status,
    @required this.imageUrl,
  });
  @override
  factory EmotionModel.fromJson(Map<String, dynamic> json) {
    return EmotionModel(
        id: json['id'],
        code: json['code'],
        vietnameseName: json['vietnameseName'],
        englishName: json['englishName'],
        description: json['description'],
        emotionCategoryId: json['emotionCategoryId'],
        coverId: json['coverId'],
        status: json['status'],
        imageUrl: json['imageUrl']);
  }
  static List<EmotionModel> toList(List<dynamic> items) {
    return items.map((item) => EmotionModel.fromJson(item)).toList();
  }
}
