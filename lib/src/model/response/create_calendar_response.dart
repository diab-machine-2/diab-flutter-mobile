import 'package:medical/src/utils/const.dart';

class CreateCalendarResponse {
  final String? creatorId;
  final String id;
  final String? code;
  final String name;
  final String coachAvatar;
  final int type;
  final int appointmentDate;
  final int? duration;
  final String performerId;
  final String? updaterName;
  final int repeatType;
  final String? goal;
  final String? meetingLink;
  final String? linkJoin;
  final String? meetingPassword;
  final String? calendarSchedulerId;
  final bool complete;
  final String? calendarId;
  final String? roomId;
  final String? hostZoomId;
  final int zoomTypeId;
  final String? dynamicLink;
  final dynamic performer;
  final dynamic calendarScheduler;
  final dynamic calendarAccounts;
  final dynamic calendarTraining;
  final dynamic calendarTypes;
  final dynamic calendarActive;
  final dynamic calendarRepeatTypes;
  final dynamic trainingGroups;
  final dynamic patients;
  final dynamic coaches;
  final dynamic hostZooms;
  final bool? isDeleted;

  CreateCalendarResponse({
    required this.coachAvatar,
    this.creatorId,
    required this.id,
    this.code,
    required this.name,
    required this.type,
    required this.appointmentDate,
    this.duration,
    required this.performerId,
    this.updaterName,
    required this.repeatType,
    this.goal,
    this.meetingLink,
    this.linkJoin,
    this.meetingPassword,
    this.calendarSchedulerId,
    required this.complete,
    this.calendarId,
    this.roomId,
    this.hostZoomId,
    required this.zoomTypeId,
    this.dynamicLink,
    this.performer,
    this.calendarScheduler,
    this.calendarAccounts,
    this.calendarTraining,
    this.calendarTypes,
    this.calendarActive,
    this.calendarRepeatTypes,
    this.trainingGroups,
    this.patients,
    this.coaches,
    this.hostZooms,
    this.isDeleted,
  });

  factory CreateCalendarResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return CreateCalendarResponse(
      creatorId: json['creatorId'],
      id: json['id'] ?? '00000000-0000-0000-0000-000000000000',
      code: json['code'],
      name: json['name'] ?? 'NO_HOST_ZOOM',
      type: json['type'] ?? 0,
      appointmentDate: json['appointmentDate'] ?? -62135596800,
      duration: json['duration'],
      performerId:
          json['performerId'] ?? '00000000-0000-0000-0000-000000000000',
      updaterName: json['updaterName'],
      repeatType: json['repeatType'] ?? 0,
      goal: json['goal'],
      meetingLink: json['meetingLink'],
      linkJoin: json['linkJoin'],
      meetingPassword: json['meetingPassword'],
      calendarSchedulerId: json['calendarSchedulerId'],
      complete: json['complete'] ?? false,
      calendarId: json['calendarId'],
      roomId: json['roomId'],
      hostZoomId: json['hostZoomId'],
      zoomTypeId: json['zoomTypeId'] ?? 0,
      dynamicLink: json['dynamicLink'],
      performer: json['performer'],
      calendarScheduler: json['calendarScheduler'],
      calendarAccounts: json['calendarAccounts'],
      calendarTraining: json['calendarTraining'],
      calendarTypes: json['calendarTypes'],
      calendarActive: json['calendarActive'],
      calendarRepeatTypes: json['calendarRepeatTypes'],
      trainingGroups: json['trainingGroups'],
      patients: json['patients'],
      coaches: json['coaches'],
      hostZooms: json['hostZooms'],
      isDeleted: json['isDeleted'] || false,
      coachAvatar: json['coachAvatar']["url"] ?? Const.DEFAULT_BG_COACH,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creatorId': creatorId,
      'id': id,
      'code': code,
      'name': name,
      'type': type,
      'appointmentDate': appointmentDate,
      'duration': duration,
      'performerId': performerId,
      'updaterName': updaterName,
      'repeatType': repeatType,
      'goal': goal,
      'meetingLink': meetingLink,
      'linkJoin': linkJoin,
      'meetingPassword': meetingPassword,
      'calendarSchedulerId': calendarSchedulerId,
      'complete': complete,
      'calendarId': calendarId,
      'roomId': roomId,
      'hostZoomId': hostZoomId,
      'zoomTypeId': zoomTypeId,
      'dynamicLink': dynamicLink,
      'performer': performer,
      'calendarScheduler': calendarScheduler,
      'calendarAccounts': calendarAccounts,
      'calendarTraining': calendarTraining,
      'calendarTypes': calendarTypes,
      'calendarActive': calendarActive,
      'calendarRepeatTypes': calendarRepeatTypes,
      'trainingGroups': trainingGroups,
      'patients': patients,
      'coaches': coaches,
      'hostZooms': hostZooms,
      'isDeleted': isDeleted
    };
  }
}
