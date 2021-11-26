import 'package:medical/src/modal/base/images.dart';
import 'package:meta/meta.dart';
@immutable
class LearningPostModel {
  final String? id;
  final String? title;
  final String? link;
  final ImagesModel imageUrl;

  const LearningPostModel(
      {required this.id,
      required this.title,
      required this.link,
      required this.imageUrl});
  @override
  factory LearningPostModel.fromJson(Map<String, dynamic> json) {
    return LearningPostModel(
        id: json['id'],
        title: json['title'],
        link: json['link'],
        imageUrl: ImagesModel.fromJson(json['imageUrl']));
  }

  static List<LearningPostModel> toList(List<dynamic> items) {
    return items.map((item) => LearningPostModel.fromJson(item)).toList();
  }
}
