// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bmi_get_weight_lessons_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BmiGetWeightLessonsResponse _$BmiGetWeightLessonsResponseFromJson(
        Map<String, dynamic> json) =>
    BmiGetWeightLessonsResponse(
      meta: json['meta'] == null
          ? null
          : Meta.fromJson(json['meta'] as Map<String, dynamic>),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => BmiWeightLesson.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BmiGetWeightLessonsResponseToJson(
        BmiGetWeightLessonsResponse instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'data': instance.data,
    };

BmiWeightLesson _$BmiWeightLessonFromJson(Map<String, dynamic> json) =>
    BmiWeightLesson(
      id: json['id'] as String?,
      code: json['code'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      status: (json['status'] as num?)?.toInt(),
      type: (json['type'] as num?)?.toInt(),
      order: (json['order'] as num?)?.toInt(),
      orderHighest: (json['orderHighest'] as num?)?.toInt(),
      isEnabledRating: json['isEnabledRating'] as bool?,
      minCompletePercent: (json['minCompletePercent'] as num?)?.toInt(),
      coverId: json['coverId'] as String?,
      lessonModuleId: json['lessonModuleId'] as String?,
      lessonLevelId: json['lessonLevelId'] as String?,
      countLessonSection: (json['countLessonSection'] as num?)?.toInt(),
      countLessonAccount: (json['countLessonAccount'] as num?)?.toInt(),
      countLessonQuiz: (json['countLessonQuiz'] as num?)?.toInt(),
      countLessonQuizAccount: (json['countLessonQuizAccount'] as num?)?.toInt(),
      learningStatus: (json['learningStatus'] as num?)?.toInt(),
      lessonModule: json['lessonModule'] == null
          ? null
          : PurpleLesson.fromJson(json['lessonModule'] as Map<String, dynamic>),
      lessonLevel: json['lessonLevel'] == null
          ? null
          : PurpleLesson.fromJson(json['lessonLevel'] as Map<String, dynamic>),
      quizLessons: (json['quizLessons'] as List<dynamic>?)
          ?.map((e) => QuizLesson.fromJson(e as Map<String, dynamic>))
          .toList(),
      lessonTagMappings: (json['lessonTagMappings'] as List<dynamic>?)
          ?.map((e) => LessonTagMapping.fromJson(e as Map<String, dynamic>))
          .toList(),
      lessonSections: (json['lessonSections'] as List<dynamic>?)
          ?.map((e) => LessonSection.fromJson(e as Map<String, dynamic>))
          .toList(),
      lessonQuizAccounts: (json['lessonQuizAccounts'] as List<dynamic>?)
          ?.map((e) => LessonQuizAccount.fromJson(e as Map<String, dynamic>))
          .toList(),
      lessonReviews: (json['lessonReviews'] as List<dynamic>?)
          ?.map((e) => LessonReview.fromJson(e as Map<String, dynamic>))
          .toList(),
      lessonStates: (json['lessonStates'] as List<dynamic>?)
          ?.map((e) => LessonLevelElement.fromJson(e as Map<String, dynamic>))
          .toList(),
      lessonModules: (json['lessonModules'] as List<dynamic>?)
          ?.map((e) => LessonLevelElement.fromJson(e as Map<String, dynamic>))
          .toList(),
      lessonTypes: (json['lessonTypes'] as List<dynamic>?)
          ?.map((e) => LessonLevelElement.fromJson(e as Map<String, dynamic>))
          .toList(),
      lessonLevels: (json['lessonLevels'] as List<dynamic>?)
          ?.map((e) => LessonLevelElement.fromJson(e as Map<String, dynamic>))
          .toList(),
      lessonTags: (json['lessonTags'] as List<dynamic>?)
          ?.map((e) => LessonLevelElement.fromJson(e as Map<String, dynamic>))
          .toList(),
      image: json['image'] == null
          ? null
          : BmiLessonImage.fromJson(json['image'] as Map<String, dynamic>),
      imageVendor: json['imageVendor'] == null
          ? null
          : BmiLessonImage.fromJson(
              json['imageVendor'] as Map<String, dynamic>),
      numberOfQuiz: (json['numberOfQuiz'] as num?)?.toInt(),
      percentComplete: (json['percentComplete'] as num?)?.toInt(),
      linkShare: json['linkShare'] as String?,
    );

Map<String, dynamic> _$BmiWeightLessonToJson(BmiWeightLesson instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
      'status': instance.status,
      'type': instance.type,
      'order': instance.order,
      'orderHighest': instance.orderHighest,
      'isEnabledRating': instance.isEnabledRating,
      'minCompletePercent': instance.minCompletePercent,
      'coverId': instance.coverId,
      'lessonModuleId': instance.lessonModuleId,
      'lessonLevelId': instance.lessonLevelId,
      'countLessonSection': instance.countLessonSection,
      'countLessonAccount': instance.countLessonAccount,
      'countLessonQuiz': instance.countLessonQuiz,
      'countLessonQuizAccount': instance.countLessonQuizAccount,
      'learningStatus': instance.learningStatus,
      'lessonModule': instance.lessonModule,
      'lessonLevel': instance.lessonLevel,
      'quizLessons': instance.quizLessons,
      'lessonTagMappings': instance.lessonTagMappings,
      'lessonSections': instance.lessonSections,
      'lessonQuizAccounts': instance.lessonQuizAccounts,
      'lessonReviews': instance.lessonReviews,
      'lessonStates': instance.lessonStates,
      'lessonModules': instance.lessonModules,
      'lessonTypes': instance.lessonTypes,
      'lessonLevels': instance.lessonLevels,
      'lessonTags': instance.lessonTags,
      'image': instance.image,
      'imageVendor': instance.imageVendor,
      'numberOfQuiz': instance.numberOfQuiz,
      'percentComplete': instance.percentComplete,
      'linkShare': instance.linkShare,
    };

BmiLessonImage _$BmiLessonImageFromJson(Map<String, dynamic> json) =>
    BmiLessonImage(
      id: json['id'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$BmiLessonImageToJson(BmiLessonImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
    };

PurpleLesson _$PurpleLessonFromJson(Map<String, dynamic> json) => PurpleLesson(
      id: json['id'] as String?,
      code: json['code'] as String?,
      name: json['name'] as String?,
      order: (json['order'] as num?)?.toInt(),
      updateDate: json['updateDate'] as String?,
      updaterName: json['updaterName'] as String?,
      updaterUsername: json['updaterUsername'] as String?,
      updaterCode: json['updaterCode'] as String?,
      updaterImage: json['updaterImage'] == null
          ? null
          : BmiLessonImage.fromJson(
              json['updaterImage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PurpleLessonToJson(PurpleLesson instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'order': instance.order,
      'updateDate': instance.updateDate,
      'updaterName': instance.updaterName,
      'updaterUsername': instance.updaterUsername,
      'updaterCode': instance.updaterCode,
      'updaterImage': instance.updaterImage,
    };

LessonLevelElement _$LessonLevelElementFromJson(Map<String, dynamic> json) =>
    LessonLevelElement(
      disabled: json['disabled'] as bool?,
      group: json['group'] == null
          ? null
          : Group.fromJson(json['group'] as Map<String, dynamic>),
      selected: json['selected'] as bool?,
      text: json['text'] as String?,
      value: json['value'] as String?,
    );

Map<String, dynamic> _$LessonLevelElementToJson(LessonLevelElement instance) =>
    <String, dynamic>{
      'disabled': instance.disabled,
      'group': instance.group,
      'selected': instance.selected,
      'text': instance.text,
      'value': instance.value,
    };

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
      disabled: json['disabled'] as bool?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
      'disabled': instance.disabled,
      'name': instance.name,
    };

LessonQuizAccount _$LessonQuizAccountFromJson(Map<String, dynamic> json) =>
    LessonQuizAccount(
      id: json['id'] as String?,
      accountId: json['accountId'] as String?,
      lessonId: json['lessonId'] as String?,
      packageAccountTransactionId:
          json['packageAccountTransactionId'] as String?,
    );

Map<String, dynamic> _$LessonQuizAccountToJson(LessonQuizAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'lessonId': instance.lessonId,
      'packageAccountTransactionId': instance.packageAccountTransactionId,
    };

LessonReview _$LessonReviewFromJson(Map<String, dynamic> json) => LessonReview(
      id: json['id'] as String?,
      lessonId: json['lessonId'] as String?,
      accountId: json['accountId'] as String?,
      rating: (json['rating'] as num?)?.toInt(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$LessonReviewToJson(LessonReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lessonId': instance.lessonId,
      'accountId': instance.accountId,
      'rating': instance.rating,
      'note': instance.note,
    };

LessonSection _$LessonSectionFromJson(Map<String, dynamic> json) =>
    LessonSection(
      id: json['id'] as String?,
      code: json['code'] as String?,
      lessonId: json['lessonId'] as String?,
      name: json['name'] as String?,
      type: (json['type'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
      firstContent: json['firstContent'] as String?,
      secondContent: json['secondContent'] as String?,
      imageId: json['imageId'] as String?,
      imageTitle: json['imageTitle'] as String?,
      videoAddressLink: json['videoAddressLink'] as String?,
      linkType: (json['linkType'] as num?)?.toInt(),
      videoDescription: json['videoDescription'] as String?,
      audioAddressLink: json['audioAddressLink'] as String?,
      audioDescription: json['audioDescription'] as String?,
      order: (json['order'] as num?)?.toInt(),
      linkShare: json['linkShare'] as String?,
      isComplete: json['isComplete'] as bool?,
      quizLessonSections: (json['quizLessonSections'] as List<dynamic>?)
          ?.map((e) => QuizLessonSection.fromJson(e as Map<String, dynamic>))
          .toList(),
      lessonSectionLinks: (json['lessonSectionLinks'] as List<dynamic>?)
          ?.map((e) => LessonSectionLink.fromJson(e as Map<String, dynamic>))
          .toList(),
      lessonAccounts: (json['lessonAccounts'] as List<dynamic>?)
          ?.map((e) => LessonAccount.fromJson(e as Map<String, dynamic>))
          .toList(),
      lessonSectionStates: (json['lessonSectionStates'] as List<dynamic>?)
          ?.map((e) => LessonLevelElement.fromJson(e as Map<String, dynamic>))
          .toList(),
      lessonSectionTypes: (json['lessonSectionTypes'] as List<dynamic>?)
          ?.map((e) => LessonLevelElement.fromJson(e as Map<String, dynamic>))
          .toList(),
      image: json['image'] == null
          ? null
          : BmiLessonImage.fromJson(json['image'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LessonSectionToJson(LessonSection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'lessonId': instance.lessonId,
      'name': instance.name,
      'type': instance.type,
      'status': instance.status,
      'firstContent': instance.firstContent,
      'secondContent': instance.secondContent,
      'imageId': instance.imageId,
      'imageTitle': instance.imageTitle,
      'videoAddressLink': instance.videoAddressLink,
      'linkType': instance.linkType,
      'videoDescription': instance.videoDescription,
      'audioAddressLink': instance.audioAddressLink,
      'audioDescription': instance.audioDescription,
      'order': instance.order,
      'linkShare': instance.linkShare,
      'isComplete': instance.isComplete,
      'quizLessonSections': instance.quizLessonSections,
      'lessonSectionLinks': instance.lessonSectionLinks,
      'lessonAccounts': instance.lessonAccounts,
      'lessonSectionStates': instance.lessonSectionStates,
      'lessonSectionTypes': instance.lessonSectionTypes,
      'image': instance.image,
    };

LessonAccount _$LessonAccountFromJson(Map<String, dynamic> json) =>
    LessonAccount(
      id: json['id'] as String?,
      code: json['code'] as String?,
      accountId: json['accountId'] as String?,
      lessonId: json['lessonId'] as String?,
      lessonType: (json['lessonType'] as num?)?.toInt(),
      lessonSectionId: json['lessonSectionId'] as String?,
      isComplete: json['isComplete'] as bool?,
      packageAccountTransactionId:
          json['packageAccountTransactionId'] as String?,
    );

Map<String, dynamic> _$LessonAccountToJson(LessonAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'accountId': instance.accountId,
      'lessonId': instance.lessonId,
      'lessonType': instance.lessonType,
      'lessonSectionId': instance.lessonSectionId,
      'isComplete': instance.isComplete,
      'packageAccountTransactionId': instance.packageAccountTransactionId,
    };

LessonSectionLink _$LessonSectionLinkFromJson(Map<String, dynamic> json) =>
    LessonSectionLink(
      id: json['id'] as String?,
      type: (json['type'] as num?)?.toInt(),
      url: json['url'] as String?,
    );

Map<String, dynamic> _$LessonSectionLinkToJson(LessonSectionLink instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'url': instance.url,
    };

QuizLessonSection _$QuizLessonSectionFromJson(Map<String, dynamic> json) =>
    QuizLessonSection(
      id: json['id'] as String?,
      quizId: json['quizId'] as String?,
      lessonSectionId: json['lessonSectionId'] as String?,
      quiz: json['quiz'] == null
          ? null
          : Quiz.fromJson(json['quiz'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QuizLessonSectionToJson(QuizLessonSection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'quizId': instance.quizId,
      'lessonSectionId': instance.lessonSectionId,
      'quiz': instance.quiz,
    };

Quiz _$QuizFromJson(Map<String, dynamic> json) => Quiz(
      id: json['id'] as String?,
      code: json['code'] as String?,
      name: json['name'] as String?,
      status: (json['status'] as num?)?.toInt(),
      type: (json['type'] as num?)?.toInt(),
      lessonLevel: json['lessonLevel'] as String?,
      lesson: json['lesson'] as String?,
      explain: json['explain'] as String?,
      updateDatetime: (json['updateDatetime'] as num?)?.toInt(),
      quizAnswers: (json['quizAnswers'] as List<dynamic>?)
          ?.map((e) => QuizAnswer.fromJson(e as Map<String, dynamic>))
          .toList(),
      userAnswers: (json['userAnswers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$QuizToJson(Quiz instance) => <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'status': instance.status,
      'type': instance.type,
      'lessonLevel': instance.lessonLevel,
      'lesson': instance.lesson,
      'explain': instance.explain,
      'updateDatetime': instance.updateDatetime,
      'quizAnswers': instance.quizAnswers,
      'userAnswers': instance.userAnswers,
    };

QuizAnswer _$QuizAnswerFromJson(Map<String, dynamic> json) => QuizAnswer(
      id: json['id'] as String?,
      name: json['name'] as String?,
      isCorrect: json['isCorrect'] as bool?,
      order: (json['order'] as num?)?.toInt(),
      quizId: json['quizId'] as String?,
    );

Map<String, dynamic> _$QuizAnswerToJson(QuizAnswer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isCorrect': instance.isCorrect,
      'order': instance.order,
      'quizId': instance.quizId,
    };

LessonTagMapping _$LessonTagMappingFromJson(Map<String, dynamic> json) =>
    LessonTagMapping(
      id: json['id'] as String?,
      lessonId: json['lessonId'] as String?,
      lessonTagId: json['lessonTagId'] as String?,
      tag: json['tag'] == null
          ? null
          : Tag.fromJson(json['tag'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LessonTagMappingToJson(LessonTagMapping instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lessonId': instance.lessonId,
      'lessonTagId': instance.lessonTagId,
      'tag': instance.tag,
    };

Tag _$TagFromJson(Map<String, dynamic> json) => Tag(
      id: json['id'] as String?,
      name: json['name'] as String?,
      type: (json['type'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TagToJson(Tag instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
    };

QuizLesson _$QuizLessonFromJson(Map<String, dynamic> json) => QuizLesson(
      id: json['id'] as String?,
      code: json['code'] as String?,
      quizId: json['quizId'] as String?,
      lessonId: json['lessonId'] as String?,
      quiz: json['quiz'] == null
          ? null
          : Quiz.fromJson(json['quiz'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QuizLessonToJson(QuizLesson instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'quizId': instance.quizId,
      'lessonId': instance.lessonId,
      'quiz': instance.quiz,
    };
