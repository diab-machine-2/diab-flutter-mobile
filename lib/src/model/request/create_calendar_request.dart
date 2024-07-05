import 'package:medical/src/widget/calendar/calendar_model.dart';

class CreateCalendarRequest {
  String name;
  int appointmentDate;
  int duration;
  String repeatType;
  int modelStatus;
  String meetingLink;
  String performerId;
  int zoomTypeId;
  String type;
  List<CalendarAccount> calendarAccounts;
  String goal;
  List<String> trainingGroupIds;
  List<CalendarCoachModel> calendarCoachs;
  String courseId;

  CreateCalendarRequest({
    required this.name,
    required this.appointmentDate,
    required this.duration,
    required this.repeatType,
    required this.modelStatus,
    required this.meetingLink,
    required this.performerId,
    required this.zoomTypeId,
    required this.type,
    required this.calendarAccounts,
    required this.goal,
    required this.trainingGroupIds,
    required this.calendarCoachs,
    required this.courseId,
  });

  factory CreateCalendarRequest.fromJson(Map<String, dynamic> json) {
    // Parse calendarAccounts
    List<CalendarAccount> accounts = [];
    if (json['calendarAccounts'] != null) {
      json['calendarAccounts'].forEach((accountJson) {
        accounts.add(CalendarAccount.fromJson(accountJson));
      });
    }

    // Parse calendarCoachs
    List<CalendarCoachModel> coaches = [];
    if (json['calendarCoachs'] != null) {
      json['calendarCoachs'].forEach((coachJson) {
        coaches.add(CalendarCoachModel.fromJson(coachJson));
      });
    }

    // Parse trainingGroupIds (assuming it's a list of strings)
    List<String> trainingGroups = [];
    if (json['trainingGroupIds'] != null) {
      json['trainingGroupIds'].forEach((groupId) {
        trainingGroups.add(groupId as String);
      });
    }

    return CreateCalendarRequest(
      name: json['name'] ?? '',
      appointmentDate: json['appointmentDate'] ?? 0,
      duration: json['duration'] ?? 0,
      repeatType: json['repeatType'] ?? '',
      modelStatus: json['modelStatus'] ?? 0,
      meetingLink: json['meetingLink'] ?? '',
      performerId: json['performerId'] ?? '',
      zoomTypeId: json['zoomTypeId'] ?? 0,
      type: json['type'] ?? '',
      calendarAccounts: accounts,
      goal: json['goal'] ?? '',
      trainingGroupIds: trainingGroups,
      calendarCoachs: coaches,
      courseId: json['courseId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'appointmentDate': appointmentDate,
      'duration': duration,
      'repeatType': repeatType,
      'modelStatus': modelStatus,
      'meetingLink': meetingLink,
      'performerId': performerId,
      'zoomTypeId': zoomTypeId,
      'type': type,
      'calendarAccounts':
          calendarAccounts.map((account) => account.toJson()).toList(),
      'goal': goal,
      'trainingGroupIds': trainingGroupIds,
      'calendarCoachs': calendarCoachs.map((coach) => coach.toJson()).toList(),
      'courseId': courseId,
    };
  }
}

class CalendarAccount {
  String accountId;
  int modelStatus;

  CalendarAccount({
    required this.accountId,
    required this.modelStatus,
  });

  factory CalendarAccount.fromJson(Map<String, dynamic> json) {
    return CalendarAccount(
      accountId: json['accountId'] ?? '',
      modelStatus: json['modelStatus'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'modelStatus': modelStatus,
    };
  }
}
