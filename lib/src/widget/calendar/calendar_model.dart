import 'package:easy_localization/easy_localization.dart';

class CalendarCoachModel {
  final String id;
  final String coachId;
  final String courseId;
  final int startTime;
  final int endTime;
  final int status; // 1 for booked, 0 for not booked
  int? createDatetime;
  int? updateDatetime;
  bool? isDeleted;

  CalendarCoachModel(
      {required this.id,
      required this.coachId,
      required this.startTime,
      required this.endTime,
      required this.status,
      required this.courseId,
      this.createDatetime,
      this.updateDatetime,
      this.isDeleted});

  factory CalendarCoachModel.fromJson(Map<String, dynamic> json) {
    return CalendarCoachModel(
      id: json['id'],
      coachId: json['coachId'],
      courseId: json['courseId'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      status: json['status'],
      isDeleted: json['isDeleted'] ?? false,
      createDatetime: json['createDatetime'] ?? 0,
      updateDatetime: json['updateDatetime'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coachId': coachId,
      'courseId': courseId,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'isDeleted': isDeleted ?? false,
      'createDatetime': createDatetime,
      'updateDatetime': updateDatetime,
    };
  }

  // Method to format the start time to a specific string format
}
