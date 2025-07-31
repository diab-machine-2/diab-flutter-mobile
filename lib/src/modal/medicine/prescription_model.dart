import 'medication_model.dart';
import 'reminder_model.dart';

class PrescriptionModel {
  final String id;
  final String name;
  final DateTime startDate;
  final String? note;
  final List<MedicationModel> medications;
  final List<ReminderModel> reminders;
  final int replenishReminderDays;
  final bool enableNotification;

  PrescriptionModel({
    required this.id,
    required this.name,
    required this.startDate,
    this.note,
    required this.medications,
    required this.reminders,
    required this.replenishReminderDays,
    required this.enableNotification,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'],
      name: json['name'],
      startDate: DateTime.parse(json['startDate']),
      note: json['note'],
      medications: (json['medications'] as List)
          .map((e) => MedicationModel.fromJson(e))
          .toList(),
      reminders: (json['reminders'] as List)
          .map((e) => ReminderModel.fromJson(e))
          .toList(),
      replenishReminderDays: json['replenishReminderDays'],
      enableNotification: json['enableNotification'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'startDate': startDate.toIso8601String(),
    'note': note,
    'medications': medications.map((e) => e.toJson()).toList(),
    'reminders': reminders.map((e) => e.toJson()).toList(),
    'replenishReminderDays': replenishReminderDays,
    'enableNotification': enableNotification,
  };
}