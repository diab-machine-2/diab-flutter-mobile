import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/model/response/user_info_referral_code_response.dart';

import '../../../../../../res/R.dart';
import '../../../../helper/helper.dart';

class ExpertCommentModel {
  ExpertCommentModel({
    required this.id,
    required this.calendarTrainingId,
    required this.accountId,
    required this.comment,
    required this.creatorId,
    required this.creator,
    required this.nextActivity,
    required this.type,
    required this.updateDateTime,
    required this.calendarTraining,
    required this.creatorUrl,
    required this.reviewerUrl,
  });

  final String? id;
  final String? calendarTrainingId;
  final String? accountId;
  final String? comment;
  final String? creatorId;
  final String? creator;
  final String? nextActivity;
  final int? type;
  final int? updateDateTime;
  final CalendarTraining? calendarTraining;
  final Avatar? creatorUrl;
  final Avatar? reviewerUrl;

  String get name {
    if (creator != null) {
      return creator!;
    } else {
      return '';
    }
  }

  String get dateTimeFormatted {
    if (updateDateTime != null) {
      return convertToUTC(updateDateTime!, 'dd/MM/yyyy');
    } else {
      return '';
    }
  }

  String get typeString {
    if (type != null) {
      switch (type!) {
        case 0:
          return 'Phân loại đầu ra';
        case 1:
          return R.string.input_evaluate.tr();
        case 2:
          return 'Tư vấn cá nhân';
        case 3:
          return 'Tư vấn nhóm';
        case 4:
          return 'Livestream';
        case 5:
          return 'Khác';
        case 6:
          return 'Bác sĩ nhận xét';
        default:
          return '';
      }
    } else {
      return '';
    }
  }

  String? get url {
    if (creatorUrl != null) {
      return creatorUrl!.url;
    } else {
      if(reviewerUrl != null){
        return reviewerUrl!.url;
      } else {
        return null;
      }
    }
  }

  String get nextAction {
    return nextActivity ?? '';
  }

  Color getColor() {
    if (type != null) {
      switch (type!) {
        case 0:
          return R.color.greenGradientBottom;
        case 1:
          return R.color.greenGradientBottom;
        case 2:
          return R.color.green;
        case 3:
          return R.color.orange_1;
        case 6:
          return R.color.yellow;
        default:
          return R.color.mainColor;
      }
    } else {
      return R.color.mainColor;
    }
  }

  @override
  factory ExpertCommentModel.fromJson(Map<String, dynamic> json) {
    return ExpertCommentModel(
      nextActivity: json['nextActivity'],
      id: json['id'],
      accountId: json['accountId'],
      calendarTrainingId: json['calendarTrainingId'],
      comment: json['comment'],
      creatorId: json['creatorId'],
      creator: json['creator'],
      type: json['type'],
      updateDateTime: json['updateDateTime'],
      creatorUrl: json['creatorUrl'] == null ? null : Avatar.fromJson(json['creatorUrl']),
      reviewerUrl: json['reviewerUrl'] == null ? null : Avatar.fromJson(json['reviewerUrl']),
      calendarTraining: json['calendarTraining'] == null ? null : CalendarTraining.fromJson(json['calendarTraining']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["id"] = id;
    data["accountId"] = accountId;
    data["calendarTrainingId"] = calendarTrainingId;
    data["comment"] = comment;
    data["creatorId"] = creatorId;
    data["creator"] = creator;
    data["nextActivity"] = nextActivity;
    data['type'] = type;
    data["updateDateTime"] = updateDateTime;
    if (calendarTraining != null) {
      data["calendarTraining"] = calendarTraining!.toJson();
    }
    if (creatorUrl != null) {
      data["creatorUrl"] = creatorUrl!.toJson();
    }
    if (reviewerUrl != null) {
      data["reviewerUrl"] = reviewerUrl!.toJson();
    }
    return data;
  }

  static List<ExpertCommentModel> toList(List<dynamic> items) {
    return items.map((item) => ExpertCommentModel.fromJson(item)).toList();
  }
}

class CalendarTraining {
  CalendarTraining({
    required this.calendarId,
    required this.trainingGroupId,
    required this.comment,
    required this.coachId,
    required this.type,
    required this.calendar,
  });

  final String? calendarId;
  final String? trainingGroupId;
  final String? comment;
  final String? coachId;
  final int? type;
  final CalendarModel? calendar;

//  DateTime? get time => DateUtil.parseStringToDate(updateDateTime, 'dd/MM/yyyy');

  @override
  factory CalendarTraining.fromJson(Map<String, dynamic> json) {
    return CalendarTraining(
      trainingGroupId: json['trainingGroupId'],
      calendarId: json['calendarId'],
      comment: json['comment'],
      coachId: json['coachId'],
      type: json['type'],
      calendar: json['calendar'] == null ? null : CalendarModel.fromJson(json['calendar']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["trainingGroupId"] = trainingGroupId;
    data["calendarId"] = calendarId;
    data["comment"] = comment;
    data["coachId"] = coachId;
    data['type'] = type;
    if (calendar != null) {
      data["calendar"] = calendar!.toJson();
    }
    return data;
  }

  static List<CalendarTraining> toList(List<dynamic> items) {
    return items.map((item) => CalendarTraining.fromJson(item)).toList();
  }
}

class CalendarModel {
  CalendarModel({
    required this.name,
    required this.type,
    required this.appointmentDate,
    required this.duration,
    required this.performerId,
    required this.repeatType,
    required this.goal,
    required this.meetingLink,
    required this.meetingPassword,
    required this.calendarSchedulerId,
    required this.calendarId,
    required this.roomId,
    required this.complete,
    required this.performer,
  });

  final String? name;
  final double? type;
  final double? appointmentDate;
  final double? duration;
  final String? performerId;
  final double? repeatType;
  final String? goal;
  final String? meetingLink;
  final String? meetingPassword;
  final String? calendarSchedulerId;
  final String? calendarId;

  final String? roomId;
  final bool? complete;
  final UserInfoReferralCodeResponseData? performer;

//  DateTime? get time => DateUtil.parseStringToDate(updateDateTime, 'dd/MM/yyyy');

  @override
  factory CalendarModel.fromJson(Map<String, dynamic> json) {
    return CalendarModel(
      name: json['name'],
      type: json['type'],
      appointmentDate: json['appointmentDate'],
      duration: json['duration'],
      performerId: json['performerId'],
      repeatType: json['repeatType'],
      goal: json['goal'],
      meetingLink: json['meetingLink'],
      meetingPassword: json['meetingPassword'],
      calendarSchedulerId: json['calendarSchedulerId'],
      calendarId: json['calendarId'],
      roomId: json['roomId'],
      complete: json['complete'],
      performer: json['performer'] == null ? null : UserInfoReferralCodeResponseData.fromJson(json['performer']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["name"] = name;
    data["type"] = type;
    data["appointmentDate"] = appointmentDate;
    data["duration"] = duration;
    data['performerId'] = performerId;
    data["repeatType"] = repeatType;
    data["goal"] = goal;
    data["meetingLink"] = meetingLink;
    data["meetingPassword"] = meetingPassword;
    data["calendarSchedulerId"] = calendarSchedulerId;
    data["calendarId"] = calendarId;
    data["roomId"] = roomId;
    data["complete"] = complete;
    if (performer != null) {
      data["performer"] = performer!.toJson();
    }
    return data;
  }

  static List<CalendarModel> toList(List<dynamic> items) {
    return items.map((item) => CalendarModel.fromJson(item)).toList();
  }
}
