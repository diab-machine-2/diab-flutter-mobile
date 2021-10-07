import 'package:medical/src/modal/user/schedule_reminder_model.dart';
import 'package:meta/meta.dart';

class ScheduleReminderDataModel {
  final List<ScheduleReminderModel> models;
  final bool hasMore;

  ScheduleReminderDataModel({required this.models, required this.hasMore});
}
