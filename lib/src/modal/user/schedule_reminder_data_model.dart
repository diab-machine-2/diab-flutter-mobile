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

  /// BE-3: inactive reminders must not show on Home. Null until the backend
  /// sends it, so treat null as active.
  final bool? isActive;

  ScheduleReminderDataModelNew({
    required this.id,
    required this.patientId,
    required this.name,
    this.content,
    this.timeFrameName,
    required this.time,
    this.isActive,
  });

  factory ScheduleReminderDataModelNew.fromJson(Map<String, dynamic> json) {
    return ScheduleReminderDataModelNew(
      id: json['id'],
      patientId: json['patientId'],
      name: json['name'],
      content: json['content'],
      timeFrameName: json['timeFrameName'],
      time: json['time'],
      isActive: _parseBool(json['isActive']),
    );
  }

  // Lenient: a type mismatch here would drop every reminder on Home.
  static bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return null;
  }
}
