import 'package:medical/src/modal/base/images.dart';
import 'package:meta/meta.dart';

@immutable
class LearningPostModel {
  final String? id;
  final String title;
  final String? link;
  final ImagesModel imageUrl;
  final ImagesModel? imagePartnerUrl;
  final int? status;
  final bool enableLink;
  final String content;
  final String? partnerName;
  final String createDatetime;
  final List<LearningPostTagMappings> learningPostTagMappings;

  const LearningPostModel({
    required this.id,
    required this.title,
    required this.link,
    required this.imageUrl,
    required this.imagePartnerUrl,
    required this.status,
    required this.enableLink,
    required this.content,
    required this.createDatetime,
    this.partnerName,
    required this.learningPostTagMappings,
  });
  @override
  factory LearningPostModel.fromJson(Map<String, dynamic> json) {
    List<LearningPostTagMappings> _learningPostTagMappings = [];
    if (json['learningPostTagMappings'] != null) {
      json['learningPostTagMappings'].forEach((v) {
        _learningPostTagMappings.add(new LearningPostTagMappings.fromJson(v));
      });
    }

    return LearningPostModel(
      id: json['id'],
      title: json['title'] ?? "",
      link: json['link'],
      status: json['status'],
      enableLink: json['enableLink'] ?? false,
      content: json['content'] ?? "",
      partnerName: json['partnerName'],
      createDatetime: json['createDatetime'],
      learningPostTagMappings: _learningPostTagMappings,
      imageUrl: ImagesModel.fromJson(json['imageUrl']),
      imagePartnerUrl: ImagesModel.fromJson(json['imagePartnerUrl']),
    );
  }

  static List<LearningPostModel> toList(List<dynamic> items) {
    return items.map((item) => LearningPostModel.fromJson(item)).toList();
  }

  static LearningPostModel toItem(dynamic item) {
    return LearningPostModel.fromJson(item);
  }
}

class LearningPostTagMappings {
  late String id;
  late String name;
  late int type;

  LearningPostTagMappings.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
  }
}
