import 'package:meta/meta.dart';

class ScheduleReminderModel {
  final String id;
  final String patientId;
  final int remindType;
  final int time;
  final String name;
  final String content;
  final bool isActive;

  ScheduleReminderModel(
      {@required this.id,
      @required this.patientId,
      @required this.remindType,
      @required this.time,
      @required this.name,
      @required this.content,
      @required this.isActive});

  factory ScheduleReminderModel.fromJson(Map<String, dynamic> json) {
    return ScheduleReminderModel(
        id: json['id'],
        patientId: json['patientId'],
        remindType: json['remindType'],
        time: json['time'],
        name: json['name'],
        content: json['content'],
        isActive: json['isActive']);
  }

  static List<ScheduleReminderModel> toList(List<dynamic> items) {
    return items.map((item) => ScheduleReminderModel.fromJson(item)).toList();
  }
}
