class ExerciseMovementTarget {
  String? id;
  String? code;
  String? coverId;
  String? agendaId;
  String? name;
  String? description;
  bool? isFree;
  bool? isBlank;
  int? practiceTime;
  String? videoUrl;
  int? day;
  Image? image;
  List<Sections>? sections;
  ReviewSummary? reviewSummary;
  List<ExerciseMovementAccounts>? exerciseMovementAccounts;
  int? exerciseMovementStates;
  bool? isToday;

  ExerciseMovementTarget(
      {this.id,
      this.code,
      this.coverId,
      this.agendaId,
      this.name,
      this.description,
      this.isFree,
      this.isBlank,
      this.practiceTime,
      this.videoUrl,
      this.day,
      this.image,
      this.sections,
      this.reviewSummary,
      this.exerciseMovementAccounts,
      this.exerciseMovementStates,
      this.isToday});

  ExerciseMovementTarget.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    coverId = json['coverId'];
    agendaId = json['agendaId'];
    name = json['name'];
    description = json['description'];
    isFree = json['isFree'];
    isBlank = json['isBlank'];
    practiceTime = json['practiceTime'];
    videoUrl = json['videoUrl'];
    day = json['day'];
    image = json['image'] != null ? new Image.fromJson(json['image']) : null;
    if (json['sections'] != null) {
      sections = <Sections>[];
      json['sections'].forEach((v) {
        sections!.add(new Sections.fromJson(v));
      });
    }
    reviewSummary = json['reviewSummary'] != null
        ? new ReviewSummary.fromJson(json['reviewSummary'])
        : null;
    if (json['exerciseMovementAccounts'] != null) {
      exerciseMovementAccounts = <ExerciseMovementAccounts>[];
      json['exerciseMovementAccounts'].forEach((v) {
        exerciseMovementAccounts!.add(new ExerciseMovementAccounts.fromJson(v));
      });
    }
    exerciseMovementStates = json['exerciseMovementStates'];
    isToday = json['isToday'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['coverId'] = this.coverId;
    data['agendaId'] = this.agendaId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['isFree'] = this.isFree;
    data['isBlank'] = this.isBlank;
    data['practiceTime'] = this.practiceTime;
    data['videoUrl'] = this.videoUrl;
    data['day'] = this.day;
    if (this.image != null) {
      data['image'] = this.image!.toJson();
    }
    if (this.sections != null) {
      data['sections'] = this.sections!.map((v) => v.toJson()).toList();
    }
    if (this.reviewSummary != null) {
      data['reviewSummary'] = this.reviewSummary!.toJson();
    }
    if (this.exerciseMovementAccounts != null) {
      data['exerciseMovementAccounts'] =
          this.exerciseMovementAccounts!.map((v) => v.toJson()).toList();
    }
    data['exerciseMovementStates'] = this.exerciseMovementStates;
    data['isToday'] = this.isToday;
    return data;
  }
}

class Image {
  String? id;
  String? url;

  Image({this.id, this.url});

  Image.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['url'] = this.url;
    return data;
  }
}

class Sections {
  String? id;
  String? code;
  String? name;
  String? exerciseCategoryId;
  int? replayTime;
  String? videoUrl;
  int? duration;
  int? order;

  Sections(
      {this.id,
      this.code,
      this.name,
      this.exerciseCategoryId,
      this.replayTime,
      this.videoUrl,
      this.duration,
      this.order});

  Sections.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    exerciseCategoryId = json['exerciseCategoryId'];
    replayTime = json['replayTime'];
    videoUrl = json['videoUrl'];
    duration = json['duration'];
    order = json['order'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name'] = this.name;
    data['exerciseCategoryId'] = this.exerciseCategoryId;
    data['replayTime'] = this.replayTime;
    data['videoUrl'] = this.videoUrl;
    data['duration'] = this.duration;
    data['order'] = this.order;
    return data;
  }
}

class ReviewSummary {
  double? tooLightExercisePercent;
  double? tooLightExerciseCount;
  double? lightExercisePercent;
  double? lightExerciseCount;
  double? moderateExercisePercent;
  double? moderateExerciseCount;
  double? heavyExercisePercent;
  double? heavyExerciseCount;
  double? tooHeavyExercisePercent;
  double? tooHeavyExerciseCount;

  ReviewSummary(
      {this.tooLightExercisePercent,
      this.tooLightExerciseCount,
      this.lightExercisePercent,
      this.lightExerciseCount,
      this.moderateExercisePercent,
      this.moderateExerciseCount,
      this.heavyExercisePercent,
      this.heavyExerciseCount,
      this.tooHeavyExercisePercent,
      this.tooHeavyExerciseCount});

  ReviewSummary.fromJson(Map<String, dynamic> json) {
    tooLightExercisePercent = json['tooLightExercisePercent'];
    tooLightExerciseCount = json['tooLightExerciseCount'];
    lightExercisePercent = json['lightExercisePercent'];
    lightExerciseCount = json['lightExerciseCount'];
    moderateExercisePercent = json['moderateExercisePercent'];
    moderateExerciseCount = json['moderateExerciseCount'];
    heavyExercisePercent = json['heavyExercisePercent'];
    heavyExerciseCount = json['heavyExerciseCount'];
    tooHeavyExercisePercent = json['tooHeavyExercisePercent'];
    tooHeavyExerciseCount = json['tooHeavyExerciseCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tooLightExercisePercent'] = this.tooLightExercisePercent;
    data['tooLightExerciseCount'] = this.tooLightExerciseCount;
    data['lightExercisePercent'] = this.lightExercisePercent;
    data['lightExerciseCount'] = this.lightExerciseCount;
    data['moderateExercisePercent'] = this.moderateExercisePercent;
    data['moderateExerciseCount'] = this.moderateExerciseCount;
    data['heavyExercisePercent'] = this.heavyExercisePercent;
    data['heavyExerciseCount'] = this.heavyExerciseCount;
    data['tooHeavyExercisePercent'] = this.tooHeavyExercisePercent;
    data['tooHeavyExerciseCount'] = this.tooHeavyExerciseCount;
    return data;
  }
}

class ExerciseMovementAccounts {
  String? id;
  String? code;
  String? accountId;
  String? exerciseMovementId;

  ExerciseMovementAccounts(
      {this.id, this.code, this.accountId, this.exerciseMovementId});

  ExerciseMovementAccounts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    accountId = json['accountId'];
    exerciseMovementId = json['exerciseMovementId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['accountId'] = this.accountId;
    data['exerciseMovementId'] = this.exerciseMovementId;
    return data;
  }
}