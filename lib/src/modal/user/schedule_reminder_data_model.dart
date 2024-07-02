import 'package:medical/src/modal/user/schedule_reminder_model.dart';
import 'package:meta/meta.dart';

@immutable
class ScheduleReminderDataModel {
  final List<ScheduleReminderModel> models;
  final bool hasMore;

  ScheduleReminderDataModel({required this.models, required this.hasMore});
}

class ScheduleReminderDataModelNew {
  final String id;
  final String patientId;
  final String name;
  final String? content;
  final String? timeFrameName;
  final int time;

  ScheduleReminderDataModelNew({
    required this.id,
    required this.patientId,
    required this.name,
    this.content,
    this.timeFrameName,
    required this.time,
  });

  factory ScheduleReminderDataModelNew.fromJson(Map<String, dynamic> json) {
    return ScheduleReminderDataModelNew(
      id: json['id'],
      patientId: json['patientId'],
      name: json['name'],
      content: json['content'],
      timeFrameName: json['timeFrameName'],
      time: json['time'],
    );
  }
}
