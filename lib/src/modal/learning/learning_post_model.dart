import 'package:medical/src/modal/base/images.dart';
import 'package:meta/meta.dart';

@immutable
class LearningPostModel {
  final String? id;
  final String title;
  final String? link;
  final ImagesModel imageUrl;
  final ImagesModel? imagePartnerUrl;
  final ImagesModel? imageBannerUrl;
  final int? status;
  final bool enableLink;
  final String? content;
  final String? partnerName;
  final String createDatetime;
  final List<LearningPostTagMappings> learningPostTagMappings;

  const LearningPostModel({
    required this.id,
    required this.title,
    required this.link,
    required this.imageUrl,
    required this.status,
    required this.enableLink,
    required this.createDatetime,
    required this.learningPostTagMappings,
    this.imagePartnerUrl,
    this.imageBannerUrl,
    this.partnerName,
    this.content,
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
      imagePartnerUrl: json['imagePartnerUrl'] != null
          ? ImagesModel.fromJson(json['imagePartnerUrl'])
          : null,
      imageBannerUrl: json['imageBannerUrl'] != null
          ? ImagesModel.fromJson(json['imageBannerUrl'])
          : null,
    );
  }

  static List<LearningPostModel> toList(List<dynamic> items) {
    return items.map((item) => LearningPostModel.fromJson(item)).toList();
  }

  static LearningPostModel toItem(dynamic item) {
    return LearningPostModel.fromJson(item);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'link': link,
      'imageUrl': imageUrl.toJson(),
      'imagePartnerUrl': imagePartnerUrl?.toJson(),
      'imageBannerUrl': imageBannerUrl?.toJson(),
      'status': status,
      'enableLink': enableLink,
      'content': content,
      'partnerName': partnerName,
      'createDatetime': createDatetime,
      'learningPostTagMappings': learningPostTagMappings
          .map((tag) => {'id': tag.id, 'name': tag.name, 'type': tag.type})
          .toList(),
    };
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

class LessonModel {
  final String id;
  final String name;
  final int status;
  final int type;
  final String level;
  final String module;
  final int learningStatus;
  final int percentComplete;
  final int order;
  final int levelOrder;
  final bool isNew;
  final int activeDateTime;
  final String? description;
  // final dynamic lessonTagMappings;
  final ImagesModel? image;
  // final int lessonLevelOrder;
  // final dynamic lessonSections;
  // final dynamic lessonQuizAccounts;

  LessonModel({
    required this.id,
    required this.name,
    required this.status,
    required this.type,
    required this.level,
    required this.module,
    required this.learningStatus,
    required this.percentComplete,
    required this.order,
    required this.levelOrder,
    required this.isNew,
    required this.activeDateTime,
    this.description,
    // required this.lessonTagMappings,
    required this.image,
    // required this.lessonLevelOrder,
    // required this.lessonSections,
    // required this.lessonQuizAccounts,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      type: json['type'],
      level: json['level'],
      module: json['module'] is Map ? json['module']["name"] : json['module'],
      learningStatus: json['learningStatus'],
      percentComplete: json['percentComplete'],
      order: json['order'],
      levelOrder: json['levelOrder'],
      isNew: json['isNew'],
      activeDateTime: json['activeDateTime'],
      description: json['description'],
      // lessonTagMappings: json['lessonTagMappings'],
      image: json['image'] != null ? ImagesModel.fromJson(json['image']) : null,
      // lessonLevelOrder: json['lessonLevelOrder'],
      // lessonSections: json['lessonSections'],
      // lessonQuizAccounts: json['lessonQuizAccounts'],
    );
  }

  static List<LessonModel> toList(List<dynamic> items) {
    return items.map((item) => LessonModel.fromJson(item)).toList();
  }
}
