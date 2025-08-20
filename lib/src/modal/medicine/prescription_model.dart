import 'medicine_item_model.dart';
import 'reminder_model.dart';

class PrescriptionModel {
  final String? id;
  String? name;
  final DateTime? startDate;
  final String? note;
  final List<MedicineItemModel>? medications;
  final List<ReminderModel>? reminders;
  final int? replenishReminderDays;
  final bool? enableNotification;
  String? description;
  List<String>? photos;

  PrescriptionModel({
    this.id,
    this.name,
    this.startDate,
    this.note,
    this.medications,
    this.reminders,
    this.replenishReminderDays,
    this.enableNotification,
    this.description,
    this.photos,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'],
      name: json['name'],
      startDate: DateTime.parse(json['startDate']),
      note: json['note'],
      medications: (json['medications'] as List)
          .map((e) => MedicineItemModel.fromJson(e))
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
    'startDate': startDate?.toIso8601String(),
    'note': note,
    'medications': medications?.map((e) => e.toJson()).toList(),
    'reminders': reminders?.map((e) => e.toJson()).toList(),
    'replenishReminderDays': replenishReminderDays,
    'enableNotification': enableNotification,
  };
}

extension PrescriptionValidator on PrescriptionModel {
  bool get isValid {
    //if (name == null || name?.isEmpty == true) return false;
    if (medications == null) return false;
    if (medications?.isEmpty == true) return false;
    for (final med in medications!) {
      if (!med.isValid) return false;
    }
    return true;
  }
}
