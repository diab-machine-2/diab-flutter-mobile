import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/model/response/user_info_referral_code_response.dart';
import 'package:medical/src/model/response/user_info_response.dart';

import 'user_coach.dart';

class CalendarTarget {
  String? creatorId;
  String? id;
  String? code;
  String? name;
  int? type;
  int? appointmentDate;
  int? duration;
  String? performerId;
  String? updaterName;
  int? repeatType;
  String? goal;
  String? meetingLink;
  String? meetingPassword;
  String? calendarSchedulerId;
  bool? complete;
  String? calendarId;
  String? roomId;
  CalendarScheduler? calendarScheduler;
  CalendarTraining? calendarTraining;
  UserCoach? performer;
  List<UserCoach>? coaches;

  CalendarTarget(
      {this.creatorId,
      this.id,
      this.code,
      this.name,
      this.type,
      this.appointmentDate,
      this.duration,
      this.performerId,
      this.updaterName,
      this.repeatType,
      this.goal,
      this.meetingLink,
      this.meetingPassword,
      this.calendarSchedulerId,
      this.complete,
      this.calendarId,
      this.roomId,
      this.calendarScheduler,
      this.calendarTraining,
      this.performer,
      this.coaches,
      });

  CalendarTarget.fromJson(Map<String, dynamic> json) {
    creatorId = json['creatorId'];
    id = json['id'];
    code = json['code'];
    name = json['name'];
    type = json['type'];
    appointmentDate = json['appointmentDate'];
    duration = json['duration'];
    performerId = json['performerId'];
    updaterName = json['updaterName'];
    repeatType = json['repeatType'];
    goal = json['goal'];
    meetingLink = json['meetingLink'];
    meetingPassword = json['meetingPassword'];
    calendarSchedulerId = json['calendarSchedulerId'];
    complete = json['complete'];
    calendarId = json['calendarId'];
    roomId = json['roomId'];
    calendarScheduler = json['calendarScheduler'] != null
        ? new CalendarScheduler.fromJson(json['calendarScheduler'])
        : null;
    calendarTraining = json['calendarTraining'] != null
        ? new CalendarTraining.fromJson(json['calendarTraining'])
        : null;
    performer = json['performer'] != null
      ? new UserCoach.fromJson(json['performer'])
      : null;
    if (json['coaches'] != null) {
      final v = json['coaches'];
      final arr0 = <UserCoach>[];
      v.forEach((v) {
        arr0.add(UserCoach.fromJson(v));
      });
      coaches = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['creatorId'] = this.creatorId;
    data['id'] = this.id;
    data['code'] = this.code;
    data['name'] = this.name;
    data['type'] = this.type;
    data['appointmentDate'] = this.appointmentDate;
    data['duration'] = this.duration;
    data['performerId'] = this.performerId;
    data['updaterName'] = this.updaterName;
    data['repeatType'] = this.repeatType;
    data['goal'] = this.goal;
    data['meetingLink'] = this.meetingLink;
    data['meetingPassword'] = this.meetingPassword;
    data['calendarSchedulerId'] = this.calendarSchedulerId;
    data['complete'] = this.complete;
    data['calendarId'] = this.calendarId;
    data['roomId'] = this.roomId;
    if (this.performer != null) {
      data['performer'] = this.performer!.toJson();
    }
    if (this.calendarScheduler != null) {
      data['calendarScheduler'] = this.calendarScheduler!.toJson();
    }
    if (this.calendarTraining != null) {
      data['calendarTraining'] = this.calendarTraining!.toJson();
    }
    if (this.coaches != null) {
      final v = this.coaches;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v.toJson());
      });
      data['coaches'] = arr0;
    }
    return data;
  }
}

class CalendarScheduler {
  String? id;
  int? repeatTime;
  int? repeatType;
  int? endDate;
  bool? isRepeatInfinite;
  List<CalendarSchedulerWeeks>? calendarSchedulerWeeks;
  List<CalendarSchedulerRepeatTypes>? calendarSchedulerRepeatTypes;
  int? modelStatus;

  CalendarScheduler(
      {this.id,
      this.repeatTime,
      this.repeatType,
      this.endDate,
      this.isRepeatInfinite,
      this.calendarSchedulerWeeks,
      this.calendarSchedulerRepeatTypes,
      this.modelStatus});

  CalendarScheduler.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    repeatTime = json['repeatTime'];
    repeatType = json['repeatType'];
    endDate = json['endDate'];
    isRepeatInfinite = json['isRepeatInfinite'];
    if (json['calendarSchedulerWeeks'] != null) {
      calendarSchedulerWeeks = <CalendarSchedulerWeeks>[];
      json['calendarSchedulerWeeks'].forEach((v) {
        calendarSchedulerWeeks!.add(new CalendarSchedulerWeeks.fromJson(v));
      });
    }
    if (json['calendarSchedulerRepeatTypes'] != null) {
      calendarSchedulerRepeatTypes = <CalendarSchedulerRepeatTypes>[];
      json['calendarSchedulerRepeatTypes'].forEach((v) {
        calendarSchedulerRepeatTypes!
            .add(new CalendarSchedulerRepeatTypes.fromJson(v));
      });
    }
    modelStatus = json['modelStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['repeatTime'] = this.repeatTime;
    data['repeatType'] = this.repeatType;
    data['endDate'] = this.endDate;
    data['isRepeatInfinite'] = this.isRepeatInfinite;
    if (this.calendarSchedulerWeeks != null) {
      data['calendarSchedulerWeeks'] =
          this.calendarSchedulerWeeks!.map((v) => v.toJson()).toList();
    }
    if (this.calendarSchedulerRepeatTypes != null) {
      data['calendarSchedulerRepeatTypes'] =
          this.calendarSchedulerRepeatTypes!.map((v) => v.toJson()).toList();
    }
    data['modelStatus'] = this.modelStatus;
    return data;
  }
}

class CalendarSchedulerWeeks {
  int? dayInWeek;
  String? calendarSchedulerId;
  int? modelStatus;

  CalendarSchedulerWeeks(
      {this.dayInWeek, this.calendarSchedulerId, this.modelStatus});

  CalendarSchedulerWeeks.fromJson(Map<String, dynamic> json) {
    dayInWeek = json['dayInWeek'];
    calendarSchedulerId = json['calendarSchedulerId'];
    modelStatus = json['modelStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dayInWeek'] = this.dayInWeek;
    data['calendarSchedulerId'] = this.calendarSchedulerId;
    data['modelStatus'] = this.modelStatus;
    return data;
  }
}

class CalendarSchedulerRepeatTypes {
  bool? disabled;
  Group? group;
  bool? selected;
  String? text;
  String? value;

  CalendarSchedulerRepeatTypes(
      {this.disabled, this.group, this.selected, this.text, this.value});

  CalendarSchedulerRepeatTypes.fromJson(Map<String, dynamic> json) {
    disabled = json['disabled'];
    group = json['group'] != null ? new Group.fromJson(json['group']) : null;
    selected = json['selected'];
    text = json['text'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['disabled'] = this.disabled;
    if (this.group != null) {
      data['group'] = this.group!.toJson();
    }
    data['selected'] = this.selected;
    data['text'] = this.text;
    data['value'] = this.value;
    return data;
  }
}

class Group {
  bool? disabled;
  String? name;

  Group({this.disabled, this.name});

  Group.fromJson(Map<String, dynamic> json) {
    disabled = json['disabled'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['disabled'] = this.disabled;
    data['name'] = this.name;
    return data;
  }
}

class CalendarTraining {
  String? id;
  String? calendarId;
  String? trainingGroupId;
  String? coachId;
  int? type;
  String? comment;
  int? coachDate;
  String? coachName;

  CalendarTraining(
      {this.id,
      this.calendarId,
      this.trainingGroupId,
      this.coachId,
      this.type,
      this.comment,
      this.coachDate,
      this.coachName});

  CalendarTraining.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    calendarId = json['calendarId'];
    trainingGroupId = json['trainingGroupId'];
    coachId = json['coachId'];
    type = json['type'];
    comment = json['comment'];
    coachDate = json['coachDate'];
    coachName = json['coachName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['calendarId'] = this.calendarId;
    data['trainingGroupId'] = this.trainingGroupId;
    data['coachId'] = this.coachId;
    data['type'] = this.type;
    data['comment'] = this.comment;
    data['coachDate'] = this.coachDate;
    data['coachName'] = this.coachName;
    return data;
  }
}