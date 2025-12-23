import 'package:medical/src/modal/base/images.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/response/user_coach.dart';
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
  // Webinar fields
  final String? accountId;
  final bool? eventType;
  final int? eventJoinCount;
  final String? eventTime;
  final int? eventDate;
  final bool? isJoin;
  final String? eventAddress;
  final UserCoach? account;
  final int? duration; // Event duration in hours
  final String? lessonId; // ID of the lesson for replay
  final LessonSectionListResponseData? lesson; // Lesson data for replay

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
    this.accountId,
    this.eventType,
    this.eventJoinCount,
    this.eventTime,
    this.eventDate,
    this.isJoin,
    this.eventAddress,
    this.account,
    this.duration,
    this.lessonId,
    this.lesson,
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
      id: json['id']?.toString(),
      title: json['title'] ?? "",
      link: json['link']?.toString(),
      status: json['status'],
      enableLink: json['enableLink'] ?? false,
      content: json['content'] ?? "",
      partnerName: json['partnerName'],
      createDatetime: json['createDatetime']?.toString() ?? '',
      learningPostTagMappings: _learningPostTagMappings,
      imageUrl: json['imageUrl'] != null && json['imageUrl'] is Map
          ? ImagesModel.fromJson(json['imageUrl'] as Map<String, dynamic>)
          : const ImagesModel(id: null, url: null),
      imagePartnerUrl:
          json['imagePartnerUrl'] != null && json['imagePartnerUrl'] is Map
              ? ImagesModel.fromJson(
                  json['imagePartnerUrl'] as Map<String, dynamic>)
              : null,
      imageBannerUrl: json['imageBannerUrl'] != null &&
              json['imageBannerUrl'] is Map
          ? ImagesModel.fromJson(json['imageBannerUrl'] as Map<String, dynamic>)
          : null,
      accountId: json['accountId']?.toString(),
      eventType: json['eventType'],
      eventJoinCount: json['eventJoinCount'],
      eventTime: json['eventTime']?.toString(),
      eventDate: json['eventDate'],
      isJoin: json['isJoin'],
      eventAddress: json['eventAddress']?.toString(),
      account: json['account'] != null && json['account'] is Map
          ? UserCoach.fromJson(json['account'] as Map<String, dynamic>)
          : null,
      duration: json['duration'] is int
          ? json['duration']
          : (json['duration'] != null
              ? int.tryParse(json['duration'].toString())
              : null),
      lessonId: json['lessonId']?.toString(),
      lesson: json['lesson'] != null && json['lesson'] is Map
          ? LessonSectionListResponseData.fromJson(
              json['lesson'] as Map<String, dynamic>)
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
      'accountId': accountId,
      'eventType': eventType,
      'eventJoinCount': eventJoinCount,
      'eventTime': eventTime,
      'eventDate': eventDate,
      'isJoin': isJoin,
      'eventAddress': eventAddress,
      'account': account?.toJson(),
      'duration': duration,
      'lessonId': lessonId,
      'lesson': lesson?.toJson(),
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
