import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'bmi_get_weight_lessons_response.g.dart';

@JsonSerializable()
class BmiGetWeightLessonsResponse {
    @JsonKey(name: "id")
    final String? id;
    @JsonKey(name: "code")
    final String? code;
    @JsonKey(name: "name")
    final String? name;
    @JsonKey(name: "description")
    final String? description;
    @JsonKey(name: "status")
    final int? status;
    @JsonKey(name: "type")
    final int? type;
    @JsonKey(name: "order")
    final int? order;
    @JsonKey(name: "orderHighest")
    final int? orderHighest;
    @JsonKey(name: "isEnabledRating")
    final bool? isEnabledRating;
    @JsonKey(name: "minCompletePercent")
    final int? minCompletePercent;
    @JsonKey(name: "coverId")
    final String? coverId;
    @JsonKey(name: "lessonModuleId")
    final String? lessonModuleId;
    @JsonKey(name: "lessonLevelId")
    final String? lessonLevelId;
    @JsonKey(name: "countLessonSection")
    final int? countLessonSection;
    @JsonKey(name: "countLessonAccount")
    final int? countLessonAccount;
    @JsonKey(name: "countLessonQuiz")
    final int? countLessonQuiz;
    @JsonKey(name: "countLessonQuizAccount")
    final int? countLessonQuizAccount;
    @JsonKey(name: "learningStatus")
    final int? learningStatus;
    @JsonKey(name: "lessonModule")
    final PurpleLesson? lessonModule;
    @JsonKey(name: "lessonLevel")
    final PurpleLesson? lessonLevel;
    @JsonKey(name: "quizLessons")
    final List<QuizLesson>? quizLessons;
    @JsonKey(name: "lessonTagMappings")
    final List<LessonTagMapping>? lessonTagMappings;
    @JsonKey(name: "lessonSections")
    final List<LessonSection>? lessonSections;
    @JsonKey(name: "lessonQuizAccounts")
    final List<LessonQuizAccount>? lessonQuizAccounts;
    @JsonKey(name: "lessonReviews")
    final List<LessonReview>? lessonReviews;
    @JsonKey(name: "lessonStates")
    final List<LessonLevelElement>? lessonStates;
    @JsonKey(name: "lessonModules")
    final List<LessonLevelElement>? lessonModules;
    @JsonKey(name: "lessonTypes")
    final List<LessonLevelElement>? lessonTypes;
    @JsonKey(name: "lessonLevels")
    final List<LessonLevelElement>? lessonLevels;
    @JsonKey(name: "lessonTags")
    final List<LessonLevelElement>? lessonTags;
    @JsonKey(name: "image")
    final Image? image;
    @JsonKey(name: "imageVendor")
    final Image? imageVendor;
    @JsonKey(name: "numberOfQuiz")
    final int? numberOfQuiz;
    @JsonKey(name: "percentComplete")
    final int? percentComplete;
    @JsonKey(name: "linkShare")
    final String? linkShare;

    BmiGetWeightLessonsResponse({
        this.id,
        this.code,
        this.name,
        this.description,
        this.status,
        this.type,
        this.order,
        this.orderHighest,
        this.isEnabledRating,
        this.minCompletePercent,
        this.coverId,
        this.lessonModuleId,
        this.lessonLevelId,
        this.countLessonSection,
        this.countLessonAccount,
        this.countLessonQuiz,
        this.countLessonQuizAccount,
        this.learningStatus,
        this.lessonModule,
        this.lessonLevel,
        this.quizLessons,
        this.lessonTagMappings,
        this.lessonSections,
        this.lessonQuizAccounts,
        this.lessonReviews,
        this.lessonStates,
        this.lessonModules,
        this.lessonTypes,
        this.lessonLevels,
        this.lessonTags,
        this.image,
        this.imageVendor,
        this.numberOfQuiz,
        this.percentComplete,
        this.linkShare,
    });

    factory BmiGetWeightLessonsResponse.fromJson(Map<String, dynamic> json) => _$BmiGetWeightLessonsResponseFromJson(json);

    Map<String, dynamic> toJson() => _$BmiGetWeightLessonsResponseToJson(this);
}

@JsonSerializable()
class Image {
    @JsonKey(name: "id")
    final String? id;
    @JsonKey(name: "url")
    final String? url;

    Image({
        this.id,
        this.url,
    });

    factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);

    Map<String, dynamic> toJson() => _$ImageToJson(this);
}

@JsonSerializable()
class PurpleLesson {
    @JsonKey(name: "id")
    final String? id;
    @JsonKey(name: "code")
    final String? code;
    @JsonKey(name: "name")
    final String? name;
    @JsonKey(name: "order")
    final int? order;
    @JsonKey(name: "updateDate")
    final String? updateDate;
    @JsonKey(name: "updaterName")
    final String? updaterName;
    @JsonKey(name: "updaterUsername")
    final String? updaterUsername;
    @JsonKey(name: "updaterCode")
    final String? updaterCode;
    @JsonKey(name: "updaterImage")
    final Image? updaterImage;

    PurpleLesson({
        this.id,
        this.code,
        this.name,
        this.order,
        this.updateDate,
        this.updaterName,
        this.updaterUsername,
        this.updaterCode,
        this.updaterImage,
    });

    factory PurpleLesson.fromJson(Map<String, dynamic> json) => _$PurpleLessonFromJson(json);

    Map<String, dynamic> toJson() => _$PurpleLessonToJson(this);
}

@JsonSerializable()
class LessonLevelElement {
    @JsonKey(name: "disabled")
    final bool? disabled;
    @JsonKey(name: "group")
    final Group? group;
    @JsonKey(name: "selected")
    final bool? selected;
    @JsonKey(name: "text")
    final String? text;
    @JsonKey(name: "value")
    final String? value;

    LessonLevelElement({
        this.disabled,
        this.group,
        this.selected,
        this.text,
        this.value,
    });

    factory LessonLevelElement.fromJson(Map<String, dynamic> json) => _$LessonLevelElementFromJson(json);

    Map<String, dynamic> toJson() => _$LessonLevelElementToJson(this);
}

@JsonSerializable()
class Group {
    @JsonKey(name: "disabled")
    final bool? disabled;
    @JsonKey(name: "name")
    final String? name;

    Group({
        this.disabled,
        this.name,
    });

    factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

    Map<String, dynamic> toJson() => _$GroupToJson(this);
}

@JsonSerializable()
class LessonQuizAccount {
    @JsonKey(name: "id")
    final String? id;
    @JsonKey(name: "accountId")
    final String? accountId;
    @JsonKey(name: "lessonId")
    final String? lessonId;
    @JsonKey(name: "packageAccountTransactionId")
    final String? packageAccountTransactionId;

    LessonQuizAccount({
        this.id,
        this.accountId,
        this.lessonId,
        this.packageAccountTransactionId,
    });

    factory LessonQuizAccount.fromJson(Map<String, dynamic> json) => _$LessonQuizAccountFromJson(json);

    Map<String, dynamic> toJson() => _$LessonQuizAccountToJson(this);
}

@JsonSerializable()
class LessonReview {
    @JsonKey(name: "id")
    final String? id;
    @JsonKey(name: "lessonId")
    final String? lessonId;
    @JsonKey(name: "accountId")
    final String? accountId;
    @JsonKey(name: "rating")
    final int? rating;
    @JsonKey(name: "note")
    final String? note;

    LessonReview({
        this.id,
        this.lessonId,
        this.accountId,
        this.rating,
        this.note,
    });

    factory LessonReview.fromJson(Map<String, dynamic> json) => _$LessonReviewFromJson(json);

    Map<String, dynamic> toJson() => _$LessonReviewToJson(this);
}

@JsonSerializable()
class LessonSection {
    @JsonKey(name: "id")
    final String? id;
    @JsonKey(name: "code")
    final String? code;
    @JsonKey(name: "lessonId")
    final String? lessonId;
    @JsonKey(name: "name")
    final String? name;
    @JsonKey(name: "type")
    final int? type;
    @JsonKey(name: "status")
    final int? status;
    @JsonKey(name: "firstContent")
    final String? firstContent;
    @JsonKey(name: "secondContent")
    final String? secondContent;
    @JsonKey(name: "imageId")
    final String? imageId;
    @JsonKey(name: "imageTitle")
    final String? imageTitle;
    @JsonKey(name: "videoAddressLink")
    final String? videoAddressLink;
    @JsonKey(name: "linkType")
    final int? linkType;
    @JsonKey(name: "videoDescription")
    final String? videoDescription;
    @JsonKey(name: "audioAddressLink")
    final String? audioAddressLink;
    @JsonKey(name: "audioDescription")
    final String? audioDescription;
    @JsonKey(name: "order")
    final int? order;
    @JsonKey(name: "linkShare")
    final String? linkShare;
    @JsonKey(name: "isComplete")
    final bool? isComplete;
    @JsonKey(name: "quizLessonSections")
    final List<QuizLessonSection>? quizLessonSections;
    @JsonKey(name: "lessonSectionLinks")
    final List<LessonSectionLink>? lessonSectionLinks;
    @JsonKey(name: "lessonAccounts")
    final List<LessonAccount>? lessonAccounts;
    @JsonKey(name: "lessonSectionStates")
    final List<LessonLevelElement>? lessonSectionStates;
    @JsonKey(name: "lessonSectionTypes")
    final List<LessonLevelElement>? lessonSectionTypes;
    @JsonKey(name: "image")
    final Image? image;

    LessonSection({
        this.id,
        this.code,
        this.lessonId,
        this.name,
        this.type,
        this.status,
        this.firstContent,
        this.secondContent,
        this.imageId,
        this.imageTitle,
        this.videoAddressLink,
        this.linkType,
        this.videoDescription,
        this.audioAddressLink,
        this.audioDescription,
        this.order,
        this.linkShare,
        this.isComplete,
        this.quizLessonSections,
        this.lessonSectionLinks,
        this.lessonAccounts,
        this.lessonSectionStates,
        this.lessonSectionTypes,
        this.image,
    });

    factory LessonSection.fromJson(Map<String, dynamic> json) => _$LessonSectionFromJson(json);

    Map<String, dynamic> toJson() => _$LessonSectionToJson(this);
}

@JsonSerializable()
class LessonAccount {
    @JsonKey(name: "id")
    final String? id;
    @JsonKey(name: "code")
    final String? code;
    @JsonKey(name: "accountId")
    final String? accountId;
    @JsonKey(name: "lessonId")
    final String? lessonId;
    @JsonKey(name: "lessonType")
    final int? lessonType;
    @JsonKey(name: "lessonSectionId")
    final String? lessonSectionId;
    @JsonKey(name: "isComplete")
    final bool? isComplete;
    @JsonKey(name: "packageAccountTransactionId")
    final String? packageAccountTransactionId;

    LessonAccount({
        this.id,
        this.code,
        this.accountId,
        this.lessonId,
        this.lessonType,
        this.lessonSectionId,
        this.isComplete,
        this.packageAccountTransactionId,
    });

    factory LessonAccount.fromJson(Map<String, dynamic> json) => _$LessonAccountFromJson(json);

    Map<String, dynamic> toJson() => _$LessonAccountToJson(this);
}

@JsonSerializable()
class LessonSectionLink {
    @JsonKey(name: "id")
    final String? id;
    @JsonKey(name: "type")
    final int? type;
    @JsonKey(name: "url")
    final String? url;

    LessonSectionLink({
        this.id,
        this.type,
        this.url,
    });

    factory LessonSectionLink.fromJson(Map<String, dynamic> json) => _$LessonSectionLinkFromJson(json);

    Map<String, dynamic> toJson() => _$LessonSectionLinkToJson(this);
}

@JsonSerializable()
class QuizLessonSection {
    @JsonKey(name: "id")
    final String? id;
    @JsonKey(name: "quizId")
    final String? quizId;
    @JsonKey(name: "lessonSectionId")
    final String? lessonSectionId;
    @JsonKey(name: "quiz")
    final Quiz? quiz;

    QuizLessonSection({
        this.id,
        this.quizId,
        this.lessonSectionId,
        this.quiz,
    });

    factory QuizLessonSection.fromJson(Map<String, dynamic> json) => _$QuizLessonSectionFromJson(json);

    Map<String, dynamic> toJson() => _$QuizLessonSectionToJson(this);
}

@JsonSerializable()
class Quiz {
    @JsonKey(name: "id")
    final String? id;
    @JsonKey(name: "code")
    final String? code;
    @JsonKey(name: "name")
    final String? name;
    @JsonKey(name: "status")
    final int? status;
    @JsonKey(name: "type")
    final int? type;
    @JsonKey(name: "lessonLevel")
    final String? lessonLevel;
    @JsonKey(name: "lesson")
    final String? lesson;
    @JsonKey(name: "explain")
    final String? explain;
    @JsonKey(name: "updateDatetime")
    final int? updateDatetime;
    @JsonKey(name: "quizAnswers")
    final List<QuizAnswer>? quizAnswers;
    @JsonKey(name: "userAnswers")
    final List<String>? userAnswers;

    Quiz({
        this.id,
        this.code,
        this.name,
        this.status,
        this.type,
        this.lessonLevel,
        this.lesson,
        this.explain,
        this.updateDatetime,
        this.quizAnswers,
        this.userAnswers,
    });

    factory Quiz.fromJson(Map<String, dynamic> json) => _$QuizFromJson(json);

    Map<String, dynamic> toJson() => _$QuizToJson(this);
}

@JsonSerializable()
class QuizAnswer {
    @JsonKey(name: "id")
    final String? id;
    @JsonKey(name: "name")
    final String? name;
    @JsonKey(name: "isCorrect")
    final bool? isCorrect;
    @JsonKey(name: "order")
    final int? order;
    @JsonKey(name: "quizId")
    final String? quizId;

    QuizAnswer({
        this.id,
        this.name,
        this.isCorrect,
        this.order,
        this.quizId,
    });

    factory QuizAnswer.fromJson(Map<String, dynamic> json) => _$QuizAnswerFromJson(json);

    Map<String, dynamic> toJson() => _$QuizAnswerToJson(this);
}

@JsonSerializable()
class LessonTagMapping {
    @JsonKey(name: "id")
    final String? id;
    @JsonKey(name: "lessonId")
    final String? lessonId;
    @JsonKey(name: "lessonTagId")
    final String? lessonTagId;
    @JsonKey(name: "tag")
    final Tag? tag;

    LessonTagMapping({
        this.id,
        this.lessonId,
        this.lessonTagId,
        this.tag,
    });

    factory LessonTagMapping.fromJson(Map<String, dynamic> json) => _$LessonTagMappingFromJson(json);

    Map<String, dynamic> toJson() => _$LessonTagMappingToJson(this);
}

@JsonSerializable()
class Tag {
    @JsonKey(name: "id")
    final String? id;
    @JsonKey(name: "name")
    final String? name;
    @JsonKey(name: "type")
    final int? type;

    Tag({
        this.id,
        this.name,
        this.type,
    });

    factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

    Map<String, dynamic> toJson() => _$TagToJson(this);
}

@JsonSerializable()
class QuizLesson {
    @JsonKey(name: "id")
    final String? id;
    @JsonKey(name: "code")
    final String? code;
    @JsonKey(name: "quizId")
    final String? quizId;
    @JsonKey(name: "lessonId")
    final String? lessonId;
    @JsonKey(name: "quiz")
    final Quiz? quiz;

    QuizLesson({
        this.id,
        this.code,
        this.quizId,
        this.lessonId,
        this.quiz,
    });

    factory QuizLesson.fromJson(Map<String, dynamic> json) => _$QuizLessonFromJson(json);

    Map<String, dynamic> toJson() => _$QuizLessonToJson(this);
}